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
            GlobalConfig.self,
            Stock.self,
            PriceHistory.self
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
        seedStockIfNeeded(context: sharedModelContainer.mainContext)
        seedBalanceIfNeeded(context: sharedModelContainer.mainContext)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
    
    
    // MARK: - Some initials data
    /// GLOBAL CONFIG
    func seedGlobalConfigIfNeeded(context: ModelContext) {
        let existing = try? context.fetch(FetchDescriptor<GlobalConfig>())
        /// Try and catch something
        /// No exclamation mark!
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

    struct StockJSON: Codable {
        let symbol: String
        let name: String
    }
    func seedStockIfNeeded(context: ModelContext) {
        let existing = try? context.fetch(FetchDescriptor<Stock>())
        guard existing?.isEmpty == true else {
            return
        }
        
        let url = Bundle.main.url(forResource: "stock", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let records = try! decoder.decode([StockJSON].self, from: data)

        for recordS in records {
            let tempStock = Stock(symbol: recordS.symbol, name: recordS.name)
            context.insert(tempStock)
            
            let priceHistoryRecords = getPriceHistoryForSymbol(tempStock.symbol)
            for recordPH in priceHistoryRecords {
                let ph = PriceHistory(timestamp: recordPH.timestamp, price: recordPH.price)
                tempStock.priceHistory.append(ph)
            }
        }

        try! context.save()
    }

    struct PriceHistoryJSON: Codable {
        let price: Double
        let timestamp: Date
    }
    func getPriceHistoryForSymbol(_ symbol: String) -> [PriceHistoryJSON] {
        let url = Bundle.main.url(forResource: symbol, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let records = try! decoder.decode([PriceHistoryJSON].self, from: data)
        return records
    }

}
