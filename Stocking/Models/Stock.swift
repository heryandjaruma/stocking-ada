import SwiftData
import SwiftUI

@Model
class Stock: Identifiable, Hashable {
    var id = UUID()
    var symbol: String
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \PriceHistory.stock)
    var priceHistory: [PriceHistory] = []

    init(
        id: UUID = UUID(),
        symbol: String,
        name: String,
        priceHistory: [PriceHistory] = []
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.priceHistory = priceHistory
    }

    var sortedPriceHistory: [PriceHistory] {
        priceHistory.sorted(by: { $0.timestamp < $1.timestamp })
    }

    func previousPrice(date: Date) -> Double? {
        priceHistory.last(where: { $0.timestamp < date })?.price
    }

    func changeForDate(_ date: Date, _ daysBack: Date? = nil) -> Double {
        let calendar = Calendar.current
        let previousDate = daysBack ?? Calendar.current.date(byAdding: .day, value: -1, to: date)!

        if let currentPrice = priceHistory.first(where: { calendar.isDate($0.timestamp, inSameDayAs: date) })?.price,
           let previousPrice = priceHistory.first(where: { calendar.isDate($0.timestamp, inSameDayAs: previousDate) })?.price {
            return currentPrice - previousPrice
        }

        return 0
    }
    
    func getPriceByDate(_ date: Date) -> PriceHistory? {
        let calendar = Calendar.current
        return priceHistory.first(where: { calendar.isDate($0.timestamp, inSameDayAs: date) })
    }
}
