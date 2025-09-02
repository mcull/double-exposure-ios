import AVFoundation
import SwiftUI

@MainActor
final class CameraViewModel: ObservableObject {
    enum AuthorizationState { case unknown, authorized, denied }
    enum Stage { case idle, ghosting }

    @Published var authState: AuthorizationState = .unknown
    @Published var lastCapturedImage: UIImage?
    @Published var ghostImage: UIImage?
    @Published var shot2Image: UIImage?
    @Published var overlayOpacity: Double = 0.5
    @Published var isLockedAEAF: Bool = false
    @Published var showGrid: Bool = false
    @Published var stage: Stage = .idle

    let controller = CameraController()

    init() {
        controller.onPhotoCapture = { [weak self] image in
            Task { @MainActor in
                self?.lastCapturedImage = image
                self?.handleCapture(image)
            }
        }
        refreshAuthorizationStatus()
        controller.configureSession()
    }

    private func handleCapture(_ image: UIImage) {
        switch stage {
        case .idle:
            ghostImage = image
            stage = .ghosting
            // Lock AE/AF when ghosting starts (user can toggle off)
            isLockedAEAF = true
            controller.setAEAFLocked(true)
        case .ghosting:
            shot2Image = image
            // Keep stage; blending will be implemented in next milestones
        }
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

    func toggleAEAF() {
        isLockedAEAF.toggle()
        controller.setAEAFLocked(isLockedAEAF)
    }

    func resetGhost() {
        ghostImage = nil
        shot2Image = nil
        overlayOpacity = 0.5
        stage = .idle
        if isLockedAEAF {
            isLockedAEAF = false
            controller.setAEAFLocked(false)
        }
    }
}
