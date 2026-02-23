import SwiftUI

struct NeoRetroCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var backgroundColor: Color = .white
    
    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.neoCharcoal, lineWidth: 2)
            )
            .shadow(color: Color.neoCharcoal, radius: 0, x: 4, y: 4)
    }
}

extension View {
    func neoRetroCard(cornerRadius: CGFloat = 16, backgroundColor: Color = .white) -> some View {
        self.modifier(NeoRetroCardModifier(cornerRadius: cornerRadius, backgroundColor: backgroundColor))
    }
}
