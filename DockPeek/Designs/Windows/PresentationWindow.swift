import AppKit

protocol Presentation : AnyObject {
    func show()
    func hide()
    func clearAll()
}

/// The controller used for `PresentationWindow`.
class PresentationWindowController : Presentation {
    fileprivate func _attach(_ window: NSWindow) {
        _window = window
        _window!.contentView?.wantsLayer = true
    }
    
    fileprivate func _detach() {
        _window = nil
    }
    
    /// Show the presentation window.
    func show() {
        if let window = _window, !_isShown {
            _isShown = true
            window.orderFront(nil)
            NSAnimationContext.runAnimationGroup {
                [unowned window] context in
                context.allowsImplicitAnimation = true
                window.contentView!.layer!.opacity = 1
            }
        }
    }
    
    /// Hide the presentation window.
    func hide() {
        if _isShown {
            _isShown = false
            NSAnimationContext.runAnimationGroup({
                [unowned self] context in
                context.allowsImplicitAnimation = true
                _window?.contentView!.layer!.opacity = 0
            }, completionHandler: {
                [unowned self] in
                if let window = _window, window.contentView!.layer!.opacity == 0 {
                    window.orderOut(nil)
                    clearAll()
                }
            })
        }
    }
    
    /// Clear all window previews.
    func clearAll() {
        for view in _windowPreviews.values {
            view.value!.removeFromSuperview()
        }
        _windowPreviews.removeAll()
    }
    
    /// Add a window preview with animation.
    func addWindowPreview(windowID: CGWindowID, windowElement: AXUIElement? = nil) {
        let bestImage = captureWindowImage(windowID: windowID, options: [.bestResolution, .ignoreGlobalClipShape])
        let imageView: NSImageView
        let frame: NSRect
        if let windowElement = windowElement {
            if var thisFrame = windowElement.frame {
                thisFrame.origin.y = NSScreen.currentScreen.frame.height - thisFrame.origin.y - thisFrame.height
                frame = thisFrame
            } else {
                frame = .zero
            }
        } else {
            frame = NSScreen.currentScreen.frame
        }
        imageView = NSImageView(image: NSImage(cgImage: bestImage, size: bestImage.size))
        imageView.frame = frame
        imageView.wantsLayer = true
        imageView.layer!.opacity = 0
        if let oldView = _windowPreviews[windowID]?.value {
            oldView.removeFromSuperview()
        }
        _windowPreviews[windowID] = .init(imageView)
        _window?.contentView!.addSubview(imageView)
        NSAnimationContext.runAnimationGroup{
            [unowned imageView] context in
            context.allowsImplicitAnimation = true
            imageView.layer!.opacity = 1
        }
    }
    
    /// Remove a window preview with animation.
    func removeWindowPreview(windowID: CGWindowID) {
        if let windowPreview = _windowPreviews[windowID]?.value {
            NSAnimationContext.runAnimationGroup({
                [weak windowPreview] context in
                context.allowsImplicitAnimation = true
                windowPreview?.layer!.opacity = 0
            }, completionHandler: {
                [unowned self, weak windowPreview] in
                if let windowPreview = windowPreview {
                    _windowPreviews.removeValue(forKey: windowID)
                    windowPreview.removeFromSuperview()
                }
            })
        }
    }
    
    private weak var _window: NSWindow?
    private var _windowPreviews: [CGWindowID : WeakReference<NSImageView>] = [:]
    private var _isHiding: Bool = false
    private var _isShown: Bool = false
}

/// A window to present window previews with high resolution.
class PresentationWindow : CanvasWindow {
    init(controller: PresentationWindowController? = nil) {
        if controller != nil {
            _controller = controller!
        } else {
            _controller = PresentationWindowController()
        }
        super.init()
        _controller._attach(self)
        super.level = .floating
        super.ignoresMouseEvents = true
        super.setAccessibilityHidden(true)
        super.contentView!.layer!.opacity = 0
        super.contentView!.layer!.backgroundColor = NSColor.black.withAlphaComponent(0.25).cgColor
    }
    
    deinit {
        _controller._detach()
    }
    
    private var _controller: PresentationWindowController
    
    var controller: PresentationWindowController {
        get { _controller }
        set {
            _controller._detach()
            _controller = newValue
            _controller._attach(self)
        }
    }
}
