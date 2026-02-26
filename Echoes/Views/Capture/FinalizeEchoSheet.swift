import SwiftUI
import PhotosUI
import SwiftData

struct FinalizeEchoSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    var prompt: Prompt?
    var audioURL: URL?
    var transcript: String?
    var onSave: () -> Void
    
    @State private var title: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var showImageSourceDialog = false
    @State private var showCamera = false
    @State private var showPhotosPicker = false
    
    init(prompt: Prompt? = nil, audioURL: URL? = nil, transcript: String? = nil, onSave: @escaping () -> Void) {
        self.prompt = prompt
        self.audioURL = audioURL
        self.transcript = transcript
        self.onSave = onSave
        _title = State(initialValue: prompt?.text ?? "")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 4) {
                    Text("Echo Captured!")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.neoCharcoal)
                    
                    Text("Analyzing audio & smiles...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.neoCharcoal.opacity(0.6))
                }
                .padding(.top, 24)
                
                // Polaroid Photo Placeholder
                Button(action: {
                    showImageSourceDialog = true
                }) {
                    ZStack {
                        Rectangle()
                            .fill(Color.neoBackground)
                            .frame(width: 180, height: 180)
                            .overlay(
                                Group {
                                    if let data = selectedImageData, let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 180, height: 180)
                                            .clipped()
                                            .cornerRadius(0)
                                    } else {
                                        VStack(spacing: 12) {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 40))
                                            Text("Add Photo")
                                                .font(.system(size: 14, weight: .bold))
                                        }
                                        .foregroundColor(.neoCharcoal)
                                    }
                                }
                            )
                            .border(Color.neoCharcoal, width: selectedImageData != nil ? 2 : 0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.neoCharcoal, style: StrokeStyle(lineWidth: 2, dash: selectedImageData != nil ? [] : [6]))
                            )
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Title Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("TITLE")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.neoCharcoal.opacity(0.4))
                        .padding(.leading, 4)
                    
                    TextField("", text: $title, prompt: Text("Name your echo...").foregroundColor(.neoCharcoal.opacity(0.25)))
                        .padding(16)
                        .background(Color.white)
                        .overlay(
                            Rectangle()
                                .stroke(Color.neoCharcoal, lineWidth: 2)
                        )
                        .font(.system(size: 18, weight: .bold))
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Save Button
                Button(action: saveEcho) {
                    Text("Save to Library")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(NeoRetroButtonStyle(backgroundColor: .neoPrimary, isPaddingEnabled: true))
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .background(Color.neoBackground.ignoresSafeArea())
            .confirmationDialog("Change Photo", isPresented: $showImageSourceDialog) {
                Button("Take Photo") {
                    showCamera = true
                }
                Button("Choose from Library") {
                    showPhotosPicker = true
                }
                Button("Cancel", role: .cancel) { }
            }
            .photosPicker(isPresented: $showPhotosPicker, selection: $selectedItem, matching: .images)
            .sheet(isPresented: $showCamera) {
                CameraPicker(imageData: $selectedImageData)
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
        }
    }
    
    private func saveEcho() {
        // Theme prediction! Use the transcript, fallback to prompt text if empty.
        let textToAnalyze = transcript ?? prompt?.text ?? ""
        let predictedTheme = ThemeAnalyzerService.shared.predictTheme(from: textToAnalyze)
        
        let newEcho = EchoCard(
            title: title.isEmpty ? (prompt?.text ?? "Untitled Echo") : title,
            category: predictedTheme,
            audioFileName: audioURL?.lastPathComponent,
            transcript: transcript,
            imageData: selectedImageData
        )
        
        modelContext.insert(newEcho)
        
        do {
            try modelContext.save()
            onSave()
            dismiss()
        } catch {
            print("Failed to save Echo: \(error.localizedDescription)")
        }
    }
}

// Simple Helper for Camera
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.imageData = uiImage.jpegData(compressionQuality: 0.8)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
