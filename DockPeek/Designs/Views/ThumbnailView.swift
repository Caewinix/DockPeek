import AppKit

private func adjustImageView(_ imageView: NSImageView) {
    imageView.imageScaling = .scaleProportionallyUpOrDown
    let currentScreen = NSScreen.currentScreen
    let possibleSize = getThumbnailSize(pixelDensitySize: pixelDensitySize(currentScreen), screenPtSize: getScreenSize(currentScreen), imageSize: imageView.image!.size)
    imageView.setFrameSize(possibleSize)
}

/// The `ThumbnailView` is only designed for showing the thumbnail with an icon button.
class ThumbnailView : PaddingView {
    enum UnifiedLength {
        case none
        case height(CGFloat)
        case width(CGFloat)
    }
    
    init(image: CGImage) {
        self._image = image
        let imageView = NSImageView(image: NSImage(cgImage: image, size: image.size))
        adjustImageView(imageView)
        super.init(mainView: imageView)
        setDefaultPadding()
        _setViews()
    }
    
    override init(frame frameRect: NSRect = .zero) {
        super.init(mainView: NSImageView())
        super.frame = frameRect
        setDefaultPadding()
        _setViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        super.mainView = NSImageView()
        setDefaultPadding()
        _setViews()
    }
    
    private func _setViews() {
        super.mainView!.wantsLayer = true
        super.mainView!.layer!.backgroundColor = .clear
        
        super.wantsLayer = true
        super.layer!.backgroundColor = ThumbnailView._normalBackgroundColor
        
        let titleTextField = NSTextField()
        titleTextField.backgroundColor = .clear
        titleTextField.isBordered = false
        titleTextField.isEditable = false
        titleTextField.alignment = .center
        titleTextField.font = titleTextField.font!.withSize(14)
        titleTextField.cell!.lineBreakMode = .byTruncatingTail
        _titleTextField = titleTextField
        super.addSubview(_titleTextField!)
    }
    
