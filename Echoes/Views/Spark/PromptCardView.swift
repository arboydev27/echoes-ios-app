import SwiftUI

struct PromptCardView: View {
    let prompt: Prompt
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .top) {
                Text(prompt.category.uppercased())
                    .font(.system(size: 10, weight: .heavy))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.neoCharcoal.opacity(0.2), lineWidth: 1)
                    )
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "bookmark")
                        .font(.title3)
                        .foregroundColor(.neoCharcoal)
                }
            }
            .padding(20)
            
            // Content
            VStack(spacing: 16) {
                Image(systemName: prompt.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.neoCharcoal.opacity(0.8))
                
                Text(prompt.text)
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundColor(.neoCharcoal)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                Text(prompt.subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.neoCharcoal.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Footer Image/Actions
            ZStack(alignment: .bottom) {
                // Background image equivalent
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 100)
                    .overlay(
                        Image(systemName: "photo.fill")
                            .font(.largeTitle)
                            .foregroundColor(.black.opacity(0.05))
                    )
                
                // Gradient Overlay
                LinearGradient(gradient: Gradient(colors: [.white, .white.opacity(0.8), .clear]), startPoint: .bottom, endPoint: .top)
                    .frame(height: 100)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.point.left.fill")
                        Text("SKIP")
                            .font(.system(size: 12, weight: .bold))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("SAVE")
                            .font(.system(size: 12, weight: .bold))
                        Image(systemName: "hand.point.right.fill")
                    }
                }
                .foregroundColor(.neoCharcoal.opacity(0.5))
                .padding(.horizontal, 32)
                .padding(.bottom, 20)
            }
            .frame(height: 100)
            .border(Color.neoCharcoal, width: 2)
        }
        .background(Color(hex: prompt.colorHex))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.neoCharcoal, lineWidth: 2)
        )
        .shadow(color: .neoCharcoal, radius: 0, x: 4, y: 4)
        .aspectRatio(4/5, contentMode: .fit)
    }
}
