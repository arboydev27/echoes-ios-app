import Foundation
import SwiftData
import AVFoundation

enum CaptureState: Equatable {
    case idle
    case countdown
    case recording
    case paused
    case processing
    case finalizing
    case saved
    case error(String)
}

@Observable
final class CaptureSessionManager {
    // Service Instances
    let audioManager = AudioRecorderManager()
    let cameraService = CameraStreamService()
    let faceTracker = FaceTrackingService()
    let transcriber = TranscriptionService()
    let themeAnalyzer = ThemeAnalyzerService.shared
    
    // Orchestration State
    var state: CaptureState = .idle
    var countdown: Int = 3
    var transcript: String = ""
    var themeTag: String = ""
    var tempAudioURL: URL?
    var hasPermissions: Bool = false
    
    var recordingQuality: String = "High Fidelity"
    
    // Timer for countdown
    private var countdownTimer: Timer?
    
    @MainActor
    func requestAllPermissions() async -> Bool {
        // Microphone
        let audioGranted = await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        guard audioGranted else { return false }
        
        // Camera
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let cameraGranted: Bool
        if cameraStatus == .notDetermined {
            cameraGranted = await AVCaptureDevice.requestAccess(for: .video)
        } else {
            cameraGranted = (cameraStatus == .authorized)
        }
        guard cameraGranted else { return false }
        
        // Speech Recognition
        let speechGranted = await transcriber.requestPermission()
        
        let allGranted = audioGranted && cameraGranted && speechGranted
        self.hasPermissions = allGranted
        return allGranted
    }
    
    // MARK: - Sequence Methods
    
    func startSequence(withCountdown: Bool = true, quality: String = "High Fidelity") {
        guard state == .idle || state == .error("") else { return }
        
        self.recordingQuality = quality
        
        if !withCountdown {
            beginRecording()
            return
        }
        
        state = .countdown
        countdown = 3
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            DispatchQueue.main.async {
                if self.countdown > 1 {
                    self.countdown -= 1
                } else {
                    self.countdown = 0
                    timer.invalidate()
                    self.beginRecording()
                }
            }
        }
    }
    
    private func beginRecording() {
        state = .recording
        
        // Connect Face Tracker to Audio Manager (to get timestamps)
        faceTracker.attach(audioManager: audioManager)
        faceTracker.reset()
        
        // Map Camera frames to Face Tracker
        cameraService.onFrameGenerated = { [weak self] sampleBuffer in
            self?.faceTracker.process(sampleBuffer: sampleBuffer)
        }
        
        cameraService.startSession()
        audioManager.startRecording(quality: recordingQuality)
    }
    
    func pauseRecording() {
        guard state == .recording else { return }
        
        state = .paused
        audioManager.pauseRecording()
        // Note: Camera feed is kept alive intentionally to avoid black screen, but audio recording is paused. 
        // We could pause camera processing here too if needed for performance.
    }
    
    func resumeRecording() {
        guard state == .paused else { return }
        
        state = .recording
        audioManager.resumeRecording()
    }
    
    func stopAndProcessSequence() {
        guard state == .recording || state == .paused else { return }
        
        state = .processing
        
        // 1. Stop Recording
        cameraService.stopSession()
        let audioURL = audioManager.stopRecording()
        self.tempAudioURL = audioURL
        
        guard let url = audioURL else {
            state = .error("Failed to get audio recording.")
            return
        }
        
        // 2. Process async
        Task {
            let finalTranscript = await transcriber.transcribeAudio(url: url)
            
            let finalTheme: String
            if finalTranscript.isEmpty || finalTranscript.starts(with: "Audio captured, but") {
               finalTheme = "General"
            } else {
               finalTheme = themeAnalyzer.predictTheme(from: finalTranscript)
            }
            
            await MainActor.run {
                self.transcript = finalTranscript
                self.themeTag = finalTheme
                self.state = .finalizing
            }
        }
    }
    
    func finalCommit(title: String, promptText: String, coverImageData: Data?, modelContext: ModelContext) async throws {
        guard state == .finalizing, let tempURL = tempAudioURL else { return }
        
        // Move Audio to FileManager
        let finalAudioFilename = try StorageManager.shared.saveAudio(from: tempURL)
        
        // Process Image if exists
        var finalCoverFilename: String?
        if let imageData = coverImageData {
            finalCoverFilename = try StorageManager.shared.saveCoverImage(data: imageData)
        }
        
        // Extract joy pins
        let pins = faceTracker.joyPins
        let finalDuration = audioManager.currentTime // Use the time recorded at the stop point
        
        // Instantiate Echo
        let echo = Echo(
            title: title,
            promptText: promptText,
            duration: finalDuration,
            transcript: self.transcript,
            themeTag: self.themeTag,
            joyPins: pins,
            audioFilename: finalAudioFilename,
            coverImageFilename: finalCoverFilename
        )
        
        // Insert and Save
        modelContext.insert(echo)
        try modelContext.save()
        
        await MainActor.run {
            self.state = .saved
        }
    }
    
    func reset() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        // Try to clear temporary audio file if we canceled before saving
        if let tempURL = tempAudioURL, state != .saved {
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        _ = audioManager.stopRecording() // safe to call if not recording
        cameraService.stopSession()
        faceTracker.reset()
        
        tempAudioURL = nil
        transcript = ""
        themeTag = ""
        countdown = 3
        state = .idle
    }
}
