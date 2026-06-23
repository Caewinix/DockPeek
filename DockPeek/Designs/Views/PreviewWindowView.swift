import AppKit

private class _PreviewWindowInnerView : RenderView {
    override init(frame frameRect: NSRect = .zero) {
        super.init(frame: frameRect)
        _setViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setViews()
    }
    
    private func _setViews() {
        let visualEffect = NSVisualEffectView(frame: .zero)
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.material = .hudWindow
        _visualEffect = visualEffect
        super.addSubview(_visualEffect!)
        
        let collectionView = CollectionView()
        collectionView.wantsLayer = true
        _collectionView = collectionView
        super.addSubview(_collectionView!)
        
        super.wantsLayer = true
        super.layer!.cornerRadius = CGFloat(ThumbnailConstant.contentCornerRadius)
        super.layer!.borderWidth = 1
        super.layer!.borderColor = CGColor(red: 142.17283951, green: 138.17283951, blue: 136.27160494, alpha: 0.3)
        super.layer!.masksToBounds = true
    }
    
    override func performLayout() {
        _collectionView!.needsSize = true
        _visualEffect!.setFrameSize(NSMakeSize(_collectionView!.frame.width + 1000, _collectionView!.frame.height + 1000))
        super.size = _collectionView!.size
    }
    
    private weak var _visualEffect: NSVisualEffectView?
    
    private weak var _collectionView: CollectionView?
    
    var contentView: CollectionView {
        return _collectionView!
    }
}

fileprivate class _PreviewWindowInnerWrapperView : RenderView {
    override init(frame frameRect: NSRect = .zero) {
        super.init(frame: frameRect)
        _setViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setViews()
    }
    
    private func _setViews() {
        let innerView = _PreviewWindowInnerView()
        _innerView = innerView
        super.addSubview(_innerView!)
        
        super.wantsLayer = true

        super.layer!.cornerRadius = CGFloat(ThumbnailConstant.contentCornerRadius)
        super.layer!.borderWidth = 0.8
        super.layer!.borderColor = NSColor.black.withAlphaComponent(0.1).cgColor

        super.layer!.shadowColor = NSColor.shadowColor.cgColor
        super.layer!.shadowOpacity = 0.5
        super.layer!.shadowRadius = 40
        super.layer!.shadowOffset = NSMakeSize(0, -20)

        super.layer!.masksToBounds = false

        (super.layer! as! _PreviewWindowInnerWrapperLayer).addShadowWithRoundedCorners()
    }
    
    override func makeBackingLayer() -> CALayer {
        return _PreviewWindowInnerWrapperLayer()
    }
    
    override func setFrameOrigin(_ newOrigin: NSPoint) {
        super.setFrameOrigin(NSMakePoint(newOrigin.x - super.layer!.borderWidth, newOrigin.y - super.layer!.borderWidth))
    }
    
    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(NSMakeSize(newSize.width + 2 * super.layer!.borderWidth, newSize.height + 2 * super.layer!.borderWidth))
    }
    
    override func performLayout() {
        _innerView!.needsSize = true
        _innerView!.setFrameOrigin(NSMakePoint(super.layer!.borderWidth, super.layer!.borderWidth))
        super.size = _innerView!.size
    }
    
    private weak var _innerView: _PreviewWindowInnerView?
    
    var contentView: CollectionView {
        return _innerView!.contentView
    }
    
    override var frame: NSRect {
        get {
            return NSMakeRect(super.frame.origin.x + super.layer!.borderWidth, super.frame.origin.y + super.layer!.borderWidth, super.frame.width - 2 * super.layer!.borderWidth, super.frame.height - 2 * super.layer!.borderWidth)
        }
        set { super.frame = newValue }
    }
}

fileprivate class _PreviewWindowInnerWrapperLayer : CALayer {
    private struct Constants {
        static let contentLayerName = "shadowCorner"
    }
    
    fileprivate func addShadowWithRoundedCorners() {
        if let contents = self.contents {
            masksToBounds = false
            sublayers?.filter{ $0.frame.equalTo(self.bounds) }
                .forEach{ $0.cornerRadius = self.cornerRadius }
            self.contents = nil
            if let sublayer = _contentLayer,
                sublayer.name == Constants.contentLayerName {
                sublayer.removeFromSuperlayer()
            }
            let contentLayer = CALayer()
            contentLayer.name = Constants.contentLayerName
            contentLayer.contents = contents
            contentLayer.frame = bounds
            contentLayer.cornerRadius = cornerRadius
            contentLayer.masksToBounds = true
            _contentLayer = contentLayer
            addSublayer(_contentLayer!)
        }
    }
    
    private weak var _contentLayer: CALayer?
}

/// This view is used to show the apperance style of the collection view, which are all set and wrapped in this implementation.
class PreviewWindowView : RenderView {
    override init(frame frameRect: NSRect = .zero) {
        super.init(frame: frameRect)
        _setViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setViews()
    }
    
    private func _setViews() {
        let wrapperView = _PreviewWindowInnerWrapperView()
        _wrapperView = wrapperView
        super.addSubview(_wrapperView!)
        
        super.wantsLayer = true
        super.layer!.masksToBounds = false
    }
    
    override func setFrameOrigin(_ newOrigin: NSPoint) {
        super.setFrameOrigin(NSMakePoint(newOrigin.x - _wrapperView!.layer!.borderWidth, newOrigin.y - _wrapperView!.layer!.borderWidth))
    }
    
    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(NSMakeSize(newSize.width + 2 * _wrapperView!.layer!.borderWidth, newSize.height + 2 * _wrapperView!.layer!.borderWidth))
    }
    
    override func performLayout() {
        _wrapperView!.needsSize = true
        super.size = _wrapperView!.size
    }
    
    private weak var _wrapperView: _PreviewWindowInnerWrapperView?
    
    var contentView: CollectionView {
        return _wrapperView!.contentView
    }
    
    override var frame: NSRect {
        get {
            return NSMakeRect(super.frame.origin.x + _wrapperView!.layer!.borderWidth, super.frame.origin.y + _wrapperView!.layer!.borderWidth, super.frame.width - 2 * _wrapperView!.layer!.borderWidth, super.frame.height - 2 * _wrapperView!.layer!.borderWidth)
        }
        set { super.frame = newValue }
    }
}
