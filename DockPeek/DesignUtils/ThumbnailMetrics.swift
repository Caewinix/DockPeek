import Foundation
import CoreGraphics

fileprivate let screenStdWidthPt: Double = 200

fileprivate func calculateScreenStdPtHeight(screenPtSize: CGSize) -> Double {
    return Double(screenStdWidthPt) / screenPtSize.width * screenPtSize.height;
}

// Create a window thumbnail size
func getThumbnailSize(pixelDensitySize: CGSize, screenPtSize: CGSize, imageSize: CGSize) -> CGSize {
    let imgPtSize = pixelToPt(CGSize(width: imageSize.width, height: imageSize.height), pixelDensity: pixelDensitySize)
    if (imgPtSize.width / imgPtSize.height) < (screenPtSize.width / screenPtSize.height) {
        // The image has a larger proportion of height. Use standard thumbnail height to obtain thumbnail width.
        let screenStdHeightPt = calculateScreenStdPtHeight(screenPtSize: screenPtSize)
        let ratio = imgPtSize.height / screenStdHeightPt
        return CGSize(width: imgPtSize.width / ratio, height: screenStdHeightPt)
    } else {
        // The image may have a larger proportion of width. Use standard thumbnail width to obtain thumbnail height.
        let ratio = imgPtSize.width / screenStdWidthPt
        return CGSize(width: screenStdWidthPt, height: imgPtSize.height / ratio)
    }
}

struct ThumbnailConstant {
    private init() {}
    static let rectSpacerPtLength = 8
    static let rectTopSpacerPtHeight = 38
    static let gapBetweenDockAndRectPtHeight = 12
    static let buttonCubePtLength = 29
    static let closeIconSizePtLength = 9
    static let buttonRelativePtPosition: NSPoint = .init(x: 3.5, y: 4.5)
    static let buttonCornerRadius = 2
    static let contentCornerRadius = 8
}
