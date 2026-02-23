import SwiftUI

struct MemoryCardTileView: View {
    let memory: MemoryCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(Color(hex: memory.categoryColorHex).opacity(0.4))
                .overlay(
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 40))
                        .foregroundColor(.neoCharcoal.opacity(0.3))
                )
                .aspectRatio(1, contentMode: .fill)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.neoCharcoal.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 8)
                .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(memory.category.uppercased())
                    .font(.system(size: 10, weight: .heavy))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.7))
                    .foregroundColor(.neoCharcoal)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.neoCharcoal.opacity(0.2), lineWidth: 1)
                    )
                    .compositingGroup()
                    .shadow(color: .neoCharcoal, radius: 0, x: 2, y: 2)
                
                Text(memory.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.neoCharcoal)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(height: 40, alignment: .topLeading) // Ensures 2 lines of text always takes up consistent space
                
                Spacer(minLength: 4)
                
                Text(memory.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.neoCharcoal.opacity(0.6))
            }
            .padding(.horizontal, 10)
            .padding(.top, 12)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: memory.categoryColorHex))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.neoCharcoal, lineWidth: 2)
        )
        .compositingGroup()
        .shadow(color: .neoCharcoal, radius: 0, x: 4, y: 4)
    }
}
