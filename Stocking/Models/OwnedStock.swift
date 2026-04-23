//
//  OwnedStock.swift
//  Stocking
//
//  Created by Agustinus Juan Kurniawan on 22/04/26.
//

import SwiftUI
import SwiftData

@Model
class OwnedStock: Identifiable {
    var id: UUID = UUID()
    var timestamp: Date
    var stock : Stock
    var isFinalized: Bool = false
    @Relationship(deleteRule: .noAction, inverse: \PriceHistory.stock)
    var orders: [Order] = []
    
    init(timestamp: Date, stock: Stock) {
        self.timestamp = timestamp
        self.stock = stock
    }
}
