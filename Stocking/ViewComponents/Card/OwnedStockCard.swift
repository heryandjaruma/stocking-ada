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
    
    private var priceStatus: PriceStatus {
        let change = ownedStock.stock.changeForDate(currentDate)
        if change > 0 { return .rising } else if change < 0 { return .falling }
        return .neutral
    }
    private var statusColor: Color { priceStatus.color }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(ownedStock.stockSymbol)
                    .font(.title2.bold())
                    .lineLimit(1)
                Text(ownedStock.stock.name)
                    .lineLimit(1)
                    .foregroundStyle(.gray)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(
                    "<this stock total value>"
                    //                    ownedStock.stock.getPriceByDate(currentDate)?.price ?? 0,
                    //                    format: .number.precision(.fractionLength(2))
                )
                .font(.system(size: 14, weight: .semibold))
                
                Text(
                    "<this stock pnl>"
                    //                    ownedStock.stock.changeForDate(currentDate),
                    //                    format: .number.precision(.fractionLength(2))
                )
                .foregroundStyle(.white)
                .font(.system(size: 13, weight: .bold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(statusColor)
                )
            }
            .frame(width: 70, alignment: .trailing)
        }
    }
}

#Preview {
    let ownedStock = OwnedStock(timestamp: Date.now, stock: Stock(symbol: "AAPL", name: "Apple Inc."), stockSymbol: "AAPL")
    OwnedStockCard(ownedStock: ownedStock, currentDate: Date.now)
}
