//
//  WalletScreen.swift
//  Stocking
//
//  Created by Heryan Djaruma on 17/04/26.
//

import SwiftData
import SwiftUI

struct WalletScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userData: [UserStockingData]
    @Query(sort: \EquityHistory.timestamp, order: .forward) private
        var equityHistory: [EquityHistory]

    var user: UserStockingData? { userData.first }

    @Query(
        filter: #Predicate<GlobalConfig> { config in
            config.key == "currentDate"
        }
    )
    private var configs: [GlobalConfig]

    var currentDateConfig: GlobalConfig? { configs.first }

    var body: some View {
        Group {
            if let user {
                WalletView(
                    userData: user,
                    equityHistory: equityHistory,
                    currentDate: currentDateConfig?.dateValue ?? Date.now,
                    onSaveBalance: { balance in
                        user.totalEquity = balance
                        modelContext.insert(user)
                    }
                )
            } else {
                Color.clear
            }
            /// Needed so SwiftUI can re-render properly when condition becomes true
        }
    }
}
