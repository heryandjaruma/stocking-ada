// StockDetailsView.swift
import SwiftUI

struct StockDetailsView: View {
    var stock: Stock
    var currentDate: Date
    
    @State private var selectedRange: ChartRange = .oneMonth
    @State private var selectedDate: Date? = nil
    
    /// To be passed by parent for transaction error
    @Binding var transactionError: TransactionError?
    
    private var timeRangedStockPriceHistory: [PriceHistory] {
        let someTimeAgo: Date = selectedRange.startDate(from: currentDate)
        return stock.sortedPriceHistory.filter {
            $0.timestamp >= someTimeAgo && $0.timestamp <= currentDate
        }
    }
    
    private var timeRangedChartDataPoint: [ChartDataPoint] {
        return timeRangedStockPriceHistory.map { priceHistory in
            ChartDataPoint(date: priceHistory.timestamp, value: priceHistory.price)
        }
    }
    
    private var changePercent: Double {
        guard let current = timeRangedStockPriceHistory.last?.price else { return 0 }
        let previous = timeRangedStockPriceHistory.last(where: { $0.timestamp < currentDate })?.price ?? current /// default to current if no previous price is found (maybe the case if it's the first day)
        guard previous != 0 else { return 0 }
        return (stock.changeForDate(currentDate, selectedRange.startDate(from: currentDate)) / previous) * 100
    }
    
    private var priceStatus: PriceStatus {
        let change = stock.changeForDate(currentDate, selectedRange.startDate(from: currentDate))
        if change > 0 { return .rising }
        if change < 0 { return .falling }
        return .neutral
    }
    
    private var statusColor: Color { priceStatus.color }
    
    /// Optional callback for buying stocks
    var onBuyOrSell: ((Order) -> Void)? = nil

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
                    Image("\(stock.symbol)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 69, height: 69)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 20)

                //Price + change
                VStack(alignment: .leading, spacing: 4) {
                    Text("$\(timeRangedStockPriceHistory.last?.price ?? 0, specifier: "%.2f")")
                        .font(.system(size: 28, weight: .bold))

                    HStack(spacing: 6) {
                        HStack(spacing: 2) {
                            Image(systemName: priceStatus == .falling ? "arrow.down" :
                                             priceStatus == .rising  ? "arrow.up"   : "minus")
                                .font(.system(size: 13, weight: .bold))
                            Text("\(abs(stock.changeForDate(currentDate, selectedRange.startDate(from: currentDate))), specifier: "%.2f")")
                            Text("(\(changePercent, specifier: "%.2f")%)")
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(statusColor)

                        Spacer()

                        // Filter Range
                        HStack(spacing: 4) {
                            ForEach(ChartRange.allCases, id: \.self) { range in
                                Button(range.rawValue) {
                                    selectedRange = range
                                    selectedDate = nil
//                                    withAnimation(.interpolatingSpring) {
//                                    }
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
                PriceChart(data: timeRangedChartDataPoint)
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .padding(.horizontal, 24)

                Divider()
                    .padding(.vertical, 16)

                // MARK: Trade form
                TradeForm(stock: stock, currentDate: currentDate, ownedLots: 0)
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
        ), currentDate: Date.now, transactionError: .constant(nil))
    }
}
