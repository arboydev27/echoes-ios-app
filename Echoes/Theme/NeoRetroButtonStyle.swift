import SwiftUI

struct NeoRetroButtonStyle: ButtonStyle {
    var backgroundColor: Color = .neoPrimary
    var foregroundColor: Color = .neoCharcoal
    var cornerRadius: CGFloat = 999
    var borderWidth: CGFloat = 2
    var shadowOffset: CGFloat = 4
    var isPaddingEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(foregroundColor)
            .padding(.horizontal, isPaddingEnabled ? 20 : 0)
            .padding(.vertical, isPaddingEnabled ? 12 : 0)
            .background(
                ZStack {
                    // Shadow layer
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.neoCharcoal)
                        .offset(x: configuration.isPressed ? 0 : shadowOffset,
                                y: configuration.isPressed ? 0 : shadowOffset)
                    
                    // Main background layer
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(backgroundColor)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.neoCharcoal, lineWidth: borderWidth)
            )
            .offset(x: configuration.isPressed ? shadowOffset : 0,
                    y: configuration.isPressed ? shadowOffset : 0)
            .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct NeoRetroIconButtonStyle: ButtonStyle {
    var backgroundColor: Color = .white
    var foregroundColor: Color = .neoCharcoal
    var size: CGFloat = 40
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(foregroundColor)
            .frame(width: size, height: size)
            .background(
                ZStack {
                    // Shadow layer
                    Circle()
                        .fill(Color.neoCharcoal)
                        .offset(x: configuration.isPressed ? 0 : 2,
                                y: configuration.isPressed ? 0 : 2)
                    
                    // Main background layer
                    Circle()
                        .fill(backgroundColor)
                }
            )
            .overlay(
                Circle()
                    .stroke(Color.neoCharcoal, lineWidth: 2)
            )
            .offset(x: configuration.isPressed ? 2 : 0,
                    y: configuration.isPressed ? 2 : 0)
            .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
