import SwiftUI
import StoreKit
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    @Environment(\.modelContext) private var modelContext
    
    // Settings State
    @AppStorage("enableCountdown") private var enableCountdown = true
    @AppStorage("recordingQuality") private var recordingQuality = "High Fidelity"
    @AppStorage("privacyMode") private var privacyMode = false
    
    // Alert State
    @State private var showResetAlert = false
    
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
                                SettingsRowLabel(icon: "faceid", title: "Privacy Mode", subtitle: "Lock the Library with FaceID/TouchID.")
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
                        
                        // Legacy & Community Section
                        SettingsSection(title: "Legacy & Community") {
                            ShareLink(item: URL(string: "https://echoes-app.com")!) {
                                HStack {
                                    SettingsRowLabel(icon: "square.and.arrow.up", title: "Share Echoes", subtitle: "Invite friends and family.")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.neoCharcoal.opacity(0.3))
                                    }
                            }
                            
                            Divider().background(Color.neoCharcoal.opacity(0.3))
                            
                            Button(action: {
                                requestReview()
                            }) {
                                HStack {
                                    SettingsRowLabel(icon: "star.bubble", title: "Leave a Review", subtitle: "Tell us about your experience.")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.neoCharcoal.opacity(0.3))
                                }
                            }
                        }
                        
                        // Support & About Section
                        SettingsSection(title: "Support & About") {
                            NavigationLink(destination: Text("Quick Start Guide details here.")
                                .font(.title3)
                                .foregroundColor(.neoCharcoal)
                                .navigationTitle("Help & Tutorials")
                                .navigationBarTitleDisplayMode(.inline)) {
                                HStack {
                                    SettingsRowLabel(icon: "questionmark.circle", title: "Help & Tutorials", subtitle: "Learn how to use Echoes.")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.neoCharcoal.opacity(0.3))
                                }
                            }
                            
                            Divider().background(Color.neoCharcoal.opacity(0.3))
                            
                            NavigationLink(destination: ScrollView {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Meet the Developer")
                                        .font(.largeTitle.weight(.heavy))
                                        .foregroundColor(.neoCharcoal)
                                    Text("Hi! I'm Arboy Magomba, and I built Echoes for the Swift Student Challenge 2026. My goal is to capture memories authentically.")
                                        .font(.body)
                                        .foregroundColor(.neoCharcoal)
                                        .lineSpacing(6)
                                }
                                .padding()
                                .navigationTitle("About Me")
                                .navigationBarTitleDisplayMode(.inline)
                            }) {
                                HStack {
                                    SettingsRowLabel(icon: "person.text.rectangle", title: "Meet the Developer", subtitle: "Swift Student Challenge 2026")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.neoCharcoal.opacity(0.3))
                                }
                            }
                            
                            Divider().background(Color.neoCharcoal.opacity(0.3))
                            
                            Button(action: {
                                if let url = URL(string: "mailto:arboydev@gmail.com") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    SettingsRowLabel(icon: "envelope", title: "Send Feedback", subtitle: "I'd love to hear from you.")
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(.neoCharcoal.opacity(0.3))
                                }
                            }
                        }
                        
                        // Housekeeping Section
                        SettingsSection(title: "Housekeeping") {
                            NavigationLink(destination: ScrollView {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Your stories never leave this device. Echoes is 100% private. All data is stored strictly on-device only.")
                                        .font(.body)
                                        .foregroundColor(.neoCharcoal)
                                        .lineSpacing(6)
                                }
                                .padding()
                                .navigationTitle("Privacy & Terms")
                                .navigationBarTitleDisplayMode(.inline)
                            }) {
                                HStack {
                                    SettingsRowLabel(icon: "lock.shield", title: "Privacy Policy & Terms", subtitle: "On-Device Only")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.neoCharcoal.opacity(0.3))
                                }
                            }
                            
                            Divider().background(Color.neoCharcoal.opacity(0.3))
                            
                            Button(action: {
                                showResetAlert = true
                            }) {
                                HStack {
                                    SettingsRowLabel(icon: "trash", title: "Reset Data", subtitle: "Clear all echoes in the library.", tintColor: .red)
                                    Spacer()
                                }
                            }
                        }
                        
                        // Version Info
                        VStack(spacing: 4) {
                            Text("Echoes v1.0.0 (Build 2026)")
                                .font(.system(size: 12, weight: .bold))
                            Text("Created with ♥ for Swift Student Challenge")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.neoCharcoal.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                        
                    }
                    .padding()
                }
                .alert("Reset All Data?", isPresented: $showResetAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        do {
                            try modelContext.delete(model: Echo.self)
                        } catch {
                            print("Error clearing data: \(error)")
                        }
                    }
                } message: {
                    Text("This action cannot be undone. All your memories will be permanently deleted from this device.")
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
    var tintColor: Color = .neoCharcoal
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(tintColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(tintColor)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(tintColor.opacity(0.7))
                }
            }
        }
    }
}
