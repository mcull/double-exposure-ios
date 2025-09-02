import UIKit

extension UIImage {
    /// Returns a copy of the image with orientation flattened to `.up`.
    /// If the image is already `.up`, returns self.
    func normalizedUpOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let img = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return img
    }
}

