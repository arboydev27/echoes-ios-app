import Foundation
import SwiftData

@Model
final class MemoryCard {
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
        case "childhood": return "#F2D3CD" // Rose
        case "romance": return "#DCD6F7"   // Lilac
        case "travel": return "#D3E5EF"    // Blue-Sky
        case "family": return "#D4E0D9"    // Sage
        case "home": return "#FEF3C7"      // Maize
        default: return "#B8E6D6"          // Mint
        }
    }
}
