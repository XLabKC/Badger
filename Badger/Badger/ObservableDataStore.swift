@objc protocol DataEntity: class {
    class func createFromSnapshot(snapshot: FDataSnapshot) -> DataEntity;
}

class ObservableDataStore<T: DataEntity> {
    private var entryByUrl: [String: Entry] = [:]
    private var waitersByUrl: [String: [T -> ()]] = [:]
    private var observersByUrl: [String: [WeakObserver]] = [:]
    private var handlesByUrl: [String: UInt] = [:]
    private let waitersLock = dispatch_queue_create("waitersLockQueue", nil)
    private let sendUpdateFunc: (T, AnyObject) -> ()

    init(sendUpdateFunc: (T, AnyObject) -> ()) {
        self.sendUpdateFunc = sendUpdateFunc
    }

    // Gets an entity.
    func getEntity(ref: Firebase, withBlock: T -> ()) -> T? {
        let url = ref.description()
        var needToMakeRequest = false

        if let entry = self.entryByUrl[url] {
            withBlock(entry.entity as T)
            if entry.expiration.compare(NSDate()) == .OrderedDescending {
                // Valid user entry. Just return.
                return entry.entity as? T
            } else {
                // The entry is out of date so request a new one.
                needToMakeRequest = true
            }
        }

        dispatch_sync(self.waitersLock) {
            var waiters = self.waitersByUrl[url]
            if waiters == nil {
                waiters = []
            }
            needToMakeRequest = waiters!.isEmpty
            waiters!.append(withBlock)
            self.waitersByUrl[url] = waiters!
        }

        if needToMakeRequest {
            ref.observeSingleEventOfType(.Value, withBlock: self.entityFetched)
        }
        return nil
    }

    func getEntities(refs: [Firebase], withBlock: [T] -> ()) {
        if refs.isEmpty {
            withBlock([])
            return
        }
        var entities = [T]()
        let barrier = Barrier(count: refs.count, done: { _ in
            withBlock(entities)
        })
        for ref in refs {
            self.getEntity(ref, withBlock: { entity in
                entities.append(entity)
                barrier.decrement()
            })
        }
    }

    // Adds an observer for a ref.
    func addObserver(observer: AnyObject, ref: Firebase) {
        let url = ref.description()
        var observers = self.observersByUrl[url]
        if observers == nil {
            observers = [WeakObserver]()
        }

        if observers!.isEmpty {
            observers!.append(WeakObserver(observer: observer))

            // Start listening for this user.
            self.handlesByUrl[url] = ref.observeEventType(.Value, withBlock: self.entityFetched)
        } else {
            observers!.append(WeakObserver(observer: observer))
            if let entry = self.entryByUrl[url]? {
                self.sendUpdateFunc(entry.entity as T, observer)
            }
        }

        self.observersByUrl[url] = observers!
    }

    // Removes an observer for a ref.
    func removeObserver(observer: AnyObject, ref: Firebase) {
        let url = ref.description()
        if var observers = self.observersByUrl[url]? {
            for (index, weakObserver) in enumerate(observers) {
                if weakObserver.observer === observer {
                    observers.removeAtIndex(index)
                    break
                }
            }
            if observers.isEmpty {
                self.stopListening(ref)
            }
        }
    }

    // Called every time an entity is fetched.
    private func entityFetched(snapshot: FDataSnapshot!) {
        let url = snapshot.ref.description()

        // Make sure that the snapshot is valid.
        if !(snapshot.value is NSDictionary) {
            return
        }
        dispatch_sync(self.waitersLock) {
            var entity = T.createFromSnapshot(snapshot) as T
            self.entryByUrl[url] = Entry(entity: entity)

            // Reply to all waiters.
            if let waiters = self.waitersByUrl[url]? {
                for block in waiters {
                    block(entity)
                }
            }
            self.waitersByUrl[url] = []

            // Update all observers.
            if let observers = self.observersByUrl[url]? {
                if !observers.isEmpty {
                    var valid = [WeakObserver]()
                    for weakObserver in observers {
                        if let observer: AnyObject = weakObserver.observer? {
                            self.sendUpdateFunc(entity, observer)
                            valid.append(weakObserver)
                        }
                    }
                    self.observersByUrl[url] = valid

                    // Check to make sure that there were at least one valid
                    // listener. Otherwise, stop listening.
                    if !valid.isEmpty {
                        return
                    }
                }
            }
            if let handle = self.handlesByUrl[url] {
                // There are no observers, stop listening.
                self.stopListening(snapshot.ref)
            }
        }
    }

    // Stop listening for updates of a user.
    private func stopListening(ref: Firebase) {
        if let handle = self.handlesByUrl[ref.description()]? {
            ref.removeObserverWithHandle(handle)
        }
    }
}

private class Entry {
    let entity: DataEntity
    let expiration: NSDate
    init(entity: DataEntity) {
        self.entity = entity
        // Set expiration for 15 minutes.
        self.expiration = NSDate(timeIntervalSinceNow: 15.0 * 60.0)
    }
}

private class WeakObserver {
    weak var observer: AnyObject?
    init(observer: AnyObject) {
        self.observer = observer
    }
}