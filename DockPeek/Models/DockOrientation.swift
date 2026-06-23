typealias DockOrientation = CoreDockOrientation

extension DockOrientation {
    init() {
        var orientation: DockOrientation.RawValue = 0
        var dockPinning: CoreDockPinning.RawValue = 0
        CoreDockGetOrientationAndPinning(&orientation, &dockPinning)
        self.init(rawValue: orientation)!
    }
}
