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
                    Text("Graph")
                        .frame(maxWidth: .infinity, minHeight: 100)
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
    //                            Text("$\(userData.tradeableBalance, specifier: "%.2f")")
                                Text("$<PnL>")
                                    .bold()
                                Text("PnL")
                                    .font(.caption)
                            }
                            .foregroundStyle(.green)
                            VStack(alignment: .leading) {
    //                            Text("$\(userData.investedBalance, specifier: "%.2f")")
                                Text("$<Gain>")
                                    .bold()
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

#Preview {
    var userData = UserStockingData(totalEquity: 100.0, tradeableBalance: 67.0, investedBalance: 33.0)
    
    WalletView(userData: userData)
}
