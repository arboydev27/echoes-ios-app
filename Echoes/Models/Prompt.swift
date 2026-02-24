import Foundation

struct Prompt: Identifiable {
    let id = UUID()
    let text: String
    let subtitle: String
    let category: String
    let icon: String
    var colorHex: String
}

extension Prompt {
    static let samples: [Prompt] = [
        Prompt(text: "What was the first car you ever owned?",
               subtitle: "Think about the model, the color, and who you bought it from.",
               category: "Childhood", icon: "car.fill", colorHex: "#b8e6d6"), // Mint
        Prompt(text: "What was the most rebellious thing you did?",
               subtitle: "Did you ever get caught?",
               category: "Lessons", icon: "flame.fill", colorHex: "#dcd6f7"), // Lilac
        Prompt(text: "Tell me about the day you met Mom.",
               subtitle: "Where were you? What did she say?",
               category: "Love & Dating", icon: "heart.fill", colorHex: "#f4e06d"), // Mustard
        Prompt(text: "What was your hardest lesson?",
               subtitle: "How did you overcome it?",
               category: "Hardship", icon: "bolt.fill", colorHex: "#b8e6d6") // Mint (cycled)
    ]
}
