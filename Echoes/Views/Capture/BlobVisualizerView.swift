import SwiftUI

struct BlobVisualizerView: View {
    @State private var isAnimating = false
    @State private var phase: Double = 0
    var isRecording: Bool = true
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(Color.neoMustard.opacity(0.3))
                .blur(radius: 40)
                .scaleEffect(isAnimating && isRecording ? 1.1 : 0.9)
                .frame(width: 300, height: 300)
            
            // Core Blob
            BlobShape(phase: isRecording ? phase : 0)
                .fill(
                    LinearGradient(gradient: Gradient(colors: [.neoPrimary, .neoMustard]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 250, height: 250)
                // Remove shadow when not animating for tactile feel
                .shadow(color: .neoCharcoal.opacity(0.2), radius: isRecording ? 10 : 0, x: 0, y: isRecording ? 10 : 0)
            
            // Inner Core pulse
            Circle()
                .fill(Color.white.opacity(0.2))
                .blur(radius: 10)
                .frame(width: 120, height: 120)
                .scaleEffect(isAnimating && isRecording ? 1.05 : 0.95)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
        .onChange(of: isRecording) { _, recording in
            if recording {
                withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                    phase = .pi * 2
                }
            } else {
                withAnimation(.spring()) {
                    phase = 0
                }
            }
        }
    }
}

struct BlobShape: Shape {
    var phase: Double
    
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = min(rect.width, rect.height) / 2
        
        path.move(to: CGPoint(x: center.x + baseRadius, y: center.y))
        
        for angle in stride(from: 0, to: .pi * 2, by: 0.1) {
            // The amplitude of the wave depends on the phase to make it dynamic
            let offset = sin(angle * 3 + phase) * 15 + cos(angle * 4 + phase) * 10
            let radius = baseRadius + offset
            
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)
            
            if angle == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}
