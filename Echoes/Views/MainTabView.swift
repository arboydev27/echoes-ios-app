import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showCapture = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                LibraryView()
                    .tag(0)
                
                KindleView()
                    .tag(1)
                
                Color.clear
                    .tag(2)
                
                OrbitView()
                    .tag(3)
            }
            .toolbar(.hidden, for: .tabBar)
            
            CustomTabBar(selectedTab: $selectedTab, showCapture: $showCapture)
        }
        .fullScreenCover(isPresented: $showCapture) {
            CaptureView(startImmediately: false)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var showCapture: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(icon: "film.stack.fill", title: "Library", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabBarButton(icon: "flame.fill", title: "Kindle", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            TabBarButton(icon: "mic.fill", title: "Capture", isSelected: false) {
                showCapture = true
            }
            
            TabBarButton(icon: "circle.hexagonpath", title: "Orbit", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 32)
        .background(Color.neoBackground)
        .overlay(
            Rectangle()
                .frame(height: 2)
                .foregroundColor(.neoCharcoal),
            alignment: .top
        )
    }
}

struct TabBarButton: View {
    var icon: String
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .textCase(.uppercase)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? .neoPrimary : .neoCharcoal.opacity(0.5))
        }
    }
}
