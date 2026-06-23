import Foundation
import AppKit

func getScreenSize(_ screen: NSScreen) -> NSSize {
    return screen.convertRectToBacking(screen.frame).size;
}

func pixelDensitySize(_ screen: NSScreen) -> NSSize {
    let sizePt: NSSize = screen.frame.size
    let sizePixel: NSSize = getScreenSize(screen)
    return .init(width: sizePixel.width / sizePt.width, height: sizePixel.height / sizePt.height)
}

func pixelToPt(_ px: Int, pixelDensity: Double) -> Double {
    return Double(px) / pixelDensity;
}

func pixelToPt(_ pixelSize: NSSize, pixelDensity: NSSize) -> NSSize {
    return .init(width: pixelSize.width / pixelDensity.width, height: pixelSize.height / pixelDensity.height)
}

func ptToPixel(_ dp: Double, pixelDensity: Double) -> Int {
    return Int(dp * pixelDensity);
}

func ptToPixel(_ ptSize: NSSize, pixelDensity: NSSize) -> NSSize {
    return .init(width: ptSize.width * pixelDensity.width, height: ptSize.height * pixelDensity.height)
}
