// PriceChart.swift
import Charts
import SwiftUI
import Foundation

struct PriceChart: View {
    let data: [ChartDataPoint]
    var ruleDate: Date? = nil

    private var firstValue: Double { data.first?.value ?? 0 }
    private var lastValue:  Double { data.last?.value  ?? 0 }

    private var trend: PriceStatus {
        if lastValue > firstValue { return .rising }
        if lastValue < firstValue { return .falling }
        return .neutral
    }

    private var trendColor: Color { trend.color }

    var body: some View {
        Chart {
            ForEach(data) { point in
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
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(trendColor)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)
            }

            if let ruleDate {
                RuleMark(x: .value("Marker", ruleDate))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    .foregroundStyle(.secondary.opacity(0.4))
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel()
                    .font(.system(size: 11))
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing) { value in
                AxisValueLabel()
                    .font(.system(size: 11))
                AxisGridLine()
            }
        }
        .chartYScale(domain: chartYDomain)
        .chartXScale(domain: chartXDomain)
        .clipped()
    }

    private var chartXDomain: ClosedRange<Date> {
        guard let first = data.map(\.date).min(),
              let last  = data.map(\.date).max()
        else { return Date()...Date() }
        return first...last
    }
    
    private var chartYDomain: ClosedRange<Double> {
        guard let min = data.map(\.value).min(),
              let max = data.map(\.value).max(),
              min != max
        else { return 0...1 }
        let padding = (max - min) * 0.3
        return (min - padding)...(max + padding)
    }
}

// MARK: - Preview helpers

private func previewDate(_ offset: Int) -> Date {
    Calendar.current.date(byAdding: .hour, value: offset, to: Date())!
}

private let previewStockData: [ChartDataPoint] = [
    .init(date: previewDate(-8),  value: 267.20),
    .init(date: previewDate(-7),  value: 266.80),
    .init(date: previewDate(-6),  value: 269.50),
    .init(date: previewDate(-5),  value: 272.10),
    .init(date: previewDate(-4),  value: 271.80),
    .init(date: previewDate(-3),  value: 270.40),
    .init(date: previewDate(-2),  value: 269.90),
    .init(date: previewDate(-1),  value: 270.60),
    .init(date: previewDate(0),   value: 270.80),
]

private let previewBalanceData: [ChartDataPoint] = [
    .init(date: previewDate(-8),  value: 50.00),
    .init(date: previewDate(-6),  value: 52.30),
    .init(date: previewDate(-4),  value: 51.80),
    .init(date: previewDate(-2),  value: 60.75),
    .init(date: previewDate(0),   value: 67.00),
]

#Preview {
    VStack(spacing: 24) {
        VStack(alignment: .leading, spacing: 8) {
            Text("TSLA — Stock").font(.headline)
            PriceChart(data: previewStockData, ruleDate: previewDate(-3))
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }

        VStack(alignment: .leading, spacing: 8) {
            Text("Total Equity — Balance").font(.headline)
            PriceChart(data: previewBalanceData)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    .padding()
}

import Foundation

struct PriceRecord: Codable {
    let price: Double
    let timestamp: Date
}

#Preview("Balance History") {
    let url = Bundle.main.url(forResource: "WMT", withExtension: "json")!
    let data = try! Data(contentsOf: url)
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let records = try! decoder.decode([PriceRecord].self, from: data)
    
    let chartData = records.map { record in
        ChartDataPoint(date: record.timestamp, value: record.price)
    }
    
    return VStack(alignment: .leading, spacing: 8) {
        Text("My Balance").font(.headline)
        PriceChart(data: chartData)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
