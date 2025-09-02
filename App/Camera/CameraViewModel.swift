import AVFoundation
import SwiftUI
import Combine

@MainActor
final class CameraViewModel: ObservableObject {
    enum AuthorizationState { case unknown, authorized, denied }
    enum Stage { case idle, ghosting }

    @Published var authState: AuthorizationState = .unknown
    @Published var lastCapturedImage: UIImage?
    @Published var ghostImage: UIImage?
    @Published var shot2Image: UIImage?
    @Published var blendedImage: UIImage?
    @Published var showingBlendPreview: Bool = false
    @Published var overlayOpacity: Double = 0.5
    @Published var isLockedAEAF: Bool = false
    @Published var showGrid: Bool = false
    @Published var stage: Stage = .idle
    @Published var isCapturing: Bool = false
    @Published var initialDeviceOrientation: UIDeviceOrientation?
    @Published var currentDeviceOrientation: UIDeviceOrientation = UIDevice.current.orientation

    let orientationTracker = OrientationTracker()
    private var cancellables = Set<AnyCancellable>()

    let controller = CameraController()

    init() {
        controller.onPhotoCapture = { [weak self] image in
            Task { @MainActor in
                let normalized = image.normalizedUpOrientation()
                self?.lastCapturedImage = normalized
                self?.handleCapture(normalized)
                self?.isCapturing = false
            }
        }
        controller.onCaptureStateChanged = { [weak self] in Task { @MainActor in self?.isCapturing = $0 } }
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
            initialDeviceOrientation = currentDeviceOrientation
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
        orientationTracker.start()
        orientationTracker.$orientation
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.currentDeviceOrientation = $0 }
            .store(in: &cancellables)
        if authState == .authorized { controller.startSession() }
    }

    func onDisappear() {
        orientationTracker.stop()
        controller.stopSession()
    }

    func capture() {
        guard !isCapturing else { return }
        isCapturing = true
        controller.capturePhoto()
    }

    func toggleAEAF() {
        isLockedAEAF.toggle()
        controller.setAEAFLocked(isLockedAEAF)
    }

    func resetGhost() {
        ghostImage = nil
        shot2Image = nil
        blendedImage = nil
        showingBlendPreview = false
        overlayOpacity = 0.5
        stage = .idle
        if isLockedAEAF {
            isLockedAEAF = false
            controller.setAEAFLocked(false)
        }
    }

    func blendSimple() {
        guard let base = ghostImage, let top = shot2Image else { return }
        let alpha = overlayOpacity
        blendedImage = ImageProcessor.alphaBlend(background: base, foreground: top, alpha: alpha)
        showingBlendPreview = blendedImage != nil
    }
}
