import SwiftUI

struct FeaturedMemoryCardView: View {
    let echo: Echo
    
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
                if let filename = echo.coverImageFilename, !filename.isEmpty {
                    if filename.hasPrefix("dummy_") {
                        Image(filename)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .clipped()
                    } else if let url = StorageManager.shared.getCoverImageURL(filename: filename),
                              let uiImage = UIImage(contentsOfFile: url.path) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .clipped()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            
            // Bottom Info Area
            VStack(alignment: .leading, spacing: 8) {
                Text(echo.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                
                Text(echo.dateRecorded.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            .padding(.horizontal, 20)
            .padding(.top, 40) // More space for the gradient
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .background(.ultraThinMaterial)
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
        
        FeaturedMemoryCardView(echo: Echo(
            title: "Hiking story",
            promptText: "Mock",
            duration: 120,
            transcript: "Mock transcript",
            themeTag: "Travel",
            audioFilename: ""
        ))
        .padding()
    }
}
