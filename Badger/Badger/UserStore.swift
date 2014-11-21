
class UserStore {
    // Accesses the singleton.
    class func sharedInstance() -> UserStore {
        struct Static {
            static var instance: UserStore?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = UserStore()
        }
        return Static.instance!
    }

    private var usersByUid: [String: UserStoreEntry] = [:]
    private var waitersByUid: [String: [(User -> ())]] = [:]
    private let ref = Firebase(url: Global.FirebaseUsersUrl)
    private let waitersLock = dispatch_queue_create( "waitersLockQueue", nil)

    init() {
        
    }

    func isAuthUser(uid: String) -> Bool {
        return uid == ref.authData.uid
    }

    func getAuthUser(withBlock: (User -> ())) -> User? {
        return self.getUser(self.ref.authData.uid, withBlock: withBlock)
    }

    // Returns the user immediately if available and passes it to the block, otherwise
    // makes the request and passes the user to the block.
    func getUser(uid: String, withBlock: (User -> ())) -> User? {
        if let userEntry = self.usersByUid[uid] {
            if userEntry.expiration.compare(NSDate()) == .OrderedDescending {
                // Valid user entry. Just return.
                withBlock(userEntry.user)
                return userEntry.user
            } else {
                self.usersByUid.removeValueForKey(uid)
            }
        }

        var needToMakeRequest = false

        dispatch_sync(self.waitersLock) {
            var waiters = self.waitersByUid[uid]
            if waiters == nil {
                waiters = []
            }
            needToMakeRequest = waiters!.isEmpty
            waiters!.append(withBlock)
            self.waitersByUid[uid] = waiters!
        }

        if needToMakeRequest {
            self.ref.childByAppendingPath(uid).observeSingleEventOfType(.Value, withBlock: self.userFetched)
        }

        return nil
    }

    private func userFetched(snapshot: FDataSnapshot!) {
        let uid = snapshot.key

        // Make sure that the snapshot is valid.
        if !(snapshot.value is NSDictionary) {
            return
        }
        dispatch_sync(self.waitersLock) {
            let user = User.createUserFromSnapshot(snapshot)
            self.usersByUid[uid] = UserStoreEntry(user: user)
            if let waiters = self.waitersByUid[uid]? {
                for block in waiters {
                    block(user)
                }
            }
        }
    }
}

class UserStoreEntry {
    let user: User
    let expiration: NSDate
    init(user: User) {
        self.user = user
        // Set expiration for 15 minutes.
        self.expiration = NSDate(timeIntervalSinceNow: 15.0 * 60.0)
    }
}
