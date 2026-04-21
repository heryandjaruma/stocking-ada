import Foundation

enum ChartRange: String, CaseIterable {
    case oneDay   = "1D"
    case oneWeek  = "1W"
    case oneMonth = "1M"

    /// Returns the start date for this range relative to the app's "today"
    func startDate(from appToday: Date) -> Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: appToday)
        switch self {
        case .oneDay:   return calendar.date(byAdding: .day,   value: -1, to: today)!
        case .oneWeek:  return calendar.date(byAdding: .day,   value: -7, to: today)!
        case .oneMonth: return calendar.date(byAdding: .month, value: -1, to: today)!
        }
    }

    /// Filters a sorted [ChartDataPoint] array to only include points within this range
    func filtered(_ data: [ChartDataPoint], appToday: Date) -> [ChartDataPoint] {
        let start = startDate(from: appToday)
        let end   = Calendar.current.startOfDay(for: appToday)
            .addingTimeInterval(86400 - 1) // end of app's today
        return data.filter { $0.date >= start && $0.date <= end }
    }
}
