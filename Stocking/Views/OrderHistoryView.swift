//
//  OrderHistoryView.swift
//  Stocking
//
//  Created by Heryan Djaruma on 24/04/26.
//

import SwiftUI
import SwiftData

struct OrderHistoryView: View {
//    var symbol: String?
    var orders: [Order]

//    private var filteredOrders: [Order] {
//        orders.filter { symbol == nil || $0.stockSymbol == symbol }
//    }

    var body: some View {
        ScrollView {
            LazyVStack {
                if orders.isEmpty {
                    ContentUnavailableView(
                        "No Orders Yet",
                        systemImage: "chart.line.flattrend.xyaxis",
                        description: Text("You haven't bought anything yet.")
                    )
                } else {
                    ForEach(orders) { order in
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
