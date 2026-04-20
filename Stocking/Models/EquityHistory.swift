//
//  EquityHistory.swift
//  Stocking
//
//  Created by Heryan Djaruma on 17/04/26.
//

import SwiftData
import SwiftUI

@Model
class EquityHistory {
    var id = UUID()
    var totalEquity: Double
    var timestamp: Date = Date()
    
    var userStockingData: UserStockingData?
    
    init(id: UUID = UUID(), totalEquity: Double, timestamp: Date, userStockingData: UserStockingData? = nil) {
        self.totalEquity = totalEquity
        self.timestamp = timestamp
        self.userStockingData = userStockingData
    }
}
