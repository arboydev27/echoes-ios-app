import SwiftUI

struct LegacyConstellationView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Legacy Constellation")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.neoCharcoal.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1.0)
                
                Spacer()
                
                Text("Live View")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.neoPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.neoPrimary.opacity(0.15))
                    .clipShape(Capsule())
            }
            .padding(.bottom, 8)
            
            // Constellation Map
            GeometryReader { geometry in
                ZStack {
                    // Background pattern
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.neoMaize)
                        .overlay(
                            // Optional: Dotted pattern
                            GeometryReader { geo in
                                Path { path in
                                    for x in stride(from: 0, to: geo.size.width, by: 20) {
                                        for y in stride(from: 0, to: geo.size.height, by: 20) {
                                            path.addEllipse(in: CGRect(x: x, y: y, width: 2, height: 2))
                                        }
                                    }
                                }
                                .fill(Color.neoPrimary.opacity(0.15))
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.neoCharcoal, lineWidth: 2)
                        )
                        .compositingGroup()
                        .shadow(color: .neoCharcoal, radius: 0, x: 4, y: 4)
                    
                    // Lines
                    Path { path in
                        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        let grandpaPos = CGPoint(x: geometry.size.width * 0.25, y: geometry.size.height * 0.25)
                        let momPos = CGPoint(x: geometry.size.width * 0.75, y: geometry.size.height * 0.3)
                        let invitePos = CGPoint(x: geometry.size.width * 0.75, y: geometry.size.height * 0.8)
                        
                        path.move(to: center)
                        path.addQuadCurve(to: grandpaPos, control: CGPoint(x: center.x * 0.8, y: center.y * 0.6))
                        
                        path.move(to: center)
                        path.addQuadCurve(to: momPos, control: CGPoint(x: center.x * 1.2, y: center.y * 0.8))
                        
                        path.move(to: center)
                        path.addQuadCurve(to: invitePos, control: CGPoint(x: center.x * 1.1, y: center.y * 1.2))
                    }
                    .stroke(Color.neoCharcoal, style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    
                    // Center Node (You)
                    ConstellationNode(title: "You", iconName: "person.fill", isCentral: true, color: .neoPrimary)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    
                    // Grandpa
                    ConstellationNode(title: "Grandpa", iconName: "person.2.fill", color: .white)
                        .position(x: geometry.size.width * 0.25, y: geometry.size.height * 0.25)
                        .offset(y: isAnimating ? -5 : 5)
                        .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isAnimating)
                    
                    // Mom
                    ConstellationNode(title: "Mom", iconName: "person.2.fill", color: .white)
                        .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.3)
                        .offset(y: isAnimating ? 5 : -5)
                        .animation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true), value: isAnimating)
                    
                    // Invite Node
                    ConstellationNode(title: "Invite", iconName: "plus", color: .white, isGhost: true)
                        .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.8)
                        .offset(y: isAnimating ? -3 : 3)
                        .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: isAnimating)
                }
            }
            .frame(height: 240)
            .onAppear {
                isAnimating = true
            }
        }
    }
}

struct ConstellationNode: View {
    var title: String
    var iconName: String
    var isCentral: Bool = false
    var color: Color
    var isGhost: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: isCentral ? 64 : 48, height: isCentral ? 64 : 48)
                    .overlay(
                        Circle()
                            .stroke(Color.neoCharcoal, lineWidth: 2)
                    )
                    .compositingGroup()
                    .shadow(color: .neoCharcoal, radius: 0, x: isCentral ? 4 : 2, y: isCentral ? 4 : 2)
                
                Image(systemName: iconName)
                    .font(.system(size: isCentral ? 28 : 20, weight: .bold))
                    .foregroundColor(isGhost ? .neoCharcoal.opacity(0.5) : .neoCharcoal)
            }
            .onTapGesture {
                let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                impactHeavy.impactOccurred()
            }
            
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isCentral ? Color.white : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.neoCharcoal.opacity(0.2), lineWidth: isCentral ? 1 : 0)
                )
                .foregroundColor(isGhost ? .neoCharcoal.opacity(0.6) : .neoCharcoal)
        }
    }
}
