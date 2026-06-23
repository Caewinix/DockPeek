import AppKit

class PreviewWindow : CanvasWindow {
    override init() {
        super.init()
        super.setAccessibilityHidden(true)
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override var canBecomeKey: Bool {
        return false
    }
}
