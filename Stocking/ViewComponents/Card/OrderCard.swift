//
//  OrderCard.swift
//  Stocking
//
//  Created by Heryan Djaruma on 24/04/26.
//

import SwiftUI

struct OrderCard: View {
    var order: Order
    var body: some View {
        HStack {
            Grid {
                GridRow {
                    VStack(alignment: .leading) {
                        Text("\(order.side) \(order.stockSymbol)")
                            .foregroundStyle(order.side == "Buy" ? .green : .red)
                            .font(.body.bold())
                            .lineLimit(1)
                        Text("\(order.quantity) share\(order.quantity > 0 ? "s" : "")")
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    .gridCellColumns(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    VStack(alignment: .trailing) {
                        Text("\(order.price * Double(order.quantity), specifier: "%.2f")")
                            .font(.body.bold())
                        Text("\(order.price, specifier: "%.2f")")
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    .gridCellColumns(1)
                    .frame(maxWidth: .infinity)
                    VStack(alignment: .trailing) {
                        Text("\(order.status)")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .foregroundStyle(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(order.status == "Created" ? .gray :
                                            order.status == "Filled" ? .green : .red)
                            )
                        Text("\(order.expiry ?? "-")")
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    .gridCellColumns(1)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
}

#Preview {
    let order = Order(timestamp: Date.now, quantity: 6, stockSymbol: "AAPL", price: 70.0, orderType: "Market", side: "Sell", expiry: "GTC", status: "Created")
    OrderCard(order: order)
}
