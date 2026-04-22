// StockDetailsView.swift
import SwiftUI

struct StockDetailsView: View {
    var stock: Stock
    var currentDate: Date
    
    @State private var selectedRange: ChartRange = .oneMonth
    @State private var selectedDate: Date? = nil

    private var priceStatus: PriceStatus {
        guard let current = stock.priceHistory.last?.price else { return .neutral }
        let previous = stock.previousPrice(date: currentDate) ?? current
        if current > previous { return .rising }
        if current < previous { return .falling }
        return .neutral
    }

    private var statusColor: Color { priceStatus.color }

    private var changePercent: Double {
        guard let current = stock.priceHistory.last?.price else { return 0 }
        let previous = stock.previousPrice(date: currentDate) ?? current
        guard previous != 0 else { return 0 }
        return (stock.changeForDate(currentDate) / previous) * 100
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: Header
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

                // MARK: Price + change
                VStack(alignment: .leading, spacing: 4) {
                    Text("$\(stock.priceHistory.last?.price ?? 0, specifier: "%.2f")")
                        .font(.system(size: 28, weight: .bold))

                    HStack(spacing: 6) {
                        HStack(spacing: 2) {
                            Image(systemName: priceStatus == .falling ? "arrow.down" :
                                             priceStatus == .rising  ? "arrow.up"   : "minus")
                                .font(.system(size: 13, weight: .bold))
                            Text("\(abs(stock.changeForDate(currentDate)), specifier: "%.2f")")
                            Text("(\(changePercent, specifier: "%.2f")%)")
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(statusColor)

                        Text("Today")
                            .font(.system(size: 15))
                            .foregroundStyle(.primary)

                        Spacer()

                        // Filter Range
                        HStack(spacing: 4) {
                            ForEach(ChartRange.allCases, id: \.self) { range in
                                Button(range.rawValue) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedRange = range
                                        selectedDate = nil
                                    }
                                }
                                .font(.system(size: 12, weight: selectedRange == range ? .bold : .regular))
                                .foregroundStyle(selectedRange == range ? .primary : .secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    selectedRange == range
                                        ? RoundedRectangle(cornerRadius: 6).fill(.secondary.opacity(0.2))
                                        : nil
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                // MARK: Chart — padded to match screen margins
                PriceChart(data: stock.chartData)
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .padding(.horizontal, 24)

                Divider()
                    .padding(.vertical, 16)

                // MARK: Trade form
                TradeForm(stock: stock, ownedLots: 0)
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
                PriceHistory(timestamp: previewDate(-6), price: 279.20),
                PriceHistory(timestamp: previewDate(-5), price: 418.20),
                PriceHistory(timestamp: previewDate(-4), price: 412.80),
                PriceHistory(timestamp: previewDate(-3), price: 416.50),
                PriceHistory(timestamp: previewDate(-2), price: 419.00),
                PriceHistory(timestamp: previewDate(-1), price: 420.00),
                PriceHistory(timestamp: previewDate(0),  price: 429.20),
            ]
        ), currentDate: Date.now)
    }
}
