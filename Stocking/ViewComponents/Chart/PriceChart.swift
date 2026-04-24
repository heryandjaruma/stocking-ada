// PriceChart.swift
import Charts
import SwiftUI
import Foundation

struct PriceChart: View {
    let data: [ChartDataPoint]
    var ruleDate: Date? = nil
    var maxPoints: Int = 60

    @State private var selectedDate: Date? = nil

    // Downsample evenly to maxPoints
    private var sampledData: [ChartDataPoint] {
        guard data.count > maxPoints else { return data }
        let step = data.count / maxPoints
        return stride(from: 0, to: data.count, by: step).map { data[$0] }
    }

    private var firstValue: Double { sampledData.first?.value ?? 0 }
    private var lastValue:  Double { sampledData.last?.value  ?? 0 }

    private var trend: PriceStatus {
        if lastValue > firstValue { return .rising  }
        if lastValue < firstValue { return .falling }
        return .neutral
    }

    private var trendColor: Color { trend.color }

    private func nearestPoint(to date: Date) -> ChartDataPoint? {
        sampledData.min {
            abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            // Crosshair value header
            HStack {
                if let date = selectedDate, let point = nearestPoint(to: date) {
                    Text("$\(point.value, specifier: "%.2f")")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(trendColor)

                    Text(point.date, format: .dateTime.month(.abbreviated).day().year())
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .frame(height: 18) // reserve space so chart doesn't jump

            Chart {
                ForEach(sampledData) { point in
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [trendColor.opacity(0.4), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.linear)

                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(trendColor)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.linear)
                }

                // Static rule date marker
                if let ruleDate {
                    RuleMark(x: .value("Marker", ruleDate))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        .foregroundStyle(.secondary.opacity(0.4))
                }

                // Crosshair
                if let date = selectedDate, let point = nearestPoint(to: date) {
                    RuleMark(x: .value("Selected", point.date))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        .foregroundStyle(.secondary.opacity(0.6))

                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.value)
                    )
                    .symbolSize(50)
                    .foregroundStyle(trendColor)
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel().font(.system(size: 11).bold())
                    AxisGridLine().foregroundStyle(.gray.opacity(0.5))
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing) { value in
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text("\(v, specifier: "%.0f")").font(.system(size: 11).bold())
                        }
                    }
                    AxisGridLine().foregroundStyle(.gray.opacity(0.5))
                }
            }
            .chartYScale(domain: chartYDomain)
            .chartXScale(domain: chartXDomain)
            .clipped()
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
                            // Sticky: no onEnded clear
                        )
                        .onTapGesture {
                            selectedDate = nil // tap to dismiss
                        }
                }
            }
        }
    }

    private var chartXDomain: ClosedRange<Date> {
        guard let first = sampledData.map(\.date).min(),
              let last  = sampledData.map(\.date).max()
        else { return Date()...Date() }
        return first...last
    }

    private var chartYDomain: ClosedRange<Double> {
        guard let min = data.map(\.value).min(),
              let max = data.map(\.value).max(),
              min != max
        else { return 0...1 }
        let padding = (max - min) * 0.1
        return (min - padding)...(max + padding)
    }
}
