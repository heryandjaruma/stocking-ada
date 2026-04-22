import Charts
import SwiftUI

struct CompareChart: View {
    let primary: Stock
    let secondary: Stock
    var appToday: Date = Date()

    @State private var selectedRange: ChartRange = .oneMonth
    @State private var selectedDate: Date? = nil

    // MARK: - Data

    private func normalizedData(for stock: Stock) -> [ChartDataPoint] {
        let sorted = stock.priceHistory.sorted { $0.timestamp < $1.timestamp }
        guard let baseline = sorted.first?.price, baseline != 0 else { return [] }
        return sorted.map {
            ChartDataPoint(date: $0.timestamp, value: (($0.price - baseline) / baseline) * 100)
        }
    }

    private func rangedData(for stock: Stock) -> [ChartDataPoint] {
        let all = normalizedData(for: stock)
        let filtered = selectedRange.filtered(all, appToday: appToday)
        return filtered.isEmpty ? all : filtered // fallback to all if not enough history
    }

    private var primaryData:   [ChartDataPoint] { rangedData(for: primary) }
    private var secondaryData: [ChartDataPoint] { rangedData(for: secondary) }

    // MARK: - Unified Series

    struct SeriesPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
        let series: String
    }

    private var combinedData: [SeriesPoint] {
        primaryData.map   { SeriesPoint(date: $0.date, value: $0.value, series: primary.symbol) } +
        secondaryData.map { SeriesPoint(date: $0.date, value: $0.value, series: secondary.symbol) }
    }

    // MARK: - Domain

    private var sharedStartDate: Date { combinedData.map(\.date).min() ?? .distantPast }
    private var sharedEndDate:   Date { combinedData.map(\.date).max() ?? Date() }

    private var chartYDomain: ClosedRange<Double> {
        let values = combinedData.map(\.value)
        guard let min = values.min(), let max = values.max(), min != max else { return -1...1 }
        let padding = (max - min) * 0.2
        return (min - padding)...(max + padding)
    }

    // MARK: - Crosshair

    private func nearestPoint(in data: [ChartDataPoint], to date: Date) -> ChartDataPoint? {
        data.min { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }
    }

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Legend + crosshair values
            HStack(spacing: 16) {
                LegendDot(color: .blue, label: primary.symbol)
                if let date = selectedDate, let point = nearestPoint(in: primaryData, to: date) {
                    Text("\(point.value, specifier: "%+.2f")%")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.blue)
                }

                LegendDot(color: .yellow, label: secondary.symbol)
                if let date = selectedDate, let point = nearestPoint(in: secondaryData, to: date) {
                    Text("\(point.value, specifier: "%+.2f")%")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.yellow)
                }

                Spacer()

                if let date = selectedDate {
                    Text(date, format: .dateTime.month().day())
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }

            // Range picker
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

            Chart {
                RuleMark(y: .value("Baseline", 0))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    .foregroundStyle(.secondary.opacity(0.3))

                ForEach(combinedData) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Change %", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(
                        lineWidth: 2,
                        dash: point.series == secondary.symbol ? [6, 3] : []
                    ))
                    .foregroundStyle(by: .value("Stock", point.series))
                }

                if let date = selectedDate {
                    RuleMark(x: .value("Selected", date))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        .foregroundStyle(.secondary.opacity(0.5))

                    ForEach([primary, secondary], id: \.symbol) { stock in
                        let data = stock.symbol == primary.symbol ? primaryData : secondaryData
                        if let point = nearestPoint(in: data, to: date) {
                            PointMark(
                                x: .value("Date", point.date),
                                y: .value("Change %", point.value)
                            )
                            .symbolSize(40)
                            .foregroundStyle(by: .value("Stock", stock.symbol))
                        }
                    }
                }
            }
            .chartForegroundStyleScale([primary.symbol: Color.blue, secondary.symbol: Color.yellow])
            .chartLegend(.hidden)
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel().font(.system(size: 11).bold())
                    AxisGridLine().foregroundStyle(.gray.opacity(0.4))
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing) { value in
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text("\(v, specifier: "%.1f")%").font(.system(size: 11).bold())
                        }
                    }
                    AxisGridLine().foregroundStyle(.gray.opacity(0.4))
                }
            }
            .chartXScale(domain: sharedStartDate...sharedEndDate)
            .chartYScale(domain: chartYDomain)
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let origin = geo[proxy.plotFrame!].origin
                                    let x = value.location.x - origin.x
                                    if let date: Date = proxy.value(atX: x) {
                                        selectedDate = date
                                    }
                                }
                                .onEnded { _ in selectedDate = nil }
                        )
                }
            }
        }
    }
}

// MARK: - Legend Dot

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
