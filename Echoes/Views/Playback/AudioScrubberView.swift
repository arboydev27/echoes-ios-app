import SwiftUI

struct AudioScrubberView: View {
    @Binding var progress: Double
    var currentTime: String
    var totalTime: String
    var joyPins: [Double] = [] // percentages
    var onSeek: (Double) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(currentTime) // Current time
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.neoCharcoal)
                Spacer()
                Text(totalTime) // Total time
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.neoCharcoal.opacity(0.6))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track background
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: .neoCharcoal, radius: 0, x: 2, y: 2)
                        .overlay(Capsule().stroke(Color.neoCharcoal, lineWidth: 2))
                    
                    // Fill
                    Capsule()
                        .fill(Color.neoPrimary)
                        .frame(width: max(20, geo.size.width * progress))
                        .overlay(
                            Capsule().stroke(Color.neoCharcoal, lineWidth: 2)
                        )
                    
                    // Joy Pins
                    ForEach(joyPins, id: \.self) { pin in
                        Image(systemName: "star.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.neoMustard)
                            .shadow(color: .neoCharcoal.opacity(0.5), radius: 1)
                            .position(x: geo.size.width * pin, y: geo.size.height / 2)
                    }
                    
                    // Handle
                    Circle()
                        .fill(Color.neoCharcoal)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(color: .neoCharcoal.opacity(0.5), radius: 2)
                        .position(x: max(10, geo.size.width * progress), y: geo.size.height / 2)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newProgress = Double(value.location.x / geo.size.width)
                                    progress = min(max(newProgress, 0.0), 1.0)
                                }
                                .onEnded { value in
                                    onSeek(progress)
                                }
                        )
                }
            }
            .frame(height: 16)
        }
    }
}
