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
                            
                        }) {
                            Text("Add Balance")
                                .bold()
                        }
                        .buttonStyle(.glass)
                        .padding()
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
                            .foregroundStyle(.green)
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
        EquityHistory(totalEquity: 200.0, timestamp: Calendar.current.date(byAdding: .day, value: 0, to: Date())!),
        EquityHistory(totalEquity: 103.0, timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!),
        EquityHistory(totalEquity: 104.0, timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!),
        EquityHistory(totalEquity: 105.0, timestamp: Calendar.current.date(byAdding: .day, value: -3, to: Date())!),
        EquityHistory(totalEquity: 106.0, timestamp: Calendar.current.date(byAdding: .day, value: -4, to: Date())!),
        EquityHistory(totalEquity: 108.0, timestamp: Calendar.current.date(byAdding: .day, value: -5, to: Date())!),
    ]
        .sorted { $0.timestamp < $1.timestamp }
    
    WalletView(userData: userData, equityHistory: previewEquityHistory)
}
