import SwiftData
import SwiftUI

@Model
class Stock: Identifiable {
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

    func changeForDate(_ date: Date) -> Double {
        let calendar = Calendar.current
        let currentDate = date
        let previousDate = Calendar.current.date(
            byAdding: .day,
            value: -1,
            to: currentDate
        )!
        
        if let currentPrice = priceHistory.first(where: { calendar.isDate($0.timestamp, inSameDayAs: currentDate) })?.price,
           let previousPrice = priceHistory.first(where: { calendar.isDate($0.timestamp, inSameDayAs: previousDate) })?.price {
            return currentPrice - previousPrice
        }
        
        return 0
    }
}