    func setDefaultPadding() {
        let length = CGFloat(ThumbnailConstant.rectSpacerPtLength)
        super.padding = Padding(top: CGFloat(ThumbnailConstant.rectTopSpacerPtHeight), left: length, bottom: length, right: length)
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        let trackingArea = NSTrackingArea(rect: super.bounds, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }
    
    private func _mouseEntered() {
        _iconButton!.layer!.opacity = 1
        super.layer!.backgroundColor = ThumbnailView._hoveredBackgroundColor
        onHovered?()
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        _mouseEntered()
    }
    
    private func _mouseExited() {
        _iconButton!.layer!.opacity = 0
        super.layer!.backgroundColor = ThumbnailView._normalBackgroundColor
        onHoveredEnd?()
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        _mouseExited()
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        super.layer!.backgroundColor = ThumbnailView._pressedBackgroundColor
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        if super.bounds.contains(super.convert(event.locationInWindow, from: nil)) {
            _mouseEntered()
            self.onPressed?()
        } else {
            _mouseExited()
        }
    }
    
    override func performLayout() {
        super.performLayout()
        
        let maxTitleWidth = (super.frame.width - (_iconButtonRelativePosition.x + _iconButton!.frame.width) * 2) * 0.95
        if _titleTextField!.frame.width > maxTitleWidth {
            _titleTextField!.setFrameSize(NSMakeSize(maxTitleWidth, _titleTextField!.frame.height))
        }
        _titleTextField!.setFrameOrigin(NSMakePoint((super.frame.width - _titleTextField!.frame.width) / 2, super.frame.height - super.padding.top + (super.padding.top - _titleTextField!.frame.height) / 2))
        if _iconButton != nil {
            _iconButton!.setFrameOrigin(NSMakePoint(_iconButtonRelativePosition.x, super.frame.height - _iconButtonRelativePosition.y - _iconButton!.frame.height))
        }
    }
    
    func setIconButton<T : IconButton>(_ type: T.Type) {
        if let iconButton = _iconButton {
            iconButton.removeFromSuperview()
        }
        let iconButton = T()
        iconButton.layer!.opacity = 0
        _iconButton = iconButton
        super.addSubview(_iconButton!)
    }
    
    private static let _normalBackgroundColor = CGColor.clear
    
    private static let _hoveredBackgroundColor = NSColor(white:1.0, alpha:0.4).cgColor
    
    private static let _pressedBackgroundColor = NSColor(white:1.0, alpha:0.25).cgColor
    
    private var _image: CGImage?
    
    private var _iconButtonRelativePosition: NSPoint = ThumbnailConstant.buttonRelativePtPosition
    
    private weak var _titleTextField: NSTextField?
    
    private weak var _iconButton: IconButton?
    
    var onPressed: (() -> Void)?
    
    var image: CGImage? {
        get { _image }
        set {
            _image = newValue
            let imageView = mainView! as! NSImageView
            if let image = _image {
                let newSize = image.size
                imageView.image = NSImage(cgImage: image, size: newSize)
                adjustImageView(imageView)
            } else {
                imageView.image = nil
            }
        }
    }
    
    var iconButtonRelativePosition: NSPoint {
        get { _iconButtonRelativePosition }
        set {
            _iconButtonRelativePosition = newValue
            _iconButton!.setFrameOrigin(NSMakePoint(_iconButtonRelativePosition.x, super.frame.height - _iconButtonRelativePosition.y - _iconButton!.frame.height))
        }
    }
    
    var title: String {
        get { _titleTextField!.stringValue }
        set {
            _titleTextField!.stringValue = newValue
            _titleTextField!.sizeToFit()
            _titleTextField!.setFrameOrigin(NSMakePoint((super.frame.width - _titleTextField!.frame.width) / 2, super.frame.height - super.padding.top + (super.padding.top - _titleTextField!.frame.height) / 2))
        }
    }
    
    var titleFont: NSFont? {
        get { _titleTextField!.font }
        set { _titleTextField!.font = newValue }
    }
    
    var onPressedIconButton: (() -> Void)? {
        get { _iconButton!.onPressed }
        set { _iconButton!.onPressed = newValue }
    }
    
    var onHovered: (() -> Void)?
    var onHoveredEnd: (() -> Void)?
}

class IconButton : NSView {
    required init(length: CGFloat = CGFloat(ThumbnailConstant.buttonCubePtLength)) {
        super.init(frame: NSMakeRect(0, 0, length, length))
        super.wantsLayer = true
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        super.wantsLayer = true
        setupLayer()
    }
    
    private func setupLayer() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.strokeColor = nil
        shapeLayer.lineWidth = 1.0
        shapeLayer.fillColor = nil
        shapeLayer.lineCap = .round
        
        _shapeLayer = shapeLayer
        self.iconColor = normalIconColor
        super.layer!.addSublayer(shapeLayer)
        
        self.backgroundColor = normalBackgroundColor
        self.cornerRadius = Double(ThumbnailConstant.buttonCornerRadius)
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        let trackingArea = NSTrackingArea(rect: super.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        super.addTrackingArea(trackingArea)
    }
    
    override func mouseEntered(with event: NSEvent) {
        self.backgroundColor = hoveredBackgroundColor
        self.iconColor = hoveredIconColor
    }
    
    override func mouseExited(with event: NSEvent) {
        self.backgroundColor = normalBackgroundColor
        self.iconColor = normalIconColor
    }
    
    override func mouseDown(with event: NSEvent) {
        self.backgroundColor = pressedBackgroundColor
    }
    
    override func mouseUp(with event: NSEvent) {
        if super.bounds.contains(super.convert(event.locationInWindow, from: nil)) {
            self.mouseEntered(with: event)
            self.onPressed?()
        } else {
            self.mouseExited(with: event)
        }
    }
    
    var normalBackgroundColor = CGColor.clear
    
