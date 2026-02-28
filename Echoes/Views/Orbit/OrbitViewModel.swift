import SwiftUI
import SwiftData

@Observable
class OrbitViewModel {
    var totalMemories: Int = 0
    var totalHours: Double = 0
    var currentStreak: Int = 0
    var topicMix: [String: Int] = [:]
    var uniqueSpeakers: [(name: String, profile: SpeakerProfile?)] = []
    
    // Calculate stats from a given array of Echo objects
    func calculateStats(from cards: [Echo], profiles: [SpeakerProfile]) {
        totalMemories = cards.count
        
        // Sum total seconds and convert to hours
        let totalSeconds = cards.reduce(0.0) { $0 + $1.duration }
        totalHours = totalSeconds / 3600.0
        
        // Topic Mix
        var mix: [String: Int] = [:]
        for card in cards {
            mix[card.themeTag, default: 0] += 1
        }
        topicMix = mix
        
        // Extract unique speakers (ignoring empty strings) and match with profiles
        let speakers = Set(cards.map(\.speakerName).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty })
        let sortedNames = Array(speakers).sorted()
        
        uniqueSpeakers = sortedNames.map { name in
            (name: name, profile: profiles.first(where: { $0.name == name }))
        }
        
        // Streak (consecutive weeks)
        currentStreak = calculateConsecutiveWeeks(from: cards.map(\.dateRecorded))
    }
    
    private func calculateConsecutiveWeeks(from dates: [Date]) -> Int {
        guard !dates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Get unique year/week pairs
        var weekIdentifiers: [Int] = []
        for date in dates {
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            if let y = components.yearForWeekOfYear, let w = components.weekOfYear {
                let id = y * 100 + w
                if !weekIdentifiers.contains(id) {
                    weekIdentifiers.append(id)
                }
            }
        }
        
        weekIdentifiers.sort(by: >)
        guard !weekIdentifiers.isEmpty else { return 0 }
        
        var streak = 0
        var checkDate = now
        
        // Check if there is an entry for this week
        let currentComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        let currentId = (currentComponents.yearForWeekOfYear ?? 0) * 100 + (currentComponents.weekOfYear ?? 0)
        
        if weekIdentifiers.first == currentId {
            // They have an entry this week, start counting from this week backwards
        } else {
            // Maybe they haven't recorded THIS week yet. Try last week.
            guard let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: now) else { return 0 }
            let lastWeekComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: lastWeek)
            let lastWeekId = (lastWeekComponents.yearForWeekOfYear ?? 0) * 100 + (lastWeekComponents.weekOfYear ?? 0)
            
            if weekIdentifiers.first == lastWeekId {
                // Streak is active from last week
                checkDate = lastWeek
            } else {
                // Streak broken
                return 0
            }
        }
        
        // Count backwards
        for _ in 0..<5200 { // Arbitrary safe limit (100 years)
            let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: checkDate)
            let id = (comps.yearForWeekOfYear ?? 0) * 100 + (comps.weekOfYear ?? 0)
            
            if weekIdentifiers.contains(id) {
                streak += 1
                guard let prev = calendar.date(byAdding: .weekOfYear, value: -1, to: checkDate) else { break }
                checkDate = prev
            } else {
                break
            }
        }
        
        return streak
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
