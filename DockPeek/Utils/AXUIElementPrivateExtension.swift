import ApplicationServices

extension AXUIElement {
    @discardableResult
    func windowIdentifier(_ throwable: Throwable = .always) throws -> CGWindowID {
        var value: CGWindowID = 0
        let error = _AXUIElementGetWindow(self, &value)
        if error != .success {
            throw error
        }
        return value
    }
    
    var windowIdentifier: CGWindowID? { try? windowIdentifier() }
}
