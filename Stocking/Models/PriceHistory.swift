import SwiftUI
import SwiftData

@Model
class PriceHistory: Identifiable {
    var id = UUID()
    var timestamp: Date
    var price: Double
    var stock: Stock?
    
    init(timestamp: Date, price: Double) {
        self.timestamp = timestamp
        self.price = price
    }
}
