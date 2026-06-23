extension Unmanaged {
    @discardableResult
    private static func _passRetained(_ value: Instance) -> Unmanaged<Instance> {
        Unmanaged.passRetained(value)
    }
    
    @discardableResult
    private static func _takeRetainedValue(_ value: Instance) -> Instance {
        Unmanaged.passUnretained(value).takeRetainedValue()
    }
    
    static func increaseRetainCount(for value: Instance) {
        Unmanaged._passRetained(value)
    }
    
    static func decreaseRetainCount(for value: Instance) {
        Unmanaged._takeRetainedValue(value)
    }
    
    static func getRetainCount(for value: Instance) -> Int {
        CFGetRetainCount(value)
    }
}
