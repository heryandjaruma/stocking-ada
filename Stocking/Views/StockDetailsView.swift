// StockDetailsView.swift
import SwiftUI

struct StockDetailsView: View {
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
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stock.symbol)
                            .font(.title.bold())
                        Text(stock.name)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "apple.logo")
                        .font(.system(size: 44))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 20)

                VStack(alignment: .leading, spacing: 4) {
                    Text(stock.priceHistory.last?.price ?? 0,
                         format: .number.precision(.fractionLength(2)))
                        .font(.system(size: 36, weight: .bold))

                    Text(stock.change, format: .number.precision(.fractionLength(2)))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(statusColor)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)

                PriceChart(
                    data: stock.chartData
                )
                .frame(maxWidth: .infinity)
                .frame(height: 220)

                Spacer().frame(height: 32)
                
                HStack {
                    Text("Test")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

private func previewDate(_ offset: Int) -> Date {
    Calendar.current.date(byAdding: .day, value: offset, to: Date())!
}

#Preview {
    NavigationStack {
        StockDetailsView(stock: Stock(
            symbol: "AAPL",
            name: "Apple Inc.",
            priceHistory: [
                PriceHistory(date: previewDate(-6), price: 415.00),
                PriceHistory(date: previewDate(-5), price: 418.20),
                PriceHistory(date: previewDate(-4), price: 412.80),
                PriceHistory(date: previewDate(-3), price: 416.50),
                PriceHistory(date: previewDate(-2), price: 419.00),
                PriceHistory(date: previewDate(-1), price: 420.00),
                PriceHistory(date: previewDate(0),  price: 420.00),
            ]
        ))
    }
}
