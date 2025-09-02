import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

enum ImageProcessor {
    private static let context = CIContext(options: nil)

    /// Simple alpha blend: foreground over background with given alpha (0..1)
    /// Returns UIImage rendered at the background image size.
    static func alphaBlend(background: UIImage, foreground: UIImage, alpha: CGFloat) -> UIImage? {
        guard let bgCI = CIImage(image: background), let fgCIOrig = CIImage(image: foreground) else { return nil }

        let bgExtent = bgCI.extent

        // Scale foreground to match background extent if needed
        let fgExtent = fgCIOrig.extent
        let scaleX = bgExtent.width / max(fgExtent.width, 1)
        let scaleY = bgExtent.height / max(fgExtent.height, 1)
        let scale = min(scaleX, scaleY)
        let scaledFG = fgCIOrig.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        // Center the scaled foreground on the background
        let dx = (bgExtent.width - scaledFG.extent.width) / 2 - scaledFG.extent.origin.x
        let dy = (bgExtent.height - scaledFG.extent.height) / 2 - scaledFG.extent.origin.y
        let positionedFG = scaledFG.transformed(by: CGAffineTransform(translationX: dx, y: dy))

        // Reduce alpha of foreground using CIColorMatrix
        let alphaFilter = CIFilter.colorMatrix()
        alphaFilter.inputImage = positionedFG
        alphaFilter.aVector = CIVector(x: 0, y: 0, z: 0, w: Float(alpha))
        guard let fgWithAlpha = alphaFilter.outputImage else { return nil }

        // Composite: SourceOver (foreground over background)
        let comp = CIFilter.sourceOverCompositing()
        comp.backgroundImage = bgCI
        comp.inputImage = fgWithAlpha
        guard let output = comp.outputImage?.cropped(to: bgExtent) else { return nil }

        guard let cg = context.createCGImage(output, from: bgExtent) else { return nil }
        return UIImage(cgImage: cg, scale: background.scale, orientation: background.imageOrientation)
    }
}

