import SwiftUI
import SwiftData

struct VaultView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MemoryCard.date, order: .reverse) private var memories: [MemoryCard]
    @State private var searchText = ""
    @State private var selectedFilter: String? = nil
    @State private var showSettings = false
    
    let filters = ["Childhood", "Romance", "Travel", "Family", "Home"]
    
    var filteredMemories: [MemoryCard] {
        memories.filter { memory in
            let matchesSearch = searchText.isEmpty || memory.title.localizedCaseInsensitiveContains(searchText)
            let matchesFilter = selectedFilter == nil || memory.category.localizedCaseInsensitiveCompare(selectedFilter!) == .orderedSame
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
                        
                        Text("The Vault")
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
                    
                    // Grid
                    ScrollView {
                        if filteredMemories.isEmpty {
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
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(filteredMemories) { memory in
                                    NavigationLink(destination: Text("Connection view for \(memory.title)")) {
                                        MemoryCardTileView(memory: memory)
                                    }
                                }
                            }
                            .padding(.horizontal)
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
