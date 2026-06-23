import AppKit
import Carbon.HIToolbox.Events

/// This `AppWindow` stores each required information from each window, and wraps accessibility functions.
struct AppWindow {
    init(windowID: CGWindowID, pid: pid_t, element: AXUIElement) {
        _windowID = windowID
        _pid = pid
        _element = element
        let image: CGImage = captureWindowImage(windowID: windowID)
        if image.isEffective {
            _image = image
        }
    }
    
    init(windowID: CGWindowID, pid: pid_t, dockElement: AXUIElement, title: String) {
        _windowID = windowID
        _pid = pid
        _dockElement = dockElement
        _title = title
        let image: CGImage = captureWindowImage(windowID: windowID)
        if image.isEffective {
            _image = image
        }
    }
    
    private var _windowID: CGWindowID
    
    private var _element: AXUIElement?
    
    private var _dockElement: AXUIElement?
    
    private var _image: CGImage?
    
    private var _pid: pid_t
    
    private var _title: String?
    
    var windowID: CGWindowID { _windowID }
    
    var element: AXUIElement? { _element }
    
    var image: CGImage? { _image }
    
    var pid: pid_t { _pid }
    
    var isFullscreen: Bool { _element == nil }
    
    var title: String? {
        if let element = element {
            return element.title
        } else {
            return _title
        }
    }
    
    func focus() {
        if let element = element {
            focusWindow(element: element, pid: pid, windowID: windowID)
        } else {
            _focusFullscreen {}
        }
    }
    
    /// This function helps switch to the fullscreen desktop space. It checks whther the current space ID equals to the required fullscreen space ID, if it does, the future completer completes to return the `async` task, otherwise it will check whether the current space is switched, if not, it will send the switch signal.
    private func _tuggleFullscreen(_ cid: CGSConnectionID, lastSpaceID: CGSSpaceID, fullscreenSpaceID: CGSSpaceID, completer: Completer<Void>) {
        let currentScreen = NSScreen.currentScreen
        let uuid = currentScreen.uuid!
        let currentSpaceID: CGSSpaceID = CGSManagedDisplayGetCurrentSpace(cid, uuid as CFString)
        if currentSpaceID == fullscreenSpaceID {
            completer.complete(())
        } else if currentSpaceID != lastSpaceID {
            DispatchQueue.main.async {
                [unowned completer] in
                _dockElement!.press()
                _tuggleFullscreen(cid, lastSpaceID: currentSpaceID, fullscreenSpaceID: fullscreenSpaceID, completer: completer)
            }
        } else {
            DispatchQueue.main.async {
                [unowned completer] in
                _tuggleFullscreen(cid, lastSpaceID: currentSpaceID, fullscreenSpaceID: fullscreenSpaceID, completer: completer)
            }
        }
    }
    
    func _focusFullscreen(_ afterFocused: @escaping () -> Void) {
        let mainConnectionID = CGSMainConnectionID()
        let fullscreenSpaceID = (CGSCopySpacesForWindows(mainConnectionID, CGSSpaceMask.all.rawValue, [windowID] as CFArray) as! [CGSSpaceID])[0]
        let currentScreen = NSScreen.currentScreen
        let uuid = currentScreen.uuid!
        let currentSpaceID: CGSSpaceID = CGSManagedDisplayGetCurrentSpace(mainConnectionID, uuid as CFString)
        let completer = Completer<Void>()
        Task {
            await completer.future()
            afterFocused()
        }
        DispatchQueue.main.async {
            [unowned completer] in
            _dockElement!.press()
            if currentSpaceID == CGSManagedDisplayGetCurrentSpace(mainConnectionID, uuid as CFString) {
                _dockElement!.press()
            }
            _tuggleFullscreen(mainConnectionID, lastSpaceID: currentSpaceID, fullscreenSpaceID: fullscreenSpaceID, completer: completer)
        }
    }
    
    /// Also use similar to ensure the window is closed, when closable, the window `AXUIElement` cannot know the children element, so it will throw a  exception, in this case, the counterpart should be `.invalidUIElement`, informing that closing sucessful, whereas the new added `AXSheet` or non-null title tell the failure.
    func close(handler: @escaping (Bool) -> Void) {
        if _element != nil {
            let completer = Completer<Bool>()
            /* Counting sheetNumber version.
            var sheetNumber: Int = 0
            if let children = _element!.children {
                for child in children {
                    if child.role == "AXSheet" {
                        sheetNumber += 1
                    }
                }
            }
            */
            _element!.closeButton?.press()
            Task {
                handler(await completer.future())
            }
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                [unowned completer] in
                do {
                    try _element!.closeButton()
                    let app = AXUIElement.createApplication(processIdentifier: pid)
                    let windows = try app.windows()
                    var isReallyClosed: Bool = true
                    for window in windows {
                        if let windowIdentifier = window.windowIdentifier, windowIdentifier == windowID {
                            isReallyClosed = false
                            break
                        }
                    }
                    completer.complete(isReallyClosed)
                    /* Counting sheetNumber version.
                    let children = try _element!.children()
                    var whetherNotAddedNewSheet = true
                    var newSheetNumber: Int = 0
                    for child in children {
                        if child.role == "AXSheet" {
                            newSheetNumber += 1
                            if newSheetNumber > sheetNumber {
                                whetherNotAddedNewSheet = false
                                break
                            }
                        }
                    }
                    completer.complete(_element!.title == nil && whetherNotAddedNewSheet)
                    */
                } catch {
                    let error = error as! AXError
                    completer.complete(error == .invalidUIElement || error == .cannotComplete)
                }
            }
        }
    }
    
    func exitFullscreen() {
        _focusFullscreen {
            let appElement = AXUIElement.createApplication(processIdentifier: pid)
            if let windows = appElement.windows {
                for window in windows {
                    if window.windowIdentifier == windowID {
                        window.isFullscreen = false
                        break
                    }
                }
            }
        }
    }
}
