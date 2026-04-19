import Foundation

extension Stock: Chartable {
    var chartData: [ChartDataPoint] {
        priceHistory
            .sorted { $0.date < $1.date }
            .map { ChartDataPoint(date: $0.date, value: $0.price) }
        }
}

struct BalanceHistory {
    let date: Date
    let value: Double
}

struct PortfolioBalance: Chartable {
    var history: [BalanceHistory]

    var chartData: [ChartDataPoint] {
        history.map { ChartDataPoint(date: $0.date, value: $0.value) }
    }
}
