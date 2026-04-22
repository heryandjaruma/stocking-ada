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
    
    var body: some View {
        HomeView(currentDate: currentDateConfig?.dateValue ?? Date.now, stocks: stocks,
                 onForwardDay: {
            guard let config = currentDateConfig else { return }
            config.dateValue = Calendar.current.date(byAdding: .day, value: 1, to: config.dateValue!)!
            try? modelContext.save()
        }) { order, ownedStock in
            onBuyOrSellStock(order: order, ownedStock: ownedStock)
        }
    }
    
    private func onBuyOrSellStock(order: Order, ownedStock: OwnedStock) {
        /// Business logic
        
        /// MARKET
        /// For Buying:
        /// 1. Check for available balance
        /// 2. If the stock is not in OwnedStock, add record
        
        let availableBalance = user?.tradeableBalance
        
        /// If balance not enough
        if availableBalance < order.price * order.quantity {
            
        }
        
        
        /// For Selling:
        /// 1. Check when is the first lot bought since the OwnedStock
        /// 2. Check for PnL from initial buy date
    }
}
