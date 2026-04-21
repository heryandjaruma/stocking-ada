import SwiftUI

struct SelectStock: View {
    var currentDate: Date
    var stocks: [Stock] = []
    var onSelect: (Stock) -> Void

    @State private var searchText: String = ""

    var filteredStocks: [Stock] {
        if searchText.isEmpty {
            return stocks
        }
        return stocks.filter {
            $0.symbol.localizedCaseInsensitiveContains(searchText) ||
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredStocks) { stock in
                    StockCard(stock: stock, currentDate: currentDate)
                        .listRowSeparator(.hidden)
                        .onTapGesture {
                            onSelect(stock)
                        }
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Search symbol or name")
            .navigationTitle("Select Stock")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let stocks: [Stock] = [
        .init(symbol: "AAPL", name: "Apple Inc.",
              priceHistory: [
                  PriceHistory(
                      timestamp: Calendar.current.date(
                          byAdding: .day,
                          value: -6,
                          to: Date()
                      )!,
                      price: 178.50
                  ),
                  PriceHistory(
                      timestamp: Calendar.current.date(
                          byAdding: .day,
                          value: -5,
                          to: Date()
                      )!,
                      price: 182.30
                  ),
                  PriceHistory(
                      timestamp: Calendar.current.date(
                          byAdding: .day,
                          value: -4,
                          to: Date()
                      )!,
                      price: 179.90
                  ),
                  PriceHistory(
                      timestamp: Calendar.current.date(
                          byAdding: .day,
                          value: -3,
                          to: Date()
                      )!,
                      price: 185.10
                  ),
                  PriceHistory(
                      timestamp: Calendar.current.date(
                          byAdding: .day,
                          value: -2,
                          to: Date()
                      )!,
                      price: 188.75
                  ),
                  PriceHistory(
                      timestamp: Calendar.current.date(
                          byAdding: .day,
                          value: -1,
                          to: Date()
                      )!,
                      price: 191.20
                  ),
                  PriceHistory(timestamp: Date(), price: 195.60),
              ]
             ),
        .init(symbol: "MSFT", name: "Microsoft Corporation"),
        .init(symbol: "NVDA", name: "NVIDIA Corporation"),
    ]
    
    SelectStock(currentDate: Date.now, stocks: stocks, onSelect: { _ in })
}
