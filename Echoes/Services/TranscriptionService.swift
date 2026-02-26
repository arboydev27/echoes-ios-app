import Foundation
import Speech
import Observation

@Observable
final class TranscriptionService {
    
    var isAuthorized: Bool = false
    var isTranscribing: Bool = false
    
    // Keep a strong reference to the recognizer and task while running
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    init() {
        // We could check authorization status on init, but we'll wait for explicit requests
    }
    
    func requestPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                Task { @MainActor in
                    let authorized = (status == .authorized)
                    self.isAuthorized = authorized
                    continuation.resume(returning: authorized)
                }
            }
        }
    }
    
    func transcribeAudio(url: URL) async -> String {
        await MainActor.run { isTranscribing = true }
        defer { Task { @MainActor in self.isTranscribing = false } }
        
        // Ensure authorization
        let authStatus = SFSpeechRecognizer.authorizationStatus()
        guard authStatus == .authorized else {
            return "Audio captured, but transcription was unavailable. (Not authorized)"
        }
        
        // Initialize recognizer
        speechRecognizer = SFSpeechRecognizer()
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            return "Audio captured, but speech recognizer is currently unavailable."
        }
        
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = false
        
        // Use a traditional completion handler mapped to async/await
        // since we only expect one final result or one error.
        return await withCheckedContinuation { continuation in
            let task = recognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self = self else { return }
                
                if let error = error {
                    continuation.resume(returning: "Audio captured, but transcription was unavailable. (\(error.localizedDescription))")
                    self.recognitionTask = nil
                    return
                }
                
                if let result = result, result.isFinal {
                    let text = result.bestTranscription.formattedString
                    let textResult = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Audio captured, but no speech was detected." : text
                    continuation.resume(returning: textResult)
                    self.recognitionTask = nil
                }
            }
            self.recognitionTask = task
        }
    }
}
