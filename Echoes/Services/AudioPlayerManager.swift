import Foundation
import AVFoundation
import CoreHaptics

@Observable
final class AudioPlayerManager: NSObject, AVAudioPlayerDelegate {
    var isPlaying = false
    var currentTime: TimeInterval = 0.0
    var duration: TimeInterval = 0.0
    
    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: Timer?
    private var hapticEngine: CHHapticEngine?
    
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
    
    private func startTimers() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer, player.isPlaying else { return }
            
            self.currentTime = player.currentTime
            player.updateMeters()
            
            let power = player.averagePower(forChannel: 0)
            let normalizedPower = max(0.0, min(1.0, Double(power + 60.0) / 60.0))
            
            // Only trigger haptic if power is quite significant to feel like a voice pulse
            if normalizedPower > 0.6 {
                self.triggerHapticPulse(intensity: Float(normalizedPower))
            }
        }
    }
    
    private func stopTimers() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    private func triggerHapticPulse(intensity: Float) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityParam, sharpnessParam], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: .now)
        } catch {
            print("Failed to play haptic pattern: \(error)")
        }
    }
    
    // AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        stopTimers()
        currentTime = duration
    }
}
