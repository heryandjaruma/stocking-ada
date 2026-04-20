//
//  ContentView.swift
//  Stocking
//
//  Created by Heryan Djaruma on 17/04/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                
            }
            Tab("Insights", systemImage: "rectangle.and.text.magnifyingglass") {

            }
            Tab("Wallet", systemImage: "wallet.bifold") {
                WalletScreen()
            }
        }
    }

}

#Preview {
    ContentView()
        .modelContainer(for: UserStockingData.self, inMemory: true)
}
