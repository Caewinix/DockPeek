import Cocoa
import SwiftUI

/// This window do not has the window itself, but useful when users want to draw in the screen.
class CanvasWindow: NSWindow {
    init() {
        super.init(contentRect: NSScreen.currentScreen.frame, styleMask: [.fullSizeContentView], backing: .buffered, defer: false)
        self.level = .screenSaver
        self.isOpaque = false
        self.contentView!.wantsLayer = true
        self.backgroundColor = NSColor.clear
        super.makeKeyAndOrderFront(nil)
        self.acceptsMouseMovedEvents = true
    }
    
    private func _refreshFrame() {
        let currentScreenFrame = NSScreen.currentScreen.frame
        if super.frame != currentScreenFrame {
            super.setFrame(currentScreenFrame, display: true)
        }
    }
    
    override func makeKeyAndOrderFront(_ sender: Any?) {
        _refreshFrame()
        super.makeKeyAndOrderFront(sender)
    }
    
    override func orderFront(_ sender: Any?) {
        _refreshFrame()
        super.orderFront(sender)
    }
    
    override func orderFrontRegardless() {
        _refreshFrame()
        super.orderFrontRegardless()
    }
}
