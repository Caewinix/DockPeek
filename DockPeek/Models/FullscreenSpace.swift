import AppKit

/// This model is only for recording the information of a fullscreen window.
struct FullscreenSpace : Equatable {
    var spaceID: CGSSpaceID
    var pid: pid_t
    var windowID: CGWindowID
    var title: String
    
    static func == (lhs: FullscreenSpace, rhs: FullscreenSpace) -> Bool {
        return (lhs.windowID == rhs.windowID) && (lhs.pid == rhs.pid)
    }
}
