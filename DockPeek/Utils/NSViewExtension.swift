import AppKit

extension NSView {
    @objc func scaleBy(x: CGFloat, y: CGFloat) {
        if let layer = self.layer {
            let scaleFactor = layer.scaleFactor2D
            self.scaleUnitSquare(to: NSMakeSize(x / scaleFactor.x, y / scaleFactor.y))
        } else {
            self.scaleUnitSquare(to: NSMakeSize(x, y))
        }
    }
}
