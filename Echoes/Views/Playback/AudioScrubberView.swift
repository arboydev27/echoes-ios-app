import SwiftUI

struct AudioScrubberView: View {
    @State private var progress: CGFloat = 0.35
    let joyPins: [CGFloat] = [0.2, 0.65, 0.82] // percentages
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("04:12") // Current time
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.neoCharcoal)
                Spacer()
                Text("12:30") // Total time
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.neoCharcoal.opacity(0.6))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track background
                    Capsule()
                        .fill(Color.white)
                        .overlay(Capsule().stroke(Color.neoCharcoal, lineWidth: 2))
                        .shadow(color: .neoCharcoal, radius: 0, x: 2, y: 2)
                    
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
                                    let newProgress = value.location.x / geo.size.width
                                    progress = min(max(newProgress, 0), 1)
                                }
                        )
                }
            }
            .frame(height: 16)
        }
    }
}
