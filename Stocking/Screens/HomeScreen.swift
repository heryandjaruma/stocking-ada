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
    @Query var stocks: [Stock]
    
    /// Get user Stocking data
    @Query private var userData: [UserStockingData]
    private var user: UserStockingData? { userData.first }
    
    /// Useful to show validation in the child view
    @State private var transactionAlert: TransactionAlert? = nil
    
    var body: some View {
        HomeView(
            currentDate: currentDateConfig?.dateValue ?? Date.now,
            stocks: stocks,
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
                } catch let error as TransactionError {
                    transactionAlert = TransactionAlert(message: error.localizedDescription)
                } catch {
                    transactionAlert = TransactionAlert(message: error.localizedDescription)
                }
            },
            transactionAlert: $transactionAlert
        )
    }
    
    /// Check if balance is sufficient for executing the order
    private func isBalanceSufficient(for order: Order) -> Bool {
        return (user?.tradeableBalance ?? 0) >= order.price
        * Double(order.quantity)
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
        guard isBalanceSufficient(for: order) else {
            throw TransactionError.insufficientFunds
        }
    }
    
    private func executeMarketSell(order: Order) throws {
        //       guard isPrice
    }
    
    private func executeLimitBuy(order: Order) throws {
        guard isBalanceSufficient(for: order) else {
            throw TransactionError.insufficientFunds
        }
    }
    
    private func executeLimitSell(order: Order) throws {
        
    }
    
}
