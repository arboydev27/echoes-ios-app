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
            Echo.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            #if DEBUG
            // Synchronous deep wipe and reset for debugging
            Task { @MainActor in
                do {
                    try container.mainContext.delete(model: Echo.self)
                    
                    let sample1 = Echo(dateRecorded: Date().addingTimeInterval(-86400 * 1), title: "The Summer of '65", promptText: "Mock", duration: 60, transcript: "Mock", themeTag: "Childhood", audioFilename: "mock.m4a", coverImageFilename: "dummy_image_1")
                    let sample2 = Echo(dateRecorded: Date().addingTimeInterval(-86400 * 2), title: "First Date at the Diner", promptText: "Mock", duration: 60, transcript: "Mock", themeTag: "Romance", audioFilename: "mock.m4a", coverImageFilename: "dummy_image_2")
                    let sample3 = Echo(dateRecorded: Date().addingTimeInterval(-86400 * 3), title: "Trip to Paris 1980", promptText: "Mock", duration: 60, transcript: "Mock", themeTag: "Travel", audioFilename: "mock.m4a", coverImageFilename: "dummy_image_3")
                    let sample4 = Echo(dateRecorded: Date().addingTimeInterval(-86400 * 4), title: "Holiday at the Cabin", promptText: "Mock", duration: 60, transcript: "Mock", themeTag: "Family", audioFilename: "mock.m4a", coverImageFilename: "dummy_image_4")
                    let sample5 = Echo(dateRecorded: Date().addingTimeInterval(-86400 * 5), title: "Graduation Day", promptText: "Mock", duration: 60, transcript: "Mock", themeTag: "Childhood", audioFilename: "mock.m4a", coverImageFilename: "dummy_image_5")
                    let sample6 = Echo(dateRecorded: Date().addingTimeInterval(-86400 * 6), title: "New Puppy Arrival", promptText: "Mock", duration: 60, transcript: "Mock", themeTag: "Home", audioFilename: "mock.m4a", coverImageFilename: "dummy_image_6")
                    let sample7 = Echo(dateRecorded: Date().addingTimeInterval(-86400 * 7), title: "Cross Country Roadtrip", promptText: "Mock", duration: 60, transcript: "Mock", themeTag: "Travel", audioFilename: "mock.m4a", coverImageFilename: "dummy_image_7")
                    
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
