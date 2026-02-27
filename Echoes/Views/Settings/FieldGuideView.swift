import SwiftUI

struct FieldGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.neoBackground.ignoresSafeArea()
            
            // Swipeable Flashcards
            TabView {
                // Card 1: The Kindle
                FieldGuideCard(
                    iconName: "flame.fill",
                    iconColor: .neoTangerine,
                    title: "The Kindle",
                    description: "Swipe through prompts to spark a memory. Tap 'Start Interview' when you're ready."
                )
                
                // Card 2: The Capture
                FieldGuideCard(
                    iconName: "face.smiling",
                    iconColor: .neoBubblegum,
                    title: "The Capture",
                    description: "Just speak. Echoes will silently map your smiles and laughs into 'Joy Pins' on the timeline."
                )
                
                // Card 3: The Library
                FieldGuideCard(
                    iconName: "film.stack.fill",
                    iconColor: .neoLilac,
                    title: "The Library",
                    description: "Watch your family's or loved one's legacy grow offline. Tap any memory to feel their voice."
                )
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .padding(.bottom, 20)
            .padding(.top, 16) // Added padding to reduce card height slightly from the top
        }
        .navigationTitle("Field Guide")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FieldGuideCard: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 32) {
            // Icon Graphic
            ZStack {
                Circle()
                    .fill(iconColor)
                    .frame(width: 140, height: 140)
                    .shadow(color: .neoCharcoal, radius: 0, x: 4, y: 4)
                
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.neoCharcoal)
            }
            .overlay(Circle().stroke(Color.neoCharcoal, lineWidth: 3))
            
            // Text Content
            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundColor(.neoCharcoal)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.neoCharcoal.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        // Neo-Retro Card Styling
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .neoCharcoal, radius: 0, x: 8, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.neoCharcoal, lineWidth: 3)
        )
        .padding(.horizontal, 32)
        .padding(.vertical, 40)
    }
}

#Preview {
    FieldGuideView()
}
