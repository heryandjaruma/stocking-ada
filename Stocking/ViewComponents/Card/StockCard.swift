import Charts
import SwiftUI

struct StockCard: View {
    var stock: Stock

    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    private var priceStatus: PriceStatus {
        guard let current = stock.priceHistory.last?.price else {
            return .neutral
        }
        let previous = stock.previousPrice(for: today) ?? current
        if current > previous { return .rising }
        if current < previous { return .falling }
        return .neutral
    }

    private var statusColor: Color { priceStatus.color }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stock.symbol)
                    .font(.title2.bold())
                    .lineLimit(1)
                Text(stock.name)
                    .lineLimit(1)
                    .foregroundStyle(.gray)
            }
            .frame(width: 100, alignment: .leading)

            Spacer()

            // generated
            Chart {
                ForEach(stock.priceHistory, id: \.date) { item in
                    AreaMark(
                        x: .value("Date", item.date),
                        y: .value("Price", item.price)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [statusColor.opacity(0.5), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Price", item.price)
                    )
                    .foregroundStyle(statusColor)
                }

                RuleMark(y: .value("Threshold", 200))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [10, 5]))
                    .foregroundStyle(statusColor.opacity(0.6))
            }
            .frame(width: 100, height: 50)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)

            VStack(alignment: .trailing, spacing: 4) {
                Text(
                    stock.priceHistory.last?.price ?? 0,
                    format: .number.precision(.fractionLength(2))
                )
                .font(.system(size: 14, weight: .semibold))

                Text(
                    stock.change,
                    format: .number.precision(.fractionLength(2))
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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {

    let fallingStock = Stock(
        symbol: "TSLA",
        name: "Tesla Inc.",
        priceHistory: [
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -6,
                    to: Date()
                )!,
                price: 245.00
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -5,
                    to: Date()
                )!,
                price: 238.50
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -4,
                    to: Date()
                )!,
                price: 242.10
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -3,
                    to: Date()
                )!,
                price: 230.80
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -2,
                    to: Date()
                )!,
                price: 225.40
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -1,
                    to: Date()
                )!,
                price: 219.90
            ),
            PriceHistory(date: Date(), price: 212.30),
        ]
    )

    let neutralStock = Stock(
        symbol: "MSFT",
        name: "Microsoft Corp.",
        priceHistory: [
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -6,
                    to: Date()
                )!,
                price: 415.00
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -5,
                    to: Date()
                )!,
                price: 418.20
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -4,
                    to: Date()
                )!,
                price: 412.80
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -3,
                    to: Date()
                )!,
                price: 416.50
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -2,
                    to: Date()
                )!,
                price: 419.00
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -1,
                    to: Date()
                )!,
                price: 420.00
            ),
            PriceHistory(date: Date(), price: 420.00),  // same as previous → neutral
        ]
    )

    StockCard(stock: fallingStock)
    StockCard(stock: neutralStock)

}

#Preview("Green") {
    let sampleStock = Stock(
        symbol: "AAPL",
        name: "Apple Inc.",
        priceHistory: [
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -6,
                    to: Date()
                )!,
                price: 178.50
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -5,
                    to: Date()
                )!,
                price: 182.30
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -4,
                    to: Date()
                )!,
                price: 179.90
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -3,
                    to: Date()
                )!,
                price: 185.10
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -2,
                    to: Date()
                )!,
                price: 188.75
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -1,
                    to: Date()
                )!,
                price: 191.20
            ),
            PriceHistory(date: Date(), price: 195.60),
        ]
    )
    StockCard(stock: sampleStock)
}
