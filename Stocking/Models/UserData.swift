//
//  UserData.swift
//  Stocking
//
//  Created by Heryan Djaruma on 17/04/26.
//

import Foundation
import SwiftData

@Model
class UserStockingData {
    var id: UUID = UUID()
    var totalEquity: Double = 100.0
    var tradeableBalance: Double = 0.0
    var investedBalance: Double = 0.0
    
    /// Mark relationship one-to-many for equity history
    @Relationship(deleteRule: .cascade)
    var equityHistory: [EquityHistory] = []
    
    init(totalEquity: Double, tradeableBalance: Double, investedBalance: Double) {
        self.totalEquity = totalEquity
        self.tradeableBalance = tradeableBalance
        self.investedBalance = investedBalance
    }
}
