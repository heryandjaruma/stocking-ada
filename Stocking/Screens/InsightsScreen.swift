//
//  InsightsScreen.swift
//  Stocking
//
//  Created by Agustinus Juan Kurniawan on 21/04/26.
//

import SwiftData
import SwiftUI

import SwiftData
import SwiftUI

struct InsightsScreen: View {

    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<GlobalConfig> { config in
            config.key == "currentDate"
        }
    )
    private var configs: [GlobalConfig]

    var currentDateConfig: GlobalConfig? { configs.first }

    @Query var stocks: [Stock]
    @Query var news: [News]

    var body: some View {
        InsightsView(
            stocks: stocks,
            news: news,
            currentDate: currentDateConfig?.dateValue ?? Date.now,
            onForwardDay: {
                guard let config = currentDateConfig else { return }
                config.dateValue = Calendar.current.date(
                    byAdding: .day,
                    value: 1,
                    to: config.dateValue!
                )!
                try? modelContext.save()
            }
        )
    }
}
