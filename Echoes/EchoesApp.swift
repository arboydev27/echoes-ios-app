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
            EchoCard.self,
            Echo.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            #if DEBUG
            // Synchronous deep wipe and reset for debugging
            Task { @MainActor in
                do {
                    try container.mainContext.delete(model: EchoCard.self)
                    
                    let sample1 = EchoCard(title: "The Summer of '65", date: Date().addingTimeInterval(-86400 * 1), category: "Childhood", imageName: "dummy_image_1")
                    let sample2 = EchoCard(title: "First Date at the Diner", date: Date().addingTimeInterval(-86400 * 2), category: "Romance", imageName: "dummy_image_2")
                    let sample3 = EchoCard(title: "Trip to Paris 1980", date: Date().addingTimeInterval(-86400 * 3), category: "Travel", imageName: "dummy_image_3")
                    let sample4 = EchoCard(title: "Holiday at the Cabin", date: Date().addingTimeInterval(-86400 * 4), category: "Family", imageName: "dummy_image_4")
                    let sample5 = EchoCard(title: "Graduation Day", date: Date().addingTimeInterval(-86400 * 5), category: "Childhood", imageName: "dummy_image_5")
                    let sample6 = EchoCard(title: "New Puppy Arrival", date: Date().addingTimeInterval(-86400 * 6), category: "Home", imageName: "dummy_image_6")
                    let sample7 = EchoCard(title: "Cross Country Roadtrip", date: Date().addingTimeInterval(-86400 * 7), category: "Travel", imageName: "dummy_image_7")
                    
                    container.mainContext.insert(sample1)
                    container.mainContext.insert(sample2)
                    container.mainContext.insert(sample3)
                    container.mainContext.insert(sample4)
                    container.mainContext.insert(sample5)
                    container.mainContext.insert(sample6)
                    container.mainContext.insert(sample7)
                    
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
