// NewsCard.swift
import SwiftUI

struct NewsCard: View {
    var news: News
    var currentDate: Date

    private var priceStatus: PriceStatus {
        let change = news.stock.changeForDate(currentDate)
        if change > 0 { return .rising }
        if change < 0 { return .falling }
        return .neutral
    }
    
    private var priceSymbol: String {
        let change = news.stock.changeForDate(currentDate)
        return change.isZero ? "" : (change > 0 ? "+" : "-")
    }

    private var statusColor: Color { priceStatus.color }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Symbol
            Text(news.stock.symbol)
                .font(.title2.bold())

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(
                            news.stock.priceHistory.last?.price ?? 0,
                            format: .number.precision(.fractionLength(2))
                        )
                        .font(.system(size: 15, weight: .semibold))

                        Text("\(priceSymbol)\(abs(news.stock.changeForDate(currentDate)), format: .number.precision(.fractionLength(2)))")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(statusColor)
                    }
                    Text("At Close")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Divider()

            // Article
            VStack(alignment: .leading, spacing: 4) {
                Text(news.source)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(news.headline)
                    .font(.system(size: 17, weight: .bold))
                    .lineLimit(3)

                Text(news.desc)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

private func previewDate(_ offset: Int) -> Date {
    Calendar.current.date(byAdding: .day, value: offset, to: Date())!
}

#Preview {
    let stock = Stock(
        symbol: "AAPL",
        name: "Apple Inc.",
        priceHistory: [
            PriceHistory(timestamp: previewDate(-1), price: 196.46),
            PriceHistory(timestamp: previewDate(0), price: 198.87),
        ]
    )
    NewsCard(
        news: News(
            stock: stock,
            source: "The Wall Street Journal",
            headline: "TSMC Posts Profit Beat Despite Middle East Conflict",
            desc:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim..."
        ), currentDate: Date.now
    )
}
