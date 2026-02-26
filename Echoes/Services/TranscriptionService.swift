import Foundation
import Speech
import AVFoundation
import Observation

@Observable
final class TranscriptionService {
    
    var isAuthorized: Bool = false
    var isTranscribing: Bool = false
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionTask: SFSpeechRecognitionTask?
    
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
        var authStatus = SFSpeechRecognizer.authorizationStatus()
        if authStatus == .notDetermined {
            _ = await requestPermission()
            authStatus = SFSpeechRecognizer.authorizationStatus()
        }
        guard authStatus == .authorized else {
            return "Audio captured, but transcription was unavailable. (Not authorized)"
        }
        
        // Use the device's current locale
        let locale = Locale.current
        speechRecognizer = SFSpeechRecognizer(locale: locale)
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            return "Audio captured, but speech recognizer is unavailable."
        }
        
        // Use buffer-based request — URL-based request truncates at ~15s on-device.
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = false
        
        return await withCheckedContinuation { continuation in
            var hasResumed = false
            var accumulatedSegments: [String] = []
            var taskRef: SFSpeechRecognitionTask?
            
            // Finalize helper — always dispatches to main queue for thread safety
            let finalize: (String?) -> Void = { errorMessage in
                DispatchQueue.main.async {
                    guard !hasResumed else { return }
                    hasResumed = true
                    taskRef?.cancel()
                    taskRef = nil
                    self.recognitionTask = nil
                    
                    if !accumulatedSegments.isEmpty {
                        continuation.resume(returning: accumulatedSegments.joined(separator: " "))
                    } else if let msg = errorMessage {
                        continuation.resume(returning: msg)
                    } else {
                        continuation.resume(returning: "Audio captured, but no speech was detected.")
                    }
                }
            }
            
            // STEP 1: Create the recognition task FIRST so the callback is registered
            // before any audio is delivered. This is the correct order per Apple's design.
            let task = recognizer.recognitionTask(with: request) { result, error in
                if let result = result, result.isFinal {
                    let text = result.bestTranscription.formattedString
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    if !text.isEmpty {
                        accumulatedSegments.append(text)
                    }
                }
                
                // Finalize on error (the normal "stream ended" signal after endAudio)
                if let error = error {
                    let isStreamEndedError = (error as NSError).code == 301 ||
                                             (error as NSError).code == 203 ||
                                             (error as NSError).code == 216
                    if isStreamEndedError || !accumulatedSegments.isEmpty {
                        // Normal end-of-stream or we have content — return what we have
                        finalize(nil)
                    } else {
                        finalize("Audio captured, but transcription failed. (\(error.localizedDescription))")
                    }
                    return
                }
                
                // Also finalize if isFinal with no error AND task is finishing/completed.
                // Some on-device builds don't send a trailing error after endAudio().
                if result?.isFinal == true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        // If no error callback came in 1.5s, this was the true final result
                        if taskRef?.state == .completed || taskRef?.state == .finishing {
                            finalize(nil)
                        }
                    }
                }
            }
            taskRef = task
            self.recognitionTask = task
            
            // STEP 2: Feed the audio file buffers in the background AFTER the task is created.
            Task.detached(priority: .userInitiated) {
                do {
                    let audioFile = try AVAudioFile(forReading: url)
                    let format = audioFile.processingFormat
                    let chunkSize: AVAudioFrameCount = 4096
                    var framesRead: AVAudioFramePosition = 0
                    
                    while framesRead < audioFile.length {
                        let remaining = AVAudioFrameCount(audioFile.length - framesRead)
                        let currentChunk = min(chunkSize, remaining)
                        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: currentChunk) else { break }
                        try audioFile.read(into: buffer, frameCount: currentChunk)
                        request.append(buffer)
                        framesRead += AVAudioFramePosition(currentChunk)
                    }
                    // Signal end of audio stream
                    request.endAudio()
                } catch {
                    request.endAudio()
                    finalize("Audio captured, but the audio file could not be read. (\(error.localizedDescription))")
                }
            }
            
            // STEP 3: Safety timeout — if nothing resolves after the recording duration + buffer,
            // finalize with whatever we have accumulated so far.
            DispatchQueue.global().asyncAfter(deadline: .now() + 60.0) {
                finalize(nil)
            }
        }
    }
}
