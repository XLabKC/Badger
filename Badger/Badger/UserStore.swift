
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
    private var waitingForUserBlocks: [User -> ()] = []
    private var hasLoadedUser = false

    var unauthorizedBlock: (() -> ())?
    var authorizedBlock: (() -> ())?

    deinit {
        if let observer = self.observer {
            observer.dispose()
        }
    }

    // Initializes the UserStore.
    func initialize() {
        self.ref.root.observeAuthEventWithBlock { authData in
            if (authData != nil && authData.uid != nil) {
                self.startWatchingUser(authData.uid)
                if let block = self.authorizedBlock {
                    block()
                }
            } else {
                self.stopWatchingUser()
                if let block = self.unauthorizedBlock {
                    block()
                }
            }
        }
    }

    // Wait for the auth user to be loaded.
    func waitForUser(block: User -> ()) {
        if self.hasLoadedUser {
            return block(self.authUser)
        }
        self.waitingForUserBlocks.append(block)
    }

    func hasValidAuth() -> Bool {
        return self.ref.root.authData != nil && self.ref.root.authData.uid != nil
    }

    // Returns the current auth user's uid.
    func getAuthUid() -> String {
        return self.authUser.uid
    }

    // Returns a value indicating if this uid is the current auth user's.
    func isAuthUser(uid: String) -> Bool {
        return uid == self.getAuthUid()
    }

    // Returns the authenticated user.
    func getAuthUser() -> User {
        return self.authUser
    }

    // Start observing the authorized user.
    private func startWatchingUser(uid: String) {
        if self.observer != nil {
            self.stopWatchingUser()
        }
        let ref = self.ref.childByAppendingPath(uid)
        var firstTime = true
        self.observer = FirebaseObserver<User>(query: ref, withBlock: { user in
            self.authUser = user
            self.hasLoadedUser = true
            if !self.waitingForUserBlocks.isEmpty {
                for block in self.waitingForUserBlocks {
                    block(user)
                }
                self.waitingForUserBlocks.removeAll(keepCapacity: false)
            }
        })
    }

    // Stops watching the auth user.
    private func stopWatchingUser() {
        self.observer?.dispose()
        self.observer = nil
        self.hasLoadedUser = false
        self.authUser = User(uid: "unauthenticated", provider: "none")
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
