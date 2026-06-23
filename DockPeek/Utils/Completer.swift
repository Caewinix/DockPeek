import Foundation

/// The general workflow for creating a new future is to 1) create a new completer, 2) hand out its future, and, at a later point, 3) invoke either `complete`.
/// The `Completer` completer completes the future asynchronously. That means that callbacks registered on the future are not called immediately when `complete` is called. Instead the callbacks are delayed until a later microtask.
class Completer<T> {
    func complete(_ value: T) {
        _lock.async {
            [unowned self] in
            self._value = value
            self._continuation?.resume(returning: value)
        }
    }

    func future() async -> T {
        return await withCheckedContinuation {
            continuation in
            _lock.async {
                [unowned self] in
                if let value = self._value {
                    continuation.resume(returning: value)
                } else {
                    self._continuation = continuation
                }
            }
        }
    }
    
    func reset() {
        _lock.async {
            [unowned self] in
            self._value = nil
        }
    }
    
    private var _value: T?
    
    private var _lock = DispatchQueue.main
    
    private var _continuation: CheckedContinuation<T, Never>?

    var isCompleted: Bool {
        return self._value != nil
    }
    
    var dispatcher: DispatchQueue {
        get { _lock }
        set { _lock = newValue }
    }
}

/// A thread locker based on the `Completer`.
class CompletionLocker : NSLocking {
    init() {
        _completer.complete(())
    }
    
    func lock() {
        _completer.reset()
    }
    
    func unlock() {
        _completer.complete(())
    }
    
    func future() async {
        await _completer.future()
    }
    
    func future<T>(of: inout T) async -> T {
        await _completer.future()
        return withUnsafePointer(to: &of, { pointer in pointer.pointee })
    }
    
    func futureUnsafePointer<T>(of: inout T) async -> UnsafePointer<T> {
        await _completer.future()
        return withUnsafePointer(to: &of, { pointer in pointer })
    }
    
    func futureUnsafeMutablePointer<T>(of: inout T) async -> UnsafeMutablePointer<T> {
        await _completer.future()
        return withUnsafeMutablePointer(to: &of, { pointer in pointer })
    }
    
    private let _completer = Completer<Void>()
    
    var dispatcher: DispatchQueue {
        get { _completer.dispatcher }
        set { _completer.dispatcher = newValue }
    }
}
