import Foundation

/// This model is only for recording the information of a dock item.
struct DockItem {
    init(title: String, pid: pid_t, type: String, frame: NSRect, element: AXUIElement) {
        self._title = title
        self._pid = pid
        self._type = type
        self._frame = frame
        self._element = element
    }
    
    private var _title: String
    
    private var _pid: pid_t
    
    private var _type: String
    
    private var _frame: NSRect
    
    private var _element: AXUIElement
    
    var title: String { _title }
    
    var pid: pid_t { _pid }
    
    var type: String { _type }
    
    var frame: NSRect {
        get { _frame }
        set { _frame = newValue }
    }
    
    var element: AXUIElement { _element }
    
    var size: NSSize {
        get { _frame.size }
        set { _frame.size = newValue }
    }
    
    var origin: NSPoint {
        get { _frame.origin }
        set { _frame.origin = newValue }
    }
    
    var isApplicationRunning: Bool { _pid != -1 }
}
