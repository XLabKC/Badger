
class FirebaseObserver<T: DataEntity> {
    private var disposed = false
    private let query: FQuery
    private var started = false
    private var handles = [UInt]()
    private var loadedInitial = false

    var afterInitial: (() -> ())?
    var value: ((T) -> ())?
    var childAdded: ((T, previousId: String?, isInitial: Bool) -> ())?
    var childChanged: ((T, previousId: String?) -> ())?
    var childMoved: ((T, previousId: String?) -> ())?
    var childRemoved: ((T, previousId: String?) -> ())?

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
            var handle = self.query.observeEventType(.ChildMoved, withBlock: { snapshot in
                valueFunc(T.createFromSnapshot(snapshot) as T)
            })
            self.handles.append(handle)
        } else {
            if let childAddedFunc = self.childAdded? {
                var handle = self.query.observeEventType(.ChildAdded, andPreviousSiblingKeyWithBlock: { (snapshot, id) in
                    var data = T.createFromSnapshot(snapshot) as T
                    childAddedFunc(data, previousId: id, isInitial: !self.loadedInitial)
                })
                self.handles.append(handle)
            }
            self.maybeAddObservingFunc(self.childChanged, type: .ChildChanged)
            self.maybeAddObservingFunc(self.childMoved, type: .ChildMoved)
            self.maybeAddObservingFunc(self.childRemoved, type: .ChildRemoved)

            // After initial.
            self.query.observeSingleEventOfType(.Value, withBlock: { _ in
                self.loadedInitial = true
                if let afterInitial = self.afterInitial? {
                    afterInitial()
                }
            })
        }
    }

    func isStarted() -> Bool {
        return self.started
    }

    func hasLoadedInitial() -> Bool {
        return self.loadedInitial
    }

    func dispose() {
        if !self.disposed {
            self.disposed = true
            for handle in self.handles {
                self.query.removeObserverWithHandle(handle)
            }
        }
    }

    private func maybeAddObservingFunc(function: ((T, previousId: String?) -> ())?, type: FEventType) {
        if let observer = function? {
            var handle = self.query.observeEventType(type, andPreviousSiblingKeyWithBlock: { (snapshot, id) in
                observer(T.createFromSnapshot(snapshot) as T, previousId: id)
            })
            self.handles.append(handle)
        }
    }
}