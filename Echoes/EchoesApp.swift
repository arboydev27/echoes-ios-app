//
//  EchoesApp.swift
//  Echoes
//
//  Created by Arboy Magomba on 2/23/26.
//

import SwiftUI
import SwiftData

@main
struct EchoesApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MemoryCard.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            #if DEBUG
            // Synchronous deep wipe and reset for debugging
            Task { @MainActor in
                do {
                    try container.mainContext.delete(model: MemoryCard.self)
                    
                    let sample1 = MemoryCard(title: "The Summer of '65", category: "Childhood", imageName: "dummy_image_1")
                    let sample2 = MemoryCard(title: "First Date at the Diner", category: "Romance", imageName: "dummy_image_2")
                    let sample3 = MemoryCard(title: "Trip to Paris 1980", category: "Travel", imageName: "dummy_image_3")
                    let sample4 = MemoryCard(title: "Holiday at the Cabin", category: "Family", imageName: "dummy_image_4")
                    
                    container.mainContext.insert(sample1)
                    container.mainContext.insert(sample2)
                    container.mainContext.insert(sample3)
                    container.mainContext.insert(sample4)
                    
                    try container.mainContext.save()
                } catch {
                    print("Failed to seed debug data: \(error)")
                }
            }
            #endif
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
