//
//  StorageManager.swift
//  Echoes
//

import Foundation
import UIKit

enum StorageError: Error {
    case documentDirectoryNotFound
    case fileSaveFailed
    case fileLoadFailed
}

/// A helper class to handle saving and loading heavy media files (audio, images) to the device's local Document Directory.
final class StorageManager {
    static let shared = StorageManager()
    
    private init() {}
    
    /// The URL to the app's Document directory.
    private var documentDirectory: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    // MARK: - Audio
    
    /// Moves a temporary audio file into the Document directory and returns its new filename.
    /// - Parameter tempURL: The temporary URL where the recording was initially saved.
    /// - Returns: The filename string to be saved in SwiftData.
    func saveAudio(from tempURL: URL) throws -> String {
        guard let documentDir = documentDirectory else {
            throw StorageError.documentDirectoryNotFound
        }
        
        let filename = "echo_\(UUID().uuidString).m4a"
        let destinationURL = documentDir.appendingPathComponent(filename)
        
        do {
            // Move file instead of copying to clear up temp space immediately
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.moveItem(at: tempURL, to: destinationURL)
            return filename
        } catch {
            print("Failed to save audio file: \(error)")
            throw StorageError.fileSaveFailed
        }
    }
    
    /// Dynamically resolves the absolute path for an audio file at runtime.
    /// - Parameter filename: The filename saved in SwiftData.
    /// - Returns: The absolute URL to play the audio.
    func getAudioURL(filename: String) -> URL? {
        guard let documentDir = documentDirectory else { return nil }
        return documentDir.appendingPathComponent(filename)
    }
    
    /// Deletes an audio file from the Document directory.
    func deleteAudio(filename: String) {
        guard let url = getAudioURL(filename: filename) else { return }
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            print("Failed to delete audio file: \(error)")
        }
    }
    
    // MARK: - Images
    
    /// Saves image data into the Document directory and returns its filename.
    /// - Parameter data: The raw image data (e.g., JPEG or PNG data).
    /// - Returns: The filename string to be saved in SwiftData.
    func saveCoverImage(data: Data) throws -> String {
        guard let documentDir = documentDirectory else {
            throw StorageError.documentDirectoryNotFound
        }
        
        let filename = "cover_\(UUID().uuidString).jpg"
        let destinationURL = documentDir.appendingPathComponent(filename)
        
        do {
            try data.write(to: destinationURL, options: .atomic)
            return filename
        } catch {
            print("Failed to save cover image: \(error)")
            throw StorageError.fileSaveFailed
        }
    }
    
    /// Dynamically resolves the absolute path for a cover image at runtime.
    /// - Parameter filename: The filename saved in SwiftData.
    /// - Returns: The absolute URL to load the image.
    func getCoverImageURL(filename: String) -> URL? {
        guard let documentDir = documentDirectory else { return nil }
        return documentDir.appendingPathComponent(filename)
    }
    
    /// Deletes a cover image from the Document directory.
    func deleteCoverImage(filename: String) {
        guard let url = getCoverImageURL(filename: filename) else { return }
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            print("Failed to delete cover image: \(error)")
        }
    }
    
    // MARK: - Avatars
    
    /// Saves avatar image data into the Document directory and returns its filename.
    /// - Parameter data: The raw image data (e.g., JPEG or PNG data).
    /// - Returns: The filename string to be saved in SwiftData.
    func saveAvatarImage(data: Data) throws -> String {
        guard let documentDir = documentDirectory else {
            throw StorageError.documentDirectoryNotFound
        }
        
        let filename = "avatar_\(UUID().uuidString).jpg"
        let destinationURL = documentDir.appendingPathComponent(filename)
        
        do {
            try data.write(to: destinationURL, options: .atomic)
            return filename
        } catch {
            print("Failed to save avatar image: \(error)")
            throw StorageError.fileSaveFailed
        }
    }
    
    /// Dynamically resolves the absolute path for an avatar image at runtime.
    /// - Parameter filename: The filename saved in SwiftData.
    /// - Returns: The absolute URL to load the image.
    func getAvatarImageURL(filename: String) -> URL? {
        guard let documentDir = documentDirectory else { return nil }
        return documentDir.appendingPathComponent(filename)
    }
    
    /// Deletes an avatar image from the Document directory.
    func deleteAvatarImage(filename: String) {
        guard let url = getAvatarImageURL(filename: filename) else { return }
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            print("Failed to delete avatar image: \(error)")
        }
    }
    
    /// Seeds an avatar from an asset and returns the filename in Documents.
    func seedAvatar(fromAssetName name: String) -> String? {
        guard let documentDir = documentDirectory,
              let image = UIImage(named: name),
              let data = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        let filename = "avatar_seed_\(name).jpg"
        let destinationURL = documentDir.appendingPathComponent(filename)
        
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                return filename // Already seeded
            }
            try data.write(to: destinationURL, options: .atomic)
            return filename
        } catch {
            print("Failed to seed avatar from asset: \(error)")
            return nil
        }
    }
}
