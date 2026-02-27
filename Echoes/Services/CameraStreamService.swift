import Foundation
import AVFoundation
import Vision

@Observable
final class CameraStreamService: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var captureSession: AVCaptureSession?
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    // Callback to pass the sample buffer to the face tracking service
    var onFrameGenerated: ((CMSampleBuffer) -> Void)?
    
    override init() {
        super.init()
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSession(captureSession)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.configureSession(captureSession)
                    }
                }
            }
        default:
            print("Camera access denied or restricted")
        }
    }
    
    private func configureSession(_ session: AVCaptureSession) {
        session.beginConfiguration()
        
        // Lower the resolution and framerate to save battery/CPU specifically for Vision detection
        session.sessionPreset = .vga640x480
        
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("No front camera available")
            session.commitConfiguration()
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            // Adjust framerate
            try frontCamera.lockForConfiguration()
            frontCamera.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 15) // 15 FPS
            frontCamera.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 15)
            frontCamera.unlockForConfiguration()
            
        } catch {
            print("Failed to set up camera input: \(error)")
            session.commitConfiguration()
            return
        }
        
        videoDataOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
        ]
        
        let cameraQueue = DispatchQueue(label: "com.echoes.cameraStreamQueue", qos: .userInteractive)
        videoDataOutput.setSampleBufferDelegate(self, queue: cameraQueue)
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        
        // Ensure orientation if needed (typically handled by Vision automatically if configured, or default portrait)
        if let connection = videoDataOutput.connection(with: .video) {
            #if swift(>=5.9)
            if #available(iOS 17.0, *) {
                if connection.isVideoRotationAngleSupported(90) {
                    connection.videoRotationAngle = 90
                }
            } else {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                }
            }
            #else
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
            #endif
        }
        
        session.commitConfiguration()
    }
    
    func startSession() {
        guard let session = captureSession, !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }
    
    func stopSession() {
        guard let session = captureSession, session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            session.stopRunning()
        }
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        onFrameGenerated?(sampleBuffer)
    }
}
