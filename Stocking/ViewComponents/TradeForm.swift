import SwiftUI



struct TradeForm: View {
    var stock: Stock
    var currentDate: Date
    
    /// To be passed by parent for transaction error
    @Binding var transactionAlert: TransactionAlert?
    
    @State private var orderSide: OrderSide = .buy
    @State private var orderType: OrderType = .limit
    @State private var price: Double = 260
    @State private var lot: Int = 1
    
    private var expiryOptions = ["Good For Day", "Good Till Canceled"]
    @State private var selectedExpiry = "Good For Day"
    
    // How many lots the user already owns (need to be connected to portfolio)
    var ownedLots: Int = 0
    
    init(stock: Stock, currentDate: Date, ownedLots: Int = 0, onBuyOrSell: ((Order) -> Void)? = nil, transactionAlert: Binding<TransactionAlert?> = .constant(nil)) {
        self.stock = stock
        self.currentDate = currentDate
        self.ownedLots = ownedLots
        self.onBuyOrSell = onBuyOrSell
        self._transactionAlert = transactionAlert
    }
    
    private var actionColor: Color {
        orderSide == .buy ? .green : .red
    }
    
    /// Optional callback
    var onBuyOrSell: ((Order) -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                Text(orderSide == .buy ? "Buy" : "Sell")
                    .font(.title2.bold())
                
                Spacer()
                
                // Buy / Sell toggle
                Picker("Side", selection: $orderSide) {
                    Text("Buy").tag(OrderSide.buy)
                    Text("Sell").tag(OrderSide.sell)
                }
                .pickerStyle(.segmented)
                .frame(width: 110)
                
                Picker("Type", selection: $orderType) {
                    ForEach(OrderType.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
            }
            
            // Owned lots hint
            
            Text("You currently own \(ownedLots) lot\(ownedLots == 1 ? "" : "s")")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            // MARK: Form fields
            VStack(spacing: 0) {
                if orderType == .limit {
                    StepperRow(label: "Price", value: $price, step: 1)
                    Divider().padding(.leading, 16)
                }
                
                IntStepperRow(label: "Lot", value: $lot, step: 1, minimum: 1)
                
                if orderType == .limit {
                    Divider().padding(.leading, 16)
                    ExpiryRow(options: expiryOptions, selected: $selectedExpiry)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
            
            // MARK: Action buttons
            if orderSide == .buy {
                ActionButton(label: "Buy", color: .green) {
                    onBuyOrSell!(
                        Order(
                            timestamp: currentDate,
                            quantity: lot,
                            stockSymbol: stock.symbol,
                            price: price,
                            orderType: orderType.rawValue,
                            side: orderSide.rawValue,
                            status: "Created"
                        )
                    )
                }
            } else {
                HStack(spacing: 12) {
                    ActionButton(label: "Sell", color: .red) {
//                        onBuyOrSell!(
//                            Order(
//                                timestamp: currentDate,
//                                quantity: lot,
//                                price: price,
//                                orderType: orderType.rawValue,
//                                side: orderSide.rawValue
//                            ),
//                        )
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}
private struct StepperRow: View {
    let label: String
    @Binding var value: Double
    var step: Double = 1
    var minimum: Double = 0
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
            Spacer()
            Button { if value - step >= minimum { value -= step } } label: {
                Image(systemName: "minus")
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color(.systemGray5)))
            }
            .buttonStyle(.plain)
            
            Text("\(value)")
                .font(.system(size: 15, weight: .semibold))
                .frame(minWidth: 44, alignment: .center)
            
            Button { value += step } label: {
                Image(systemName: "plus")
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color(.systemGray5)))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

private struct IntStepperRow: View {
    let label: String
    @Binding var value: Int
    var step: Int = 1
    var minimum: Int = 0
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
            Spacer()
            Button { if value - step >= minimum { value -= step } } label: {
                Image(systemName: "minus")
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color(.systemGray5)))
            }
            .buttonStyle(.plain)
            
            Text("\(value)")
                .font(.system(size: 15, weight: .semibold))
                .frame(minWidth: 44, alignment: .center)
            
            Button { value += step } label: {
                Image(systemName: "plus")
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color(.systemGray5)))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

private struct ExpiryRow: View {
    let options: [String]
    @Binding var selected: String
    
    var body: some View {
        HStack {
            Text("Expiry")
                .font(.system(size: 15))
            Spacer()
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selected = option }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selected)
                        .font(.system(size: 14))
                        .foregroundStyle(.primary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

private struct ActionButton: View {
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 12).fill(color))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

private func previewDate(_ offset: Int) -> Date {
    Calendar.current.date(byAdding: .day, value: offset, to: Date())!
}

#Preview {
    ScrollView {
        VStack(spacing: 32) {
            // Buy - Limit
            TradeForm(stock: Stock(
                symbol: "AAPL", name: "Apple Inc.",
                priceHistory: [
                    PriceHistory(timestamp: previewDate(-1), price: 256.00),
                    PriceHistory(timestamp: previewDate(0), price: 259.20),
                ]
            ), currentDate: Date.now, ownedLots: 0)
            
            Divider()
            
            // Sell - with owned lots
            TradeForm(stock: Stock(
                symbol: "AAPL", name: "Apple Inc.",
                priceHistory: [
                    PriceHistory(timestamp: previewDate(-1), price: 256.00),
                    PriceHistory(timestamp: previewDate(0), price: 259.20),
                ]
            ), currentDate: Date.now, ownedLots: 6)
        }
    }
}
