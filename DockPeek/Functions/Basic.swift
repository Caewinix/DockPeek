import Foundation
import AppKit

func getMouseLocation() -> NSPoint {
    // Get global location of the mouse.
    let mouseLocation: NSPoint = NSEvent.mouseLocation
    // All of the mouse co-ordinates for multiple monitors are based on the primary screen.
    // So if you have monitor A (1080) to your left, and monitor B to the right (1200), arranged in such a way
    // that they are both vertically aligned to the top, if your mouse was on B at the bottom, it would report a position of -120 for the Y value.
    //
    // The accessibility API uses the inverse, so we need to convert this Y value to something it understands.
    // To do this, we take the first primary display, and get it's height.
    // So using the above example: 1080 - (-120) = 1200.
    let primary_display_height: CGFloat = NSMaxY(NSScreen.screens[0].frame)
    let y: CGFloat = primary_display_height - mouseLocation.y
    return NSMakePoint(mouseLocation.x, y)
}

func getWindowIDsInSpaces(_ spaceIds: [CGSSpaceID]) -> [CGWindowID] {
    var set_tags = ([] as CGSCopyWindowsTags).rawValue
    var clear_tags = ([] as CGSCopyWindowsTags).rawValue
    let options = ([.minimizedAndTabbed, .screenSaverLevel1000] as CGSCopyWindowsOptions).rawValue
    return CGSCopyWindowsWithOptionsAndTags(CGSMainConnectionID(), 0, spaceIds as CFArray, options, &set_tags, &clear_tags) as! [CGWindowID]
}

func getDisplayIDs(withPoint: NSPoint, maxDisplays: Int = 1) -> [CGDirectDisplayID] {
    var displays: [CGDirectDisplayID] = .init(repeating: 0, count: maxDisplays)
    var matchingDisplayCount: UInt32 = 0
    CGGetDisplaysWithPoint(withPoint, UInt32(maxDisplays), &displays, &matchingDisplayCount)
    return displays
}

func getDisplayUUIDs(withPoint: NSPoint, maxDisplays: Int = 1) -> [String] {
    let displays: [CGDirectDisplayID] = getDisplayIDs(withPoint: withPoint, maxDisplays: maxDisplays)
    var uuids: [String] = []
    uuids.reserveCapacity(displays.count)
    for display in displays {
        if let uuid = CGDisplayCreateUUIDFromDisplayID(display)?.takeRetainedValue(), let uuid = CFUUIDCreateString(kCFAllocatorDefault, uuid) as? String {
            uuids.append(uuid)
        }
    }
    return uuids
}

func getScreenSpaceIDs(_ cid: CGSConnectionID, fromDisplayUUID uuid: String) -> [CGSSpaceID] {
    var spaceIDs: [CGSSpaceID] = []
    
    let displaySpaces = CGSCopyManagedDisplaySpaces(cid) as! [NSDictionary]
    for screen in displaySpaces {
        if screen["Display Identifier"] as! String == uuid {
            let spaces = screen["Spaces"] as! [NSDictionary]
            for space in spaces {
                spaceIDs.append(space["ManagedSpaceID"] as! CGSSpaceID)
            }
            break
        }
    }
    return spaceIDs
}

func getFullcreenSpaces(_ cid: CGSConnectionID, fromDisplayUUID uuid: String) -> [FullscreenSpace] {
    var fullscreenSpaces: [FullscreenSpace] = []
    
    let displaySpaces = CGSCopyManagedDisplaySpaces(cid) as! [NSDictionary]
    for screen in displaySpaces {
        if screen["Display Identifier"] as! String == uuid {
            let spaces = screen["Spaces"] as! [NSDictionary]
            for space in spaces {
                if let fullscreenTileSpace = ((space["TileLayoutManager"] as? NSDictionary)?["TileSpaces"] as? [NSDictionary])?[0] {
                    fullscreenSpaces.append(.init(spaceID: space["ManagedSpaceID"] as! CGSSpaceID, pid: fullscreenTileSpace["pid"] as! pid_t, windowID: fullscreenTileSpace["TileWindowID"] as! CGWindowID, title: fullscreenTileSpace["name"] as! String))
                }
            }
            break
        }
    }
    return fullscreenSpaces
}
