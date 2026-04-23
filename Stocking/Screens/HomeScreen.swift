//
//  HomeScreen.swift
//  Stocking
//
//  Created by Heryan Djaruma on 20/04/26.
//

import SwiftUI
import SwiftData

struct HomeScreen: View {
    
    @Environment(\.modelContext) private var modelContext
    
    /// Get current date from local SwiftDate
    @Query(filter: #Predicate<GlobalConfig> { config in
        config.key == "currentDate"
    })
    private var configs: [GlobalConfig]
    var currentDateConfig: GlobalConfig? { configs.first }
    
    /// Get all stocks
    @Query var stocks: [Stock]
    
    /// Get user Stocking data
    @Query private var userData: [UserStockingData]
    private var user: UserStockingData? { userData.first }
    
    /// Useful to show validation in the child view
    @State private var transactionError: TransactionError? = nil
    
    var body: some View {
        HomeView(
            currentDate: currentDateConfig?.dateValue ?? Date.now,
            stocks: stocks,
            onForwardDay: {
                guard let config = currentDateConfig else { return }
                config.dateValue = Calendar.current.date(byAdding: .day, value: 1, to: config.dateValue!)!
                try? modelContext.save()
            }, onBuyOrSell: { order in
                onBuyOrSellStock(order: order)
            }, transactionError: $transactionError)
    }
    
    /// Check if balance is sufficient for executing the order
    private func isBalanceSufficient(for order: Order) -> Bool {
        return (user?.tradeableBalance ?? 0) >= order.price * Double(order.quantity)
    }
    
    private func onBuyOrSellStock(order: Order) {
        if order.orderType == "Market" {
            if order.side == "Buy" {
                executeMarketSell(order: order)
            } else { executeMarketBuy(order: order)}
        } else {
            if order.side == "Limit" {
                executeLimitBuy(order: order)
            } else {executeLimitSell(order: order)}
        }
    }
    
    private func executeMarketBuy(order: Order) {
        
    }
    
    private func executeMarketSell(order: Order) {
        
    }
    
    private func executeLimitBuy(order: Order) {
        
    }
    
    private func executeLimitSell(order: Order) {
        
    }
    
}
