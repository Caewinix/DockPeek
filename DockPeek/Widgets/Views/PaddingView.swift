import AppKit

extension NSEdgeInsets {
    static let zero = NSEdgeInsets()
    static func all(_ value: CGFloat) -> NSEdgeInsets {
        return NSEdgeInsets(top: value, left: value, bottom: value, right: value)
    }
}

typealias Padding = NSEdgeInsets

/// This `PaddingView` adds padding around the inner view.
class PaddingView : RenderView {
    init(mainView: NSView) {
        self.padding = .zero
        super.init(frame: .zero)
        super.addSubview(mainView)
        self._hasMainView = true
    }
    
    override init(frame frameRect: NSRect = .zero) {
        self.padding = .zero
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        self.padding = .zero
        super.init(coder: coder)
    }
    
    /// This property indicates the main inner view that needs to add padding.
    var mainView: NSView? {
        get { _hasMainView ? super.subviews.last : nil }
        set {
            if let newView = newValue {
                _hasMainView = true
                if let mainView = self.mainView {
                    super.replaceSubview(mainView, with: newView)
                } else {
                    super.addSubview(newView)
                }
            } else {
                if let mainView = self.mainView {
                    mainView.removeFromSuperview()
                }
                _hasMainView = false
            }
        }
    }
    
    private func _maintainMainViewIndex() {
        if _hasMainView {
            let count = super.subviews.count
            super.subviews.swapAt(count - 1, count - 2)
        }
    }
    
    override func addSubview(_ view: NSView) {
        super.addSubview(view)
        _maintainMainViewIndex()
    }
    
    override func addSubview(_ view: NSView, positioned place: NSWindow.OrderingMode, relativeTo otherView: NSView?) {
        super.addSubview(view, positioned: place, relativeTo: otherView)
        _maintainMainViewIndex()
    }
    
    override func performLayout() {
        if let mainView = self.mainView {
            mainView.needsSize = true
            mainView.setFrameOrigin(NSMakePoint(self.left, self.bottom))
            super.size = NSMakeSize(self.left + self.right + mainView.size.width, self.bottom + self.top + mainView.size.height)
        }
    }
    
    private var _hasMainView: Bool = false
    
    var padding: NSEdgeInsets
    
    var top: Double {
        get { padding.top }
        set { padding.top = newValue }
    }
    
    var left: Double {
        get { padding.left }
        set { padding.left = newValue }
    }
    
    var bottom: Double {
        get { padding.bottom }
        set { padding.bottom = newValue }
    }
    
    var right: Double {
        get { padding.right }
        set { padding.right = newValue }
    }
}
