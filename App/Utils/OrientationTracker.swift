import SwiftUI
import Combine

final class OrientationTracker: ObservableObject {
    @Published var orientation: UIDeviceOrientation = UIDevice.current.orientation

    private var didBegin = false

    func start() {
        guard !didBegin else { return }
        didBegin = true
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(onChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        orientation = UIDevice.current.orientation
    }

    func stop() {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        if didBegin { UIDevice.current.endGeneratingDeviceOrientationNotifications() }
        didBegin = false
    }

    @objc private func onChange() {
        orientation = UIDevice.current.orientation
    }
}

extension UIDeviceOrientation {
    var label: String {
        switch self {
        case .portrait: return "Portrait"
        case .portraitUpsideDown: return "Portrait ⤵︎"
        case .landscapeLeft: return "Landscape ⟲"
        case .landscapeRight: return "Landscape ⟳"
        case .faceUp: return "Face Up"
        case .faceDown: return "Face Down"
        default: return "Unknown"
        }
    }
    var isUsable: Bool { self == .portrait || self == .portraitUpsideDown || self == .landscapeLeft || self == .landscapeRight }
}

