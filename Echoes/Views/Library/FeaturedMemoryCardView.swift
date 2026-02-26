import SwiftUI

struct FeaturedMemoryCardView: View {
    let echo: EchoCard
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Full Background Image Area
            ZStack {
                // Background color if no image
                Color(hex: echo.categoryColorHex).opacity(0.8)
                
                // Placeholder for actual image
                if let imageName = echo.imageName, !imageName.isEmpty {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.5))
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
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 40) // Extra padding for the TabView dots to sit within the frame
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
