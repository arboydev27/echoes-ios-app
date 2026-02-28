import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
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
                
                TabView(selection: $currentPage) {
                    WelcomeSlide()
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
            }
        }
    }
}

// MARK: - Slide 1: Welcome
struct WelcomeSlide: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App Logo (Static & Resized)
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            
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
            
            Spacer()
            Spacer()
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
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.neoRose)
                    .frame(width: 280, height: 320)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.neoCharcoal, lineWidth: 3)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.neoCharcoal)
                            .offset(x: 10, y: 10)
                    )
                
                VStack(spacing: 24) {
                    Image(systemName: "record.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.neoCharcoal)
                    
                    Text(isTutorial ? "Keep Exploring" : "Ready to start?")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(.neoCharcoal)
                    
                    Text(isTutorial ? "You can revisit these tips anytime in the Settings menu." : "The best way to experience Echoes is to record your first memory.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.neoCharcoal.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(30)
            }
            .padding(.top, 20)
            
            Button(action: onComplete) {
                Text(isTutorial ? "DISMISS" : "GET STARTED")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .background(Color.neoCharcoal)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .padding(.horizontal, 40)
                    .shadow(color: .neoPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
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
