import Foundation
import CoreGraphics

typealias Image = CGImage

extension CGImage {
    var isEffective: Bool { width > 0 }
    var size: NSSize { NSMakeSize(CGFloat(width), CGFloat(height)) }
}

extension CGImage {
    func resize(_ newSize: NSSize) -> CGImage? {
        let newWidth = newSize.width
        let newHeight = newSize.height
        return resize(Int(newWidth), Int(newHeight))
    }
    
    func resize(_ newWidth: Int, _ newHeight: Int) -> CGImage? {
        return _resizeWithOriginalWidth(newWidth, newHeight, originalWidth: width)
    }
    
    func scaleUp(ratio: CGFloat) -> CGImage? {
        let newWidth = Int(round(CGFloat(width) * ratio))
        let newHeight = Int(round(CGFloat(height) * ratio))
        return _resizeWithOriginalWidth(newWidth, newHeight, originalWidth: width)
    }

    func scaleUp(ratio: Int) -> CGImage? {
        let newWidth = width * ratio
        let newHeight = height * ratio
        return _resizeWithOriginalWidth(newWidth, newHeight, originalWidth: width)
    }
    
    func scaleDown(ratio: CGFloat) -> CGImage? {
        let newWidth = Int(round(CGFloat(width) / ratio))
        let newHeight = Int(round(CGFloat(height) / ratio))
        return _resizeWithOriginalWidth(newWidth, newHeight, originalWidth: width)
    }
}

fileprivate extension CGImage {
    func _resizeWithOriginalWidth(_ newWidth: Int, _ newHeight: Int, originalWidth: Int) -> CGImage? {
        // Scale down the image
        if let colorSpace = self.colorSpace, let context = CGContext(data: nil, width: newWidth, height: newHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow / originalWidth * newWidth, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) {
            context.interpolationQuality = .high
            context.draw(self, in: context.boundingBoxOfClipPath)
            return context.makeImage()
        }
        return nil
    }
}
