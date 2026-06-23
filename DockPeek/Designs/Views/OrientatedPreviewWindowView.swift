import AppKit

/// This view extends behavior of the `PreviewWindowView` which only provides appearance style.
class OrientatedPreviewWindowView : PreviewWindowView {
    init(dockItem: DockItem, presentation: Presentation) {
        self.dockItem = dockItem
        self.presentation = presentation
        self._initialScale = (dockItem.size.height / 72).clamp(from: 0.75, to: 1.0)
        super.init(frame: .zero)
        self.layer!.opacity = 0
        self.dockOrientation = DockOrientation()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func scaleBy(x: CGFloat, y: CGFloat) {
        _currentaScale = NSMakePoint(x, y)
        super.scaleBy(x: x, y: y)
    }
    
    private func _superScaleBy(x: CGFloat, y: CGFloat) {
        super.scaleBy(x: x, y: y)
    }
    
    override func makeBackingLayer() -> CALayer {
        return OrientatedPreviewWindowLayer()
    }
    
    private func _removeMonitor() {
        if let monitor = _universalMonitor {
            CGEvent.removeMonitor(monitor)
            _universalMonitor = nil
        }
    }
    
    /// If not set, the view will have a weird behavior since `mouseExit(with:)` may not be called.
    private func _activateHandyHover() {
        if let window = super.window, window.ignoresMouseEvents {
            window.ignoresMouseEvents = false
        }
    }
    
    /// Activate the preview window with animation firstly.
    func firstlyActivate(duration: TimeInterval = 0.2) {
        _isActivated = true
        _deactivateHandyHover()
        if self.layer!.animation(forKey: "opacity") == nil {
            self._setInapparentScale!()
        }
        NSAnimationContext.runAnimationGroup {
            [weak self] context in
            guard let self = self else { return }
            context.duration = duration
            context.allowsImplicitAnimation = true
            self.layer!.opacity = 1
            self._superScaleBy(x: _currentaScale.x, y: _currentaScale.y)
            if let originalPosition = _originalPosition {
                self.layer!.position = originalPosition
            }
        }
    }
    
    /// Activate the preview window with animation. Avoid activating for multiple times.
    func activate(duration: TimeInterval = 0.2) {
        if !_isActivated && _canActivate {
            firstlyActivate(duration: duration)
        }
    }
    
    /// Deactivate the preview window with animation.
    private func _deactivationAnimate(duration: TimeInterval = 0.2, completionBlock: @escaping () -> Void) {
        _completionBlock = completionBlock
        NSAnimationContext.runAnimationGroup({
            [weak self] context in
            guard let self = self else { return }
            context.duration = duration
            context.allowsImplicitAnimation = true
            self.layer!.opacity = 0
            self._setInapparentScale!()
        }, completionHandler: _complete)
    }
    
    /// If not set back, the window may prevent mouse click.
    private func _deactivateHandyHover() {
        if let window = self.window, !window.ignoresMouseEvents {
            window.ignoresMouseEvents = true
        }
    }
    
    func deactivateForcibly(duration: TimeInterval = 0.2) {
        if _isActivated {
            _isActivated = false
            _deactivationAnimate(duration: duration) {
                [weak self] in
                guard let self = self else { return }
                self._deactivateHandyHover()
                self._mustCalledCompletionFunction()
            }
        }
    }
    
    /// Deactivate the preview window with animation. Avoid deactivating for multiple times.
    func deactivate(duration: TimeInterval = 0.2) {
        if _isActivated {
            _isActivated = false
            _deactivationAnimate(duration: duration) {
                [weak self] in
                guard let self = self else { return }
                if self.layer!.presentation()!.opacity == 0 && self.layer!.opacity == 0 {
                    self._mustCalledCompletionFunction()
                }
            }
        }
    }
    
    /// Avoid the animation completion block turns to a different value which makes the completion clock be called immediately, it wrap the real required  completion block as a result.
    private func _complete() {
        _completionBlock?()
    }
    
    /// After deactivating, all things need to be clear and clean.
    private func _mustCalledCompletionFunction() {
        self.removeFromSuperview()
        presentation?.hide()
        self.whenDeactivating?()
        _removeMonitor()
    }
    
    private var _isActivated: Bool = false
    
    private var _canActivate: Bool = true
    
    private var _completionBlock: (() -> Void)?
    
    private var _currentaScale: NSPoint = NSMakePoint(1, 1)
    
    private var _setInapparentScale: (() -> Void)?
    
    /// Adjust location and scale.
    func adjustPreviewWindowView() {
        let point: NSPoint = _getOrientatedPointWithAdjustment!()
        self.scaleBy(x: _scale, y: _scale)
        self.setFrameOrigin(point)
    }
    
    private func _scaleWith(_ value: CGFloat) -> CGFloat {
        return _scale * value
    }
    
    /// Add a monitor to know whether activation and deactivation is needed.
    private func _addUniversalMoveMonitor(_ function: @escaping (NSSize) -> Bool) -> CGEventObserver? {
        return CGEvent.addUniversalMonitorForEvents(matching: [.mouseMoved]) {
            [weak self] event in
            guard let self = self else { return }
            if function(NSMakeSize(self._scaleWith(self.frame.width), self._scaleWith(self.frame.height))) {
                self.activate()
            } else {
                self.deactivate()
            }
        }
    }
    
    /// Check whether the presentation window is necessary to show, also modify the cursor.
    private func _doesPresentationNeedShow(_ frame: NSRect) {
        if let presentation = self.presentation {
            if frame.contains(NSEvent.mouseLocation) {
                NSCursor.arrow.push()
                self.window?.orderFront(nil)
                _activateHandyHover()
                presentation.show()
            } else {
                NSCursor.pop()
                _deactivateHandyHover()
                presentation.hide()
            }
        }
    }
    
    private func _setAsBottom() {
        _getOrientatedPointWithAdjustment = {
            [weak self] in
            guard let self = self else { return NSPoint.zero }
            let currentScreen = NSScreen.currentScreen
            self.contentView.orientation = .horizontal
            self.needsSize = true
            var scaledWidth = self.frame.width * self._initialScale
            if scaledWidth > currentScreen.frame.width {
                self._scale = currentScreen.frame.width / self.frame.width
            } else {
                self._scale = self._initialScale
            }
            scaledWidth = self._scaleWith(self.frame.width)
            var point = NSMakePoint(self.dockItem.origin.x + (self.dockItem.size.width - scaledWidth) / 2, currentScreen.visibleFrame.origin.y + OrientatedPreviewWindowView.gapBetweenDockAndRect * self._scale)
            if point.x < 0 {
                point.x = 0
            } else if point.x + scaledWidth > currentScreen.frame.width {
                point.x = currentScreen.frame.width - scaledWidth
            }
            return point
        }
        _universalMonitor = _addUniversalMoveMonitor {
            [weak self] scaledSize in
            guard let self = self else { return false }
            let currentScreen = NSScreen.currentScreen
            let frame = NSMakeRect(currentScreen.frame.origin.x + self.frame.origin.x, currentScreen.visibleFrame.origin.y - OrientatedPreviewWindowView.gapTolerance * self._scale, scaledSize.width, (OrientatedPreviewWindowView.gapBetweenDockAndRect + OrientatedPreviewWindowView.gapTolerance) * self._scale + scaledSize.height)
            self._doesPresentationNeedShow(NSMakeRect(currentScreen.frame.origin.x + self.frame.origin.x, currentScreen.frame.origin.y + self.frame.origin.y, scaledSize.width, scaledSize.height))
            let dockItemFrame = NSMakeRect(self.dockItem.origin.x, self.dockItem.origin.y - self.dockItem.size.height, self.dockItem.size.width, self.dockItem.size.height)
            return frame.contains(NSEvent.mouseLocation) || dockItemFrame.contains(NSEvent.mouseLocation)
        }
        _setInapparentScale = {
            [weak self] in
            guard let self = self else { return }
            self._superScaleBy(x: self._currentaScale.x, y: 1e-6)
        }
    }
    
    private func _setAsLeft() {
        _getOrientatedPointWithAdjustment = {
            [weak self] in
            guard let self = self else { return NSPoint.zero }
            let currentScreen = NSScreen.currentScreen
            self.contentView.orientation = .vertical
            self.needsSize = true
            var scaledHeight = self.frame.height * self._initialScale
            let screenHeight = currentScreen.effectiveHeight
            if scaledHeight > screenHeight {
                self._scale = screenHeight / self.frame.height
            } else {
                self._scale = self._initialScale
            }
            scaledHeight = self._scaleWith(self.frame.height)
            var point = NSMakePoint(currentScreen.visibleFrame.origin.x + OrientatedPreviewWindowView.gapBetweenDockAndRect * self._scale, self.dockItem.origin.y - (self.dockItem.size.height + scaledHeight) / 2)
            if point.y < 0 {
                point.y = 0
            } else if point.y + scaledHeight > screenHeight {
                point.y = screenHeight - scaledHeight
            }
            return point
        }
        _universalMonitor = _addUniversalMoveMonitor {
            [weak self] scaledSize in
            guard let self = self else { return false }
            let currentScreen = NSScreen.currentScreen
            let frame = NSMakeRect(currentScreen.visibleFrame.origin.x - OrientatedPreviewWindowView.gapTolerance * self._scale, currentScreen.frame.origin.y + self.frame.origin.y, (OrientatedPreviewWindowView.gapBetweenDockAndRect + OrientatedPreviewWindowView.gapTolerance) * self._scale + scaledSize.width, scaledSize.height)
            self._doesPresentationNeedShow(NSMakeRect(currentScreen.frame.origin.x + self.frame.origin.x, currentScreen.frame.origin.y + self.frame.origin.y, scaledSize.width, scaledSize.height))
            let dockItemFrame = NSMakeRect(self.dockItem.origin.x, self.dockItem.origin.y - self.dockItem.size.height, self.dockItem.size.width, self.dockItem.size.height)
            return frame.contains(NSEvent.mouseLocation) || dockItemFrame.contains(NSEvent.mouseLocation)
        }
        _setInapparentScale = {
            [weak self] in
            guard let self = self else { return }
            self._superScaleBy(x: 1e-6, y: self._currentaScale.y)
        }
    }
    
    var _originalPosition: NSPoint?
    private func _setAsRight() {
        _getOrientatedPointWithAdjustment = {
            [weak self] in
            guard let self = self else { return NSPoint.zero }
            let currentScreen = NSScreen.currentScreen
            self.contentView.orientation = .vertical
            self.needsSize = true
            var scaledHeight = self.frame.height * self._initialScale
            let screenHeight = currentScreen.effectiveHeight
            if scaledHeight > screenHeight {
                self._scale = screenHeight / self.frame.height
            } else {
                self._scale = self._initialScale
            }
            scaledHeight = self._scaleWith(self.frame.height)
            var point = NSMakePoint(currentScreen.visibleFrame.width - self._scaleWith(self.frame.width + OrientatedPreviewWindowView.gapBetweenDockAndRect), self.dockItem.origin.y - (self.dockItem.size.height + scaledHeight) / 2)
            if point.y < 0 {
                point.y = 0
            } else if point.y + scaledHeight > screenHeight {
                point.y = screenHeight - scaledHeight
            }
            return point
        }
        _universalMonitor = _addUniversalMoveMonitor {
            [weak self] scaledSize in
            guard let self = self else { return false }
            let currentScreen = NSScreen.currentScreen
            let frame = NSMakeRect(currentScreen.frame.origin.x + currentScreen.visibleFrame.width - scaledSize.width - OrientatedPreviewWindowView.gapBetweenDockAndRect * self._scale, currentScreen.frame.origin.y + self.frame.origin.y, (OrientatedPreviewWindowView.gapBetweenDockAndRect + OrientatedPreviewWindowView.gapTolerance) * self._scale + scaledSize.width, scaledSize.height)
            self._doesPresentationNeedShow(NSMakeRect(currentScreen.frame.origin.x + self.frame.origin.x, currentScreen.frame.origin.y + self.frame.origin.y, scaledSize.width, scaledSize.height))
            let dockItemFrame = NSMakeRect(self.dockItem.origin.x, self.dockItem.origin.y - self.dockItem.size.height, self.dockItem.size.width, self.dockItem.size.height)
            return frame.contains(NSEvent.mouseLocation) || dockItemFrame.contains(NSEvent.mouseLocation)
        }
        _setInapparentScale = {
            [weak self] in
            guard let self = self else { return }
            self._superScaleBy(x: 1e-6, y: self._currentaScale.y)
            self._originalPosition = self.layer!.position
            self.layer!.position = NSMakePoint(self._originalPosition!.x + self._currentaScale.x * self.frame.width, self._originalPosition!.y)
        }
    }
    
    /// A gap between visible frame and the dock edge.
    static let gapTolerance = 4.0
    
    static let gapBetweenDockAndRect = CGFloat(ThumbnailConstant.gapBetweenDockAndRectPtHeight)
    
    private var _getOrientatedPointWithAdjustment: (() -> NSPoint)?
    
    private var _universalMonitor: CGEventObserver?
    
    private var _scale: CGFloat = 1
    
    private var _dockOrientation: DockOrientation = .bottom
    
    private let _initialScale: CGFloat
    
    private var _whenDeactivating: (() -> Void)?
    
    var whenDeactivating: (() -> Void)? {
        get { _whenDeactivating }
        set {
            if let newFunction = newValue {
                _whenDeactivating = {
                    [weak self] in
                    guard let self = self else { return }
                    newFunction()
                    self._removeMonitor()
                }
            }
        }
    }
    
    var dockItem: DockItem
    
    var dockOrientation: DockOrientation {
        get { _dockOrientation }
        set {
            _dockOrientation = newValue
            switch (_dockOrientation) {
            case .bottom:
                _setAsBottom()
            case .left:
                _setAsLeft()
            case .right:
                _setAsRight()
            default:
                _setAsBottom()
            }
        }
    }
    
    /// To control the presentation window.
    weak var presentation: Presentation?
}

/// Correct animation errors caused by some bugs occured when setting values to `transform`.
class OrientatedPreviewWindowLayer : CALayer {
    override func action(forKey event: String) -> CAAction? {
        if event == "transform" {
            if let animation = super.action(forKey: event) {
                return animation
            } else if let presentation = presentation() {
                let animation = CABasicAnimation(keyPath: "transform")
                animation.fromValue = presentation.transform
                animation.fillMode = .backwards
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
                return animation
            }
        }
        return super.action(forKey: event)
    }
    
    override func presentation() -> Self? {
        if let presentation = super.presentation() {
            return presentation
        }
        return Unmanaged.passUnretained(self).takeRetainedValue()
    }
}
