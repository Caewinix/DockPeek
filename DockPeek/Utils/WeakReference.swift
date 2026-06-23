struct WeakReference<T : AnyObject> {
    weak var value: T?
    init(_ value: T? = nil) {
        self.value = value
    }
}
