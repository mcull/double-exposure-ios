import AVFoundation
import UIKit

final class CameraController: NSObject {
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let photoOutput = AVCapturePhotoOutput()

    // Callback for captured photo as UIImage data
    var onPhotoCapture: ((UIImage) -> Void)?

    override init() {
        super.init()
    }

    func configureSession() {
        sessionQueue.async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            // Inputs
            if let currentInput = self.session.inputs.first {
                self.session.removeInput(currentInput)
            }
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) ??
                                AVCaptureDevice.default(for: .video) else {
                self.session.commitConfiguration()
                return
            }
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }
            } catch {
                print("Camera input error: \(error)")
            }

            // Outputs
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                self.photoOutput.isHighResolutionCaptureEnabled = true
            }

            self.session.commitConfiguration()
        }
    }

    func startSession() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        settings.isHighResolutionPhotoEnabled = true
        if photoOutput.supportedFlashModes.contains(.off) {
            settings.flashMode = .off
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Photo capture error: \(error)")
            return
        }
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else { return }
        onPhotoCapture?(image)
    }
}

