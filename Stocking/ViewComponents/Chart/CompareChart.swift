import Charts
import SwiftUI

struct CompareChart: View {
    let primary: Stock
    let secondary: Stock

    private var primaryData:   [ChartDataPoint] { normalizedData(for: primary) }
    private var secondaryData: [ChartDataPoint] { normalizedData(for: secondary) }

    private func normalizedData(for stock: Stock) -> [ChartDataPoint] {
        let sorted = stock.priceHistory
            .sorted { $0.timestamp < $1.timestamp }

        guard let baseline = sorted.first?.price, baseline != 0 else { return [] }

        return sorted.map {
            ChartDataPoint(date: $0.timestamp, value: (($0.price - baseline) / baseline) * 100)
        }
    }
    
    private var sharedStartDate: Date {
        let d1 = primary.priceHistory.map(\.timestamp).min() ?? .distantPast
        let d2 = secondary.priceHistory.map(\.timestamp).min() ?? .distantPast
        return max(d1, d2)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 16) {
                LegendDot(color: .blue,   label: primary.symbol)
                LegendDot(color: .yellow, label: secondary.symbol)
            }

            Chart {
                // baseline
                RuleMark(y: .value("Baseline", 0))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    .foregroundStyle(.secondary.opacity(0.4))

                // Primary stock
                ForEach(primaryData.filter { $0.date >= sharedStartDate }) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Change %", point.value)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.catmullRom)
                }
                .foregroundStyle(by: .value("Stock", primary.symbol))

                // Secondary stock
                ForEach(secondaryData.filter { $0.date >= sharedStartDate }) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Change %", point.value)
                    )
                    .foregroundStyle(.yellow)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 3]))
                    .interpolationMethod(.catmullRom)
                }
                .foregroundStyle(by: .value("Stock", secondary.symbol))
            }
            .chartLegend(.hidden)
            .chartXAxis {
                AxisMarks { AxisValueLabel().font(.system(size: 11)); AxisGridLine() }
            }
            .chartYAxis {
                AxisMarks(position: .trailing) { value in
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text("\(v, specifier: "%.1f")%")
                                .font(.system(size: 11))
                        }
                    }
                    AxisGridLine()
                }
            }
            .chartXScale(domain: sharedStartDate...(primaryData.map(\.date).max() ?? Date()))
            .clipped()
        }
    }
}

private struct LegendDot: View {
    let color: Color
    let label: String
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(.system(size: 13, weight: .semibold))
        }
    }
}

// MARK: - Preview

private func previewDate(_ offset: Int) -> Date {
    Calendar.current.date(byAdding: .day, value: offset, to: Date())!
}

#Preview {
    let aapl = Stock(symbol: "AAPL", name: "Apple Inc.", priceHistory: [
        PriceHistory(timestamp: previewDate(-6), price: 170.00),
        PriceHistory(timestamp: previewDate(-5), price: 173.50),
        PriceHistory(timestamp: previewDate(-4), price: 171.20),
        PriceHistory(timestamp: previewDate(-3), price: 176.80),
        PriceHistory(timestamp: previewDate(-2), price: 180.10),
        PriceHistory(timestamp: previewDate(-1), price: 178.90),
        PriceHistory(timestamp: previewDate(0),  price: 182.30),
    ])

    let msft = Stock(symbol: "MSFT", name: "Microsoft Corp.", priceHistory: [
        PriceHistory(timestamp: previewDate(-6), price: 415.00),
        PriceHistory(timestamp: previewDate(-5), price: 412.30),
        PriceHistory(timestamp: previewDate(-4), price: 418.60),
        PriceHistory(timestamp: previewDate(-3), price: 420.00),
        PriceHistory(timestamp: previewDate(-2), price: 416.50),
        PriceHistory(timestamp: previewDate(-1), price: 422.10),
        PriceHistory(timestamp: previewDate(0),  price: 419.80),
    ])

    CompareChart(primary: aapl, secondary: msft)
        .frame(height: 260)
        .padding(24)
}
