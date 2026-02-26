import SwiftUI

struct FeaturedMemoryCardView: View {
    let echo: EchoCard
    
    // For randomizing a mock duration if none exists in model
    // Just for visual parity with the provided design sample
    private let mockDuration = "00:11.84" 
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Image Area
            ZStack {
                // Background color if no image
                Color(hex: echo.categoryColorHex).opacity(0.8)
                
                // Placeholder for actual image
                if let imageName = echo.imageName, !imageName.isEmpty {
                    // Assuming we have an Image accessible by name, or use AsyncImage if URL
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            // Clip to rect so image doesn't overflow
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            
            // Bottom Info Area
            VStack(alignment: .leading, spacing: 8) {
                Text(echo.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(echo.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 14, weight: .bold))
                    Text(mockDuration)
                        .font(.system(size: 14, weight: .bold))
                    
                    Spacer()
                    
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 20))
                }
                .foregroundColor(.white)
                .padding(.top, 8)
            }
            .padding(20)
            .background(Color(hex: "#8C6D53")) // Warm brown from design
        }
        .frame(height: 480) // Fixed height for hero card
        .cornerRadius(32) // Very generous rounding like the sample
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.white, lineWidth: 6) // Thick white border
        )
        // Add neo-retro outer shadow
        .compositingGroup()
        .shadow(color: .black.opacity(0.8), radius: 0, x: 4, y: 6)
        .padding(.horizontal, 8)
        .padding(.vertical, 16)
    }
}

// Preview provider to help visualize
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        FeaturedMemoryCardView(echo: EchoCard(
            title: "Hiking story",
            date: Date(),
            category: "Travel"
        ))
        .padding()
    }
}
