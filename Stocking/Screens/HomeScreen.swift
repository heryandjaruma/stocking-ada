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
            onBuyOrSell: { order in
                do {
                    try onBuyOrSellStock(order: order)
                    transactionAlert = TransactionAlert(message: "Order placed successfully", type: .success)
                } catch let error as TransactionError {
                    transactionAlert = TransactionAlert(message: error.localizedDescription, type: .error)
                } catch {
                    transactionAlert = TransactionAlert(message: error.localizedDescription, type: .error)
                }
            },
            transactionAlert: $transactionAlert
        )
        .alert(item: $transactionAlert) { alert in
            Alert(title: Text(alert.type == .success ? "Success" : "Error"),
                  message: Text(alert.message))
        }
    }
    
    /// Check if balance is sufficient for executing the order
    private func isBalanceSufficient(for order: Order) -> Bool {
        print("Tradable: \(String(describing: user?.tradeableBalance)), price: \((order.price * Double(order.quantity)))")
        return (user?.tradeableBalance ?? 0) >= (order.price * Double(order.quantity))
    }
    
    private func isSellPriceDiffMatch(for order: Order, stock: Stock) -> Bool{
        //        return (stock)
        return true
    }
    
    private func onBuyOrSellStock(order: Order) throws {
        if order.orderType == "Market" {
            if order.side == "Buy" {
                try executeMarketBuy(order: order)
            } else {
                try executeMarketSell(order: order)
            }
        } else {
            if order.side == "Limit" {
                try executeLimitBuy(order: order)
            } else {
                try executeLimitSell(order: order)
            }
        }
    }
    
    private func executeMarketBuy(order: Order) throws {
        print(order)
        guard isBalanceSufficient(for: order) else {
            throw TransactionError.insufficientFunds
        }
        
        /// Get current stock object
        let stock = try findStockByStockSymbol(order.stockSymbol)!
        
        /// Check current existing ownedStock
        let ownedStock: OwnedStock
        if let existingOwnedStock = try findOwnedStockWithIsFinalizedByStockSymbol(false, order.stockSymbol) {
            ownedStock = existingOwnedStock
        } else { /// Else create a new one to be inserted
            ownedStock = OwnedStock(timestamp: Date.now, stock: stock, stockSymbol: order.stockSymbol)
            modelContext.insert(ownedStock)
        }
        
        /// Randomize fill price to +/- 5%
        order.price = order.price * Double.random(in: 0.99...1.01)
        
        /// Set status to filled
        order.status = "Filled"
        
        /// Attach new order attached to the ownedStock
        ownedStock.orders.append(order)
        
        let orderValue = order.price * Double(order.quantity)
        /// Change user's invested balance
        user?.investedBalance += orderValue
        
        /// Change user's tradeable balance
        user?.tradeableBalance -= orderValue
        
        try modelContext.save()
    }
    
    /// Execute market sell
    /// Uses Average Cost Basis (ACB) to blend all purchase price into a weighted average.
    private func executeMarketSell(order: Order) throws {
        print(order)
        
        /// Check current existing ownedStock
        let ownedStock: OwnedStock
        if let existingOwnedStock = try findOwnedStockWithIsFinalizedByStockSymbol(false, order.stockSymbol) {
            ownedStock = existingOwnedStock
        } else {
            throw TransactionError.stockNotOwned
        }
        
        /// Calculate total stock owned from timeranged order array
        //        let orders = try findOrdersFromStartDateByStockSymbol(ownedStock.timestamp, order.stockSymbol)
        //        let totalStockOwned = orders.reduce(0) { $0 + $1.quantity }
        let orders = ownedStock.orders
        let buyOrders = orders.filter { $0.side == "Buy" }
        let sellOrders = orders.filter { $0.side == "Sell" }
        let totalStockOwned = buyOrders.reduce(0) { $0 + $1.quantity }
                            - sellOrders.reduce(0) { $0 + $1.quantity }
        
        /// Guard against selling more than owned
        guard order.quantity <= totalStockOwned else {
            throw TransactionError.insufficientStocks
        }
        
        /// Randomize fill price
        order.price = order.price * Double.random(in: 0.99...1.01)
        order.status = "Filled"
        
        /// PnL logics
        let totalBuyValue = buyOrders.reduce(0.0) { $0 + ($1.price * Double($1.quantity)) } /// Calculate average price considering weight of each buy
        let totalBuyQuantity = buyOrders.reduce(0) { $0 + $1.quantity }
        let avgBuyPrice = totalBuyValue / Double(totalBuyQuantity)
        let originalCost = avgBuyPrice * Double(order.quantity) /// Originally paid by users to buy shares
        let soldValue = order.price * Double(order.quantity) /// Current market value for shares to be sold
        let realizedPnL = soldValue - originalCost
        
        /// Calculate actual order transaction
        let deltaTransactionQuantity = totalStockOwned - order.quantity
        
        /// When delta is 0, mark the ownedStock as finalized
        if deltaTransactionQuantity == 0 {
            ownedStock.isFinalized = true
        }
        ownedStock.orders.append(order)
        
        /// Update users info
        user?.totalEquity += realizedPnL /// Add realized to user's balance
        user?.tradeableBalance += soldValue /// Market value become tradable balance
        user?.investedBalance -= originalCost /// Remove original cost from invested
        
        try modelContext.save()
    }
    
    private func executeLimitBuy(order: Order) throws {
        guard isBalanceSufficient(for: order) else {
            throw TransactionError.insufficientFunds
        }
    }
    
    private func executeLimitSell(order: Order) throws {
        
    }
    
    /// Utils
    private func findStockByStockSymbol(_ stockSymbol: String) throws -> Stock? {
        let predicate = #Predicate<Stock> { item in
            item.symbol.contains(stockSymbol)
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }
    
    private func findOwnedStockWithIsFinalizedByStockSymbol(_ isFinalized: Bool, _ stockSymbol: String) throws -> OwnedStock? {
        let predicate = #Predicate<OwnedStock> { item in
            item.stockSymbol.contains(stockSymbol) && item.isFinalized == isFinalized
        }
        var descriptor = FetchDescriptor<OwnedStock>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
    
    private func findOrdersFromStartDateByStockSymbol(_ startDate: Date, _ stockSymbol: String) throws -> [Order] {
        let predicate = #Predicate<Order> { item in
            item.stockSymbol.contains(stockSymbol)
        }
        let descriptor = FetchDescriptor<Order>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
}
