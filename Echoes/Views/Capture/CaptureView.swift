import SwiftUI
import Combine

struct CaptureView: View {
    @Environment(\.dismiss) var dismiss
    var prompt: Prompt?
    
    @AppStorage("enableCountdown") private var enableCountdown = true
    @State private var countdown: Int = 3
    @State private var isRecording = false
    @State private var timeElapsed: TimeInterval = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var timeString: String {
        let minutes = Int(timeElapsed) / 60
        let seconds = Int(timeElapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.neoCharcoal)
                }
                
                Spacer()
                
                // Timer Chip
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .opacity(isRecording ? (Int(timeElapsed) % 2 == 0 ? 1 : 0.3) : 1) // Pulse
                    
                    Text(timeString)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.neoCharcoal)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.5))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.neoCharcoal.opacity(0.1), lineWidth: 1)
                )
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.neoCharcoal)
            }
            .padding()
            
            Spacer()
            
            // Prompt Area
            VStack(spacing: 12) {
                Text("TOPIC: \(prompt?.category.uppercased() ?? "SPARK")")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(.neoPrimary)
                    .tracking(2)
                
                Text(prompt?.text ?? "What's on your mind today?")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(.neoCharcoal)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Visualizer Area
            ZStack {
                // Sparkles Decoration
                Image(systemName: "sparkles")
                    .font(.system(size: 32))
                    .foregroundColor(.neoMustard)
                    .offset(x: 100, y: -100)
                    .opacity(0.8)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.neoPrimary)
                    .offset(x: -120, y: 80)
                    .opacity(0.6)
                
                BlobVisualizerView(isRecording: isRecording)
                
                if countdown > 0 && enableCountdown {
                    Text("\(countdown)")
                        .neoRetroFont(size: 140, weight: .heavy, isSerif: true)
                        .foregroundColor(.neoInk)
                        .shadow(color: .white, radius: 0, x: 4, y: 4)
                        .transition(.scale(scale: 2.0).combined(with: .opacity))
                        .id(countdown)
                        .zIndex(2)
                }
            }
            .frame(height: 300)
            
            Spacer()
            
            // Controls Audio Wave Placeholder
            HStack(spacing: 4) {
                ForEach(0..<5) { i in
                    Capsule()
                        .fill(Color.neoCharcoal.opacity(0.4))
                        .frame(width: 4, height: isRecording ? CGFloat.random(in: 10...30) : 10)
                        .animation(.easeInOut(duration: 0.2), value: isRecording)
                }
            }
            .frame(height: 30)
            .padding(.bottom, 32)
            
            // Primary Controls
            HStack(spacing: 32) {
                // Pause Button
                Button(action: {
                    isRecording.toggle()
                }) {
                    Image(systemName: isRecording ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                .buttonStyle(NeoRetroIconButtonStyle(size: 56))
                
                // Stop Button
                Button(action: {
                    isRecording = false
                    // Handle save and route to Connection screen
                    dismiss()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.neoPrimary)
                            .frame(width: 96, height: 96)
                        
                        Rectangle()
                            .fill(Color.neoCharcoal)
                            .frame(width: 32, height: 32)
                            .cornerRadius(4)
                    }
                }
                .buttonStyle(NeoRetroIconButtonStyle(backgroundColor: .clear, foregroundColor: .clear, size: 96))
                
                // Add Note Button
                Button(action: {}) {
                    Image(systemName: "text.badge.plus")
                        .font(.title2)
                }
                .buttonStyle(NeoRetroIconButtonStyle(size: 56))
            }
            
            Text("Tap square to finish")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.neoCharcoal.opacity(0.6))
                .padding(.top, 24)
                .padding(.bottom, 40)
        }
        .background(Color.neoBackground.ignoresSafeArea())
        .onAppear {
            if !enableCountdown {
                countdown = 0
                isRecording = true
            }
        }
        .onReceive(timer) { _ in
            if countdown > 0 && enableCountdown {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    countdown -= 1
                }
                if countdown == 0 {
                    isRecording = true
                }
            } else if isRecording {
                timeElapsed += 1
            }
        }
    }
}
