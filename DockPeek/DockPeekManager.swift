import AppKit

/// A main manager for dock thumbnails peek.
class DockPeekManager {
    /// All for setting timer for necessary delays.
    private var _previewShowTimer: Timer?
    private var _lastPid: pid_t = 0
    private var _currentPid: pid_t = 0
    private var _hasOrderedOut = false
    private var _isMenuMode = false
    private var _longPressTimer: Timer?
    private var _currentMouseLocation: NSPoint = .zero
    private var _currentMouseType: CGEventType = .null
    
    /// Cancel the show of previews, which is the menu mode, since right mouse click or long press result in the menu of the dock item.
    func _setMenuMode() {
        for previewWindowView in _previewWindowViews.values {
            previewWindowView.value!.deactivateForcibly(duration: 0)
        }
        _previewWindowViews.removeAll()
        _presentationController.hide()
        _isMenuMode = true
        _hasOrderedOut = false
    }
    
    func detectThumbnailPreviews(atMouseLocation mouseLocation: NSPoint, withMouseType mouseType: CGEventType) {
        _currentMouseLocation = mouseLocation
        _currentMouseType = mouseType
        if _isMenuMode && mouseType == .leftMouseUp {
            _isMenuMode = false
        }
        
        var dockRect: NSRect = .zero
        CoreDockGetRect(&dockRect)
        
        if dockRect.contains(mouseLocation), let dockItem = getDockItemByLocation(mouseLocation, _systemWideElement) {
            _currentPid = dockItem.pid
            if  mouseType == .rightMouseDown {
                _setMenuMode()
            } else if mouseType == .leftMouseDown {
                if _lastPid != dockItem.pid || _longPressTimer == nil {
                    if _longPressTimer != nil {
                        _longPressTimer!.invalidate()
                        _longPressTimer = nil
                    }
                    _longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {
                        [unowned self] _ in
                        if _currentMouseType == .leftMouseDown && _currentPid == dockItem.pid {
                            _setMenuMode()
                        }
                        _longPressTimer = nil
                        _lastPid = 0
                        _currentPid = 0
                    })
                }
            } else if !_isMenuMode {
                if _previewWindowViews[dockItem.pid] == nil {
                    if _lastPid != dockItem.pid || _previewShowTimer == nil {
                        if _previewShowTimer != nil {
                            _previewShowTimer!.invalidate()
                            _previewShowTimer = nil
                        }
                        _previewShowTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false) {
                            [unowned self] _ in
                            if _currentPid == dockItem.pid && getDockItemByLocation(_currentMouseLocation, _systemWideElement) != nil, let previewWindowView = _createPreviews(dockItem) {
                                for previewWindowView in _previewWindowViews.values {
                                    previewWindowView.value!.deactivateForcibly(duration: 0)
                                }
                                
                                _previewWindowViews[dockItem.pid] = .init(previewWindowView)
                                _previewWindowViews[dockItem.pid]!.value!.firstlyActivate()
                            }
                            _previewShowTimer = nil
                            _lastPid = 0
                            _currentPid = 0
                        }
                    }
                }
            }
            _lastPid = _currentPid
        }
        if _previewWindowViews.isEmpty && !_hasOrderedOut {
            _window.orderOut(nil)
            _hasOrderedOut = true
        }
    }
    
    /// Create the preview window view if possible, which generate each thumbnail view with its own behavior.
    private func _createPreviews(_ dockItem: DockItem) -> OrientatedPreviewWindowView? {
        let appWindows = getAppWindows(dockItem: dockItem)
        if !appWindows.isEmpty {
            var dockItem = dockItem
            for subview in _window.contentView!.subviews {
                let subview = (subview as! OrientatedPreviewWindowView)
                if subview.dockItem.pid == dockItem.pid {
                    return subview
                }
            }
            dockItem.origin.y = NSScreen.currentScreen.frame.height - dockItem.origin.y
            let previewWindowView = OrientatedPreviewWindowView(dockItem: dockItem, presentation: _presentationController)
            _window.contentView!.addSubview(previewWindowView)
            _window.orderFront(nil)
            
            previewWindowView.whenDeactivating = {
                [unowned self] in
                _previewWindowViews.removeValue(forKey: dockItem.pid)
                _hasOrderedOut = false
            }
            
            func hideAll(_ appWindow: AppWindow, _ previewWindowView: OrientatedPreviewWindowView) {
                _presentationController.removeWindowPreview(windowID: appWindow.windowID)
                _presentationController.hide()
                previewWindowView.deactivateForcibly()
                _previewWindowViews.removeValue(forKey: dockItem.pid)
            }
            
            for appWindow in appWindows {
                if let image = appWindow.image {
                    let view = ThumbnailView(image: image)
                    if let title = appWindow.title, title != "" {
                        view.title = title
                    } else {
                        view.title = dockItem.title
                    }
                    previewWindowView.contentView.addSubview(view)
                    view.onPressed = {
                        [unowned previewWindowView] in
                        appWindow.focus()
                        previewWindowView.deactivateForcibly()
                    }
                    if appWindow.isFullscreen {
                        view.setIconButton(ExitFullscreenButton.self)
                        view.onPressedIconButton = {
                            [unowned previewWindowView] in
                            appWindow.exitFullscreen()
                            hideAll(appWindow, previewWindowView)
                            appWindow.focus()
                        }
                    } else {
                        view.setIconButton(CloseButton.self)
                        let removeCurrentView = {
                            [unowned view] in
                            view.removeFromSuperview()
                        }
                        view.onPressedIconButton = {
                            [unowned previewWindowView] in
                            appWindow.close {
                                [weak previewWindowView] isSuccessful in
//                                print(isSuccessful)
                                guard let previewWindowView = previewWindowView else { return }
                                if isSuccessful {
                                    NSAnimationContext.runAnimationGroup {
                                        [unowned self, previewWindowView] context in
                                        context.allowsImplicitAnimation = true
                                        self._presentationController.removeWindowPreview(windowID: appWindow.windowID)
                                        removeCurrentView()
                                        previewWindowView.adjustPreviewWindowView()
                                        if previewWindowView.contentView.subviews.isEmpty {
                                            previewWindowView.deactivateForcibly()
                                            self._previewWindowViews.removeValue(forKey: dockItem.pid)
                                        }
                                    }
                                } else {
                                    hideAll(appWindow, previewWindowView)
                                    appWindow.focus()
                                }
                            }
                        }
                    }
                    view.onHovered = {
                        [unowned self] in
                        _presentationWindow.makeKeyAndOrderFront(nil)
                        _presentationController.addWindowPreview(windowID: appWindow.windowID, windowElement: appWindow.element)
                        _window.orderFront(nil)
                    }
                    view.onHoveredEnd = {
                        [unowned self] in
                        _presentationController.removeWindowPreview(windowID: appWindow.windowID)
                    }
                }
            }
            previewWindowView.adjustPreviewWindowView()
            _window.orderFront(nil)
            return previewWindowView
        }
        return nil
    }
    
    /// The thread for Dock Peek.
    static private var _locker = DispatchQueue(label: "Dock Peek")
    
    /// Assign tasks for the  thread for Dock Peek.
    static func setTask(_ task: @escaping () -> Void) {
        _locker.sync(execute: task)
    }
    
    /// The unique window for displaying thumbnails.
    private var _window: PreviewWindow = PreviewWindow()
    
    /// The system wide accessibility element for all use.
    private var _systemWideElement: AXUIElement = .systemWide
    
    /// All preview window views with PID as keys.
    private var _previewWindowViews: [pid_t : WeakReference<OrientatedPreviewWindowView>] = [:]
    
    /// The control the presentaion of the preview of each window.
    private let _presentationController = PresentationWindowController()
    
    /// The presentaion window for the preview of each window.
    private lazy var _presentationWindow: PresentationWindow = PresentationWindow(controller: _presentationController)
}
