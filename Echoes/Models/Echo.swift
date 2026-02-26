//
//  Echo.swift
//  Echoes
//

import Foundation
import SwiftData

@Model
final class Echo {
    var id: UUID
    var dateRecorded: Date
    var title: String
    var promptText: String
    var duration: Double
    var transcript: String
    var themeTag: String
    var joyPins: [Double] // Array of TimeIntervals where smiles were detected
    var audioFilename: String // Just the filename, not the full path
    var coverImageFilename: String? // Just the filename, optional
    var isFavorite: Bool
    
    init(
        id: UUID = UUID(),
        dateRecorded: Date = Date(),
        title: String,
        promptText: String,
        duration: Double,
        transcript: String,
        themeTag: String,
        joyPins: [Double] = [],
        audioFilename: String,
        coverImageFilename: String? = nil,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.dateRecorded = dateRecorded
        self.title = title
        self.promptText = promptText
        self.duration = duration
        self.transcript = transcript
        self.themeTag = themeTag
        self.joyPins = joyPins
        self.audioFilename = audioFilename
        self.coverImageFilename = coverImageFilename
        self.isFavorite = isFavorite
    }
    
    // Helper to get category color based on themeTag
    @Transient
    var categoryColorHex: String {
        switch themeTag.lowercased() {
        case "childhood": return "#FFB067" // Tangerine
        case "romance": return "#FF9CEE"   // Bubblegum
        case "wisdom": return "#B8A7EA"    // Lavender
        case "work": return "#90E0EF"      // Turquoise
        case "reflection": return "#A4C3A2" // Sage
        case "story": return "#FFD166"     // Yellow
        case "travel": return "#90E0EF"
        case "family": return "#A4C3A2"
        case "home": return "#FFB067"
        default: return "#f4e06d"          // Mustard
        }
    }
    
    var formattedDuration: String {
        formattedTime(duration)
    }
    
    func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
