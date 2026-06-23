import Cocoa
import ApplicationServices

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private let _dockPeekManager = DockPeekManager()
    private var _monitor: CGEventUniversalObserver?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AXAssertEnabled()
        CGRequestScreenCaptureAccess()
        
        _monitor = CGEvent.addUniversalMonitorForEvents(matching: [.mouseMoved, .leftMouseUp, .leftMouseDown, .rightMouseDown]) {
            [unowned self] event in
            DockPeekManager.setTask {
                [unowned self] in
                let mouseLoc = getMouseLocation()
                _dockPeekManager.detectThumbnailPreviews(atMouseLocation: mouseLoc, withMouseType: event.type)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        CGEvent.removeMonitor(_monitor!)
        _monitor = nil
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

