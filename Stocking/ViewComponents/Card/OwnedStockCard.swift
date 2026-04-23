//
//  OwnedStockCard.swift
//  Stocking
//
//  Created by Heryan Djaruma on 23/04/26.
//

import SwiftUI

struct OwnedStockCard: View {
    var ownedStock: OwnedStock
    var currentDate: Date
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(ownedStock.stockSymbol)
                Text(ownedStock.stock.name)
            }
            VStack {
                Text("\(ownedStock.stock.getPriceByDate(currentDate))")
            }
        }
    }
}

#Preview {
    let ownedStock = OwnedStock(timestamp: Date.now, stock: Stock(symbol: "AAPL", name: "Apple Inc."), stockSymbol: "AAPL")
    OwnedStockCard(ownedStock: ownedStock, currentDate: Date.now)
}
