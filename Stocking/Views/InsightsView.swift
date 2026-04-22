import SwiftUI

struct InsightsView: View {
    var stocks: [Stock]
    var news: [News] = []
    var currentDate: Date
    var onForwardDay: (() -> Void)? = nil

    @State private var primaryStock: Stock?
    @State private var secondaryStock: Stock?

    @State private var showingPrimarySheet = false
    @State private var showingSecondarySheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Insight")
                        .font(.largeTitle)
                        .bold()
                        .frame(width: 200, alignment: .leading)
                    Spacer()
                }

                VStack(alignment: .leading) {
                    HStack {
                        Button(action: { showingPrimarySheet = true }) {
                            Text(primaryStock?.symbol ?? "Primary")
                                .bold()
                        }
                        .buttonStyle(.glass)

                        Button(action: { showingSecondarySheet = true }) {
                            Text(secondaryStock?.symbol ?? "Secondary")
                                .bold()
                        }
                        .buttonStyle(.glass)
                    }
                }

                if let primary = primaryStock, let secondary = secondaryStock {
                    CompareChart(primary: primary, secondary: secondary, appToday: currentDate)
                        .frame(height: 260)
                        .padding(14)
                } else {
                    ContentUnavailableView(
                        "No Stocks Selected",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Tap the buttons above to select stocks to compare.")
                    )
                    .frame(height: 260)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("News")
                        .font(.title2)
                        .bold()

                    ForEach(news) { oneNews in
                        NewsCard(news: oneNews, currentDate: currentDate)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            if primaryStock == nil   { primaryStock   = stocks.first }
            if secondaryStock == nil { secondaryStock = stocks.dropFirst().first }
        }
        .onChange(of: stocks) { _, newStocks in
            if primaryStock == nil   { primaryStock   = newStocks.first }
            if secondaryStock == nil { secondaryStock = newStocks.dropFirst().first }
        }
        .sheet(isPresented: $showingPrimarySheet) {
            SelectStock(currentDate: currentDate, stocks: stocks) { selected in
                primaryStock = selected
                showingPrimarySheet = false
            }
        }
        .sheet(isPresented: $showingSecondarySheet) {
            SelectStock(currentDate: currentDate, stocks: stocks) { selected in
                secondaryStock = selected
                showingSecondarySheet = false
            }
        }
    }
}
#Preview {
    let primaryStock = Stock(
        symbol: "AAPL",
        name: "Apple Inc.",
        priceHistory: [
            PriceHistory(timestamp: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, price: 178.50),
            PriceHistory(timestamp: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, price: 182.30),
            PriceHistory(timestamp: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, price: 179.90),
            PriceHistory(timestamp: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, price: 185.10),
            PriceHistory(timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, price: 188.75),
            PriceHistory(timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, price: 191.20),
            PriceHistory(timestamp: Date(), price: 195.60),
        ]
    )

    let secondaryStock = Stock(
        symbol: "TSLA",
        name: "Tesla Inc.",
        priceHistory: [
            PriceHistory(timestamp: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, price: 245.00),
            PriceHistory(timestamp: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, price: 238.50),
            PriceHistory(timestamp: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, price: 242.10),
            PriceHistory(timestamp: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, price: 230.80),
            PriceHistory(timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, price: 225.40),
            PriceHistory(timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, price: 219.90),
            PriceHistory(timestamp: Date(), price: 212.30),
        ]
    )

    let allStocks: [Stock] = [primaryStock, secondaryStock,
        .init(symbol: "MSFT", name: "Microsoft Corporation"),
        .init(symbol: "NVDA", name: "NVIDIA Corporation"),
    ]

    let news: [News] = [
        News(stock: primaryStock, source: "TechCrunch", headline: "Apple Q3 2023 results", desc: "Apple reported strong Q3 2023 results."),
        News(stock: secondaryStock, source: "Djaruma Foundation", headline: "Tesla Q4 2023 earnings", desc: "Tesla reported robust Q4 2023 earnings.")
    ]

    InsightsView(
        stocks: allStocks,
        news: news,
        currentDate: Date.now
    )
}
