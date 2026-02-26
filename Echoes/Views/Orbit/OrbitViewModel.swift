import SwiftUI
import SwiftData

@Observable
class OrbitViewModel {
    var totalMemories: Int = 0
    var totalHours: Double = 0
    var currentStreak: Int = 0
    var topicMix: [String: Int] = [:]
    
    // We can calculate stats from a given array of EchoCards
    func calculateStats(from cards: [EchoCard]) {
        totalMemories = cards.count
        // Mock 1.5 hours per memory card for now
        totalHours = Double(cards.count) * 1.5
        
        // Topic Mix
        var mix: [String: Int] = [:]
        for card in cards {
            mix[card.category, default: 0] += 1
        }
        topicMix = mix
        
        // Streak (consecutive weeks)
        // Simplified mock: just using 7 weeks for now if not empty
        currentStreak = cards.isEmpty ? 0 : 7 // mock 7 weeks
    }
    
    // Helper to get mostly used category
    var topCategory: String? {
        topicMix.max { a, b in a.value < b.value }?.key
    }
    
    // Helper to get least used category
    var leastCategory: String? {
        let allCategories = ["Childhood", "Romance", "Travel", "Family", "Home"]
        for cat in allCategories {
            if topicMix[cat] == nil {
                return cat
            }
        }
        return topicMix.min { a, b in a.value < b.value }?.key
    }
}
