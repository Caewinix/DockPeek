import AppKit

/// Store the event itself and its handler .
fileprivate class _CGEventMonitorHandler {
    init(_ handler: @escaping (CGEvent) -> Void) {
        self._handler = handler
    }
    
    func handle(_ event: CGEvent) {
        if event.type == .tapDisabledByTimeout {
            CGEvent.tapEnable(tap: eventTap, enable: true)
            event.type = .mouseMoved
        }
        _handler(event)
    }
    
    var eventTap: CFMachPort {
        get { _eventTap! }
        set { _eventTap = newValue }
    }
    
    private var _handler: (CGEvent) -> Void
    
    private var _eventTap: CFMachPort?
}

extension CGEvent {
    static var mouseLocation: CGPoint {
        return NSEvent.mouseLocation
    }
}

extension CGEvent {
    /// This function provides an easy way to add a universal monitor to detect all events in the system without any prohibition, so it needs accessibility permission. It offers an API similar to `NSEvent.addLocalMonitorForEvents(matching:, handler:)` restricted by the system.
    /// By adding the reference count, it cannot be released by itself, the control ownership is exposed to users.
    @discardableResult
    class func addUniversalMonitorForEvents(matching: EventTypeMask, handler: @escaping (CGEvent) -> Void) -> CGEventUniversalObserver? {
        let handler = _CGEventMonitorHandler(handler)
        if let eventTap = CGEvent.tapCreate(tap: .cgAnnotatedSessionEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: CGEventMask(matching.rawValue), callback: {
            (tapProxy, eventType, event, context) -> Unmanaged<CGEvent>? in
            Unmanaged<_CGEventMonitorHandler>.fromOpaque(context!).takeUnretainedValue().handle(event)
            return Unmanaged.passUnretained(event)
        }, userInfo: Unmanaged.passUnretained(handler).toOpaque()), let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0) {
            handler.eventTap = eventTap
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
            return Unmanaged.passRetained(CGEventUniversalObserver(runLoopSource, handler)).takeUnretainedValue()
        }
        return nil
    }
    
    /// Remove the monitor created by the `CGEvent`.
    class func removeMonitor(_ monitor: CGEventObserver) {
        monitor.invalidate()
        Unmanaged.passUnretained(monitor).release()
    }
}

extension CGEvent {
    class EventTypeMask : OptionSet, @unchecked Sendable {
        typealias RawValue = UInt64
        
        required init(rawValue: UInt64) {
            self.rawValue = rawValue
        }
        
        static func == (lhs: CGEvent.EventTypeMask, rhs: CGEvent.EventTypeMask) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        let rawValue: UInt64
        
        public static var leftMouseDown: EventTypeMask { .init(rawValue: 1 << CGEventType.leftMouseDown.rawValue) }

        public static var leftMouseUp: EventTypeMask { .init(rawValue: 1 << CGEventType.leftMouseUp.rawValue) }

        public static var rightMouseDown: EventTypeMask { .init(rawValue: 1 << CGEventType.rightMouseDown.rawValue) }

        public static var rightMouseUp: EventTypeMask { .init(rawValue: 1 << CGEventType.rightMouseUp.rawValue) }

        public static var mouseMoved: EventTypeMask { .init(rawValue: 1 << CGEventType.mouseMoved.rawValue) }

        public static var leftMouseDragged: EventTypeMask { .init(rawValue: 1 << CGEventType.leftMouseDragged.rawValue) }

        public static var rightMouseDragged: EventTypeMask { .init(rawValue: 1 << CGEventType.rightMouseDragged.rawValue) }

        public static var keyDown: EventTypeMask { .init(rawValue: 1 << CGEventType.keyDown.rawValue) }

        public static var keyUp: EventTypeMask { .init(rawValue: 1 << CGEventType.keyUp.rawValue) }

        public static var flagsChanged: EventTypeMask { .init(rawValue: 1 << CGEventType.flagsChanged.rawValue) }

        public static var scrollWheel: EventTypeMask { .init(rawValue: 1 << CGEventType.scrollWheel.rawValue) }
        
        public static var tabletProximity: EventTypeMask { .init(rawValue: 1 << CGEventType.tabletProximity.rawValue) }

        public static var tabletPointer: EventTypeMask { .init(rawValue: 1 << CGEventType.tabletPointer.rawValue) }

        public static var otherMouseDown: EventTypeMask { .init(rawValue: 1 << CGEventType.otherMouseDown.rawValue) }

        public static var otherMouseUp: EventTypeMask { .init(rawValue: 1 << CGEventType.otherMouseUp.rawValue) }

        public static var otherMouseDragged: EventTypeMask { .init(rawValue: 1 << CGEventType.otherMouseDragged.rawValue) }
        
//        public static var tapDisabledByTimeout: EventTypeMask { .init(rawValue: 1 << CGEventType.tapDisabledByTimeout.rawValue) }
//
//        public static var tapDisabledByUserInput: EventTypeMask { .init(rawValue: 1 << CGEventType.tapDisabledByUserInput.rawValue) }
    }
}

protocol Invalidation : CGEventObserver {
    func invalidate()
}

class CGEventObserver : Invalidation {
    func invalidate() {}
}

/// The `CGEvent` observer for universal monitors.
class CGEventUniversalObserver : CGEventObserver {
    fileprivate init(_ runLoopSource: CFRunLoopSource, _ handler: _CGEventMonitorHandler) {
        _runLoopSource = runLoopSource
        _handler = handler
    }
    
    @objc override func invalidate() {
        CGEvent.tapEnable(tap: _handler.eventTap, enable: false)
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), _runLoopSource, .commonModes)
    }
    
    private var _runLoopSource: CFRunLoopSource
    private var _handler: _CGEventMonitorHandler
}
