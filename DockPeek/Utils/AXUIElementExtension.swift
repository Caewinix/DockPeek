import ApplicationServices

// for some reason, these attributes are missing from AXAttributeConstants
let kAXFullscreenAttribute = "AXFullScreen"
let kAXStatusLabelAttribute = "AXStatusLabel"
let kAXStandardWindowSubrole = "AXStandardWindow"
let kAXDialogSubrole = "AXDialog"

extension AXUIElement {
    func perform(action: String) throws {
        let error = AXUIElementPerformAction(self, action as CFString)
        if error != .success {
            throw error
        }
    }
}

extension AXUIElement {
    static var systemWide: AXUIElement {
        AXUIElementCreateSystemWide()
    }
    
    static func createApplication(processIdentifier pid: pid_t) -> AXUIElement {
        AXUIElementCreateApplication(pid)
    }
    
    @discardableResult
    func processIdentifier(_ throwable: Throwable = .always) throws -> pid_t {
        var value: pid_t = 0
        let error = AXUIElementGetPid(self, &value)
        if error != .success {
            throw error
        }
        return value
    }
    
    var processIdentifier: pid_t? { try? processIdentifier() }
    
    static func copy(atPosition position: NSPoint, fromElement: AXUIElement = .systemWide) throws -> AXUIElement {
        var element: AXUIElement?
        let error = AXUIElementCopyElementAtPosition(fromElement, Float(position.x), Float(position.y), &element)
        if error != .success {
            throw error
        }
        return element!
    }
    
    @discardableResult
    func role(placeholder value: inout AnyObject?) throws -> String {
        let error = AXUIElementCopyAttributeValue(self, kAXRoleAttribute as CFString, &value)
        if error != .success {
            throw error
        }
        return value as! String
    }
    
    @discardableResult
    func role(_ throwable: Throwable = .always) throws -> String {
        var value: AnyObject?
        return try role(placeholder: &value)
    }
    
    var role: String? { try? role() }
    
    @discardableResult
    func subrole(placeholder value: inout AnyObject?) throws -> String {
        let error = AXUIElementCopyAttributeValue(self, kAXSubroleAttribute as CFString, &value)
        if error != .success {
            throw error
        }
        return value as! String
    }
    
    @discardableResult
    func subrole(_ throwable: Throwable = .always) throws -> String {
        var value: AnyObject?
        return try subrole(placeholder: &value)
    }
    
    var subrole: String? { try? subrole() }
    
    @discardableResult
    func sheetRole(placeholder value: inout AnyObject?) throws -> String {
        let error = AXUIElementCopyAttributeValue(self, kAXSheetRole as CFString, &value)
        if error != .success {
            throw error
        }
        return value as! String
    }
    
    @discardableResult
    func sheetRole(_ throwable: Throwable = .always) throws -> String {
        var value: AnyObject?
        return try sheetRole(placeholder: &value)
    }
    
    var sheetRole: String? { try? sheetRole() }
    
    @discardableResult
    func size(placeholder value: inout AnyObject?) throws -> CGSize {
        var size: CGSize = .zero
        // Get the size of the element
        let error = AXUIElementCopyAttributeValue(self, kAXSizeAttribute as CFString, &value)
        if error != .success {
            throw error
        }
        AXValueGetValue(value as! AXValue, AXValueType.cgSize, &size)
        return size
    }
    
    @discardableResult
    func size(_ throwable: Throwable = .always) throws -> CGSize {
        var value: AnyObject?
        return try size(placeholder: &value)
    }
    
    var size: CGSize? { try? size() }
    
    @discardableResult
    func origin(placeholder value: inout AnyObject?) throws -> CGPoint {
        var origin: CGPoint = .zero
        // Get the size of the element
        let error = AXUIElementCopyAttributeValue(self, kAXPositionAttribute as CFString, &value)
        if error != .success {
            throw error
        }
        AXValueGetValue(value as! AXValue, AXValueType.cgPoint, &origin)
        return origin
    }
    
    @discardableResult
    func origin(_ throwable: Throwable = .always) throws -> CGPoint {
        var value: AnyObject?
        return try origin(placeholder: &value)
    }
    
    var origin: CGPoint? { try? origin() }
    
