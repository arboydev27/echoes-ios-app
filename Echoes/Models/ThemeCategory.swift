import Foundation

enum ThemeCategory: String, CaseIterable, Identifiable {
    case childhood = "Childhood"
    case romance = "Romance"
    case family = "Family"
    case travel = "Travel"
    case home = "Home"
    case lessons = "Lessons"
    case wisdom = "Wisdom"
    case work = "Work"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .childhood: return "figure.child"
        case .romance: return "heart.fill"
        case .family: return "person.2.fill"
        case .travel: return "airplane"
        case .home: return "house.fill"
        case .lessons: return "book.fill"
        case .wisdom: return "lightbulb.fill"
        case .work: return "briefcase.fill"
        }
    }
    
    var colorHex: String {
        switch self {
        case .childhood: return "#FFB067" // Tangerine
        case .romance: return "#FF9CEE"   // Bubblegum
        case .family: return "#A4C3A2"    // Sage
        case .travel: return "#90E0EF"    // Turquoise
        case .home: return "#FFB067"      // Tangerine
        case .lessons: return "#dcd6f7"   // Lilac
        case .wisdom: return "#B8A7EA"    // Lavender
        case .work: return "#90E0EF"      // Turquoise
        }
    }
}
