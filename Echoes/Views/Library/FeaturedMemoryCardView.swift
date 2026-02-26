import SwiftUI

struct FeaturedMemoryCardView: View {
    let echo: EchoCard
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Full Background Image Area
            ZStack {
                // Background color
                Color(hex: echo.categoryColorHex).opacity(0.8)
                
                // Always render the placeholder behind the image in case the asset is missing
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 80))
                    .foregroundColor(.neoCharcoal.opacity(0.3))
                
                // Try rendering the actual image over it
                if let imageName = echo.imageName, !imageName.isEmpty {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Bottom Info Area
            VStack(alignment: .leading, spacing: 8) {
                Text(echo.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(echo.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    // Apply dark color scheme to material to help white text contrast against bright images
                    .environment(\.colorScheme, .dark) 
            )
            .fixedSize(horizontal: false, vertical: true) // Force it to consume needed height
        }
        .frame(height: 380) // Reduced height for the hero card
        .cornerRadius(24) // Slightly tighter corners for smaller card
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white, lineWidth: 6) // Thick white border
        )
        // Add neo-retro outer shadow
        .compositingGroup()
        .shadow(color: .black.opacity(0.8), radius: 0, x: 4, y: 6)
        .padding(.vertical, 12)
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
