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
    var timestamp: Date = Date()
    var stock : Stock
    
    init(id: UUID, timestamp: Date, stock: Stock) {
        self.id = id
        self.timestamp = timestamp
        self.stock = stock
    }
}
