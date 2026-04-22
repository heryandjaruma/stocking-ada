//
//  MarketOrder.swift
//  Stocking
//
//  Created by Agustinus Juan Kurniawan on 22/04/26.
//
import SwiftUI
import SwiftData

@Model
class Order: Identifiable {
    var id: UUID = UUID()
    var timestamp: Date
    var quantity: Int
    var price: Double
    var orderType: String
    var side: String
    
    init(timestamp: Date, quantity: Int, price: Double, orderType: String, side: String) {
        self.timestamp = timestamp
        self.quantity = quantity
        self.price = price
        self.orderType = orderType
        self.side = side
    }
    
}
