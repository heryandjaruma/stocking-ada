//
//  StockingApp.swift
//  Stocking
//
//  Created by Heryan Djaruma on 17/04/26.
//

import SwiftData
import SwiftUI

@main
struct StockingApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GlobalConfig.self,
            UserStockingData.self,
            EquityHistory.self,
            Stock.self,
            PriceHistory.self,
            News.self,
            Order.self,
            OwnedStock.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
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
        seedNewsIfNeeded(context: sharedModelContainer.mainContext)
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
        let currentDateConfig = GlobalConfig(
            key: "currentDate",
            dateValue: Date.now
        )
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

        let url = Bundle.main.url(
            forResource: "equityHistory",
            withExtension: "json"
        )!
        let data = try! Data(contentsOf: url)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let records = try! decoder.decode([EquityHistoryJSON].self, from: data)

        for record in records {
            context.insert(
                EquityHistory(
                    totalEquity: record.totalEquity,
                    timestamp: record.timestamp
                )
            )
        }

        try! context.save()
    }

    /// INITIAL BALANCE
    func seedBalanceIfNeeded(context: ModelContext) {
        let existing = try? context.fetch(FetchDescriptor<UserStockingData>())
        guard existing?.isEmpty == true else { return }

        let defaultUser = UserStockingData(
            totalEquity: 10_000.0,
            tradeableBalance: 10_000.0,
            investedBalance: 0.0
        )
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
                let ph = PriceHistory(
                    timestamp: recordPH.timestamp,
                    price: recordPH.price
                )
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

    func seedNewsIfNeeded(context: ModelContext) {
        let existing = try? context.fetch(FetchDescriptor<News>())
        guard existing?.isEmpty == true else { return }

        let stocks = (try? context.fetch(FetchDescriptor<Stock>())) ?? []

        func find(_ symbol: String) -> Stock {
            stocks.first(where: { $0.symbol == symbol })!
        }

        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2026
        components.month = 4
        components.day = 29
        let baseDate = Calendar.current.date(from: components)!

        let d1 = baseDate
        let d2 = calendar.date(byAdding: .day, value: 1, to: baseDate)!
        let d3 = calendar.date(byAdding: .day, value: 2, to: baseDate)!

        let newsList: [News] = [

            // AAPL
            News(
                stock: find("AAPL"),
                source: "Bloomberg",
                headline: "Apple Gains as Supply Chain Pressures Ease",
                desc:
                    "Shares moved higher as easing component constraints supported momentum.",
                published: d1
            ),
            News(
                stock: find("AAPL"),
                source: "Reuters",
                headline: "Apple Edges Up Ahead of Product Cycle",
                desc: "Investors positioned ahead of upcoming launches.",
                published: d2
            ),
            News(
                stock: find("AAPL"),
                source: "CNBC",
                headline: "Apple Extends Gains on Services Strength",
                desc: "Continued growth in services drove further upside.",
                published: d3
            ),

            // GOOG
            News(
                stock: find("GOOG"),
                source: "Reuters",
                headline: "Alphabet Slides on Ad Slowdown Fears",
                desc: "Concerns over weaker ad demand pressured shares.",
                published: d1
            ),
            News(
                stock: find("GOOG"),
                source: "Bloomberg",
                headline: "Alphabet Drops Amid AI Competition",
                desc: "Rising competition weighed on sentiment.",
                published: d2
            ),
            News(
                stock: find("GOOG"),
                source: "Financial Times",
                headline: "Alphabet Extends Losses Despite Stability",
                desc: "Valuation concerns drove continued decline.",
                published: d3
            ),

            // META
            News(
                stock: find("META"),
                source: "CNBC",
                headline: "Meta Falls on Rising Costs",
                desc: "Heavy AI investments impacted margins.",
                published: d1
            ),
            News(
                stock: find("META"),
                source: "Reuters",
                headline: "Meta Slips as Spending Rises",
                desc: "Investor concerns deepened over expenses.",
                published: d2
            ),
            News(
                stock: find("META"),
                source: "Bloomberg",
                headline: "Meta Extends Decline on Profit Pressure",
                desc: "Profitability concerns drove further losses.",
                published: d3
            ),

            // MSFT
            News(
                stock: find("MSFT"),
                source: "Financial Times",
                headline: "Microsoft Pulls Back on Valuation",
                desc: "High valuation triggered selling pressure.",
                published: d1
            ),
            News(
                stock: find("MSFT"),
                source: "Reuters",
                headline: "Microsoft Slides Despite Cloud Growth",
                desc: "Profit-taking offset strong fundamentals.",
                published: d2
            ),
            News(
                stock: find("MSFT"),
                source: "Bloomberg",
                headline: "Microsoft Continues Downtrend",
                desc: "Sector rotation weighed on tech stocks.",
                published: d3
            ),

            // NFLX
            News(
                stock: find("NFLX"),
                source: "Variety",
                headline: "Netflix Drops on Subscriber Concerns",
                desc: "Growth concerns triggered early decline.",
                published: d1
            ),
            News(
                stock: find("NFLX"),
                source: "Reuters",
                headline: "Netflix Stabilizes After Selloff",
                desc: "Investors reassessed long-term outlook.",
                published: d2
            ),
            News(
                stock: find("NFLX"),
                source: "CNBC",
                headline: "Netflix Rebounds on Content Optimism",
                desc: "Positive outlook on upcoming releases lifted shares.",
                published: d3
            ),

            // NVDA
            News(
                stock: find("NVDA"),
                source: "WSJ",
                headline: "Nvidia Surges on AI Demand",
                desc: "Strong AI demand pushed shares higher.",
                published: d1
            ),
            News(
                stock: find("NVDA"),
                source: "Bloomberg",
                headline: "Nvidia Extends Rally",
                desc: "Momentum continued with strong outlook.",
                published: d2
            ),
            News(
                stock: find("NVDA"),
                source: "Reuters",
                headline: "Nvidia Hits New Highs",
                desc: "Sustained demand drove further gains.",
                published: d3
            ),

            // SAP
            News(
                stock: find("SAP"),
                source: "MarketWatch",
                headline: "SAP Drops on Weak Outlook",
                desc: "Short-term uncertainty impacted shares.",
                published: d1
            ),
            News(
                stock: find("SAP"),
                source: "Reuters",
                headline: "SAP Stabilizes After Losses",
                desc: "Recovery signs emerged as outlook improved.",
                published: d2
            ),
            News(
                stock: find("SAP"),
                source: "Bloomberg",
                headline: "SAP Edges Higher on Cloud Growth",
                desc: "Cloud strategy supported slight rebound.",
                published: d3
            ),

            // TGT
            News(
                stock: find("TGT"),
                source: "Yahoo Finance",
                headline: "Target Gains on Strong Demand",
                desc: "Consumer spending boosted performance.",
                published: d1
            ),
            News(
                stock: find("TGT"),
                source: "CNBC",
                headline: "Target Rallies on Efficiency Gains",
                desc: "Operational improvements lifted sentiment.",
                published: d2
            ),
            News(
                stock: find("TGT"),
                source: "Bloomberg",
                headline: "Target Extends Rally",
                desc: "Momentum continued with strong outlook.",
                published: d3
            ),

            // TSM
            News(
                stock: find("TSM"),
                source: "WSJ",
                headline: "TSMC Climbs on Chip Demand",
                desc: "Recovery in semiconductor demand supported gains.",
                published: d1
            ),
            News(
                stock: find("TSM"),
                source: "Reuters",
                headline: "TSMC Gains on AI Orders",
                desc: "AI-related demand pushed shares higher.",
                published: d2
            ),
            News(
                stock: find("TSM"),
                source: "Bloomberg",
                headline: "TSMC Continues Uptrend",
                desc: "Positive outlook sustained momentum.",
                published: d3
            ),

            // WMT
            News(
                stock: find("WMT"),
                source: "Forbes",
                headline: "Walmart Edges Up as Defensive Play",
                desc: "Investors sought stability amid uncertainty.",
                published: d1
            ),
            News(
                stock: find("WMT"),
                source: "Reuters",
                headline: "Walmart Mixed on Market Rotation",
                desc: "Shifting sentiment caused fluctuations.",
                published: d2
            ),
            News(
                stock: find("WMT"),
                source: "Bloomberg",
                headline: "Walmart Slips After Gains",
                desc: "Minor pullback followed earlier rise.",
                published: d3
            ),
        ]

        for item in newsList {
            context.insert(item)
        }
    }
}
