//
//  WalletScreen.swift
//  Stocking
//
//  Created by Heryan Djaruma on 17/04/26.
//

import SwiftUI
import SwiftData

struct WalletScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userData: [UserStockingData]
    @Query(sort: \EquityHistory.timestamp, order: .forward) private var equityHistory: [EquityHistory]
    
    var user: UserStockingData? { userData.first }
    
    var body: some View {
        Group {
            if let user {
                WalletView(userData: user, equityHistory: equityHistory)
            } else { Color.clear } /// Needed so SwiftUI can re-render properly when condition becomes true
        }
        .onAppear {
            guard userData.isEmpty else { return }
            
            let defaultUser = UserStockingData(totalEquity: 100.0, tradeableBalance: 69.00, investedBalance: 30.0)
            
            modelContext.insert(defaultUser)
            try? modelContext.save()
        }
    }
}
