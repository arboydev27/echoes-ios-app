import Foundation
import AVFoundation
import CoreHaptics

@Observable
final class AudioPlayerManager: NSObject, AVAudioPlayerDelegate {
    var isPlaying = false
    var currentTime: TimeInterval = 0.0
    var duration: TimeInterval = 0.0
    var joyPins: [TimeInterval] = []
    
    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: Timer?
    private var hapticEngine: CHHapticEngine?
    private var lastTriggeredPinTime: TimeInterval = -1.0
    
    override init() {
        super.init()
        setupHaptics()
    }
    
    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
            
            hapticEngine?.resetHandler = { [weak self] in
                do {
                    try self?.hapticEngine?.start()
                } catch {
                    print("Failed to restart the haptic engine: \(error)")
                }
            }
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }
    
    func loadAudio(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.isMeteringEnabled = true
            audioPlayer?.prepareToPlay()
            duration = audioPlayer?.duration ?? 0.0
        } catch {
            print("Failed to load audio: \(error)")
        }
    }
    
    func play() {
        audioPlayer?.play()
        isPlaying = true
        startTimers()
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimers()
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        self.currentTime = time
    }
    
    func skipForward() {
        let newTime = min((audioPlayer?.currentTime ?? 0) + 10, duration)
        seek(to: newTime)
    }
    
    func skipBackward() {
        let newTime = max((audioPlayer?.currentTime ?? 0) - 10, 0)
        seek(to: newTime)
    }
    
    private func startTimers() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer, player.isPlaying else { return }
            
            self.currentTime = player.currentTime
            player.updateMeters()
            
            // Check if we crossed a Joy Pin for a subtle haptic hum
            for pin in self.joyPins {
                if abs(self.currentTime - pin) < 0.15 && abs(self.lastTriggeredPinTime - pin) > 1.0 {
                    self.triggerHapticHum()
                    self.lastTriggeredPinTime = pin
                    break
                }
            }
        }
    }
    
    private func stopTimers() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    private func triggerHapticHum() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
        
        // A subtle continuous hum for 0.15 seconds
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensityParam, sharpnessParam], relativeTime: 0, duration: 0.15)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let hapticPlayer = try hapticEngine?.makePlayer(with: pattern)
            try hapticPlayer?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play haptic hum: \(error)")
        }
    }
    
    // AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        stopTimers()
        currentTime = duration
    }
}
