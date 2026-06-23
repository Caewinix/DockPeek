import Foundation
import ApplicationServices

/// This function helps capture a window snapshot by its window ID.
func CGSHWCaptureWindowImage(_ cid: CGSConnectionID, _ windowID: CGWindowID, _ options: CGSWindowCaptureOptions) -> CGImage {
    var windowID = windowID
    let unmangedImageCFArray = CGSHWCaptureWindowList(cid, &windowID, 1, options)
    let imageArray = unmangedImageCFArray.takeRetainedValue() as! [CGImage]
    return imageArray[0]
}

/// This function helps capture a window snapshot by its accessibility element.
func AXSHWCaptureWindowImage(_ cid: CGSConnectionID, _ element: AXUIElement, _ options: CGSWindowCaptureOptions) -> CGImage {
    var windowID: CGWindowID = 0;
    _AXUIElementGetWindow(element, &windowID)
    return CGSHWCaptureWindowImage(cid, windowID, options)
}

typealias WindowCaptureOptions = CGSWindowCaptureOptions

typealias ConnectionID = CGSConnectionID

var mainConnectionID: ConnectionID {
    return CGSMainConnectionID()
}

func captureWindowImage(connectionID: ConnectionID, windowID: CGWindowID, options: WindowCaptureOptions) -> CGImage {
    return CGSHWCaptureWindowImage(connectionID, windowID, options)
}

func captureWindowImage(windowID: CGWindowID, options: WindowCaptureOptions) -> CGImage {
    return captureWindowImage(connectionID: mainConnectionID, windowID: windowID, options: options)
}

func captureWindowImage(windowID: CGWindowID) -> CGImage {
    return captureWindowImage(windowID: windowID, options: [.nominalResolution, .ignoreGlobalClipShape])
}

func captureWindowImage(connectionID: ConnectionID, element: AXUIElement, options: WindowCaptureOptions) -> CGImage {
    return AXSHWCaptureWindowImage(connectionID, element, options)
}

func captureWindowImage(element: AXUIElement, options: WindowCaptureOptions) -> CGImage {
    return captureWindowImage(connectionID: mainConnectionID, element: element, options: options)
}

func captureWindowImage(element: AXUIElement) -> CGImage {
    return captureWindowImage(element: element, options: [.nominalResolution, .ignoreGlobalClipShape])
}
