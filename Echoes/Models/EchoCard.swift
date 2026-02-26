import Foundation
import SwiftData

@Model
final class EchoCard {
    var id: UUID
    var title: String
    var date: Date
    var category: String
    var audioFileName: String?
    var transcript: String?
    var location: String?
    var imageName: String?
    
    init(
        id: UUID = UUID(),
        title: String,
        date: Date = Date(),
        category: String,
        audioFileName: String? = nil,
        transcript: String? = nil,
        location: String? = nil,
        imageName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.category = category
        self.audioFileName = audioFileName
        self.transcript = transcript
        self.location = location
        self.imageName = imageName
    }
    
    // Helper to get category color
    @Transient
    var categoryColorHex: String {
        switch category.lowercased() {
        case "childhood": return "#FFB067" // Tangerine
        case "romance": return "#FF9CEE"   // Bubblegum
        case "travel": return "#90E0EF"    // Turquoise
        case "family": return "#D4ED6D"    // Lime
        case "home": return "#f4e06d"      // Mustard
        default: return "#b8e6d6"          // Mint
        }
    }
}
