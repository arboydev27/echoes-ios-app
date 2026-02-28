import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 1
    @State private var showCapture = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    // Internal state for the initial walkthrough sequence
    enum SequenceState {
        case boarding
        case firstCapture
        case completed
    }
    
    @State private var sequenceState: SequenceState
    
    init() {
        UITabBar.appearance().isHidden = true
        // Check if we should show the onboarding sequence or if it's already done
        let completed = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        _sequenceState = State(initialValue: completed ? .completed : .boarding)
    }
    
    var body: some View {
        ZStack {
            // MAIN APP LAYER
            // We keep this behind a conditional to ensure NO Kindle View is even created
            // until the sequence is finished, or we render it underneath if we want a transition.
            // For absolute safety against flashes, we render it only when completed.
            if sequenceState == .completed {
                mainAppContent
                    .transition(.opacity)
            } else {
                // ONBOARDING / FIRST CAPTURE OVERLAY
                ZStack {
                    Color.neoBackground.ignoresSafeArea()
                    
                    if sequenceState == .boarding {
                        OnboardingView { shouldStartCapture in
                            if shouldStartCapture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    sequenceState = .firstCapture
                                }
                            } else {
                                finishSequence(toTab: 1) // Default to Kindle if skipped
                            }
                        }
                        .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading)))
                    } else if sequenceState == .firstCapture {
                        CaptureView(startImmediately: true) {
                            finishSequence(toTab: 0) // Go to Library after first recording
                        }
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
                    }
                }
                .zIndex(10)
            }
        }
        .fullScreenCover(isPresented: $showCapture) {
            CaptureView(startImmediately: false)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    private var mainAppContent: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                Group {
                    LibraryView()
                        .tag(0)
                    
                    KindleView()
                        .tag(1)
                    
                    Color.clear
                        .tag(2)
                    
                    OrbitView()
                        .tag(3)
                }
                .toolbar(.hidden, for: .tabBar)
            }
            
            CustomTabBar(selectedTab: $selectedTab, showCapture: $showCapture)
        }
    }
    
    private func finishSequence(toTab tab: Int) {
        withAnimation(.easeInOut(duration: 0.5)) {
            selectedTab = tab
            hasCompletedOnboarding = true
            sequenceState = .completed
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var showCapture: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Main Pill
            HStack(spacing: 0) {
                TabBarButton(icon: "flame.fill", title: "Kindle", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                
                TabBarButton(icon: "mic.fill", title: "Capture", isSelected: false) {
                    showCapture = true
                }
                
                TabBarButton(icon: "film.stack.fill", title: "Library", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
            }
            .frame(height: 72)
            .background(.regularMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(.white.opacity(0.5), lineWidth: 0.5)
                    .blendMode(.overlay)
            )
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            
            // Orbit Button
            Button(action: {
                selectedTab = 3
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "circle.hexagonpath")
                        .font(.system(size: 24))
                    Text("Orbit")
                        .font(.system(size: 10, weight: .bold))
                        .textCase(.uppercase)
                }
                .frame(width: 72, height: 72)
                .foregroundColor(selectedTab == 3 ? .neoPrimary : .neoCharcoal.opacity(0.5))
                .background(.regularMaterial)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.5), lineWidth: 0.5)
                        .blendMode(.overlay)
                )
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

struct TabBarButton: View {
    var icon: String
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .textCase(.uppercase)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? .neoPrimary : .neoCharcoal.opacity(0.5))
        }
    }
}
