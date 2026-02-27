import SwiftUI
import SwiftData

struct SavedEchoesView: View {
    @Query(filter: #Predicate<Echo> { $0.isFavorite }, sort: \Echo.dateRecorded, order: .reverse) private var savedEchoes: [Echo]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlaybackEcho: Echo? = nil
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.neoBackground.ignoresSafeArea()
                
                if savedEchoes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.neoCharcoal.opacity(0.3))
                        Text("No saved echoes yet")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.neoCharcoal.opacity(0.5))
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(savedEchoes) { echo in
                                Button(action: {
                                    selectedPlaybackEcho = echo
                                }) {
                                    EchoCardTileView(echo: echo)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Saved Echoes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.neoCharcoal)
                    }
                }
            }
            .fullScreenCover(item: $selectedPlaybackEcho) { echo in
                ConnectionPlaybackView(echo: echo)
            }
        }
    }
}
