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
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.neoCharcoal)
                    }
                    
                    Spacer()
                    
                    Text("The Spark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.neoCharcoal)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
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
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.neoMustard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16).stroke(Color.neoCharcoal, lineWidth: 2)
                        )
                        .frame(maxWidth: .infinity)
                        .aspectRatio(4/5, contentMode: .fit)
                        .rotationEffect(.degrees(6))
                        .offset(y: 20)
                        .padding(.horizontal, 40)
                        .shadow(color: .neoCharcoal, radius: 0, x: 4, y: 4)
                        .opacity(prompts.count > 2 ? 1 : 0)
                    
                    // Background Card 2
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.neoLilac)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16).stroke(Color.neoCharcoal, lineWidth: 2)
                        )
                        .frame(maxWidth: .infinity)
                        .aspectRatio(4/5, contentMode: .fit)
                        .rotationEffect(.degrees(-3))
                        .offset(y: 10)
                        .padding(.horizontal, 30)
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
        let removed = prompts.removeFirst()
        prompts.append(removed)
        offset = .zero
    }
}
