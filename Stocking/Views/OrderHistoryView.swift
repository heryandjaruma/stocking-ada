//
//  OrderHistoryView.swift
//  Stocking
//
//  Created by Heryan Djaruma on 24/04/26.
//

import SwiftUI

struct OrderHistoryView: View {
    var orders: [Order]
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(orders) { order in
                    OrderCard(order: order)
                }
            }
            .padding()
        }
        .navigationTitle("Order History")
    }
}

#Preview {
    let orders = [
        Order(timestamp: Date.now, quantity: 6, stockSymbol: "AAPL", price: 70.0, orderType: "Market", side: "Buy", expiry: "GTC", status: "Created"),
        Order(timestamp: Date.now, quantity: 6, stockSymbol: "AAPL", price: 70.0, orderType: "Market", side: "Sell", expiry: "GTC", status: "Created"),
        Order(timestamp: Date.now, quantity: 6, stockSymbol: "AAPL", price: 70.0, orderType: "Market", side: "Sell", expiry: "GTC", status: "Filled"),
        Order(timestamp: Date.now, quantity: 6, stockSymbol: "AAPL", price: 70.0, orderType: "Market", side: "Buy", expiry: "GTC", status: "Canceled"),
    ]
    OrderHistoryView(orders: orders)
}
