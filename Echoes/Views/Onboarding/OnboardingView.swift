import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isControlsVisible = false
    var isTutorial: Bool = false
    var onComplete: (Bool) -> Void
    
    var body: some View {
        ZStack {
            Color.neoBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Exit/Skip Button
                HStack {
                    Spacer()
                    Button(action: { onComplete(false) }) {
                        Text(isTutorial ? "Close" : "Skip")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.neoCharcoal.opacity(0.5))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.top, 10)
                .opacity(isControlsVisible || currentPage > 0 ? 1 : 0)
                .animation(.easeIn(duration: 0.5), value: isControlsVisible || currentPage > 0)
                
                TabView(selection: $currentPage) {
                    WelcomeSlide(onBrandsVisible: {
                        withAnimation(.easeIn(duration: 0.5)) {
                            isControlsVisible = true
                        }
                    })
                        .tag(0)
                    
                    TechPrivacySlide()
                        .tag(1)
                    
                    ActionSlide(isTutorial: isTutorial, onComplete: { 
                        onComplete(isTutorial ? false : true)
                    })
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Custom Page Indicator (NeoRetro Style)
                HStack(spacing: 12) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(currentPage == index ? Color.neoPrimary : Color.clear)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(Color.neoCharcoal, lineWidth: 2)
                            )
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentPage)
                    }
                }
                .padding(.bottom, 50)
                .opacity(isControlsVisible || currentPage > 0 ? 1 : 0)
                .animation(.easeIn(duration: 0.5), value: isControlsVisible || currentPage > 0)
            }
        }
    }
}

// MARK: - Slide 1: Welcome
struct WelcomeSlide: View {
    @State private var isSplashPhase = true
    @State private var isAnimatingPulse = false
    var onBrandsVisible: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 40) {
                // App Logo
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    .scaleEffect(isAnimatingPulse ? 1.05 : 0.95)
                
                if !isSplashPhase {
                    VStack(spacing: 16) {
                        Text("Echoes")
                            .font(.system(size: 48, weight: .black, design: .serif))
                            .foregroundColor(.neoCharcoal)
                            .tracking(2)
                        
                        Text("Your voice. Your memories.\npreserved forever")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.neoCharcoal.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                    .onAppear {
                        onBrandsVisible()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .onAppear {
            // Start pulsing
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isAnimatingPulse = true
            }
            
            // Transition to content after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                    isSplashPhase = false
                }
                
                // Stop pulsing
                withAnimation(.easeInOut(duration: 0.4)) {
                    isAnimatingPulse = false
                }
            }
        }
    }
}

// MARK: - Slide 2: Tech & Privacy
struct TechPrivacySlide: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("100% PRIVATE & OFFLINE")
                .font(.system(size: 12, weight: .black))
                .foregroundColor(.neoPrimary)
                .tracking(2)
            
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(icon: "lock.shield.fill", color: .neoMint, title: "On-Device Privacy", description: "Your audio never leaves this iPhone. No cloud. Local storage only.")
                
                FeatureRow(icon: "waveform", color: .neoLilac, title: "Natural Language Processing", description: "Offline SFSpeech & NLP models generate transcripts and identify themes without internet.")
                
                FeatureRow(icon: "face.smiling.fill", color: .neoMustard, title: "CoreML Intelligence", description: "Using Vision & CoreML frameworks to detect smiles and map your emotional journey.")
            }
            .padding(.horizontal, 30)
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Slide 3: Action
struct ActionSlide: View {
    var isTutorial: Bool = false
    var onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Minimalist Icon
            ZStack {
                Circle()
                    .fill(Color.neoPrimary.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(.neoPrimary)
            }
            .padding(.bottom, 20)
            
            VStack(spacing: 16) {
                Text(isTutorial ? "Keep Exploring" : "Begin Your Journey")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(.neoCharcoal)
                
                Text(isTutorial ? "You can revisit these tips anytime in the Settings menu." : "The best way to experience Echoes is to record your first memory. Let's start today.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.neoCharcoal.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            Button(action: onComplete) {
                Text(isTutorial ? "DISMISS" : "GET STARTED")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color.neoCharcoal)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

struct FeatureRow: View {
    var icon: String
    var color: Color
    var title: String
    var description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.neoCharcoal, lineWidth: 2)
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.neoCharcoal)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.neoCharcoal)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.neoCharcoal.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    OnboardingView(onComplete: { _ in })
}
