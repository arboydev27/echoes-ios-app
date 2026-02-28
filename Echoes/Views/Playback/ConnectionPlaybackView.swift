import SwiftUI

struct ConnectionPlaybackView: View {
    let echo: Echo
    @Environment(\.dismiss) var dismiss
    @State private var player = AudioPlayerManager()
    @State private var scrubberProgress: Double = 0.0
    
    var body: some View {
        VStack(spacing: 0) {
            // Top App Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.neoCharcoal)
                }
                
                Spacer()
                
                Text(echo.title.uppercased())
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(.neoCharcoal)
                    .tracking(2)
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.neoCharcoal)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.neoBackground)
            
            // Memory Card & Controls
            VStack(spacing: 24) {
                // Simplified Memory Card
                VStack(spacing: 0) {
                    ZStack {
                        Rectangle()
                            .fill(Color(hex: echo.categoryColorHex).opacity(0.3))
                        
                        // Placeholder icon
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 56))
                            .foregroundColor(.neoCharcoal.opacity(0.3))
                        
                        // Actual image
                        if let filename = echo.coverImageFilename, !filename.isEmpty {
                            if filename.hasPrefix("dummy_") {
                                Image(filename)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                    .clipped()
                            } else if let url = StorageManager.shared.getCoverImageURL(filename: filename),
                                      let uiImage = UIImage(contentsOfFile: url.path) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                    .clipped()
                            }
                        }
                    }
                    .frame(height: 180)
                    .clipped()
                    .border(Color.neoCharcoal.opacity(0.2), width: 1)
                    .padding(12)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(echo.title)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.neoCharcoal)
                                .lineLimit(1)
                            
                            Text("\(echo.dateRecorded.formatted(date: .abbreviated, time: .omitted)) • \(echo.themeTag.uppercased())")
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
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .neoCharcoal, radius: 0, x: 4, y: 4)
                )
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.neoCharcoal, lineWidth: 3))
                .padding(.horizontal, 20)
                
                // Scrubber
                AudioScrubberView(
                    progress: $scrubberProgress,
                    currentTime: echo.formattedTime(player.currentTime),
                    totalTime: echo.formattedDuration,
                    joyPins: echo.joyPins.map { $0 / echo.duration },
                    onSeek: { newProgress in
                        player.seek(to: newProgress * echo.duration)
                    }
                )
                .padding(.horizontal, 24)
                .onChange(of: player.currentTime) { _, newValue in
                    // Only update scrubber from player if not being dragged
                    scrubberProgress = newValue / echo.duration
                }
                
                // Playback Controls
                HStack(spacing: 40) {
                    Button(action: { player.skipBackward() }) {
                        Image(systemName: "gobackward.10")
                            .font(.system(size: 28))
                            .foregroundColor(.neoCharcoal.opacity(0.6))
                    }
                    
                    Button(action: {
                        if player.isPlaying {
                            player.pause()
                        } else {
                            player.play()
                        }
                    }) {
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 32))
                    }
                    .buttonStyle(NeoRetroIconButtonStyle(backgroundColor: .neoPrimary, foregroundColor: .white, size: 72))
                    
                    Button(action: { player.skipForward() }) {
                        Image(systemName: "goforward.10")
                            .font(.system(size: 28))
                            .foregroundColor(.neoCharcoal.opacity(0.6))
                    }
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 24)
            .background(Color.neoBackground)
            
            Divider()
                .background(Color.neoCharcoal.opacity(0.2))
            
            // Memory Snippet View extending to bottom with mask
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "quote.opening")
                        .foregroundColor(.neoPrimary)
                        .font(.system(size: 14, weight: .bold))
                    Text("MEMORY SNIPPET")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.neoCharcoal.opacity(0.7))
                        .tracking(1)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                TranscriptView(transcript: echo.transcript)
            }
            .background(Color.neoBackground)
        }
        .background(Color.neoBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            if let url = StorageManager.shared.getAudioURL(filename: echo.audioFilename) {
                player.joyPins = echo.joyPins
                player.loadAudio(url: url)
            }
        }
        .onDisappear {
            player.pause()
        }
    }
}
