import SwiftUI
import Combine

struct CaptureView: View {
    @Environment(\.dismiss) var dismiss
    var prompt: Prompt?
    
    @AppStorage("enableCountdown") private var enableCountdown = true
    @State private var countdown: Int = 3
    @State private var isRecording = false
    @State private var hasStarted: Bool
    @State private var timeElapsed: TimeInterval = 0
    @State private var showSavedToast = false
    @State private var showFinalizeSheet = false
    @State private var recordedAudioURL: URL? = nil
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(prompt: Prompt? = nil, startImmediately: Bool = true) {
        self.prompt = prompt
        self._hasStarted = State(initialValue: startImmediately)
    }
    
    var timeString: String {
        let minutes = Int(timeElapsed) / 60
        let seconds = Int(timeElapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
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
                Text("TOPIC: \(prompt?.category.uppercased() ?? "KINDLE")")
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
                
                if hasStarted && countdown > 0 && enableCountdown {
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
                    if hasStarted {
                        isRecording.toggle()
                    }
                }) {
                    Image(systemName: isRecording ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                .buttonStyle(NeoRetroIconButtonStyle(size: 56))
                .opacity(hasStarted ? 1.0 : 0.5)
                .disabled(!hasStarted)
                
                // Stop / Record Button
                Button(action: {
                    if !hasStarted {
                        // Start the process
                        withAnimation {
                            hasStarted = true
                        }
                        startCaptureSequence()
                    } else {
                        // Handle stop and show finalize sheet
                        withAnimation {
                            isRecording = false
                            hasStarted = false
                            // In a real app, we'd get the actual URL here
                            recordedAudioURL = URL(string: "file:///tmp/echo.m4a") 
                            showFinalizeSheet = true
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.neoPrimary)
                            .frame(width: 96, height: 96)
                        
                        if hasStarted {
                            Rectangle()
                                .fill(Color.neoCharcoal)
                                .frame(width: 32, height: 32)
                                .cornerRadius(4)
                        } else {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.neoCharcoal)
                        }
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
            
            Text(hasStarted ? "Tap square to finish" : "Tap mic to capture")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.neoCharcoal.opacity(0.6))
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
            
            // Toast Notification
            if showSavedToast {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.neoCharcoal)
                        .font(.title3)
                    
                    Text("Echo saved to Library")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.neoCharcoal)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.neoMint)
                .cornerRadius(40)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.neoCharcoal, lineWidth: 2)
                )
                .padding(.top, 60)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(100)
            }
        }
        .background(Color.neoBackground.ignoresSafeArea())
        .sheet(isPresented: $showFinalizeSheet) {
            FinalizeEchoSheet(prompt: prompt, audioURL: recordedAudioURL) {
                // When saved, reset local state and show toast
                timeElapsed = 0
                countdown = 3
                withAnimation {
                    showSavedToast = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showSavedToast = false
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .onAppear {
            if hasStarted {
                startCaptureSequence()
            }
        }
        .onReceive(timer) { _ in
            if isRecording {
                timeElapsed += 1
            }
        }
    }
    
    private func startCaptureSequence() {
        if !enableCountdown {
            countdown = 0
            isRecording = true
            return
        }
        
        Task {
            // We start at 3, wait 1s, go to 2, wait 1s, go to 1, wait 1s, go to 0.
            while countdown > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if !hasStarted { break } // Canceled
                await MainActor.run {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        countdown -= 1
                    }
                    if countdown == 0 {
                        isRecording = true
                    }
                }
            }
        }
    }
}
