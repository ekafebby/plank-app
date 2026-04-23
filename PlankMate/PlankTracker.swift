import Foundation
import AVFoundation
import Vision
import Combine

class PlankTracker: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var isPlanking = false
    @Published var plankDuration: TimeInterval = 0
    @Published var isTrackingEnabled = false {
        didSet {
            if isTrackingEnabled {
                startTimer()
            } else {
                pauseTimer()
            }
        }
    }
    @Published var permissionGranted = false
    @Published var permissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var sessionEnded = false
    @Published var accuracy: Double = 0.0
    
    var captureSession = AVCaptureSession()
    private var videoOutput = AVCaptureVideoDataOutput()
    
    private var timer: Timer?
    private let synthesizer = AVSpeechSynthesizer()
    
    private var totalSessionFrames = 0
    private var goodFormFrames = 0
    
    override init() {
        super.init()
        checkCameraPermission()
    }
    
    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        DispatchQueue.main.async {
            self.permissionStatus = status
        }
        
        switch status {
        case .authorized:
            self.permissionGranted = true
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
                    self.permissionGranted = granted
                    if granted {
                        self.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            self.permissionGranted = false
        @unknown default:
            self.permissionGranted = false
        }
    }
    
    func setupCamera() {
        captureSession.sessionPreset = .high
        
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    func startTracking() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
        plankDuration = 0
        totalSessionFrames = 0
        goodFormFrames = 0
        isPlanking = false
        isTrackingEnabled = false
    }
    
    func stopTracking() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.stopRunning()
        }
        timer?.invalidate()
        timer = nil
        
        if totalSessionFrames > 0 {
            accuracy = Double(goodFormFrames) / Double(totalSessionFrames) * 100
        } else {
            accuracy = 0
        }
        
        sessionEnded = true
        isTrackingEnabled = false
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let request = VNDetectHumanBodyPoseRequest(completionHandler: self.bodyPoseHandler)
        do {
            let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
            try handler.perform([request])
        } catch {
            print("Vision request failed: \(error)")
        }
    }
    
    private func bodyPoseHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation],
              let observation = observations.first else {
            updatePlankState(isGoodForm: false)
            return
        }
        
        do {
            let recognizedPoints = try observation.recognizedPoints(.all)
            
            let shoulder = recognizedPoints[.leftShoulder] ?? recognizedPoints[.rightShoulder]
            let hip = recognizedPoints[.leftHip] ?? recognizedPoints[.rightHip]
            let ankle = recognizedPoints[.leftAnkle] ?? recognizedPoints[.rightAnkle]
            
            guard let s = shoulder, s.confidence > 0.3,
                  let h = hip, h.confidence > 0.3,
                  let a = ankle, a.confidence > 0.3 else {
                updatePlankState(isGoodForm: false)
                return
            }
            
            let angle = angleBetween(p1: s.location, p2: h.location, p3: a.location)
            let isGoodForm = angle > 150 && angle < 210
            
            updatePlankState(isGoodForm: isGoodForm)
            
        } catch {
            updatePlankState(isGoodForm: false)
        }
    }
    
    private func updatePlankState(isGoodForm: Bool) {
        DispatchQueue.main.async {
            guard self.isTrackingEnabled else { return }
            
            self.totalSessionFrames += 1
            if isGoodForm {
                self.goodFormFrames += 1
            }
            
            if self.isPlanking != isGoodForm {
                self.isPlanking = isGoodForm
            }
        }
    }
    
    private func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.plankDuration += 1
            }
        }
    }
    
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func angleBetween(p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGFloat {
        let v1 = CGPoint(x: p1.x - p2.x, y: p1.y - p2.y)
        let v2 = CGPoint(x: p3.x - p2.x, y: p3.y - p2.y)
        let dot = v1.x * v2.x + v1.y * v2.y
        let cross = v1.x * v2.y - v1.y * v2.x
        let angle = atan2(cross, dot)
        return abs(angle * 180 / .pi)
    }
}
