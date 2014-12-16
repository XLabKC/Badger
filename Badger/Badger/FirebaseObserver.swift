
class FirebaseObserver<T: DataEntity> {
    private var disposed = false
    private let query: FQuery
    private var started = false
    private var handles = [UInt]()

    var afterInitial: (() -> ())?
    var value: ((T) -> ())?
    var childAdded: ((T) -> ())?
    var childChanged: ((T) -> ())?
    var childMoved: ((T, previousId: String) -> ())?
    var childRemoved: ((T) -> ())?

    init(query: FQuery) {
        self.query = query
    }
    deinit {
        dispose()
    }

    func start() {
        if self.started {
            return
        }
        self.started = true

        if let valueFunc = self.value? {
            self.maybeAddObservingFunc(self.value, type: .Value)
        } else {
            self.maybeAddObservingFunc(self.childAdded, type: .ChildAdded)
            self.maybeAddObservingFunc(self.childChanged, type: .ChildChanged)
            self.maybeAddObservingFunc(self.childRemoved, type: .ChildRemoved)
            // Child moved.
            if let childMovedFunc = self.childMoved? {
                var handle = self.query.observeEventType(.ChildMoved, andPreviousSiblingKeyWithBlock: { (snapshot, id) in
                    childMovedFunc(T.createFromSnapshot(snapshot) as T, previousId: id)
                })
                self.handles.append(handle)
            }
            // After initial.
            if let afterInitial = self.afterInitial? {
                self.query.observeSingleEventOfType(.Value, withBlock: { _ in
                    afterInitial()
                })
            }

        }
    }

    func isStarted() -> Bool {
        return self.started
    }

    func dispose() {
        if !self.disposed {
            self.disposed = true
            for handle in self.handles {
                self.query.removeObserverWithHandle(handle)
            }
        }
    }

    private func maybeAddObservingFunc(function: ((T) -> ())?, type: FEventType) {
        if let observer = function? {
            var handle = self.query.observeEventType(type, withBlock: { snapshot in
                observer(T.createFromSnapshot(snapshot) as T)
            })
            self.handles.append(handle)
        }
    }
}