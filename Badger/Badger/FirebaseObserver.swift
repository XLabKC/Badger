
class FirebaseObserver<T: DataEntity> {
    private var disposed = false
    private let query: FQuery
    private var started = false
    private var handles = [UInt]()
    private var loadedInitial = false

    var afterInitial: (() -> ())?
    var childAdded: ((T, previousId: String?, isInitial: Bool) -> ())?
    var childChanged: ((T, previousId: String?) -> ())?
    var childMoved: ((T, previousId: String?) -> ())?
    var childRemoved: ((T, previousId: String?) -> ())?

    init(query: FQuery) {
        self.query = query
    }

    convenience init(query: FQuery, withBlock: T -> ()) {
        self.init(query: query)
        self.observe(withBlock)
    }

    deinit {
        dispose()
    }

    // Starts observing the ref.
    func observe(withBlock: T -> ()) {
        if self.started {
            return
        }
        self.started = true

        let handle = self.query.observeEventType(.Value, withBlock: { snapshot in
            if snapshot.childrenCount > 0 {
                withBlock(T.createFromSnapshot(snapshot) as T)
            } else {
                println("No data at: \(snapshot.ref.description())")
            }
        })
        self.handles.append(handle)
    }

    // Starts observing the ref with the handlers that have been specified.
    func start() {
        if self.started {
            return
        }
        self.started = true

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