    var hoveredBackgroundColor = NSColor.black.withAlphaComponent(0.25).cgColor
    
    var pressedBackgroundColor = NSColor.blue.withAlphaComponent(0.75).cgColor
    
    var normalIconColor = NSColor.black.withAlphaComponent(0.75).cgColor
    
    var hoveredIconColor = CGColor.white
    
    private weak var _shapeLayer: CAShapeLayer?
    
    private var _iconLength: CGFloat = 9
    
    var onPressed: (() -> Void)?
    
    var iconLength: CGFloat {
        get { _iconLength }
        set {
            _iconLength = newValue
            _shapeLayer!.path = path
        }
    }
    
    var cornerRadius: CGFloat {
        get { super.layer!.cornerRadius }
        set { super.layer!.cornerRadius = newValue }
    }
    
    var path: CGMutablePath {
        return CGMutablePath()
    }
    
    var iconFillColor: CGColor? {
        get { _shapeLayer!.fillColor }
        set { _shapeLayer!.fillColor = newValue }
    }
    
    var iconStrokeColor: CGColor? {
        get { _shapeLayer!.strokeColor }
        set { _shapeLayer!.strokeColor = newValue }
    }
    
    var iconColor: CGColor? {
        get { iconFillColor }
        set { iconFillColor = newValue }
    }
    
    var backgroundColor: CGColor {
        get { super.layer!.backgroundColor!  }
        set { super.layer!.backgroundColor = newValue }
    }
}

class CloseButton : IconButton {
    required init(length: CGFloat = CGFloat(ThumbnailConstant.buttonCubePtLength)) {
        super.init(length: length)
        _setProperties()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setProperties()
    }
    
    private func _setProperties() {
        super.pressedBackgroundColor = CGColor(red: 195/255, green: 73/255, blue: 66/255, alpha: 0.75)
        super.iconLength = CGFloat(ThumbnailConstant.closeIconSizePtLength)
    }
    
    override var path: CGMutablePath {
        let centerX = super.frame.width / 2.0
        let centerY = super.frame.height / 2.0
        let radius = iconLength / 2.0

        let path = CGMutablePath()
        path.move(to: CGPoint(x: centerX - radius, y: centerY - radius))
        path.addLine(to: CGPoint(x: centerX + radius, y: centerY + radius))
        path.move(to: CGPoint(x: centerX + radius, y: centerY - radius))
        path.addLine(to: CGPoint(x: centerX - radius, y: centerY + radius))
        
        return path
    }
    
    override var iconColor: CGColor? {
        get { super.iconStrokeColor }
        set { super.iconStrokeColor = newValue }
    }
}

class ExitFullscreenButton : IconButton {
    required init(length: CGFloat = CGFloat(ThumbnailConstant.buttonCubePtLength)) {
        super.init(length: length)
        _setProperties()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setProperties()
    }
    
    private func _setProperties() {
        super.pressedBackgroundColor = CGColor(red: 97/255, green: 197/255, blue: 84/255, alpha: 0.75)
        self.iconLength = 15
        self.iconStrokeColor = nil
    }
    
    override var path: CGMutablePath {
        let centerX = super.frame.width / 2.0
        let centerY = super.frame.height / 2.0
        let radius = iconLength / 2.0
        let gap = radius / 15

        let path = CGMutablePath()
        path.move(to: CGPoint(x: centerX - gap, y: centerY + gap))
        path.addLine(to: CGPoint(x: centerX - gap, y: centerY + radius - gap))
        path.addLine(to: CGPoint(x: centerX - radius + gap, y: centerY + gap))
        path.closeSubpath()
        
        path.move(to: CGPoint(x: centerX + gap, y: centerY - gap))
        path.addLine(to: CGPoint(x: centerX + gap, y: centerY - radius + gap))
        path.addLine(to: CGPoint(x: centerX + radius - gap, y: centerY - gap))
        path.closeSubpath()
        
        return path
    }
}
