import SwiftUI
import SwiftData

@Model
class Stock: Identifiable {
    var id = UUID()
    var symbol: String
    var name: String
    var price: Double
    var priceHistory: [PriceHistory]

    init(id: UUID = UUID(), symbol: String, name: String, price: Double, priceHistory: [PriceHistory] = []) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.price = price
        self.priceHistory = priceHistory
    }
}
