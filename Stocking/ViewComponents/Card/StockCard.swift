import Charts
import SwiftUI

struct StockCard: View, Equatable {
    var stock: Stock
    var currentDate: Date

    private var priceStatus: PriceStatus {
        let change = stock.changeForDate(currentDate)
        if change > 0 { return .rising } else if change < 0 { return .falling }
        return .neutral
    }

    private var statusColor: Color { priceStatus.color }
    
    private var timeRangedStockPriceHistory: [PriceHistory] {
        let someTimeAgo = Calendar.current.date(byAdding: .day, value: -7, to: currentDate)!
        return stock.sortedPriceHistory.filter {
            $0.timestamp >= someTimeAgo && $0.timestamp <= currentDate
        }
    }
    
    func calculateAveragePrice() -> Double {
        var total = 0.0
        for priceHistory in timeRangedStockPriceHistory {
            total += priceHistory.price
        }
        return total / Double(timeRangedStockPriceHistory.count)
    }

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
                ForEach(timeRangedStockPriceHistory, id: \.timestamp) { item in
                    AreaMark(
                        x: .value("Date", item.timestamp),
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
                        x: .value("Date", item.timestamp),
                        y: .value("Price", item.price)
                    )
                    .foregroundStyle(statusColor)
                }

                RuleMark(y: .value("Threshold", self.calculateAveragePrice()))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [10, 5]))
                    .foregroundStyle(statusColor.opacity(0.6))
            }
            .frame(width: 100, height: 50)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)

            VStack(alignment: .trailing, spacing: 4) {
                Text(
                    timeRangedStockPriceHistory.last?.price ?? 0,
                    format: .number.precision(.fractionLength(2))
                )
                .font(.system(size: 14, weight: .semibold))

                Text(
                    stock.changeForDate(currentDate),
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
    let priceHistories = [
        PriceHistory(timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date.now)!, price: 100.0),
        PriceHistory(timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date.now)!, price: 104.0),
        PriceHistory(timestamp: Calendar.current.date(byAdding: .day, value: -3, to: Date.now)!, price: 102.0),
        PriceHistory(timestamp: Calendar.current.date(byAdding: .day, value: -4, to: Date.now)!, price: 106.0),
        PriceHistory(timestamp: Calendar.current.date(byAdding: .day, value: -5, to: Date.now)!, price: 104.0),
        PriceHistory(timestamp: Calendar.current.date(byAdding: .day, value: -6, to: Date.now)!, price: 107.0),
        PriceHistory(timestamp: Calendar.current.date(byAdding: .day, value: -7, to: Date.now)!, price: 108.0),
    ]
    let stock = Stock(symbol: "AAPL", name: "Apple Inc.", priceHistory: priceHistories)
    StockCard(stock: stock, currentDate: Date.now)
}
