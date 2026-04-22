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

                RuleMark(y: .value("Threshold", 200))
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

//#Preview {
//    StockCard(stock: Stock, currentDate: Date.now)
//}
