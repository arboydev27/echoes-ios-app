import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("privacyMode") private var privacyMode = false
    
    @Query(sort: \Echo.dateRecorded, order: .reverse) private var echoes: [Echo]
    @State private var searchText = ""
    @State private var selectedFilter: String? = nil
    @State private var showSettings = false
    @State private var currentFeaturedEchoID: UUID?
    @State private var selectedPlaybackEcho: Echo? = nil
    @State private var isUnlocked = false
    
    let filters = ["Childhood", "Romance", "Travel", "Family", "Home"]
    
    var filteredEchoes: [Echo] {
        echoes.filter { echo in
            let matchesSearch = searchText.isEmpty || echo.title.localizedCaseInsensitiveContains(searchText)
            let matchesFilter = selectedFilter == nil || echo.themeTag.localizedCaseInsensitiveCompare(selectedFilter!) == .orderedSame
            return matchesSearch && matchesFilter
        }
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
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
                        
                        Text("The Library")
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundColor(.neoCharcoal)
                        
                        Spacer()
                        
                        Color.clear.frame(width: 24, height: 24)
                    }
                    .padding()
                    
                    if privacyMode && !isUnlocked {
                        lockedStateOverlay
                    } else {
                        libraryContent
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .fullScreenCover(item: $selectedPlaybackEcho) { echo in
            ConnectionPlaybackView(echo: echo)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background || newPhase == .inactive {
                if privacyMode {
                    isUnlocked = false
                }
            }
        }
        .onAppear {
            if !privacyMode {
                isUnlocked = true
            }
        }
    }
    
    private var libraryContent: some View {
        VStack(spacing: 0) {
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.neoCharcoal)
                TextField("Search memories...", text: $searchText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.neoCharcoal)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .neoCharcoal, radius: 0, x: 2, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neoCharcoal, lineWidth: 2)
            )
            .padding(.horizontal)
            .padding(.bottom, 16)
            
            // Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(title: "All Memories", icon: "star.fill", isSelected: selectedFilter == nil) {
                        selectedFilter = nil
                    }
                    
                    ForEach(filters, id: \.self) { filter in
                        FilterChip(title: filter, icon: iconForCategory(filter), isSelected: selectedFilter == filter) {
                            selectedFilter = filter
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            
            // Layout
            ScrollView {
                if filteredEchoes.isEmpty {
                    VStack(spacing: 16) {
                        Spacer().frame(height: 48)
                        Image(systemName: "auto.stories")
                            .font(.system(size: 48))
                            .foregroundColor(.neoCharcoal.opacity(0.3))
                        Text("No memories found")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.neoCharcoal.opacity(0.5))
                    }
                } else {
                    VStack(spacing: 24) {
                        let featuredCount = min(filteredEchoes.count, 3)
                        let featuredEchoes = Array(filteredEchoes.prefix(featuredCount))
                        let remainingEchoes = Array(filteredEchoes.dropFirst(featuredCount))
                        
                        if !featuredEchoes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Featured Echoes")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.neoCharcoal)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 20) {
                                        ForEach(featuredEchoes) { echo in
                                            Button(action: {
                                                selectedPlaybackEcho = echo
                                            }) {
                                                FeaturedMemoryCardView(echo: echo)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .containerRelativeFrame(.horizontal)
                                        }
                                    }
                                    .scrollTargetLayout()
                                }
                                .scrollTargetBehavior(.viewAligned)
                                .safeAreaPadding(.horizontal, 32)
                                .scrollPosition(id: $currentFeaturedEchoID)
                                .onAppear {
                                    if currentFeaturedEchoID == nil {
                                        currentFeaturedEchoID = featuredEchoes.first?.id
                                    }
                                }
                                
                                // Custom Paging Dots
                                if featuredEchoes.count > 1 {
                                    HStack(spacing: 8) {
                                        ForEach(featuredEchoes) { echo in
                                            Circle()
                                                .fill(currentFeaturedEchoID == echo.id ? Color.neoInk : Color.neoPrimary)
                                                .frame(width: 8, height: 8)
                                                .animation(.easeInOut(duration: 0.2), value: currentFeaturedEchoID)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 16)
                                    .padding(.bottom, 8)
                                }
                            }
                        }
                        
                        if !remainingEchoes.isEmpty {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(remainingEchoes) { echo in
                                    Button(action: {
                                        selectedPlaybackEcho = echo
                                    }) {
                                        EchoCardTileView(echo: echo)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 100) // Account for TabBar
                }
            }
        }
    }
    
    private var lockedStateOverlay: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(.neoCharcoal)
            
            VStack(spacing: 8) {
                Text("Library Locked")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.neoCharcoal)
                
                Text("Privacy Mode is active. Use FaceID or TouchID to view your echoes.")
                    .font(.system(size: 16))
                    .foregroundColor(.neoCharcoal.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                Task {
                    let success = await BiometricAuthService.shared.authenticate()
                    if success {
                        withAnimation {
                            isUnlocked = true
                        }
                    }
                }
            }) {
                HStack {
                    Image(systemName: "faceid")
                    Text("Unlock Library")
                }
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(Color.neoCharcoal)
                .cornerRadius(12)
                .shadow(color: .neoCharcoal.opacity(0.3), radius: 0, x: 4, y: 4)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity)
    }
    
    func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "childhood": return "figure.child"
        case "romance": return "heart.fill"
        case "travel": return "airplane"
        case "family": return "person.2.fill"
        case "home": return "house.fill"
        default: return "star.fill"
        }
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.neoCharcoal : Color.white)
                    .shadow(color: isSelected ? .clear : .neoCharcoal, radius: 0, x: 2, y: 2)
            )
            .foregroundColor(isSelected ? .white : .neoCharcoal)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.neoCharcoal, lineWidth: 2)
            )
            .offset(x: isSelected ? 2 : 0, y: isSelected ? 2 : 0)
        }
    }
}