    @discardableResult
    func frame(_ throwable: Throwable = .always) throws -> NSRect {
        return CGRect(origin: try origin(), size: try size())
    }
    
    var frame: NSRect? { try? frame() }
    
    @discardableResult
    func title(placeholder value: inout AnyObject?) throws -> String {
        let error = AXUIElementCopyAttributeValue(self, kAXTitleAttribute as CFString, &value)
        if error != . success {
            throw error
        }
        return value as! String
    }
    
    @discardableResult
    func title(_ throwable: Throwable = .always) throws -> String {
        var value: AnyObject?
        return try title(placeholder: &value)
    }
    
    var title: String? { try? title() }
    
    @discardableResult
    func URL(placeholder value: inout AnyObject?) throws -> URL {
        let error = AXUIElementCopyAttributeValue(self, kAXURLAttribute as CFString, &value)
        if error != .success {
            throw error
        }
        return value as! URL
    }
    
    @discardableResult
    func URL(_ throwable: Throwable = .always) throws -> URL {
        var value: AnyObject?
        return try URL(placeholder: &value)
    }
    
    var URL: URL? { try? URL() }
    
    @discardableResult
    func windows(placeholder value: inout AnyObject?) throws -> [AXUIElement] {
        let error = AXUIElementCopyAttributeValue(self, kAXWindowsAttribute as CFString, &value)
        if error != .success {
            throw error
        }
        return value as! [AXUIElement]
    }
    
    @discardableResult
    func windows(_ throwable: Throwable = .always) throws -> [AXUIElement] {
        var value: AnyObject?
        return try windows(placeholder: &value)
    }
    
    var windows: [AXUIElement]? { try? windows() }
    
    @discardableResult
    func mainWindow(placeholder value: inout AnyObject?) throws -> AXUIElement {
        let error = AXUIElementCopyAttributeValue(self, kAXMainWindowAttribute as CFString, &value)
        if error != .success {
            throw error
        }
        return value as! AXUIElement
    }
    
    @discardableResult
    func mainWindow(_ throwable: Throwable = .always) throws -> AXUIElement {
        var value: AnyObject?
        return try mainWindow(placeholder: &value)
    }
    
    var mainWindow: AXUIElement? { try? mainWindow() }
    
    @discardableResult
    func window(placeholder value: inout AnyObject?) throws -> AXUIElement {
        let error = AXUIElementCopyAttributeValue(self, kAXWindowAttribute as CFString, &value)
        if error != .success {
            throw error
        }
        return value as! AXUIElement
    }
    
    @discardableResult
    func window(_ throwable: Throwable = .always) throws -> AXUIElement {
        var value: AnyObject?
        return try window(placeholder: &value)
    }
    
    var window: AXUIElement? { try? window() }
    
    @discardableResult
    func visibleChildren(placeholder value: inout AnyObject?) throws -> [AXUIElement] {
        let error = AXUIElementCopyAttributeValue(self, kAXVisibleChildrenAttribute as CFString, &value)
        if error != .success {
            throw error
        }
        return value as! [AXUIElement]
    }
    
    @discardableResult
    func visibleChildren(_ throwable: Throwable = .always) throws -> [AXUIElement] {
        var value: AnyObject?
        return try visibleChildren(placeholder: &value)
    }
    
    var visibleChildren: [AXUIElement]? { try? visibleChildren() }
    
    @discardableResult
    func parent(placeholder value: inout AnyObject?) throws -> AXUIElement {
        let error = AXUIElementCopyAttributeValue(self, kAXParentAttribute as CFString, &value)
        if error != .success {
            throw error
        }
        return value as! AXUIElement
    }
    
    @discardableResult
    func parent(_ throwable: Throwable = .always) throws -> AXUIElement {
        var value: AnyObject?
        return try parent(placeholder: &value)
    }
    
    var parent: AXUIElement? { try? parent() }
    
    @discardableResult
    func children(placeholder value: inout AnyObject?) throws -> [AXUIElement] {
        let error = AXUIElementCopyAttributeValue(self, kAXChildrenAttribute as CFString, &value)
        if error != .success {
            throw error
        }
        return value as! [AXUIElement]
    }
    
