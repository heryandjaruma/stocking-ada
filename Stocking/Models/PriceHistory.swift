import SwiftUI
import SwiftData

@Model
class PriceHistory: Identifiable {
    var id = UUID()
    var timestamp: Date
    var price: Double
    
    init(date: Date, price: Double) {
        self.timestamp = date
        self.price = price
    }
}
