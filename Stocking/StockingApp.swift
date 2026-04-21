//
//  StockingApp.swift
//  Stocking
//
//  Created by Heryan Djaruma on 17/04/26.
//

import SwiftUI
import SwiftData

@main
struct StockingApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserStockingData.self,
            EquityHistory.self,
            GlobalConfig.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    /// Run seeds
    init() {
        seedEquityHistoryIfNeeded(context: sharedModelContainer.mainContext)
        seedGlobalConfigIfNeeded(context: sharedModelContainer.mainContext)
        seedBalanceIfNeeded(context: sharedModelContainer.mainContext)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Some initials data

/// GLOBAL CONFIG
func seedGlobalConfigIfNeeded(context: ModelContext) {
    let existing = try? context.fetch(FetchDescriptor<GlobalConfig>())
    guard existing?.isEmpty == true else { return }
    
    /// CURRENT DATE
    /// Define config date as today
    let currentDateConfig = GlobalConfig(key: "currentDate", dateValue: Date.now)
    context.insert(currentDateConfig)
}

/// EQUITY (balance)
struct EquityHistoryJSON: Codable {
    let totalEquity: Double
    let timestamp: Date
}
func seedEquityHistoryIfNeeded(context: ModelContext) {
    let existing = try? context.fetch(FetchDescriptor<EquityHistory>())
    guard existing?.isEmpty == true else { return }
    
    let url = Bundle.main.url(forResource: "equityHistory", withExtension: "json")!
    let data = try! Data(contentsOf: url)
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let records = try! decoder.decode([EquityHistoryJSON].self, from: data)

    for record in records {
        context.insert(EquityHistory(totalEquity: record.totalEquity, timestamp: record.timestamp))
    }

    try! context.save()
}

/// INITIAL BALANCE
func seedBalanceIfNeeded(context: ModelContext) {
    let existing = try? context.fetch(FetchDescriptor<UserStockingData>())
    guard existing?.isEmpty == true else { return }
    
    let defaultUser = UserStockingData(totalEquity: 100.0, tradeableBalance: 100.0, investedBalance: 0.0)
    context.insert(defaultUser)
}
