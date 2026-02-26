import Foundation
import Vision
import AVFoundation

@Observable
final class FaceTrackingService {
    var joyPins: [TimeInterval] = []
    var isCurrentlySmiling = false
    
    private var audioManager: AudioRecorderManager?
    
    // We process requests on a background queue to not block UI or Camera queue
    private let visionQueue = DispatchQueue(label: "com.echoes.visionQueue", qos: .userInteractive)
    
    init() {}
    
    func attach(audioManager: AudioRecorderManager) {
        self.audioManager = audioManager
    }
    
    func reset() {
        joyPins.removeAll()
        isCurrentlySmiling = false
    }
    
    func process(sampleBuffer: CMSampleBuffer) {
        // Skip if we are not recording audio right now
        guard let audioManager = audioManager, audioManager.isRecording else {
            return
        }
        
        // Convert CMSampleBuffer to CVPixelBuffer
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        let faceRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
            self?.handleFaceLandmarkObservations(request: request, error: error)
        }
        
        visionQueue.async {
            do {
                try requestHandler.perform([faceRequest])
            } catch {
                print("Vision face tracking failed: \(error)")
            }
        }
    }
    
    private func handleFaceLandmarkObservations(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNFaceObservation],
              let firstFace = observations.first,
              let landmarks = firstFace.landmarks,
              let outerLips = landmarks.outerLips else {
            return
        }
        
        let points = outerLips.normalizedPoints
        
        // Outer Lips indices approximately (check Vision docs for exact mapping if needed, but relative positional math works universally):
        // Usually, the first point[0] is one corner, and point[points.count / 2] is the other corner.
        // Bottom lip center is roughly point[points.count * 3 / 4].
        
        if points.count > 0 {
            // Find left and right corners by X coordinate mapping
            let leftCorner = points.min(by: { $0.x < $1.x }) ?? points[0]
            let rightCorner = points.max(by: { $0.x < $1.x }) ?? points[points.count / 2]
            
            // Find bottom lip center by looking for minimum Y (Y goes up from 0 to 1 in Vision coordinates if origin is bottom-left)
            // Or use a mid-point from the lower half of the points array.
            // Vision uses normalized coordinates, origin at bottom-left. Lower Y = closer to chin.
            let bottomLipCenter = points.min(by: { $0.y < $1.y }) ?? points[0]
            
            // Calculate a baseline Y between the two corners
            let cornersY = (leftCorner.y + rightCorner.y) / 2.0
            
            // The smile distance is how far the corners go "up" (higher Y) relative to the bottom center (lower Y).
            // Distance from corners to bottom lip vertically.
            let lipHeight = cornersY - bottomLipCenter.y
            
            // Find the width of the mouth
            let mouthWidth = rightCorner.x - leftCorner.x
            
            // Create a Smile Index (Smile Ratio)
            // A higher ratio means a wider, more upturned smile
            // You may need to tune this threshold based on testing
            var isSmiling = false
            if mouthWidth > 0 {
                let smileRatio = lipHeight / mouthWidth
                
                // Typical resting ratio might be 0.1, a smile might be > 0.35. Threshold depends on camera angle/face.
                // Alternatively, looking simply at the slope of corners compared to the rest of the points.
                // Let's use a simple heuristic for now: If corners are significantly higher than the center bottom lip.
                if smileRatio > 0.4 {
                    isSmiling = true
                }
            }
            
            // Debounce logic
            DispatchQueue.main.async {
                if isSmiling && !self.isCurrentlySmiling {
                    // Just started smiling
                    self.isCurrentlySmiling = true
                    if let manager = self.audioManager, manager.isRecording {
                        let currentTime = manager.currentTime
                        self.joyPins.append(currentTime)
                        print("Smile detected at \(String(format: "%0.1f", currentTime))")
                    }
                } else if !isSmiling && self.isCurrentlySmiling {
                    // Stopped smiling
                    // In a more robust system, you might add a small delay before resetting
                    // to avoid flapping if a frame drops.
                    self.isCurrentlySmiling = false
                }
            }
        }
    }
}
