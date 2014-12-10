class FirebaseAsync {
    private var firebase: Firebase
    private var handle: UInt = 0

    var forEach: ((FDataSnapshot, isNew: Bool) -> ())?
    var afterInitial: (() -> ())?


    init(firebase: Firebase) {
        self.firebase = firebase
    }

    convenience init(firebase: Firebase, forEach: ((FDataSnapshot, isNew: Bool) -> ()), afterInitial: () -> ()) {
        self.init(firebase: firebase)
        self.forEach = forEach
        self.afterInitial = afterInitial
    }

    func observeEventType(eventType: FEventType) {
        if (eventType == FEventType.Value) {
            println("The VALUE event type should not be used.")
            return
        }

        var isNewData = false
        
        handle = self.firebase.observeEventType(eventType, withBlock: { snapshot in
            if self.forEach != nil {
                self.forEach!(snapshot, isNew: isNewData)
            }
        })

        self.firebase.observeSingleEventOfType(.Value, withBlock: { snapshot in
            isNewData = true
            if self.afterInitial != nil {
                self.afterInitial!()
            }
        })
    }

    func detach() {
        self.firebase.removeObserverWithHandle(self.handle)
    }

    class func observeEventType(firebase: Firebase, eventType: FEventType,
            forEach: ((FDataSnapshot, isNew: Bool) -> ()),
            afterInitial: () -> ()) -> FirebaseAsync {
        let async = FirebaseAsync(firebase: firebase, forEach: forEach, afterInitial: afterInitial)
        async.observeEventType(eventType)
        return async;
    }

    class func fetchValues(refs: [Firebase], withBlock: [FDataSnapshot] -> ()) {
        if refs.isEmpty {
            withBlock([])
            return
        }
        var snapshots = [FDataSnapshot]()
        let barrier = Barrier(count: refs.count, done: { _ in
            withBlock(snapshots)
        })
        for ref in refs {
            ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
                snapshots.append(snapshot)
                barrier.decrement()
            })
        }
    }
}