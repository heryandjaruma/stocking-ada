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
        Text("Hello Stocking")
    }

}

#Preview {
    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
}
