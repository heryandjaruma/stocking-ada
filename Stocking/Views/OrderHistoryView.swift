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

    private var groupedOrders: [(date: Date, orders: [Order])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: orders.reversed()) { order in
            calendar.startOfDay(for: order.timestamp)
        }
        return grouped
            .map { (date: $0.key, orders: $0.value) }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                if groupedOrders.isEmpty {
                    ContentUnavailableView(
                        "No Orders Yet",
                        systemImage: "chart.line.flattrend.xyaxis",
                        description: Text("You haven't bought anything yet.")
                    )
                } else {
                    ForEach(groupedOrders, id: \.date) { group in
                        Section {
                            ForEach(group.orders) { order in
                                OrderCard(order: order)
                                    .padding(.horizontal)
                            }
                        } header: {
                            Text(group.date, format: .dateTime.day().month(.wide).year())
                                .font(.footnote.bold())
                                .foregroundStyle(.secondary)
                                .padding(.top, 16)
                                .padding(.bottom, 4)
                                .padding(.horizontal)
                            Divider()
                                .padding(.bottom, 10)
                        }
                    }
                }
            }
            .padding(.bottom)
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
        Order(timestamp: Date.now, quantity: 6, stockSymbol: "MSFT", price: 70.0, orderType: "Market", side: "Buy", expiry: "GTC", status: "Canceled"),
        
    ]
    OrderHistoryView(orders: orders)
}
