import Foundation
import SwiftData

@Model
final class SpeakerProfile {
    @Attribute(.unique) var name: String
    var avatarFilename: String?
    
    init(name: String, avatarFilename: String? = nil) {
        self.name = name
        self.avatarFilename = avatarFilename
    }
}
