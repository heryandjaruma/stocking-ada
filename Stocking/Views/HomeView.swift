//
//  HomeView.swift
//  Stocking
//
//  Created by Heryan Djaruma on 20/04/26.
//

import SwiftUI

struct HomeView: View {
    var currentDate: Date
    var stocks: [Stock] = []

    var onForwardDay: (() -> Void)? = nil  // optional callback param

    var body: some View {
        NavigationStack {

            VStack {
                HStack {
                    Spacer()
                    Button(action: {

                    }) {
                        Image(systemName: "plus.circle")
                    }
                    .padding(.horizontal, 16)
                    .buttonStyle(.plain)
                }
                List {
                    ForEach(stocks) { stock in
                        NavigationLink(
                            destination: StockDetailsView(
                                stock: stock,
                                currentDate: currentDate
                            )
                        ) {
                            StockCard(stock: stock, currentDate: currentDate)
                                .equatable()
                        }
                        .listRowSeparator(.hidden)
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(.plain)
            }
            .listRowSpacing(-12)
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VStack(alignment: .leading) {
                        Text("Stocks")
                        Text(currentDate, format: .dateTime.day().month(.wide))
                            .opacity(0.5)
                    }
                    .font(Font.title.bold())
                    .frame(width: 200, alignment: .leading)
                }
                .sharedBackgroundVisibility(.hidden)

                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button(action: { onForwardDay?() }) {
                            Text("Forward 1 day")
                                .font(.footnote)
                            Image(systemName: "chevron.forward.2")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                }
            }
        }
    }
}

#Preview {
    let stocks: [Stock] = [
        .init(
            symbol: "AAPL",
            name: "Apple Inc.",
            priceHistory: [
                PriceHistory(
                    timestamp: Calendar.current.date(
                        byAdding: .day,
                        value: -6,
                        to: Date()
                    )!,
                    price: 178.50
                ),
                PriceHistory(
                    timestamp: Calendar.current.date(
                        byAdding: .day,
                        value: -5,
                        to: Date()
                    )!,
                    price: 182.30
                ),
                PriceHistory(
                    timestamp: Calendar.current.date(
                        byAdding: .day,
                        value: -4,
                        to: Date()
                    )!,
                    price: 179.90
                ),
                PriceHistory(
                    timestamp: Calendar.current.date(
                        byAdding: .day,
                        value: -3,
                        to: Date()
                    )!,
                    price: 185.10
                ),
                PriceHistory(
                    timestamp: Calendar.current.date(
                        byAdding: .day,
                        value: -2,
                        to: Date()
                    )!,
                    price: 188.75
                ),
                PriceHistory(
                    timestamp: Calendar.current.date(
                        byAdding: .day,
                        value: -1,
                        to: Date()
                    )!,
                    price: 191.20
                ),
                PriceHistory(timestamp: Date(), price: 195.60),
            ]
        ),
        .init(symbol: "MSFT", name: "Microsoft Corporation"),
        .init(symbol: "NVDA", name: "NVIDIA Corporation"),
    ]

    HomeView(currentDate: Date.now, stocks: stocks)
}
