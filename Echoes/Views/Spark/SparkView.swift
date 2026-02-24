import SwiftUI

struct SparkView: View {
    @State private var prompts: [Prompt] = Prompt.samples
    @State private var offset: CGSize = .zero
    
    // For navigating to CaptureView with a specific prompt
    @State private var showCapture = false
    @State private var selectedPrompt: Prompt?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.neoBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title3)
                            .foregroundColor(.neoCharcoal)
                    }
                    
                    Spacer()
                    
                    Text("The Spark")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundColor(.neoCharcoal)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
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
                    // Background Card 1
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color(hex: prompts.count > 2 ? prompts[2].colorHex : "#b8e6d6"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 32).stroke(Color.neoCharcoal, lineWidth: 2)
                        )
                        .frame(maxWidth: .infinity)
                        .aspectRatio(4/5, contentMode: .fit)
                        .rotationEffect(.degrees(10))
                        .offset(x: 15, y: 30)
                        .padding(.horizontal, 35)
                        .shadow(color: .neoCharcoal, radius: 0, x: 4, y: 4)
                        .opacity(prompts.count > 2 ? 1 : 0)
                    
                    // Background Card 2
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color(hex: prompts.count > 1 ? prompts[1].colorHex : "#dcd6f7"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 32).stroke(Color.neoCharcoal, lineWidth: 2)
                        )
                        .frame(maxWidth: .infinity)
                        .aspectRatio(4/5, contentMode: .fit)
                        .rotationEffect(.degrees(-6))
                        .offset(x: -10, y: 15)
                        .padding(.horizontal, 20)
                        .shadow(color: .neoCharcoal, radius: 0, x: 4, y: 4)
                        .opacity(prompts.count > 1 ? 1 : 0)
                    
                    // Top Card (Active)
                    if let topPrompt = prompts.first {
                        PromptCardView(prompt: topPrompt)
                            .padding(.horizontal, 20)
                            .offset(x: offset.width, y: offset.height)
                            .rotationEffect(.degrees(Double(offset.width / 10)))
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        offset = gesture.translation
                                    }
                                    .onEnded { _ in
                                        withAnimation(.spring()) {
                                            if offset.width > 100 {
                                                // Swipe Right (Save)
                                                swipedCard()
                                            } else if offset.width < -100 {
                                                // Swipe Left (Skip)
                                                swipedCard()
                                            } else {
                                                // Return to center
                                                offset = .zero
                                            }
                                        }
                                    }
                            )
                    } else {
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
                .padding(.bottom, 20)
                
                Spacer()
                
                // Start Interview Button
                Button(action: {
                    if let topPrompt = prompts.first {
                        selectedPrompt = topPrompt
                        showCapture = true
                    }
                }) {
                    HStack {
                        Image(systemName: "mic.fill")
                        Text("Start Interview")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(NeoRetroButtonStyle(backgroundColor: .neoCharcoal, foregroundColor: .white, cornerRadius: 16))
                .padding(.horizontal, 24)
                .padding(.bottom, 120) // Account for TabBar padding
                .disabled(prompts.isEmpty)
                .opacity(prompts.isEmpty ? 0.5 : 1)
            }
        }
        .fullScreenCover(isPresented: $showCapture) {
            CaptureView(prompt: selectedPrompt)
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
        
        prompts.append(removed)
        offset = .zero
    }
}
