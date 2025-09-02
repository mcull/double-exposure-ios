import AVFoundation
import SwiftUI

@MainActor
final class CameraViewModel: ObservableObject {
    enum AuthorizationState { case unknown, authorized, denied }

    @Published var authState: AuthorizationState = .unknown
    @Published var lastCapturedImage: UIImage?

    let controller = CameraController()

    init() {
        controller.onPhotoCapture = { [weak self] image in
            Task { @MainActor in
                self?.lastCapturedImage = image
            }
        }
        refreshAuthorizationStatus()
        controller.configureSession()
    }

    func refreshAuthorizationStatus() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: authState = .authorized
        case .denied, .restricted: authState = .denied
        case .notDetermined: authState = .unknown
        @unknown default: authState = .unknown
        }
    }

    func requestAuthorization() async {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        authState = granted ? .authorized : .denied
        if granted { controller.startSession() }
    }

    func onAppear() {
        if authState == .authorized { controller.startSession() }
    }

    func onDisappear() {
        controller.stopSession()
    }

    func capture() { controller.capturePhoto() }
}

