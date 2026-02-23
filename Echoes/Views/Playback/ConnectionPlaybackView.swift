import SwiftUI

struct ConnectionPlaybackView: View {
    let memory: MemoryCard
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Top App Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.title3)
                }
                .buttonStyle(NeoRetroIconButtonStyle(size: 44))
                
                Spacer()
                
                Text(memory.title.uppercased())
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(.neoCharcoal)
                    .tracking(2)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                }
                .buttonStyle(NeoRetroIconButtonStyle(size: 44))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.neoBackground)
            
            // Memory Card & Controls
            VStack(spacing: 24) {
                // Simplified Memory Card
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(hex: memory.categoryColorHex).opacity(0.3))
                        .overlay(
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 56))
                                .foregroundColor(.neoCharcoal.opacity(0.3))
                        )
                        .frame(height: 180)
                        .border(Color.neoCharcoal.opacity(0.2), width: 1)
                        .padding(12)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(memory.title)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.neoCharcoal)
                                .lineLimit(1)
                            
                            Text("\(memory.date.formatted(date: .abbreviated, time: .omitted)) • \(memory.category.uppercased())")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.neoCharcoal.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        // Avatars
                        HStack(spacing: -8) {
                            Circle()
                                .fill(Color.neoMustard)
                                .frame(width: 32, height: 32)
                                .overlay(Text("J").font(.system(size: 12, weight: .bold)))
                                .overlay(Circle().stroke(Color.neoCharcoal, lineWidth: 2))
                            
                            Circle()
                                .fill(Color.neoPrimary)
                                .frame(width: 32, height: 32)
                                .overlay(Text("M").font(.system(size: 12, weight: .bold)))
                                .overlay(Circle().stroke(Color.neoCharcoal, lineWidth: 2))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .background(Color.white)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.neoCharcoal, lineWidth: 3))
                .shadow(color: .neoCharcoal, radius: 0, x: 4, y: 4)
                .padding(.horizontal, 20)
                
                // Scrubber
                AudioScrubberView()
                    .padding(.horizontal, 24)
                
                // Playback Controls
                HStack(spacing: 40) {
                    Button(action: {}) {
                        Image(systemName: "gobackward.10")
                            .font(.system(size: 28))
                            .foregroundColor(.neoCharcoal.opacity(0.6))
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 32))
                    }
                    .buttonStyle(NeoRetroIconButtonStyle(backgroundColor: .neoPrimary, foregroundColor: .white, size: 72))
                    
                    Button(action: {}) {
                        Image(systemName: "goforward.10")
                            .font(.system(size: 28))
                            .foregroundColor(.neoCharcoal.opacity(0.6))
                    }
                }
            }
            .padding(.bottom, 24)
            .background(Color.neoBackground)
            
            Divider()
                .background(Color.neoCharcoal.opacity(0.2))
            
            // Transcript View extending to bottom with mask
            TranscriptView()
                .background(Color.neoBackground)
        }
        .background(Color.neoBackground.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
