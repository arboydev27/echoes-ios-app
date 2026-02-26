import SwiftUI

struct TranscriptView: View {
    var transcript: String
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                if transcript.isEmpty {
                    Text("No transcript available for this echo.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.neoCharcoal.opacity(0.5))
                        .italic()
                        .padding(.top, 40)
                } else {
                    let segments = parseTranscript(transcript)
                    ForEach(0..<segments.count, id: \.self) { index in
                        let segment = segments[index]
                        TranscriptBubble(speaker: segment.speaker, text: segment.text)
                    }
                }
                
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
    
    private struct TranscriptSegment {
        let speaker: String
        let text: String
    }
    
    private func parseTranscript(_ text: String) -> [TranscriptSegment] {
        // Simple parser for "Speaker: Message" or fallback to one big segment
        let lines = text.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        var segments: [TranscriptSegment] = []
        for line in lines {
            if let colonIndex = line.firstIndex(of: ":") {
                let speaker = String(line[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                let message = String(line[line.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                segments.append(TranscriptSegment(speaker: speaker, text: message))
            } else {
                segments.append(TranscriptSegment(speaker: "", text: line))
            }
        }
        
        return segments.isEmpty ? [TranscriptSegment(speaker: "", text: text)] : segments
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
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.neoMustard)
                .shadow(color: .neoCharcoal, radius: 0, x: 2, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(Color.neoCharcoal, lineWidth: 2)
        )
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
