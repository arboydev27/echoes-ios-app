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
    @Attribute(.externalStorage) var imageData: Data?
    var joyPins: [Double]?
    
    init(
        id: UUID = UUID(),
        title: String,
        date: Date = Date(),
        category: String,
        audioFileName: String? = nil,
        transcript: String? = nil,
        location: String? = nil,
        imageName: String? = nil,
        imageData: Data? = nil,
        joyPins: [Double]? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.category = category
        self.audioFileName = audioFileName
        self.transcript = transcript
        self.location = location
        self.imageName = imageName
        self.imageData = imageData
        self.joyPins = joyPins
    }
    
    // Helper to get category color
    @Transient
    var categoryColorHex: String {
        switch category.lowercased() {
        case "childhood": return "#FFB067" // Tangerine
        case "romance": return "#FF9CEE"   // Bubblegum
        case "wisdom": return "#B8A7EA"    // Lavender
        case "work": return "#90E0EF"      // Turquoise
        case "reflection": return "#A4C3A2" // Sage
        case "story": return "#FFD166"     // Yellow
        default: return "#f4e06d"          // Mustard
        }
    }
}
