import SwiftUI

struct KindleView: View {
    @State private var prompts: [Prompt] = Prompt.samples
    @State private var offset: CGSize = .zero
    
    // For navigating to CaptureView with a specific prompt
    @State private var showCapture = false
    @State private var selectedPrompt: Prompt?
    @State private var showSettings = false
    @State private var showSavedPrompts = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.neoBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title3)
                            .foregroundColor(.neoCharcoal)
                    }
                    
                    Spacer()
                    
                    Text("The Kindle")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundColor(.neoCharcoal)
                    
                    Spacer()
                    
                    Button(action: { showSavedPrompts = true }) {
                        Image(systemName: "bookmark")
                            .font(.title3)
                            .foregroundColor(.neoCharcoal)
                    }

                }
                .padding()
                
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(title: "All Prompts", icon: "", isSelected: true, action: {})
                        FilterChip(title: "Childhood", icon: "", isSelected: false, action: {})
                        FilterChip(title: "Love & Dating", icon: "", isSelected: false, action: {})
                        FilterChip(title: "Hardship", icon: "", isSelected: false, action: {})
                        FilterChip(title: "Lessons", icon: "", isSelected: false, action: {})
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
                
                Spacer()
                
                // Card Stack
                ZStack {
                    ForEach(Array(prompts.enumerated().reversed()), id: \.element.id) { index, prompt in
                        if index < 4 {
                            PromptCardView(prompt: prompt, onToggleSave: {
                                if let i = prompts.firstIndex(where: { $0.id == prompt.id }) {
                                    prompts[i].isSaved.toggle()
                                }
                            })
                                .padding(.horizontal, cardPadding(index: index))
                                .offset(cardOffset(index: index))
                                .rotationEffect(.degrees(cardRotation(index: index)))
                                .opacity(cardOpacity(index: index))
                                .zIndex(Double(prompts.count - index))
                                .gesture(
                                    index == 0 ? DragGesture()
                                        .onChanged { gesture in
                                            offset = gesture.translation
                                        }
                                        .onEnded { _ in
                                            let swipeDistance = offset.width
                                            if abs(swipeDistance) > 100 {
                                                // Animate swiping away
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    offset.width = swipeDistance > 0 ? 500 : -500
                                                    offset.height = 100
                                                }
                                                // After swipe completes, trigger the recycle
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    swipedCard()
                                                }
                                            } else {
                                                // Return to center
                                                withAnimation(.spring()) {
                                                    offset = .zero
                                                }
                                            }
                                        }
                                    : nil
                                )
                        }
                    }
                    
                    if prompts.isEmpty {
                        VStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.neoMint)
                            Text("You've reviewed all prompts!")
                                .font(.headline)
                                .foregroundColor(.neoCharcoal)
                                .padding(.top, 10)
                            
                            Button("Reset Stack") {
                                prompts = Prompt.samples
                            }
                            .buttonStyle(NeoRetroButtonStyle(backgroundColor: .neoMint))
                            .padding(.top, 20)
                        }
                    }
                }
                .frame(maxWidth: 380, maxHeight: 520)
                .padding(.bottom, 60)
                
                Spacer()
                
                // Start Interview Button
                Button(action: {
                    if let topPrompt = prompts.first {
                        selectedPrompt = topPrompt
                        showCapture = true
                    }
                }) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.neoPrimary)
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "mic.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.neoInk)
                        }
                        
                        Text("Start Interview")
                            .font(.system(size: 20, weight: .bold))
                            .tracking(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(NeoRetroButtonStyle(backgroundColor: .neoInk, foregroundColor: .white, cornerRadius: 40, borderWidth: 0, isPaddingEnabled: false))
                .padding(.horizontal, 24)
                .padding(.bottom, 120) // Account for TabBar padding
                .disabled(prompts.isEmpty)
                .opacity(prompts.isEmpty ? 0.5 : 1)
            }
        }
        .fullScreenCover(isPresented: $showCapture) {
            CaptureView(prompt: selectedPrompt)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showSavedPrompts) {
            SavedPromptsView(prompts: $prompts)
        }
    }
    
    private func swipedCard() {
        guard !prompts.isEmpty else { return }
        // Move top card back to end (or drop it)
        var removed = prompts.removeFirst()
        
        let pool = [
            "#b8e6d6", // Mint
            "#dcd6f7", // Lilac
            "#f4e06d", // Mustard
            "#FFB067", // Tangerine
            "#FF9CEE", // Bubblegum
            "#90E0EF", // Turquoise
            "#D4ED6D"  // Lime
        ]
        let avoid = prompts.last?.colorHex ?? ""
        let available = pool.filter { $0 != avoid }
        
        removed.colorHex = available.randomElement() ?? pool.first!
        
        offset = .zero
        prompts.append(removed)
    }
    
    // MARK: - Animation Helpers
    
    private var dragProgress: CGFloat {
        return min(1.0, max(0.0, abs(offset.width) / 100.0))
    }
    
    private func cardOffset(index: Int) -> CGSize {
        if index == 0 { return offset }
        
        let current = baseOffset(for: index)
        let next = baseOffset(for: index - 1)
        
        let x = current.width + (next.width - current.width) * dragProgress
        let y = current.height + (next.height - current.height) * dragProgress
        return CGSize(width: x, height: y)
    }
    
    private func cardRotation(index: Int) -> Double {
        if index == 0 { return Double(offset.width / 10) }
        
        let current = baseRotation(for: index)
        let next = baseRotation(for: index - 1)
        
        return current + (next - current) * Double(dragProgress)
    }
    
    private func cardPadding(index: Int) -> CGFloat {
        if index == 0 { return 20 }
        
        let current = basePadding(for: index)
        let next = basePadding(for: index - 1)
        return current + (next - current) * dragProgress
    }
    
    private func cardOpacity(index: Int) -> Double {
        if index == 0 { return 1.0 }
        
        let current = baseOpacity(for: index)
        let next = baseOpacity(for: index - 1)
        return current + (next - current) * Double(dragProgress)
    }
    
    private func baseOffset(for index: Int) -> CGSize {
        switch index {
        case 0: return .zero
        case 1: return CGSize(width: -10, height: 15)
        case 2: return CGSize(width: 15, height: 30)
        default: return CGSize(width: 15, height: 45)
        }
    }
    
    private func baseRotation(for index: Int) -> Double {
        switch index {
        case 0: return 0
        case 1: return -6
        case 2: return 10
        default: return 10
        }
    }
    
    private func basePadding(for index: Int) -> CGFloat {
        switch index {
        case 0: return 20
        case 1: return 20
        case 2: return 35
        default: return 50
        }
    }
    
    private func baseOpacity(for index: Int) -> Double {
        switch index {
        case 0: return 1.0
        case 1: return 1.0
        case 2: return 1.0
        default: return 0.0
        }
    }
}
