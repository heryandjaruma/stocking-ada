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
    var stockSymbol: String
    var isFinalized: Bool = false
    @Relationship(deleteRule: .noAction, inverse: \Order.ownedStock)
    var orders: [Order] = []
    
    init(timestamp: Date, stock: Stock, stockSymbol: String) {
        self.timestamp = timestamp
        self.stock = stock
        self.stockSymbol = stockSymbol
    }
}
