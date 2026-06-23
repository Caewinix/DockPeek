import AppKit

extension NSView {
    /// Determine whether the size is required before calling `layout()`.
    @objc var needsSize: Bool {
        get { false }
        set {}
    }
    
    /// The method takes the place of `layout()`.
    @objc func performLayout() {}
    
    /// This property has a getter that returns expected size when the size is really needed, and a setter of the size.
    @objc var size: NSSize {
        get { framePrioritySize }
        set { setFrameSize(newValue) }
    }
}

/// The view that allows users to get the size before calling `layout()`, which means the layout of the subviews can be performed in advance.
open class RenderView : NSView {
    private func _performLayout() {
        super.layout()
        performLayout()
    }
    
    /// The template `layout()` of the `RenderView`, do not override without calling `super`. This method is only used when `needsSize` is `false`.
    open override func layout() {
        if !needsSize {
            _performLayout()
        }
    }
    
    private var _needsSize: Bool = false
    
    /// Determine whether the size is required in advance, if it is `true`, `performLayout()` will be called immediately.
    override var needsSize: Bool {
        get { _needsSize }
        set {
            if newValue {
                _performLayout()
            }
            _needsSize = newValue
        }
    }
    
    override var size: NSSize {
        get { super.frame.size }
        set { super.size = newValue }
    }
    
    open override var needsLayout: Bool {
        get { super.needsLayout }
        set {
            if newValue {
                if _needsSize {
                    _performLayout()
                }
            }
            super.needsLayout = newValue
        }
    }
}

extension NSView {
    var framePrioritySize: NSSize {
        if self.frame.width > 0 || self.frame.height > 0 {
            return frame.size
        } else {
            return self.intrinsicContentSize
        }
    }
    
    var contentPrioritySize: NSSize {
        if self.intrinsicContentSize.width == NSView.noIntrinsicMetric && self.intrinsicContentSize.height == NSView.noIntrinsicMetric {
            return self.frame.size
        } else {
            return self.intrinsicContentSize
        }
    }
}
