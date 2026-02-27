import SwiftUI

struct SavedPromptsView: View {
    @Binding var prompts: [Prompt]
    @Environment(\.dismiss) private var dismiss
    
    var savedPrompts: [Prompt] {
        prompts.filter { $0.isSaved }
    }
    
    // For navigation
    @State private var showCapture = false
    @State private var selectedPrompt: Prompt?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.neoBackground.ignoresSafeArea()
                
                if savedPrompts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.neoCharcoal.opacity(0.3))
                        Text("No saved prompts yet")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.neoCharcoal.opacity(0.5))
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(savedPrompts) { prompt in
                                SavedPromptRowView(prompt: prompt) {
                                    // Start interview action
                                    selectedPrompt = prompt
                                    showCapture = true
                                } onToggleSave: {
                                    // Toggle save status in the main array
                                    if let index = prompts.firstIndex(where: { $0.id == prompt.id }) {
                                        prompts[index].isSaved.toggle()
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Saved Prompts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.neoCharcoal)
                    }
                }
            }
            .fullScreenCover(isPresented: $showCapture) {
                CaptureView(prompt: selectedPrompt)
            }
        }
    }
}

struct SavedPromptRowView: View {
    let prompt: Prompt
    let onStart: () -> Void
    let onToggleSave: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: prompt.colorHex).opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Image(systemName: prompt.icon)
                    .font(.title2)
                    .foregroundColor(Color.neoCharcoal)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(prompt.category.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.neoCharcoal.opacity(0.6))
                
                Text(prompt.text)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.neoCharcoal)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: onToggleSave) {
                    Image(systemName: prompt.isSaved ? "heart.fill" : "heart")
                        .foregroundColor(prompt.isSaved ? .red : .neoCharcoal)
                        .font(.title3)
                }
                
                Button(action: onStart) {
                    Image(systemName: "mic.fill")
                        .foregroundColor(.neoPrimary)
                        .font(.title3)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .neoCharcoal.opacity(0.1), radius: 4, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.neoCharcoal.opacity(0.1), lineWidth: 1)
        )
    }
}
