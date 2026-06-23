import AppKit

extension NSScreen {
    var effectiveHeight: CGFloat {
        if self === NSScreen.main {
            let menuBarHeight = NSApp.mainMenu?.menuBarHeight ?? 0
            return self.frame.height - menuBarHeight
        }
        return self.frame.height
    }
    
    var uuid: String? {
        if let screenNumber = self.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")],
           // these APIs implicitly unwrap their return values, but it can actually be nil thus we check
           let screenUuid = CGDisplayCreateUUIDFromDisplayID(screenNumber as! UInt32),
           let uuid = CFUUIDCreateString(nil, screenUuid.takeRetainedValue()) {
            return uuid as String
        }
        return nil
    }
}

extension NSScreen {
    subscript(index: String) -> Any? { self.deviceDescription[NSDeviceDescriptionKey(index)] }
}

extension NSScreen {
    private static var _currentScreenIndex: Int?
    
    /// Get the screen that the mouse cursor is located.
    static var currentScreen: NSScreen {
        let mouseLocation = CGEvent.mouseLocation
        let displayID = getDisplayIDs(withPoint: mouseLocation)[0]
        if let oldCurrentScreenIndex = _currentScreenIndex {
            let oldCurrentScreen = NSScreen.screens[oldCurrentScreenIndex]
            if NSMouseInRect(mouseLocation, oldCurrentScreen.frame, false), let screenNumber = oldCurrentScreen["NSScreenNumber"] as? CGDirectDisplayID, screenNumber == displayID {
                return oldCurrentScreen
            }
        }
        for (i, screen) in NSScreen.screens.enumerated() {
            if let screenNumber = screen["NSScreenNumber"] as? CGDirectDisplayID, screenNumber == displayID {
                _currentScreenIndex = i
                break
            }
        }
        if _currentScreenIndex != nil {
            return NSScreen.screens[_currentScreenIndex!]
        } else {
            return NSScreen.main!
        }
    }
}
