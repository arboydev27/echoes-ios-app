import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Base Colors
    static let neoBackground = Color(hex: "#FDF8F2") // Warm cream
    static let neoCharcoal = Color(hex: "#1A1A1A")   // Deep charcoal
    static let neoPrimary = Color(hex: "#FF8A70")     // Coral primary
    
    // Category Colors
    static let neoMint = Color(hex: "#B8E6D6")
    static let neoLilac = Color(hex: "#DCD6F7")
    static let neoMustard = Color(hex: "#FFD166")
    static let neoRose = Color(hex: "#F2D3CD")
    static let neoBlueSky = Color(hex: "#D3E5EF")
    static let neoSage = Color(hex: "#D4E0D9")
    static let neoMaize = Color(hex: "#FEF3C7")
}

extension View {
    func neoRetroFont(size: CGFloat, weight: Font.Weight = .regular, isSerif: Bool = false) -> some View {
        // Fallbacks standard fonts since we might not have custom fonts loaded
        self.font(.system(size: size, weight: weight, design: isSerif ? .serif : .default))
    }
}
