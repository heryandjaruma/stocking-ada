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
    var price: Double /// In market used as price when bought
    var orderType: String /// Market, Limit
    var side: String /// Buy, Sell
    var expiry: String? = nil /// GTC, GFD ; Only for limit
    var status: String /// Canceled, Filled, Created
    var ownedStock: OwnedStock? /// Back relation
    
    init(timestamp: Date, quantity: Int, price: Double, orderType: String, side: String, expiry: String? = nil, status: String) {
        self.timestamp = timestamp
        self.quantity = quantity
        self.price = price
        self.orderType = orderType
        self.side = side
        self.expiry = expiry
        self.status = status
    }
    
}
