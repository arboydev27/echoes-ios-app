import SwiftUI

struct TranscriptView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                TranscriptBubble(speaker: "Grandma", text: "You know, back then, we didn't have all these fancy gadgets. We had time. Real, uninterrupted time.")
                
                TranscriptBubble(speaker: "", text: "We used to sit on the porch for hours, just watching the cars go by, guessing where people were going. It sounds boring now, I suppose, but it was peaceful.")
                
                // Active Segment
                ActiveTranscriptBubble(
                    text: "It was the first time I ever saw the ocean, and it felt like the world just opened up. I remember the smell of the salt air hitting my face before I even saw the water."
                )
                
                TranscriptBubble(speaker: "", text: "Your grandfather held my hand so tight, like he was afraid I'd blow away. He wasn't much for swimming, but he loved the sound of the waves.")
                
                TranscriptBubble(speaker: "Me", text: "Was that the trip where you bought the old station wagon?")
                
                TranscriptBubble(speaker: "Grandma", text: "Oh yes! That old rust bucket. It broke down three times on the way there, can you believe it?")
                
                TranscriptBubble(speaker: "", text: "We spent more time on the side of the road than on the beach that first day. But we laughed about it. We just laughed.")
                
                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
        .overlay(
            VStack {
                LinearGradient(colors: [.neoBackground, .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 24)
                Spacer()
                LinearGradient(colors: [.clear, .neoBackground], startPoint: .top, endPoint: .bottom)
                    .frame(height: 48)
            }
            .allowsHitTesting(false)
        )
    }
}

struct TranscriptBubble: View {
    var speaker: String
    var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !speaker.isEmpty {
                Text(speaker.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.neoPrimary)
                    .tracking(1)
            }
            
            Text(text)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.neoCharcoal.opacity(0.7))
                .lineSpacing(4)
        }
    }
}

struct ActiveTranscriptBubble: View {
    var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.neoCharcoal)
                .lineSpacing(4)
                .padding(16)
        }
        .background(Color.neoMustard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(Color.neoCharcoal, lineWidth: 2)
        )
        .shadow(color: .neoCharcoal, radius: 0, x: 2, y: 2)
        .overlay(
            Text("NOW PLAYING")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.neoCharcoal)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white, lineWidth: 1))
                .rotationEffect(.degrees(3))
                .offset(x: 10, y: -12)
            , alignment: .topTrailing
        )
        .padding(.vertical, 4)
    }
}