    @discardableResult
    func children(_ throwable: Throwable = .always) throws -> [AXUIElement] {
        var value: AnyObject?
        return try children(placeholder: &value)
    }
    
    var children: [AXUIElement]? { try? children() }
    
    @discardableResult
    func closeButton(placeholder value: inout AnyObject?) throws -> AXUIElement {
        let error = AXUIElementCopyAttributeValue(self, kAXCloseButtonAttribute as CFString, &value)
        if error != .success {
            throw error
        }
        return value as! AXUIElement
    }
    
    @discardableResult
    func closeButton(_ throwable: Throwable = .always) throws -> AXUIElement {
        var value: AnyObject?
        return try closeButton(placeholder: &value)
    }
    
    var closeButton: AXUIElement? { try? closeButton() }
    
    @discardableResult
    func isMinimized(placeholder value: inout AnyObject?) throws -> Bool {
        let error = AXUIElementCopyAttributeValue(self, kAXMinimizedAttribute as CFString, &value)
        if error != .success {
            throw error
        }
        return value as! Bool
    }
    
    @discardableResult
    func isMinimized(_ throwable: Throwable = .always) throws -> Bool {
        var value: AnyObject?
        return try isMinimized(placeholder: &value)
    }
    
    var isMinimized: Bool? {
        get { try? isMinimized() }
        set {
            if let newValue = newValue {
                let value: CFBoolean
                if newValue {
                    value = kCFBooleanTrue
                } else {
                    value = kCFBooleanFalse
                }
                AXUIElementSetAttributeValue(self, kAXMinimizedAttribute as CFString, value)
            }
        }
    }
    
    @discardableResult
    func isFocused(placeholder value: inout AnyObject?) throws -> Bool {
        let error = AXUIElementCopyAttributeValue(self, kAXFocusedAttribute as CFString, &value)
        if error != .success {
            throw error
        }
        return value as! Bool
    }
    
    @discardableResult
    func isFocused(_ throwable: Throwable = .always) throws -> Bool {
        var value: AnyObject?
        return try isFocused(placeholder: &value)
    }
    
    var isFocused: Bool? {
        get { try? isFocused() }
        set {
            if let newValue = newValue {
                let value: CFBoolean
                if newValue {
                    value = kCFBooleanTrue
                } else {
                    value = kCFBooleanFalse
                }
                AXUIElementSetAttributeValue(self, kAXFocusedAttribute as CFString, value)
            }
        }
    }
    
    @discardableResult
    func isEdited(placeholder value: inout AnyObject?) throws -> Bool {
        let error = AXUIElementCopyAttributeValue(self, kAXEditedAttribute as CFString, &value)
        if error != .success {
            throw error
        }
        return value as! Bool
    }
    
    @discardableResult
    func isEdited(_ throwable: Throwable = .always) throws -> Bool {
        var value: AnyObject?
        return try isEdited(placeholder: &value)
    }
    
    var isEdited: Bool? {
        get { try? isEdited() }
    }
    
    func press(_ throwable: Throwable = .always) throws {
        try perform(action: kAXPressAction)
    }
    
    func press() {
        try? press(.always)
    }
    
    func raise(_ throwable: Throwable = .always) throws {
        try perform(action: kAXRaiseAction)
    }
    
    func raise() {
        try? raise(.always)
    }
    
    @discardableResult
    func isFullscreen(placeholder value: inout AnyObject?) throws -> Bool {
        let error = AXUIElementCopyAttributeValue(self, kAXFullscreenAttribute as CFString, &value)
        if error != .success {
            throw error
        }
        return value as! Bool
    }
    
    @discardableResult
    func isFullscreen(_ throwable: Throwable = .always) throws -> Bool {
        var value: AnyObject?
        return try isFullscreen(placeholder: &value)
    }
    
    var isFullscreen: Bool? {
        get { try? isFullscreen() }
        set {
            if let newValue = newValue {
                let value: CFBoolean
                if newValue {
                    value = kCFBooleanTrue
                } else {
                    value = kCFBooleanFalse
                }
                AXUIElementSetAttributeValue(self, kAXFullscreenAttribute as CFString, value)
            }
        }
    }
}

extension AXUIElement {
    enum Throwable {
        case always
    }
}

extension AXError : Error {}
