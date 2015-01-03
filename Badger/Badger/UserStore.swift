
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

    private let ref = Firebase(url: Global.FirebaseUsersUrl)
    private var observer: FirebaseObserver<User>?
    private var authUser = User(uid: "unauthenticated", provider: "none")

    deinit {
        if let observer = self.observer? {
            observer.dispose()
        }
    }

    // Tells the store to start listening to the authorized user.
    func authorized(withBlock: User -> ()) {
        if self.observer != nil {
            return
        }
        let ref = User.createRef(self.ref.authData.uid)
        var firstTime = true
        self.observer = FirebaseObserver<User>(query: ref, withBlock: { user in
            self.authUser = user
            if firstTime {
                firstTime = false
                withBlock(user)
            }
        })
    }

    // Returns the current auth user's uid.
    func getAuthUid() -> String {
        return self.ref.authData.uid
    }

    // Returns a value indicating if this uid is the current auth user's.
    func isAuthUser(uid: String) -> Bool {
        return uid == self.getAuthUid()
    }

    // Returns the authenticated user.
    func getAuthUser() -> User {
        return self.authUser
    }

    // Prefetches the uids.
    class func prefetchUsers(uids: [String], withBlock: () -> ()) {
        let refs = uids.map(User.createRef)
        FirebaseAsync.fetchValues(refs, withBlock: { snapshots in
            withBlock()
        })
    }

    // Atomically adjusts the active count.
    class func adjustActiveTaskCount(id: String, delta: Int) {
        let ref = Firebase(url: Global.FirebaseUsersUrl).childByAppendingPath("\(id)/active_task_count")
        FirebaseUtil.adjustValueForRef(ref, delta: delta)
    }

    // Atomically adjusts the completed count.
    class func adjustCompletedTaskCount(id: String, delta: Int) {
        let ref = Firebase(url: Global.FirebaseUsersUrl).childByAppendingPath("\(id)/completed_task_count")
        FirebaseUtil.adjustValueForRef(ref, delta: delta)
    }

    class func followUser(follower: String, otherUid: String) {
        User.createRef(otherUid).childByAppendingPath("followers/\(follower)").setValue(true)
        User.createRef(follower).childByAppendingPath("following/\(otherUid)").setValue(true)
    }

    class func unFollowUser(follower: String, otherUid: String) {
        User.createRef(otherUid).childByAppendingPath("followers/\(follower)").removeValue()
        User.createRef(follower).childByAppendingPath("following/\(otherUid)").removeValue()
    }
}
