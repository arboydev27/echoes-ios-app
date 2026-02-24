import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Settings State
    @AppStorage("enableCountdown") private var enableCountdown = true
    @AppStorage("recordingQuality") private var recordingQuality = "High Fidelity"
    @AppStorage("privacyMode") private var privacyMode = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.neoBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Capture Settings Section
                        SettingsSection(title: "Capture") {
                            // Countdown Toggle
                            Toggle(isOn: $enableCountdown) {
                                SettingsRowLabel(icon: "timer", title: "3-Second Lead-in", subtitle: "Gives you a moment before recording starts.")
                            }
                            .tint(.neoMint)
                            
                            Divider().background(Color.neoCharcoal.opacity(0.3))
                            
                            // Recording Quality Picker
                            VStack(alignment: .leading, spacing: 12) {
                                SettingsRowLabel(icon: "waveform", title: "Recording Quality", subtitle: nil)
                                
                                Picker("Quality", selection: $recordingQuality) {
                                    Text("High Fidelity").tag("High Fidelity")
                                    Text("Space Saver").tag("Space Saver")
                                }
                                .pickerStyle(.segmented)
                                .colorMultiply(.neoMint)
                            }
                        }
                        
                        // Privacy & Security Section
                        SettingsSection(title: "Privacy & Security") {
                            Toggle(isOn: $privacyMode) {
                                SettingsRowLabel(icon: "faceid", title: "Privacy Mode", subtitle: "Lock the Vault with FaceID/TouchID.")
                            }
                            .tint(.neoMint)
                            
                            Divider().background(Color.neoCharcoal.opacity(0.3))
                            
                            Button(action: {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    SettingsRowLabel(icon: "mic.and.signal.meter", title: "Manage Permissions", subtitle: "Camera and Microphone access.")
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(.neoCharcoal.opacity(0.5))
                                }
                            }
                        }
                        
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.neoCharcoal)
                    }
                }
            }
        }
    }
}

// Custom subcomponents for the neo-retro setting rows

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.neoCharcoal.opacity(0.6))
                .padding(.leading, 4)
            
            VStack(alignment: .leading, spacing: 16) {
                content
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neoCharcoal, lineWidth: 2)
            )
            .compositingGroup()
            .shadow(color: .neoCharcoal, radius: 0, x: 2, y: 2)
        }
    }
}

struct SettingsRowLabel: View {
    let icon: String
    let title: String
    let subtitle: String?
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.neoCharcoal)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.neoCharcoal)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.neoCharcoal.opacity(0.7))
                }
            }
        }
    }
}
