import Foundation
import AVFoundation

@Observable
final class AudioRecorderManager: NSObject, AVAudioRecorderDelegate {
    var isRecording = false
    var isPaused = false
    var decibelLevel: Double = -60.0
    var currentTime: TimeInterval = 0.0
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var tempURL: URL?
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, AVAudioSession.CategoryOptions.allowBluetooth])
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func startRecording(quality: String = "Space Saver") {
        let tempDir = FileManager.default.temporaryDirectory
        let filename = "temp_recording_\(UUID().uuidString).m4a"
        let fileURL = tempDir.appendingPathComponent(filename)
        self.tempURL = fileURL
        
        let sampleRate: Double = (quality == "Space Saver") ? 22050 : 44100
        let encoderQuality: AVAudioQuality = (quality == "Space Saver") ? .medium : .high
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: encoderQuality.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            
            
            isRecording = true
            isPaused = false
            currentTime = 0.0
            startMetering()
        } catch {
            print("Failed to start recording: \(error)")
            isRecording = false
            stopMetering()
        }
    }
    
    func pauseRecording() {
        guard isRecording, !isPaused else { return }
        audioRecorder?.pause()
        isPaused = true
        stopMetering()
    }
    
    func resumeRecording() {
        guard isRecording, isPaused else { return }
        audioRecorder?.record()
        isPaused = false
        startMetering()
    }
    
    func stopRecording() -> URL? {
        audioRecorder?.stop()
        isRecording = false
        isPaused = false
        stopMetering()
        return tempURL
    }
    
    private func startMetering() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let recorder = self.audioRecorder else { return }
            recorder.updateMeters()
            let power = recorder.averagePower(forChannel: 0)
            self.decibelLevel = Double(power)
            self.currentTime = recorder.currentTime
        }
    }
    
    private func stopMetering() {
        timer?.invalidate()
        timer = nil
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            isRecording = false
            isPaused = false
            stopMetering()
            print("Recording finished unsuccessfully")
        }
    }
}
