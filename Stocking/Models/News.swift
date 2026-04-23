import SwiftData
import SwiftUI

@Model
class News: Identifiable {
    var id = UUID()
    var stock: Stock
    var source: String
    var headline: String
    var desc: String
    var published: Date

    init(id: UUID = UUID(), stock: Stock, source: String, headline: String, desc: String, published: Date) {
        self.id = id
        self.stock = stock
        self.source = source
        self.headline = headline
        self.desc = desc
        self.published = published
    }
}
