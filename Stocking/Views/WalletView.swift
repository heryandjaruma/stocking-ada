//
//  WalletView.swift
//  Stocking
//
//  Created by Heryan Djaruma on 17/04/26.
//

import SwiftUI
import SwiftData

struct WalletView: View {
    var userData: UserStockingData
    var equityHistory: [EquityHistory]
    
    /// Computed property to convert EquityHistory into ChartDataPoint
    private var chartData: [ChartDataPoint] {
        equityHistory.map { chartDataPoint in
            ChartDataPoint(date: chartDataPoint.timestamp, value: chartDataPoint.totalEquity)
        }
    }
    
    private var gainData: Double {
        let lastEquity = equityHistory.last!.totalEquity
        let firstEquity = equityHistory.first!.totalEquity
        return lastEquity - firstEquity
    }
    
    let columns = [GridItem(.flexible(), alignment: .topLeading),
                   GridItem(.flexible(), alignment: .topLeading)]
    
    /// Balance Sheets
    var onSaveBalance: ((Double) -> Void)? /// callback when saving balance
    @State private var isShowBalanceSheet: Bool = false
    @State private var isShowError: Bool = false
    @State private var currentBalance: String
    @State private var lastBalanceSaved: Double
    
    init(userData: UserStockingData, equityHistory: [EquityHistory], onSaveBalance: ((Double) -> Void)? = nil) {
        self.userData = userData
        self.equityHistory = equityHistory
        _currentBalance = State(initialValue: String(userData.totalEquity)) /// Need to set to state variable in the init()
        lastBalanceSaved = userData.totalEquity
        self.onSaveBalance = onSaveBalance
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    HStack {
                        Text("Wallet")
                            .font(.largeTitle)
                            .bold()
                    }
                    .frame(width: 200, alignment: .leading)
                    Spacer()
                    Button(action: {
                        
                    }) {
                        Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                    }
                    .controlSize(.large)
                    .buttonStyle(.glass)
                }
                
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total Equity")
                                .font(Font.body.bold())
                            Text("$\(userData.totalEquity, specifier: "%.2f")")
                                .font(.headline)
                        }
                        Spacer()
                        Button(action: {
                            isShowBalanceSheet.toggle()
                        }) {
                            Text("Add Balance")
                                .bold()
                        }
                        .buttonStyle(.glass)
                        .padding()
                        .sheet(isPresented: $isShowBalanceSheet) {
                            VStack(alignment: .center, spacing: 20) {
                                HStack {
                                    Spacer()
                                    Button {
                                        currentBalance = String(lastBalanceSaved)
                                        isShowBalanceSheet.toggle()
                                    } label: {
                                        Image(systemName: "xmark")
                                            .frame(width: 44, height: 44)
                                            .glassEffect(in: .circle)
                                    }
                                }
                                Text("Add Balance")
                                    .font(.title3)
                                TextField("Set Balance", text: $currentBalance)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(16)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.black.opacity(0.3), lineWidth: 1)
                                    }
                                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 0)
                                if isShowError {
                                    Text("Value must be a number")
                                        .font(.footnote)
                                        .foregroundStyle(.red)
                                }
                                Button(action: {
                                    /// Do some checkings
                                    if let value = Double(currentBalance) {
                                        print(currentBalance)
                                        onSaveBalance?(value)
                                        lastBalanceSaved = value
                                        isShowError = false
                                        isShowBalanceSheet.toggle()
                                    } else {
                                        isShowError = true
                                    }
                                }) {
                                    Text("Save")
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.glassProminent)
                                Spacer()
                            }
                            .padding()
                            .presentationDetents([.fraction(0.4)]) /// Allow sheet height max 40%
                            .interactiveDismissDisabled() /// Disallow interaction except on close button
                        }
                    }
                }
                
                VStack {
                    PriceChart(data: chartData)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.tertiary, lineWidth: 1)
                )
                
                VStack {
                    HStack {
                        LazyVGrid(columns: columns, spacing: 20.0) {
                            VStack(alignment: .leading) {
                                Text("$\(userData.tradeableBalance, specifier: "%.2f")")
                                    .bold()
                                Text("Trading Balance")
                                    .font(.caption)
                            }
                            VStack(alignment: .leading) {
                                Text("$\(userData.investedBalance, specifier: "%.2f")")
                                    .bold()
                                
                                Text("Invested Balance")
                                    .font(.caption)
                            }
                            
                            VStack(alignment: .leading) {
//                                Text("$\(pnlData, specifier: "%.2f")")
                                Text("$<PnL>")
                                    .bold()
                                Text("PnL")
                                    .font(.caption)
                            }
                            .foregroundStyle(.green)
                            VStack(alignment: .leading) {
                                Text("$\(gainData, specifier: "%.2f")")
                                
                                Text("Gain")
                                    .font(.caption)
                            }
                            .foregroundStyle(gainData > 0 ? .green : (gainData < 0 ? .red : .gray))
                        }
                    }
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.tertiary, lineWidth: 1)
                )
                
                HStack {
                    VStack {
                        Text("Portfolio")
                            .font(.title2)
                            .bold()
                            
                    }
                }
            }
            .padding()
        }
    }
}

private func previewDate(_ offset: Int) -> Date {
    Calendar.current.date(byAdding: .hour, value: offset, to: Date())!
}

#Preview {
    let userData = UserStockingData(totalEquity: 100.0, tradeableBalance: 67.0, investedBalance: 33.0)
    
    /// We can create date shifted fromt today using Calendar.current.date(byAdding: .day, value: -1, to: Date())
    
    let previewEquityHistory = [
        EquityHistory(totalEquity: 202.0, timestamp: Calendar.current.date(byAdding: .day, value: 0, to: Date())!),
        EquityHistory(totalEquity: 103.0, timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!),
        EquityHistory(totalEquity: 104.0, timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!),
        EquityHistory(totalEquity: 105.0, timestamp: Calendar.current.date(byAdding: .day, value: -3, to: Date())!),
        EquityHistory(totalEquity: 106.0, timestamp: Calendar.current.date(byAdding: .day, value: -4, to: Date())!),
        EquityHistory(totalEquity: 204.0, timestamp: Calendar.current.date(byAdding: .day, value: -5, to: Date())!),
    ]
        .sorted { $0.timestamp < $1.timestamp }
    
    WalletView(userData: userData, equityHistory: previewEquityHistory)
}
