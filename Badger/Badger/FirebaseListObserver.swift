
class FirebaseListObserver<T: DataEntity> {

    private var ref: Firebase
    private var keys: [String: FirebaseObserver<T>] = [:]
    private var changedFunc: [T] -> ()
    private var internalEntities = [T]()

    var comparisonFunc: (T, T) -> Bool = { (a, b) -> Bool in
        return a.getKey() < b.getKey()
    }

    init(ref: Firebase, onChanged: [T] -> ()) {
        self.ref = ref
        self.changedFunc = onChanged
    }

    convenience init(ref: Firebase, keys: [String], onChanged: [T] -> ()) {
        self.init(ref: ref, onChanged: onChanged)
        for key in keys {
            self.observeKey(key)
        }
    }

    // Sets the keys to be observed and stops observing any keys not included.
    func setKeys(keys: [String]) {
        var newKeys = [String: Bool](minimumCapacity: keys.count)
        for key in keys {
            newKeys[key] = true
        }

        // Dispose of any key not in the new list.
        var removedKey = false
        for key in self.keys.keys {
            if (newKeys[key] != true) {
                removedKey = true
                self.disposeKey(key)
            }
        }

        // Now observe all new keys.
        for key in keys {
            self.observeKey(key)
        }

        // If a key has been removed, the list is different so call
        // changed function.
        if removedKey {
            self.changedFunc(self.internalEntities)
        }
    }

    // Observe a key based on the root reference.
    func observeKey(key: String) {
        if self.keys[key] == nil {
            let ref = self.ref.childByAppendingPath(key)
            self.keys[key] = FirebaseObserver<T>(query: ref, withBlock: self.updated)
        }
    }

    // Stop listening to the key.
    func disposeKey(key: String) {
        if let observer = self.keys[key]? {
            observer.dispose()
        }
        // Remove the element from the internal list.
        let index = self.findEntity(key)
        if index >= 0 {
            self.internalEntities.removeAtIndex(index)
        }
    }

    // Dispose all observers.
    func dispose() {
        for observer in self.keys.values {
            observer.dispose()
        }
        self.keys.removeAll(keepCapacity: false)
        self.internalEntities.removeAll(keepCapacity: false)
    }

    private func updated(entity: T) {
        var found = false
        for (index, other) in enumerate(self.internalEntities) {
            if other.getKey() == entity.getKey() {
                // Already exists so insert it
                found = true
                self.internalEntities[index] = entity
                break
            } else if self.comparisonFunc(other, entity) {
                // List is sorted so we know that this entity is not in the list
                // and should be inserted here.
                found = true
                self.internalEntities.insert(entity, atIndex: index)
                break
            }
        }
        if !found {
            self.internalEntities.append(entity)
        }
        self.changedFunc(self.internalEntities)
    }

    private func findEntity(key: String) -> Int {
        for (index, entity) in enumerate(self.internalEntities) {
            if entity.getKey() == key {
                return index
            }
        }
        return -1
    }
}

//private class KeyObserver<T: DataEntity> {
//    init(ref: Firebase, )
//}