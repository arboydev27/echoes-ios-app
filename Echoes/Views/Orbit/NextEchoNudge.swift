import SwiftUI

struct NextEchoNudge: View {
    var leastCategory: String?
    var targetSpeaker: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("The Next Echo")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.neoCharcoal.opacity(0.6))
                .textCase(.uppercase)
                .tracking(1.0)
            
            Button(action: {
                // In a real app, this would route to the Kindle tab via an environment variable
                // For now, it's just visually connecting to the concept
            }) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        let category = leastCategory ?? "Wisdom"
                        let personName = targetSpeaker ?? "Someone"
                        let possessiveName = personName.hasSuffix("s") ? "\(personName)'" : "\(personName)'s"
                        
                        Text("\(possessiveName) \(category) chapter is quiet.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.leading)
                        
                        Text(targetSpeaker != nil ? "Ask about their memories?" : "Record a new memory?")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    // Icon Bubble (Moved to right)
                    ZStack {
                        Circle()
                            .fill(Color.neoPrimary.opacity(0.2))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Circle().stroke(Color.neoPrimary.opacity(0.5), lineWidth: 1)
                            )
                        
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.neoPrimary)
                    }
                }
                .padding(20)
                .background(Color.neoCharcoal)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.clear, lineWidth: 2)
                        .shadow(color: .neoPrimary.opacity(0.3), radius: 15, x: 0, y: 0)
                )
            }
            // Simple hover/tap scale effect could go here
        }
    }
}
