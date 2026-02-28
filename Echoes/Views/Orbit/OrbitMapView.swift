import SwiftUI

struct SpeakerSheetItem: Identifiable, Equatable {
    var id: String { name }
    let name: String
    let profile: SpeakerProfile?
}

struct OrbitMapView: View {
    var speakers: [(name: String, profile: SpeakerProfile?)] = []
    @State private var isAnimating = false
    
    // Sheet State
    @State private var selectedSpeakerName: String? = nil
    @State private var selectedSpeakerProfile: SpeakerProfile? = nil
    
    var body: some View {
        VStack {
            HStack {
                Text("People Recorded")
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
                    
                    let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    let displaySpeakers = Array(speakers.prefix(5))
                    let nodesCount = displaySpeakers.count + 1 // +1 for Invite
                    
                    // Lines
                    ForEach(0..<nodesCount, id: \.self) { index in
                        let pos = position(for: index, total: nodesCount, in: geometry.size)
                        Path { path in
                            path.move(to: center)
                            let offset: CGFloat = index % 2 == 0 ? 30 : -30
                            path.addQuadCurve(to: pos, control: CGPoint(x: (center.x + pos.x)/2 + offset, y: (center.y + pos.y)/2 - offset))
                        }
                        .stroke(Color.neoCharcoal, style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    }
                    
                    // Center Node (You)
                    // TODO: The user might also want to edit "You", relying on a special hardcoded profile name
                    let youProfile = speakers.first(where: { $0.name == "You" })?.profile
                    OrbitNode(title: "You", iconName: "person.fill", avatarFilename: youProfile?.avatarFilename, isCentral: true, color: .neoPrimary) {
                        selectedSpeakerName = "You"
                        selectedSpeakerProfile = youProfile
                    }
                    .position(center)
                    
                    // Dynamic Speaker Nodes
                    ForEach(Array(displaySpeakers.enumerated()), id: \.element.name) { index, speaker in
                        let pos = position(for: index, total: nodesCount, in: geometry.size)
                        OrbitNode(title: speaker.name, iconName: "person.2.fill", avatarFilename: speaker.profile?.avatarFilename, color: .white) {
                            selectedSpeakerName = speaker.name
                            selectedSpeakerProfile = speaker.profile
                        }
                        .position(pos)
                        .offset(y: isAnimating ? -5 : 5)
                        .animation(.easeInOut(duration: 2.5 + Double(index) * 0.2).repeatForever(autoreverses: true), value: isAnimating)
                    }
                    
                    // Invite Node
                    let inviteIndex = nodesCount - 1
                    let invitePos = position(for: inviteIndex, total: nodesCount, in: geometry.size)
                    OrbitNode(title: "Invite", iconName: "plus", color: .white, isGhost: true) {}
                        .position(invitePos)
                        .offset(y: isAnimating ? -3 : 3)
                        .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: isAnimating)
                }
            }
            .frame(height: 240)
            .onAppear {
                isAnimating = true
            }
        }
        .sheet(item: Binding<SpeakerSheetItem?>(
            get: {
                guard let name = selectedSpeakerName else { return nil }
                return SpeakerSheetItem(name: name, profile: selectedSpeakerProfile)
            },
            set: { item in
                if item == nil {
                    selectedSpeakerName = nil
                    selectedSpeakerProfile = nil
                }
            }
        )) { item in
            SpeakerProfileEditor(speakerName: item.name, existingProfile: item.profile)
                .presentationDetents([.medium])
        }
    }
    
    private func position(for index: Int, total: Int, in size: CGSize) -> CGPoint {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        // Leave margins
        let radius = min(size.width, size.height) * 0.35
        // Spread evenly, starting from top (-pi/2)
        let angle = CGFloat(index) / CGFloat(total) * 2 * .pi - .pi / 2
        return CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
    }
}

struct OrbitNode: View {
    var title: String
    var iconName: String
    var avatarFilename: String? = nil
    var isCentral: Bool = false
    var color: Color
    var isGhost: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        let size: CGFloat = isCentral ? 64 : 48
        
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
                    .shadow(color: .neoCharcoal, radius: 0, x: isCentral ? 4 : 2, y: isCentral ? 4 : 2)
                
                if let avatarFilename = avatarFilename,
                   let url = StorageManager.shared.getAvatarImageURL(filename: avatarFilename),
                   let uiImage = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: isCentral ? 28 : 20, weight: .bold))
                        .foregroundColor(isGhost ? .neoCharcoal.opacity(0.5) : .neoCharcoal)
                }
            }
            .overlay(
                Circle()
                    .stroke(Color.neoCharcoal, lineWidth: 2)
            )
            .onTapGesture {
                let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                impactHeavy.impactOccurred()
                action?()
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
