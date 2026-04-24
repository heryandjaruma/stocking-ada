//
//  HomeScreen.swift
//  Stocking
//
//  Created by Heryan Djaruma on 20/04/26.
//

import SwiftData
import SwiftUI

struct HomeScreen: View {

    @Environment(\.modelContext) private var modelContext

    /// Get current date from local SwiftDate
    @Query(
        filter: #Predicate<GlobalConfig> { config in
            config.key == "currentDate"
        }
    )
    private var configs: [GlobalConfig]
    var currentDateConfig: GlobalConfig? { configs.first }

    /// Get all stocks
    @Query(sort: \Stock.symbol, order: .forward) var stocks: [Stock]

    /// Get user Stocking data
    @Query private var userData: [UserStockingData]
    private var user: UserStockingData? { userData.first }

    /// Useful to show validation in the child view
    @State private var transactionAlert: TransactionAlert? = nil

    @Query private var orders: [Order]

    var body: some View {
        HomeView(
            currentDate: currentDateConfig?.dateValue ?? Date.now,
            stocks: stocks,
            orders: orders,
            onForwardDay: {
                guard let config = currentDateConfig else { return }
                config.dateValue = Calendar.current.date(
                    byAdding: .day,
                    value: 1,
                    to: config.dateValue!
                )!
                try? modelContext.save()
            },
            onProcessPendingLimitOrders: {
                try? processPendingLimitOrders()
            },
            onBuyOrSell: { order in
                do {
                    try onBuyOrSellStock(order: order)
                    transactionAlert = TransactionAlert(
                        message: "Order placed successfully",
                        type: .success
                    )
                } catch let error as TransactionError {
                    transactionAlert = TransactionAlert(
                        message: error.localizedDescription,
                        type: .error
                    )
                } catch {
                    transactionAlert = TransactionAlert(
                        message: error.localizedDescription,
                        type: .error
                    )
                }
            },
            transactionAlert: $transactionAlert
        )
        .alert(item: $transactionAlert) { alert in
            Alert(
                title: Text(alert.type == .success ? "Success" : "Error"),
                message: Text(alert.message)
            )
        }
    }

    /// Check if balance is sufficient for executing the order
    private func isBalanceSufficient(for order: Order) -> Bool {
        print(
            "Tradable: \(String(describing: user?.tradeableBalance)), price: \((order.price * Double(order.quantity)))"
        )
        return (user?.tradeableBalance ?? 0)
            >= (order.price * Double(order.quantity))
    }

    private func onBuyOrSellStock(order: Order) throws {
        switch (order.orderType, order.side) {
        case ("Market", "Buy"): try executeMarketBuy(order: order)
        case ("Market", "Sell"): try executeMarketSell(order: order)
        case ("Limit", "Buy"): try executeLimitBuy(order: order)
        case ("Limit", "Sell"): try executeLimitSell(order: order)
        default: break
        }
    }

    private func executeMarketBuy(order: Order) throws {
        guard isBalanceSufficient(for: order) else {
            throw TransactionError.insufficientFunds
        }

        let stock = try findStock(symbol: order.stockSymbol)
        let ownedStock = try findOrCreateOwnedStock(
            for: stock,
            symbol: order.stockSymbol
        )

        order.price = slippage(order.price)
        order.status = "Filled"
        ownedStock.orders.append(order)

        let orderValue = order.price * Double(order.quantity)
        user?.investedBalance += orderValue
        user?.tradeableBalance -= orderValue

        try modelContext.save()
    }

    /// Execute market sell
    /// Uses Average Cost Basis (ACB) to blend all purchase price into a weighted average.
    private func executeMarketSell(order: Order) throws {
        let ownedStock = try findActiveOwnedStock(symbol: order.stockSymbol)

        guard order.quantity <= ownedStock.getTotalOwnedShare() else {
            throw TransactionError.insufficientStocks
        }

        order.price = slippage(order.price)
        order.status = "Filled"

        let realizedPnL = calculateRealizedPnL(for: order, in: ownedStock)
        let originalCost =
            averageBuyPrice(in: ownedStock) * Double(order.quantity)
        let soldValue = order.price * Double(order.quantity)

        if ownedStock.getTotalOwnedShare() - order.quantity == 0 {
            ownedStock.isFinalized = true
        }
        ownedStock.orders.append(order)

        user?.totalEquity += realizedPnL
        user?.tradeableBalance += soldValue
        user?.investedBalance -= originalCost

        try modelContext.save()
    }

    // MARK: - Limit Order


    /// Returns true if the order is still valid (not expired)
    private func isLimitOrderActive(for order: Order) -> Bool {
        let currentDate = currentDateConfig?.dateValue ?? Date()
        guard order.expiry == "GTD" || order.expiry == "GFD" else {
            return true /// GTC never expires
        }
        let calendar = Calendar.current
        let orderDay = calendar.startOfDay(for: order.timestamp)
        let currentDay = calendar.startOfDay(for: currentDate)
        let isActive = orderDay >= currentDay

        if !isActive {
            order.status = "Expired"
        }

        return isActive
    }

    /// Returns true if limit buy should fill: limit price >= current market price
    private func shouldFillLimitBuy(for order: Order, in stock: Stock) -> Bool {
        guard let marketPrice = stock.getPriceByDate((currentDateConfig?.dateValue)!)?.price else {
            return false
        }
        return order.price >= marketPrice
    }

    /// Returns true if limit sell should fill: limit price <= current market price
    private func shouldFillLimitSell(for order: Order, in stock: Stock) -> Bool {
        guard let marketPrice = stock.getPriceByDate((currentDateConfig?.dateValue)!)?.price else {
            return false
        }
        return order.price <= marketPrice
    }

    // MARK: - Limit Order Approval

    private func approveLimitOrderBuy(order: Order, ownedStock: OwnedStock) throws {
        order.status = "Filled"
        ownedStock.orders.append(order)

        let orderValue = order.price * Double(order.quantity)
        user?.investedBalance  += orderValue
        user?.tradeableBalance -= orderValue

        try modelContext.save()
    }

    private func approveLimitOrderSell(order: Order, ownedStock: OwnedStock) throws {
        order.status = "Filled"

        let realizedPnL  = calculateRealizedPnL(for: order, in: ownedStock)
        let originalCost = averageBuyPrice(in: ownedStock) * Double(order.quantity)
        let soldValue    = order.price * Double(order.quantity)

        if ownedStock.getTotalOwnedShare() - order.quantity == 0 {
            ownedStock.isFinalized = true
        }
        ownedStock.orders.append(order)

        user?.totalEquity      += realizedPnL
        user?.tradeableBalance += soldValue
        user?.investedBalance  -= originalCost

        try modelContext.save()
    }

    // MARK: - Execute Limit Orders (place as "Created", fill on next day check)

    private func executeLimitBuy(order: Order) throws {
        guard isBalanceSufficient(for: order) else {
            throw TransactionError.insufficientFunds
        }

        let stock      = try findStock(symbol: order.stockSymbol)
        let ownedStock = try findOrCreateOwnedStock(for: stock, symbol: order.stockSymbol)

        order.status = "Created"
        ownedStock.orders.append(order)

        try modelContext.save()
    }

    private func executeLimitSell(order: Order) throws {
        let ownedStock = try findActiveOwnedStock(symbol: order.stockSymbol)

        guard order.quantity <= ownedStock.getTotalOwnedShare() else {
            throw TransactionError.insufficientStocks
        }

        order.status = "Created"
        ownedStock.orders.append(order)

        try modelContext.save()
    }

    // MARK: - Day Forward: process all pending limit orders

    func processPendingLimitOrders() throws {
        print(currentDateConfig?.dateValue ?? "no date")
        print(orders)
        let pending = try fetchPendingLimitOrders()

        for order in pending {
            let stock = try findStock(symbol: order.stockSymbol)

            guard isLimitOrderActive(for: order) else {
                order.status = "Canceled"
                try modelContext.save()
                continue
            }

            if order.side == "Buy", shouldFillLimitBuy(for: order, in: stock) {
                let ownedStock = try findOrCreateOwnedStock(for: stock, symbol: order.stockSymbol)
                try approveLimitOrderBuy(order: order, ownedStock: ownedStock)

            } else if order.side == "Sell", shouldFillLimitSell(for: order, in: stock) {
                let ownedStock = try findActiveOwnedStock(symbol: order.stockSymbol)
                try approveLimitOrderSell(order: order, ownedStock: ownedStock)
            }
        }
    }

    private func fetchPendingLimitOrders() throws -> [Order] {
        let predicate  = #Predicate<Order> { $0.orderType == "Limit" && $0.status == "Created" }
        let descriptor = FetchDescriptor<Order>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }

    private func findOrdersFromStartDateByStockSymbol(
        _ startDate: Date,
        _ stockSymbol: String
    ) throws -> [Order] {
        let predicate = #Predicate<Order> { item in
            item.stockSymbol.contains(stockSymbol)
        }
        let descriptor = FetchDescriptor<Order>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    // MARK: - Helpers

    private func slippage(_ price: Double) -> Double {
        price * Double.random(in: 0.99...1.01)
    }

    /// Weighted average buy price across all filled buy orders
    private func averageBuyPrice(in ownedStock: OwnedStock) -> Double {
        let filled = ownedStock.orders.filter {
            $0.side == "Buy" && $0.status == "Filled"
        }
        let totalValue = filled.reduce(0.0) {
            $0 + $1.price * Double($1.quantity)
        }
        let totalQuantity = filled.reduce(0) { $0 + $1.quantity }
        guard totalQuantity > 0 else { return 0 }
        return totalValue / Double(totalQuantity)
    }

    /// Realized PnL = (sell price - avg buy price) × quantity
    private func calculateRealizedPnL(
        for order: Order,
        in ownedStock: OwnedStock
    ) -> Double {
        let avgBuy = averageBuyPrice(in: ownedStock)
        let originalCost = avgBuy * Double(order.quantity)
        let soldValue = order.price * Double(order.quantity)
        return soldValue - originalCost
    }

    private func findStock(symbol: String) throws -> Stock {
        guard let stock = try findStockByStockSymbol(symbol) else {
            throw TransactionError.stockNotOwned
        }
        return stock
    }

    private func findOrCreateOwnedStock(for stock: Stock, symbol: String) throws
        -> OwnedStock
    {
        if let existing = try findOwnedStockWithIsFinalizedByStockSymbol(
            false,
            symbol
        ) {
            return existing
        }
        let new = OwnedStock(timestamp: .now, stock: stock, stockSymbol: symbol)
        modelContext.insert(new)
        return new
    }

    private func findActiveOwnedStock(symbol: String) throws -> OwnedStock {
        guard
            let owned = try findOwnedStockWithIsFinalizedByStockSymbol(
                false,
                symbol
            )
        else {
            throw TransactionError.stockNotOwned
        }
        return owned
    }

    // MARK: - Queries

    private func findStockByStockSymbol(_ stockSymbol: String) throws -> Stock?
    {
        let predicate = #Predicate<Stock> { $0.symbol.contains(stockSymbol) }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }

    private func findOwnedStockWithIsFinalizedByStockSymbol(
        _ isFinalized: Bool,
        _ stockSymbol: String
    ) throws -> OwnedStock? {
        let predicate = #Predicate<OwnedStock> {
            $0.stockSymbol.contains(stockSymbol)
                && $0.isFinalized == isFinalized
        }
        var descriptor = FetchDescriptor<OwnedStock>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

}
