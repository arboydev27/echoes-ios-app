import SwiftUI
import Combine

struct CaptureView: View {
    @Environment(\.dismiss) var dismiss
    var onDismiss: (() -> Void)? = nil // Added for ZStack integration
    @State var prompt: Prompt?
    var startImmediately: Bool
    
    @AppStorage("enableCountdown") private var enableCountdown = true
    @AppStorage("recordingQuality") private var recordingQuality = "High Fidelity"
    @State private var timeElapsed: TimeInterval = 0
    @State private var showSavedToast = false
    @State private var showFinalizeSheet = false
    @State private var showPivotSheet = false
    @State private var pivotPrompts: [Prompt] = []
    
    // Core Services
    @State private var sessionManager = CaptureSessionManager()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(prompt: Prompt? = nil, startImmediately: Bool = true, onDismiss: (() -> Void)? = nil) {
        _prompt = State(initialValue: prompt)
        self.startImmediately = startImmediately
        self.onDismiss = onDismiss
    }
    
    private func close() {
        if let onDismiss = onDismiss {
            onDismiss()
        } else {
            dismiss()
        }
    }
    
    private var hasStarted: Bool {
        sessionManager.state != .idle && sessionManager.state != .saved
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
                if onDismiss == nil {
                    Button {
                        close()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.neoCharcoal)
                    }
                }
                
                Spacer()
                
                // Timer Chip
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .opacity(sessionManager.state == .recording ? (Int(timeElapsed) % 2 == 0 ? 1 : 0.3) : 1) // Pulse
                        .opacity(sessionManager.state == .paused ? 0.3 : 1)
                    
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
                
                if onDismiss == nil {
                    Button("Cancel") {
                        close()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.neoCharcoal)
                }
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
                
                BlobVisualizerView(isRecording: sessionManager.state == .recording)
                
                if hasStarted && sessionManager.countdown > 0 && enableCountdown {
                    Text("\(sessionManager.countdown)")
                        .neoRetroFont(size: 140, weight: .heavy, isSerif: true)
                        .foregroundColor(.neoInk)
                        .shadow(color: .white, radius: 0, x: 4, y: 4)
                        .transition(.scale(scale: 2.0).combined(with: .opacity))
                        .id(sessionManager.countdown)
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
                        .frame(width: 4, height: sessionManager.state == .recording ? CGFloat.random(in: 10...30) : 10)
                        .animation(.easeInOut(duration: 0.2), value: sessionManager.state == .recording)
                }
            }
            .frame(height: 30)
            .padding(.bottom, 32)
            
            // Primary Controls
            HStack(spacing: 32) {
                // Pause Button
                Button(action: {
                    if sessionManager.state == .recording {
                        withAnimation {
                            sessionManager.pauseRecording()
                        }
                    } else if sessionManager.state == .paused {
                        withAnimation {
                            sessionManager.resumeRecording()
                        }
                    }
                }) {
                    Image(systemName: sessionManager.state == .paused ? "play.fill" : "pause.fill")
                        .font(.title2)
                }
                .buttonStyle(NeoRetroIconButtonStyle(size: 56))
                .opacity(hasStarted ? 1.0 : 0.5)
                .disabled(!hasStarted || sessionManager.state == .processing || sessionManager.state == .finalizing)
                
                // Stop / Record Button
                Button(action: {
                    if sessionManager.state == .idle {
                        // Ensure permissions before starting
                        Task {
                            if !sessionManager.hasPermissions {
                                let granted = await sessionManager.requestAllPermissions()
                                guard granted else { return }
                            }
                            sessionManager.startSequence(withCountdown: enableCountdown, quality: recordingQuality)
                        }
                    } else if sessionManager.state == .recording || sessionManager.state == .paused {
                        // Handle stop and process
                        withAnimation {
                            sessionManager.stopAndProcessSequence()
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.neoPrimary)
                            .frame(width: 96, height: 96)
                        
                        if sessionManager.state == .processing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .neoCharcoal))
                                .scaleEffect(1.5)
                        } else if hasStarted {
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
                .disabled(sessionManager.state == .processing)
                
                // Pivot Button
                Button(action: {
                    // Generate 3 random prompts that are different from the current one
                    let availablePrompts = Prompt.samples.filter { $0.id != prompt?.id }
                    pivotPrompts = Array(availablePrompts.shuffled().prefix(3))
                    showPivotSheet = true
                }) {
                    Image(systemName: "shuffle")
                        .font(.title2)
                }
                .buttonStyle(NeoRetroIconButtonStyle(size: 56))
                .disabled(sessionManager.state == .processing)
            }
            
            let statusText: String = {
                switch sessionManager.state {
                case .processing: return "Processing Echo..."
                case .paused: return "Recording Paused"
                default: return hasStarted ? "Tap square to finish" : "Tap mic to capture"
                }
            }()
            
            Text(statusText)
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
        .ignoresSafeArea(.keyboard)
        .onChange(of: sessionManager.state) { _, newState in
            if newState == .finalizing {
                showFinalizeSheet = true
            }
        }
        .sheet(isPresented: $showFinalizeSheet) {
            FinalizeEchoSheet(prompt: prompt, sessionManager: sessionManager) {
                // When saved, reset local state and show toast
                timeElapsed = 0
                withAnimation {
                    showSavedToast = true
                }
                
                sessionManager.reset()
                
                // Auto-close after a delay so they see the toast
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    close()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showSavedToast = false
                    }
                }
            }
            .presentationDetents([.height(540)])
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showPivotSheet) {
            NavigationView {
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Pivot Topic")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.neoCharcoal)
                            // // .padding(.top, 16)
                            // .padding(.bottom, 8)
                        
                        Text("Need a new direction? Choose a different prompt to continue your echo.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.neoCharcoal.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 16)
                        
                        ForEach(pivotPrompts) { pivotPrompt in
                            Button(action: {
                                prompt = pivotPrompt
                                showPivotSheet = false
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(pivotPrompt.category.uppercased())
                                            .font(.system(size: 10, weight: .black))
                                            .foregroundColor(.neoCharcoal.opacity(0.6))
                                            .tracking(1)
                                        
                                        Spacer()
                                        
                                        Image(systemName: pivotPrompt.icon)
                                            .foregroundColor(.neoCharcoal)
                                    }
                                    
                                    Text(pivotPrompt.text)
                                        .font(.system(size: 16, weight: .bold, design: .serif))
                                        .foregroundColor(.neoCharcoal)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(16)
                                .background(Color(hex: pivotPrompt.colorHex))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.neoCharcoal, lineWidth: 2)
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.neoCharcoal)
                                        .offset(x: 4, y: 4)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(24)
                }
                .background(Color.neoBackground.ignoresSafeArea())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            showPivotSheet = false
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.neoCharcoal)
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
        .onAppear {
            if startImmediately && sessionManager.state == .idle {
                Task {
                    let permissionsGranted = await sessionManager.requestAllPermissions()
                    if permissionsGranted {
                        sessionManager.startSequence(withCountdown: enableCountdown, quality: recordingQuality)
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            if sessionManager.state == .recording {
                timeElapsed += 1
            }
        }
    }
}
