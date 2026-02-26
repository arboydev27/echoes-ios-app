import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \EchoCard.date, order: .reverse) private var echoes: [EchoCard]
    @State private var searchText = ""
    @State private var selectedFilter: String? = nil
    @State private var showSettings = false
    
    let filters = ["Childhood", "Romance", "Travel", "Family", "Home"]
    
    var filteredEchoes: [EchoCard] {
        echoes.filter { echo in
            let matchesSearch = searchText.isEmpty || echo.title.localizedCaseInsensitiveContains(searchText)
            let matchesFilter = selectedFilter == nil || echo.category.localizedCaseInsensitiveCompare(selectedFilter!) == .orderedSame
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
                    
                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.neoCharcoal)
                        TextField("Search memories...", text: $searchText)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.neoCharcoal)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.neoCharcoal, lineWidth: 2)
                    )
                    .compositingGroup()
                    .shadow(color: .neoCharcoal, radius: 0, x: 2, y: 2)
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
                                        
                                        TabView {
                                            ForEach(featuredEchoes) { echo in
                                                NavigationLink(destination: Text("Connection view for \(echo.title)")) {
                                                    FeaturedMemoryCardView(echo: echo)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        // Use index display mode but add padding internally to card so dots fall below it
                                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                                        .frame(height: 440) // Adjusted height
                                        .onAppear {
                                            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.neoInk)
                                            UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.neoPrimary)
                                        }
                                    }
                                }
                                
                                if !remainingEchoes.isEmpty {
                                    LazyVGrid(columns: columns, spacing: 16) {
                                        ForEach(remainingEchoes) { echo in
                                            NavigationLink(destination: Text("Connection view for \(echo.title)")) {
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
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
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
            .background(isSelected ? Color.neoCharcoal : Color.white)
            .foregroundColor(isSelected ? .white : .neoCharcoal)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.neoCharcoal, lineWidth: 2)
            )
            .compositingGroup()
            .shadow(color: isSelected ? .clear : .neoCharcoal, radius: 0, x: 2, y: 2)
            .offset(x: isSelected ? 2 : 0, y: isSelected ? 2 : 0)
        }
    }
}
