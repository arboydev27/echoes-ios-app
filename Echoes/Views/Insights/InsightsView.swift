import SwiftUI
import SwiftData

struct InsightsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var memoryCards: [MemoryCard]
    
    @State private var viewModel = InsightsViewModel()
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.neoBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header Title Region (Optional if using NavigationTitle)
                        HStack {
                            Button(action: { showSettings = true }) {
                                Image(systemName: "line.3.horizontal")
                                    .font(.title3)
                                    .foregroundColor(.neoCharcoal)
                            }
                            
                            Spacer()
                            
                            Text("Orbit")
                                .font(.system(size: 28, weight: .heavy))
                                .foregroundColor(.neoCharcoal)
                            
                            Spacer()
                            
                            Color.clear.frame(width: 24, height: 24)
                        }
                        .padding(.top, 8)
                        
                        // Main Sections
                        LegacyConstellationView()
                            .padding(.vertical, 8)
                        
                        VStack(spacing: 4) {
                            Text("\(viewModel.totalMemories)")
                                .font(.system(size: 36, weight: .heavy))
                                .foregroundColor(.neoCharcoal)
                            
                            Text("Memories Preserved")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.neoCharcoal.opacity(0.7))
                                .textCase(.uppercase)
                                .tracking(1.5)
                        }
                        .padding(.bottom, 8)
                        
                        VitalStatsGrid(viewModel: viewModel)
                        
                        NextEchoNudge(leastCategory: viewModel.leastCategory)
                            .padding(.top, 8)
                            .padding(.bottom, 100) // Space for TabBar
                    }
                    .padding(.horizontal, 20)
                }
            }
            .onAppear {
                // Animate changes or just calculate normally
                withAnimation(.spring()) {
                    viewModel.calculateStats(from: memoryCards)
                }
            }
            .onChange(of: memoryCards) { _, newCards in
                withAnimation(.spring()) {
                    viewModel.calculateStats(from: newCards)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

#Preview {
    InsightsView()
        .modelContainer(for: MemoryCard.self, inMemory: true)
}
