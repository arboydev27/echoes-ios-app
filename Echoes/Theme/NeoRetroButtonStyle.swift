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
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.neoCharcoal, lineWidth: borderWidth)
            )
            .shadow(color: configuration.isPressed ? .clear : Color.neoCharcoal,
                    radius: 0,
                    x: configuration.isPressed ? 0 : shadowOffset,
                    y: configuration.isPressed ? 0 : shadowOffset)
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
            .background(backgroundColor)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.neoCharcoal, lineWidth: 2)
            )
            .shadow(color: configuration.isPressed ? .clear : Color.neoCharcoal,
                    radius: 0,
                    x: configuration.isPressed ? 0 : 2,
                    y: configuration.isPressed ? 0 : 2)
            .offset(x: configuration.isPressed ? 2 : 0,
                    y: configuration.isPressed ? 2 : 0)
            .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
