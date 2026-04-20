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
            EquityHistory.self
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
        seedIfNeeded(context: sharedModelContainer.mainContext)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}


// MARK: - Some initials data

/// EQUITY (balance)
struct EquityHistoryJSON: Codable {
    let totalEquity: Double
    let timestamp: Date
}
func seedIfNeeded(context: ModelContext) {
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
