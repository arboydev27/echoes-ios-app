import SwiftUI

struct PromptCardView: View {
    let prompt: Prompt
    var onToggleSave: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .top) {
                Text(prompt.category.uppercased())
                    .font(.system(size: 10, weight: .heavy))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.neoCharcoal.opacity(0.2), lineWidth: 1)
                    )
                
                Spacer()
                
                Button(action: {
                    onToggleSave?()
                }) {
                    Image(systemName: prompt.isSaved ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(prompt.isSaved ? .red : .neoCharcoal)
                }
            }
            .padding(20)
            
            
            Spacer()
            
            // Content (Vertically Centered)
            VStack(spacing: 20) {
                Image(systemName: prompt.icon)
                    .font(.system(size: 48))
                    .foregroundColor(.neoCharcoal.opacity(0.8))
                
                Text(prompt.text)
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(.neoCharcoal)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .minimumScaleFactor(0.8)
                
                Text(prompt.subtitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.neoCharcoal.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            // Floating Action Pills
            HStack {
                // Skip Pill
                Button(action: { /* Handled by drag gesture in parent */ }) {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.point.left.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text("SKIP")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.neoCharcoal.opacity(0.6))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(20)
                }
                
                Spacer()
                
                // Next Pill
                Button(action: { /* Handled by drag gesture in parent */ }) {
                    HStack(spacing: 6) {
                        Text("NEXT")
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: "hand.point.right.fill")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.neoCharcoal)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .neoCharcoal.opacity(0.1), radius: 4, y: 2)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color(hex: prompt.colorHex))
        .cornerRadius(32)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.neoCharcoal, lineWidth: 2)
        )
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.neoCharcoal)
                .offset(x: 4, y: 4)
        )
        .aspectRatio(4/5, contentMode: .fit)
    }
}
