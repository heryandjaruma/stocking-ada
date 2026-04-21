//
//  HomeScreen.swift
//  Stocking
//
//  Created by Heryan Djaruma on 20/04/26.
//

import SwiftUI
import SwiftData

struct HomeScreen: View {
    
    @Environment(\.modelContext) private var modelContext
    
    /// Get current date from local SwiftDate
    @Query(filter: #Predicate<GlobalConfig> { config in
        config.key == "currentDate"
    })
    private var configs: [GlobalConfig]
    var currentDateConfig: GlobalConfig? { configs.first }
    
    /// Get all stocks
    @Query var stocks: [Stock]
    
    var body: some View {
        HomeView(currentDate: currentDateConfig?.dateValue ?? Date.now, stocks: stocks,
                 onForwardDay: {
            guard let config = currentDateConfig else { return }
            config.dateValue = Calendar.current.date(byAdding: .day, value: 1, to: config.dateValue!)!
            try? modelContext.save()
        })
    }
}
