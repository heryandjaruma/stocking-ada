//
//  OrderHistoryView.swift
//  Stocking
//
//  Created by Heryan Djaruma on 24/04/26.
//

import SwiftUI
import SwiftData

struct OrderHistoryView: View {
    var orders: [Order]
    
    var reversedOrders: [Order] {
        return orders.reversed()
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                if reversedOrders.isEmpty {
                    ContentUnavailableView(
                        "No Orders Yet",
                        systemImage: "chart.line.flattrend.xyaxis",
                        description: Text("You haven't bought anything yet.")
                    )
                } else {
                    ForEach(reversedOrders) { order in
                        OrderCard(order: order)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    let orders = [
        Order(timestamp: Date.now, quantity: 6, stockSymbol: "AAPL", price: 70.0, orderType: "Market", side: "Buy", expiry: "GTC", status: "Created"),
        Order(timestamp: Date.now, quantity: 6, stockSymbol: "AAPL", price: 70.0, orderType: "Market", side: "Sell", expiry: "GTC", status: "Created"),
        Order(timestamp: Date.now, quantity: 6, stockSymbol: "AAPL", price: 70.0, orderType: "Market", side: "Sell", expiry: "GTC", status: "Filled"),
        Order(timestamp: Date.now, quantity: 6, stockSymbol: "AAPL", price: 70.0, orderType: "Market", side: "Buy", expiry: "GTC", status: "Canceled"),
        Order(timestamp: Date.now, quantity: 6, stockSymbol: "MSFT", price: 70.0, orderType: "Market", side: "Buy", expiry: "GTC", status: "Canceled"),
        
    ]
    OrderHistoryView(orders: orders)
}
