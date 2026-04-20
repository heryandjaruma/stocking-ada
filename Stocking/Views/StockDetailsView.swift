// StockDetailsView.swift
import SwiftUI

struct StockDetailsView: View {
    var stock: Stock

    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    @State private var selectedRange: String = "1D"
    private let ranges = ["1D", "1W", "1M"]
    
    private var changePercent: Double {
        let today = Calendar.current.startOfDay(for: Date())
        guard let current = stock.priceHistory.last?.price else { return 0 }
        let previous = stock.previousPrice(for: today) ?? current
        guard previous != 0 else { return 0 }
        return (stock.change / previous) * 100
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

                // Replace this whole VStack block + the HStack { Text("Test") }:

                VStack(alignment: .leading, spacing: 1) {
                    Text("$\(stock.priceHistory.last?.price ?? 0, specifier: "%.2f")")
                        .font(.system(size: 28, weight: .bold))

                    HStack(spacing: 6) {
                        // Arrow + change amount + percentage
                        HStack(spacing: 2) {
                            Image(systemName: priceStatus == .falling ? "arrow.down" : priceStatus == .rising ? "arrow.up" : "minus")
                                .font(.system(size: 13, weight: .bold))
                            Text("\(abs(stock.change), specifier: "%.2f")")
                            Text("(\(changePercent, specifier: "%.2f")%)")
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(statusColor)

                        Text("Today")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.primary)

                        Spacer()

                        // Time range picker
                        Picker("Range", selection: $selectedRange) {
                            ForEach(ranges, id: \.self) { range in
                                Text(range).tag(range)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 120)
                    }
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
