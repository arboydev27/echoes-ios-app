import SwiftUI
import SwiftData

@Observable
class OrbitViewModel {
    var totalMemories: Int = 0
    var totalHours: Double = 0
    var currentStreak: Int = 0
    var topicMix: [String: Int] = [:]
    
    // We can calculate stats from a given array of Echo objects
    func calculateStats(from cards: [Echo]) {
        totalMemories = cards.count
        // Mock 1.5 hours per memory card for now
        totalHours = Double(cards.count) * 1.5
        
        // Topic Mix
        var mix: [String: Int] = [:]
        for card in cards {
            mix[card.themeTag, default: 0] += 1
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
        let allCategories = ThemeCategory.allCases.map { $0.rawValue }
        for cat in allCategories {
            if topicMix[cat] == nil {
                return cat
            }
        }
        return topicMix.min { a, b in a.value < b.value }?.key
    }
}
