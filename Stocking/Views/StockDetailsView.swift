import SwiftUI

struct StockDetailsView: View {
    var stock: Stock

    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    private var priceStatus: PriceStatus {
        guard let current = stock.priceHistory.last?.price else {
            return .neutral
        }
        let previous = stock.previousPrice(for: today) ?? current
        if current > previous { return .rising }
        if current < previous { return .falling }
        return .neutral
    }

    var body: some View {
        HStack {

            VStack {
                Text(stock.symbol)
                    .font(.title.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 10)

                Text(stock.name)
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
            }
            Image(systemName: "apple.logo")
                .font(.system(size: 50))
                .padding(.horizontal, 24)
        }

        Spacer()
    }
}

#Preview {
    let neutralStock = Stock(
        symbol: "MSFT",
        name: "Microsoft Corp.",
        priceHistory: [
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -6,
                    to: Date()
                )!,
                price: 415.00
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -5,
                    to: Date()
                )!,
                price: 418.20
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -4,
                    to: Date()
                )!,
                price: 412.80
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -3,
                    to: Date()
                )!,
                price: 416.50
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -2,
                    to: Date()
                )!,
                price: 419.00
            ),
            PriceHistory(
                date: Calendar.current.date(
                    byAdding: .day,
                    value: -1,
                    to: Date()
                )!,
                price: 420.00
            ),
            PriceHistory(date: Date(), price: 420.00),  // same as previous → neutral
        ]
    )

    StockDetailsView(stock: neutralStock)
}
