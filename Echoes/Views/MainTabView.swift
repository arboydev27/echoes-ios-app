import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 1
    @State private var showCapture = false
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                Group {
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
            }
            
            CustomTabBar(selectedTab: $selectedTab, showCapture: $showCapture)
        }
        .fullScreenCover(isPresented: $showCapture) {
            CaptureView(startImmediately: false)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var showCapture: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Main Pill
            HStack(spacing: 0) {
                TabBarButton(icon: "flame.fill", title: "Kindle", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                
                TabBarButton(icon: "mic.fill", title: "Capture", isSelected: false) {
                    showCapture = true
                }
                
                TabBarButton(icon: "film.stack.fill", title: "Library", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
            }
            .frame(height: 72)
            .background(.regularMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(.white.opacity(0.5), lineWidth: 0.5)
                    .blendMode(.overlay)
            )
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            
            // Orbit Button
            Button(action: {
                selectedTab = 3
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "circle.hexagonpath")
                        .font(.system(size: 24))
                    Text("Orbit")
                        .font(.system(size: 10, weight: .bold))
                        .textCase(.uppercase)
                }
                .frame(width: 72, height: 72)
                .foregroundColor(selectedTab == 3 ? .neoPrimary : .neoCharcoal.opacity(0.5))
                .background(.regularMaterial)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.5), lineWidth: 0.5)
                        .blendMode(.overlay)
                )
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
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
