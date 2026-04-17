import SwiftData
import SwiftUI

@Model
class Stock: Identifiable {
    var id = UUID()
    var symbol: String
    var name: String
    var priceHistory: [PriceHistory]

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

    func previousPrice(for date: Date) -> Double? {
            priceHistory.last(where: { $0.date < date })?.price
        }

        var change: Double {
            let today = Calendar.current.startOfDay(for: Date())
            guard let current = priceHistory.last?.price else { return 0 }
            let previous = previousPrice(for: today) ?? current
            return current - previous
        }

}
