import SwiftUI
import SwiftData
import PhotosUI

struct SpeakerProfileEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let speakerName: String
    let existingProfile: SpeakerProfile?
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    // Camera Support
    @State private var showPhotoSourceChoice = false
    @State private var showCameraPicker = false
    @State private var capturedImage: UIImage? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(speakerName)
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.neoCharcoal)
                    .padding(.top, 24)
                
                Menu {
                    Button(action: { showCameraPicker = true }) {
                        Label("Take Photo", systemImage: "camera")
                    }
                    
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        Label("Choose from Library", systemImage: "photo.on.rectangle")
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.neoPrimary.opacity(0.1))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Circle().stroke(Color.neoPrimary, lineWidth: 2)
                            )
                        if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else if let filename = existingProfile?.avatarFilename,
                                  let url = StorageManager.shared.getAvatarImageURL(filename: filename),
                                  let uiImage = UIImage(contentsOfFile: url.path) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.neoPrimary)
                        }
                        
                        // Edit Badge
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle()
                                        .fill(Color.neoCharcoal)
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .offset(x: 10, y: 10)
                            }
                        }
                    }
                    .frame(width: 120, height: 120)
                }
                .sheet(isPresented: $showCameraPicker) {
                    ImagePicker(selectedImage: $capturedImage)
                }
                .onChange(of: capturedImage) { _, newImage in
                    if let newImage = newImage {
                        selectedImageData = newImage.jpegData(compressionQuality: 0.8)
                    }
                }
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                        }
                    }
                }
                
                Spacer()
                
                Button(action: saveProfile) {
                    Text("Save Avatar")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.neoCharcoal)
                        .cornerRadius(16)
                        .shadow(color: .neoCharcoal.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.neoCharcoal)
                }
            }
        }
    }
    
    private func saveProfile() {
        var finalFilename = existingProfile?.avatarFilename
        
        // Save new image if selected
        if let data = selectedImageData {
            do {
                if let oldFilename = finalFilename {
                    StorageManager.shared.deleteAvatarImage(filename: oldFilename)
                }
                finalFilename = try StorageManager.shared.saveAvatarImage(data: data)
            } catch {
                print("Error saving image: \(error)")
                return
            }
        }
        
        // Update or create profile
        if let profile = existingProfile {
            profile.avatarFilename = finalFilename
        } else {
            let newProfile = SpeakerProfile(name: speakerName, avatarFilename: finalFilename)
            modelContext.insert(newProfile)
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
