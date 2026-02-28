import Foundation

struct Prompt: Identifiable {
    let id = UUID()
    let text: String
    let subtitle: String
    let category: String
    let icon: String
    var colorHex: String
    var isSaved: Bool = false
}

extension Prompt {
    static let samples: [Prompt] = [
        Prompt(text: "What was the first car you ever owned?",
               subtitle: "Think about the model, the color, and who you bought it from.",
               category: ThemeCategory.childhood.rawValue, icon: ThemeCategory.childhood.icon, colorHex: "#b8e6d6"), // Mint
        Prompt(text: "What was the most rebellious thing you did?",
               subtitle: "Did you ever get caught?",
               category: ThemeCategory.lessons.rawValue, icon: ThemeCategory.lessons.icon, colorHex: "#dcd6f7"), // Lilac
        Prompt(text: "Tell me about the day you met Mom.",
               subtitle: "Where were you? What did she say?",
               category: ThemeCategory.romance.rawValue, icon: ThemeCategory.romance.icon, colorHex: "#f4e06d"), // Mustard
        Prompt(text: "What was your hardest lesson?",
               subtitle: "How did you overcome it?",
               category: ThemeCategory.lessons.rawValue, icon: ThemeCategory.lessons.icon, colorHex: "#b8e6d6") // Mint (cycled)
    ]
}
