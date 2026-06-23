import Cocoa
import ObjectiveC.runtime

/// This `StackView` provides better stacking method than the original one.
open class StackView : RenderView {
    init() {
        super.init(frame: .zero)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    enum Orientation {
        case horizontal
        case vertical
    }
    
    enum Alignment {
        case leadingOffset(CGFloat)
        case centerOffset(CGFloat)
        case trailingOffset(CGFloat)
        public static func leading(_ value: CGFloat) -> Alignment { .leadingOffset(value) }
        public static var leading: Alignment { .leadingOffset(0) }
        public static func center(_ value: CGFloat) -> Alignment { .centerOffset(value) }
        public static var center: Alignment { .centerOffset(0) }
        public static func trailing(_ value: CGFloat) -> Alignment { .trailingOffset(value) }
        public static var trailing: Alignment { .trailingOffset(0) }
    }
    
    enum Arrangement {
        case forward
        case reverse
    }

    var orientation: Orientation = .horizontal
    
    var crossAxisAlignment: Alignment = .center
    
    var arrangement: Arrangement = .forward
    
    var spacing: CGFloat = 0
    
    private var isLayouting: Bool = false
    
    override func performLayout() {
        var offset: CGFloat = 0
        var maxLength: CGFloat = 0
        
        let subviewsIterator: IndexingIterator<Array<NSView>>
        let getLength: (NSView) -> CGFloat
        let setSubviewFrameAlignedOrigin: (NSView, CGFloat) -> Void
        let getWholeFrameSize: () -> NSSize
        
        if orientation == .horizontal {
            subviewsIterator = arrangement == .forward ? subviews.makeIterator() : subviews.reversed().makeIterator()
            getLength = {
                view in
                return view.size.height
            }
            rearrangeHorizontalSubviews()
            for view in subviews {
                view.needsSize = true
                let height = view.size.height
                if height > maxLength {
                    maxLength = height
                }
            }
            setSubviewFrameAlignedOrigin = {
                [unowned self] (view, y) in
                view.setFrameOrigin(NSMakePoint(offset, y))
                offset += view.size.width + self.spacing
            }
            getWholeFrameSize = {
                return NSMakeSize(offset, maxLength)
            }
        } else {
            subviewsIterator = arrangement == .forward ? subviews.reversed().makeIterator() : subviews.makeIterator()
            getLength = {
                view in
                return view.size.width
            }
            rearrangeVerticalSubviews()
            for view in subviews {
                view.needsSize = true
                let width = view.size.width
                if width > maxLength {
                    maxLength = width
                }
            }
            setSubviewFrameAlignedOrigin = {
                [unowned self] (view, x) in
                view.setFrameOrigin(NSMakePoint(x, offset))
                offset += view.size.height + self.spacing
            }
            getWholeFrameSize = {
                return NSMakeSize(maxLength, offset)
            }
        }
        switch (crossAxisAlignment) {
            case .leadingOffset(let value):
            for view in subviewsIterator {
                setSubviewFrameAlignedOrigin(view, maxLength - getLength(view) + value)
            }
            case .centerOffset(let value):
            for view in subviewsIterator {
                setSubviewFrameAlignedOrigin(view, (maxLength - getLength(view)) / 2 + value)
            }
            case .trailingOffset(let value):
            if value != 0 {
                for view in subviewsIterator {
                    setSubviewFrameAlignedOrigin(view, value)
                }
            }
        }
        super.size = getWholeFrameSize()
    }
    
    /// This method is only proper when the `orientation` is `.horizontal`.
    func rearrangeHorizontalSubviews() {}
    
    /// This method is only proper when the `orientation` is `.vertical`.
    func rearrangeVerticalSubviews() {}
    
    open override func makeBackingLayer() -> CALayer {
        return StackLayer()
    }
    
    open override func willRemoveSubview(_ subview: NSView) {
        super.willRemoveSubview(subview)
        if let layer = super.layer as? StackLayer {
            if layer.animation(forKey: "transition") != nil, !layer._hasTransitionKey {
                super.layer!.removeAnimation(forKey: "transition")
            }
        }
    }
}

/// This `CALayer` subclass banned the transition animation when the `StackView` needs to remove subviews.
class StackLayer : CALayer {
    fileprivate var _hasTransitionKey: Bool = false
    
    override func action(forKey event: String) -> CAAction? {
        if event == "sublayers" {
            _hasTransitionKey = animation(forKey: "transition") != nil
        }
        return super.action(forKey: event)
    }
}
