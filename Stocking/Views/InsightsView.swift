import SwiftUI

struct ChartView: View {
    var primaryStock: Stock!
    var secondaryStock: Stock!

    var body: some View {
        Text("Insights")
            .font(.largeTitle)

        CompareChart(primary: primaryStock, secondary: secondaryStock).frame(
            height: 260
        )
        .padding(24)
    }
}

#Preview {
    let primaryStock = Stock(
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
    )

    let secondaryStock = Stock(
        symbol: "TSLA",
        name: "Tesla Inc.",
        priceHistory: [
            PriceHistory(
                timestamp: Calendar.current.date(
                    byAdding: .day,
                    value: -6,
                    to: Date()
                )!,
                price: 245.00
            ),
            PriceHistory(
                timestamp: Calendar.current.date(
                    byAdding: .day,
                    value: -5,
                    to: Date()
                )!,
                price: 238.50
            ),
            PriceHistory(
                timestamp: Calendar.current.date(
                    byAdding: .day,
                    value: -4,
                    to: Date()
                )!,
                price: 242.10
            ),
            PriceHistory(
                timestamp: Calendar.current.date(
                    byAdding: .day,
                    value: -3,
                    to: Date()
                )!,
                price: 230.80
            ),
            PriceHistory(
                timestamp: Calendar.current.date(
                    byAdding: .day,
                    value: -2,
                    to: Date()
                )!,
                price: 225.40
            ),
            PriceHistory(
                timestamp: Calendar.current.date(
                    byAdding: .day,
                    value: -1,
                    to: Date()
                )!,
                price: 219.90
            ),
            PriceHistory(timestamp: Date(), price: 212.30),
        ]
    )

    ChartView(primaryStock: primaryStock, secondaryStock: secondaryStock)
}
