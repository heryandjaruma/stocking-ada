import SwiftUI
import SwiftData

@Model
class PriceHistory: Identifiable {
    var id = UUID()
    var date: Date
    var price: Double
    
    init(date: Date, price: Double) {
        self.date = date
        self.price = price
    }
}
