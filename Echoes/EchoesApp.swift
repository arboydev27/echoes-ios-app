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
            Echo.self, SpeakerProfile.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Seed sample data on first launch for judges/showcase
            let hasSeededData = UserDefaults.standard.bool(forKey: "hasSeededSampleData")
            
            if !hasSeededData {
                Task { @MainActor in
                    do {
                        let sample1 = Echo(dateRecorded: Date().addingTimeInterval(-86400 * 1), title: "First Date at the Diner", speakerName: "Grandpa Ben", promptText: "Tell the story of how you and your partner met.", duration: 210, transcript: "Oh goodness, our first date. He picked me up in that beat-up old Chevy. I was so nervous my hands were shaking. We went to that diner on 4th street, the one with the red vinyl booths. He ordered a strawberry milkshake with two straws, and when he smiled at me, I just knew. I knew he was the one. We stayed there talking until they turned off the open sign.", themeTag: "Romance", joyPins: [22.1, 85.3, 150.2, 185.0], audioFilename: "mock.m4a", coverImageFilename: "dummy_image_1", isFavorite: true)
                        let sample2 = Echo(dateRecorded: Date().addingTimeInterval(-86400 * 3), title: "The Summer of '65", speakerName: "Uncle Jim", promptText: "What is your favorite childhood memory?", duration: 145, transcript: "I remember the summer of 1965 like it was yesterday. The sun was always shining, and my brother and I would ride our bikes down to the creek every single afternoon. We didn't have much money, but we had an absolute blast catching frogs and building tiny little dams out of mud and twigs. Best summer of my life.", themeTag: "Childhood", joyPins: [12.5, 45.2, 89.0, 112.4], audioFilename: "mock.m4a", coverImageFilename: "dummy_image_2")
                        let sample3 = Echo(dateRecorded: Date().addingTimeInterval(-86400 * 7), title: "Grandpa's Advice", speakerName: "Mom", promptText: "What is the best piece of advice you've ever received?", duration: 95, transcript: "My grandfather used to tell me, 'Don't borrow tomorrow's troubles today.' Whenever I get stressed about the future, I think of him sitting on his porch, whittling a piece of cedar, looking completely at peace. It reminds me to just breathe and focus on the step right in front of me.", themeTag: "Wisdom", joyPins: [15.4, 60.1, 82.5], audioFilename: "mock.m4a", coverImageFilename: "dummy_image_3")
                        let sample4 = Echo(dateRecorded: Date().addingTimeInterval(-86400 * 12), title: "The Holiday Cabin", speakerName: "Aunt Lyssa", promptText: "What is a tradition you love?", duration: 180, transcript: "Every December, the whole family crams into that tiny cabin up in the mountains. It's always freezing cold, the heater barely works, and the Wi-Fi is non-existent. But that's the magic of it. We play board games by the fire, drink hot cocoa, and actually talk to each other without staring at our phones. It's chaotic, loud, and absolutely perfect.", themeTag: "Family", joyPins: [45.0, 92.5, 130.1, 165.8], audioFilename: "mock.m4a", coverImageFilename: "dummy_image_4", isFavorite: true)
                        let sample5 = Echo(dateRecorded: Date().addingTimeInterval(-86400 * 20), title: "College Road Trip", speakerName: "Dad", promptText: "Tell me about an adventure you took.", duration: 245, transcript: "Three days. Two best friends. One terrible map. We decided to drive from Texas to California for spring break. We got a flat tire in the middle of nowhere, New Mexico. Instead of panicking, we ended up stargazing on the hood of the car while waiting for a tow. It was the brightest I've ever seen the Milky Way.", themeTag: "Travel", joyPins: [55.2, 110.4, 195.0, 220.1], audioFilename: "mock.m4a", coverImageFilename: "dummy_image_5")
                        let sample6 = Echo(dateRecorded: Date().addingTimeInterval(-86400 * 35), title: "Learning to Ride", speakerName: "Sarah", promptText: "What was a defining moment growing up?", duration: 85, transcript: "I fell off that bike at least twenty times. My knees were so scraped up, I thought my Dad was going to throw the bike away. But my dad just kept picking me back up. 'One more try,' he said. When I finally found my balance and pedaled down the block by myself, the feeling of freedom was unbelievable.", themeTag: "Childhood", joyPins: [30.5, 75.0], audioFilename: "mock.m4a", coverImageFilename: "dummy_image_6")
                        let sample7 = Echo(dateRecorded: Date().addingTimeInterval(-86400 * 40), title: "The New Puppy", speakerName: "Grandma Rose", promptText: "Describe a moment of pure joy.", duration: 120, transcript: "The box was shaking when they brought it in. We opened the flaps, and this tiny golden retriever puppy practically launched herself into my arms. She licked my entire face within three seconds. We named her Daisy, and from that day on, she slept at the foot of my bed every single night.", themeTag: "Home", joyPins: [10.1, 40.5, 88.3, 115.0], audioFilename: "mock.m4a", coverImageFilename: "dummy_image_7", isFavorite: true)
                        
                        container.mainContext.insert(sample1)
                        container.mainContext.insert(sample2)
                        container.mainContext.insert(sample3)
                        container.mainContext.insert(sample4)
                        container.mainContext.insert(sample5)
                        container.mainContext.insert(sample6)
                        container.mainContext.insert(sample7)
                        
                        try container.mainContext.save()
                        
                        // Seed Speaker Profiles
                        let youProfile = SpeakerProfile(name: "You", avatarFilename: StorageManager.shared.seedAvatar(fromAssetName: "you-image"))
                        let grandpaBen = SpeakerProfile(name: "Grandpa Ben", avatarFilename: StorageManager.shared.seedAvatar(fromAssetName: "seed_profile_1"))
                        let uncleJim = SpeakerProfile(name: "Uncle Jim", avatarFilename: StorageManager.shared.seedAvatar(fromAssetName: "seed_profile_2"))
                        let mom = SpeakerProfile(name: "Mom", avatarFilename: StorageManager.shared.seedAvatar(fromAssetName: "seed_profile_3"))
                        let auntLyssa = SpeakerProfile(name: "Aunt Lyssa", avatarFilename: StorageManager.shared.seedAvatar(fromAssetName: "seed_profile_4"))
                        let dad = SpeakerProfile(name: "Dad", avatarFilename: StorageManager.shared.seedAvatar(fromAssetName: "seed_profile_5"))
                        let sarah = SpeakerProfile(name: "Sarah", avatarFilename: StorageManager.shared.seedAvatar(fromAssetName: "seed_profile_6"))
                        let grandmaRose = SpeakerProfile(name: "Grandma Rose", avatarFilename: StorageManager.shared.seedAvatar(fromAssetName: "seed_profile_7"))
                        
                        container.mainContext.insert(youProfile)
                        container.mainContext.insert(grandpaBen)
                        container.mainContext.insert(uncleJim)
                        container.mainContext.insert(mom)
                        container.mainContext.insert(auntLyssa)
                        container.mainContext.insert(dad)
                        container.mainContext.insert(sarah)
                        container.mainContext.insert(grandmaRose)
                        
                        try container.mainContext.save()
                        UserDefaults.standard.set(true, forKey: "hasSeededSampleData")
                    } catch {
                        print("Failed to seed sample data: \(error)")
                    }
                }
            }
            
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
