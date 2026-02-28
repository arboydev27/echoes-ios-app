import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.neoBackground
                .ignoresSafeArea()
            
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                .scaleEffect(isAnimating ? 1.05 : 0.95)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: true)
                    ) {
                        isAnimating = true
                    }
                }
        }
    }
}

#Preview {
    SplashScreenView()
}
