//
//  OwnedStock.swift
//  Stocking
//
//  Created by Agustinus Juan Kurniawan on 22/04/26.
//

import SwiftData
import SwiftUI

@Model
class OwnedStock: Identifiable {
    var id: UUID = UUID()
    var timestamp: Date
    var stock: Stock
    var stockSymbol: String
    var isFinalized: Bool = false
    @Relationship(deleteRule: .noAction, inverse: \Order.ownedStock)
    var orders: [Order] = []

    init(timestamp: Date, stock: Stock, stockSymbol: String) {
        self.timestamp = timestamp
        self.stock = stock
        self.stockSymbol = stockSymbol
    }

    /// Calculate amount of share
    func getTotalOwnedShare() -> Int {
        let buyOrders = orders.filter {
            $0.side == "Buy" && $0.status == "Filled"
        }
        let sellOrders = orders.filter {
            $0.side == "Sell" && $0.status == "Filled"
        }
        return buyOrders.reduce(0) { $0 + $1.quantity }
            - sellOrders.reduce(0) { $0 + $1.quantity }
    }

    func calculateUnrealizedPnLPercentage(currentDate: Date) -> Double {
        let buyOrders = orders.filter {
            $0.side == "Buy" && $0.status == "Filled"
        }
        let sellOrders = orders.filter {
            $0.side == "Sell" && $0.status == "Filled"
        }

        let totalStockOwned =
            buyOrders.reduce(0) { $0 + $1.quantity }
            - sellOrders.reduce(0) { $0 + $1.quantity }

        guard totalStockOwned > 0 else { return 0 }

        let totalBuyValue = buyOrders.reduce(0.0) {
            $0 + ($1.price * Double($1.quantity))
        }
        let totalBuyQuantity = buyOrders.reduce(0) { $0 + $1.quantity }
        let avgBuyPrice = totalBuyValue / Double(totalBuyQuantity)

        let originalCost = avgBuyPrice * Double(totalStockOwned)
        let currentValue =
            (stock.getPriceByDate(currentDate)?.price ?? 0)
            * Double(totalStockOwned)

        return (currentValue - originalCost) / originalCost * 100
    }
}
