import SwiftUI

struct NextEchoNudge: View {
    var leastCategory: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("The Next Echo")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.neoCharcoal.opacity(0.6))
                .textCase(.uppercase)
                .tracking(1.0)
            
            Button(action: {
                // In a real app, this would route to the Spark tab via an environment variable
                // For now, it's just visually connecting to the concept
            }) {
                HStack(spacing: 16) {
                    // Icon Bubble
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
                    
                    VStack(alignment: .leading, spacing: 4) {
                        let category = leastCategory ?? "Family"
                        Text("Grandpa's \(category) chapter is quiet.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Ask about his memories?")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
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
