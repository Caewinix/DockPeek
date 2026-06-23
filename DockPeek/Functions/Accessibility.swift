import ApplicationServices
import AppKit

func getDockItemByLocation(_ location: NSPoint, _ sysWideElem: AXUIElement) -> DockItem? {
    // This element will contain whatever we are hovering over.
    if let element = try? AXUIElement.copy(atPosition: location) {
        if let axSubrole = element.subrole {
            // If this is a Dock item, gather more information.
            if axSubrole == "AXApplicationDockItem" {
                let frame = element.frame!
                let title = element.title!
                // Get the pid of the element
                if let appUnderCursorUrl = element.URL {
                    let appBundle = Bundle(url: appUnderCursorUrl)
                    if let bundleId = appBundle?.bundleIdentifier {
                        let apps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId)
                        var pid: pid_t = -1
                        if apps.count > 1 {
                            for app in apps {
                                if let appUrl = app.bundleURL, appUrl == appUnderCursorUrl {
                                    pid = app.processIdentifier
                                    break
                                }
                            }
                        } else if apps.count == 1 {
                            pid = apps[0].processIdentifier
                        }
                        if pid != -1 {
                            return DockItem(title: title, pid: pid, type: axSubrole, frame: frame, element: element)
                        } else {
                            return nil
                        }
                    }
                }
            }
        }
    }
    return nil
}

func getDockItemByMouseLocation(_ sysWideElem: AXUIElement) -> DockItem? {
    return getDockItemByLocation(getMouseLocation(), sysWideElem);
}

/// This function helps record windows information of an application, including the medium snapshot, PID, window ID, and so on. If it is not a fuscreen window, it stores the window accessibility element, otherwise the dock item accessibility element and its title.
func getAppWindows(dockItem: DockItem) -> [AppWindow] {
    let pid: pid_t = dockItem.pid
    var appWindows: [AppWindow] = []
    let appElement = AXUIElement.createApplication(processIdentifier: pid)
    let mainConnectionID = CGSMainConnectionID()
    let currentScreen = NSScreen.currentScreen
    let uuid = currentScreen.uuid!
    let fullscreenSpaces = getFullcreenSpaces(mainConnectionID, fromDisplayUUID: uuid)
    let currentSpaceID: CGSSpaceID = CGSManagedDisplayGetCurrentSpace(mainConnectionID, uuid as CFString)
    if let windows = appElement.windows {
        appWindows.reserveCapacity(windows.count + fullscreenSpaces.count)
        for window in windows {
            if let windowID = window.windowIdentifier, (CGSCopySpacesForWindows(mainConnectionID, CGSSpaceMask.all.rawValue, [windowID] as CFArray) as! [CGSSpaceID]).contains(currentSpaceID) {
                if let subrole = window.subrole, (subrole == kAXStandardWindowSubrole || subrole == kAXDialogSubrole) {
                    appWindows.append(.init(windowID: windowID, pid: pid, element: window))
                }
            }
        }
    }
    
    for fullscreenSpace in fullscreenSpaces {
        if fullscreenSpace.pid == pid {
            appWindows.append(.init(windowID: fullscreenSpace.windowID, pid: fullscreenSpace.pid, dockElement: dockItem.element, title: fullscreenSpace.title))
        }
    }
    return appWindows
}

func focusWindow(element windowElement: AXUIElement, pid: pid_t, windowID: CGWindowID) {
    var psn = ProcessSerialNumber()
    GetProcessForPID(pid, &psn)
    _SLPSSetFrontProcessWithOptions(&psn, windowID, SLPSMode.userGenerated.rawValue)
    makeKeyWindow(psn: psn, windowID: windowID)
    windowElement.raise()
}

/// The following function was ported from https://github.com/Hammerspoon/hammerspoon/issues/370#issuecomment-545545468
fileprivate func makeKeyWindow(psn: ProcessSerialNumber, windowID: CGWindowID) {
    var windowID = windowID
    var psn = psn
    var bytes1 = [UInt8](repeating: 0, count: 0xf8)
    bytes1[0x04] = 0xF8
    bytes1[0x08] = 0x01
    bytes1[0x3a] = 0x10
    var bytes2 = [UInt8](repeating: 0, count: 0xf8)
    bytes2[0x04] = 0xF8
    bytes2[0x08] = 0x02
    bytes2[0x3a] = 0x10
    memcpy(&bytes1[0x3c], &windowID, MemoryLayout<UInt32>.size)
    memset(&bytes1[0x20], 0xFF, 0x10)
    memcpy(&bytes2[0x3c], &windowID, MemoryLayout<UInt32>.size)
    memset(&bytes2[0x20], 0xFF, 0x10)
    [bytes1, bytes2].forEach {
        bytes in
        _ = bytes.withUnsafeBufferPointer() {
            pointer in
            SLPSPostEventRecordTo(&psn, &UnsafeMutablePointer(mutating: pointer.baseAddress)!.pointee)
        }
    }
}
