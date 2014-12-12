protocol AuthUserListener: class {
    func authUserUpdated(user: AuthUser)
}


class AuthUser: User {
    private var userHandle: UInt = 0
    private var teamHandlesById = [String: UInt]()
    private var listeners = [WeakListener]()

    var teamsById = [String: Team]()

    class func createFromUser(user: User) -> AuthUser {
        return AuthUser(uid: user.uid, firstName: user.firstName, lastName: user.lastName, email: user.email, status: user.status, profileImages: user.profileImages, headerImage: user.headerImage, followerIds: user.followerIds, followingIds: user.followingIds, teamIds: user.teamIds, activeTasks: user.activeTasks, ref: user.ref)
    }

    override init(uid: String, firstName: String, lastName: String, email: String, status: UserStatus, profileImages: [UserStatus : String], headerImage: String, followerIds: [String], followingIds: [String], teamIds: [String], activeTasks: Int, ref: Firebase?) {
        super.init(uid: uid, firstName: firstName, lastName: lastName, email: email, status: status, profileImages: profileImages, headerImage: headerImage, followerIds: followerIds, followingIds: followingIds, teamIds: teamIds, activeTasks: activeTasks, ref: ref)

        if self.ref == nil {
            self.ref = Firebase(url: Global.FirebaseUsersUrl).childByAppendingPath(uid)
        }

        self.fetchTeams()

        // Listen for updates.
        var initialCall = true
        self.userHandle = self.ref!.observeEventType(.Value, withBlock: { (snapshot) in
            if initialCall {
                initialCall = false
                return
            }
            let updatedUser = User.createFromSnapshot(snapshot) as User
            self.updateFields(updatedUser)
            self.fetchTeams()
            self.notifyListeners()
        })
    }

    deinit {
        if let ref = self.ref {
            ref.removeObserverWithHandle(self.userHandle)
        }
    }

    func addListener(listener: AuthUserListener) {
        self.listeners.append(WeakListener(listener: listener))
    }

    func removeListener(listener: AuthUserListener) {
        for (index, weakListener) in enumerate(self.listeners) {
            if weakListener.listener === listener {
                self.listeners.removeAtIndex(index)
                break
            }
        }
    }

    private func updateFields(user: User) {
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.email = user.email
        self.status = user.status
        self.profileImages = user.profileImages
        self.headerImage = user.headerImage
        self.followerIds = user.followerIds
        self.followingIds = user.followingIds
        self.teamIds = user.teamIds
    }

    private func fetchTeams() {
        var validHandles = [String: UInt]()

        // Stop listening to teams that this user is no longer a member.
        for (id, handle) in self.teamHandlesById {
            var found = false
            for teamId in self.teamIds {
                if teamId == id {
                    found = true
                    break
                }
            }
            if found {
                validHandles[id] = handle
            } else {
                self.ref!.removeObserverWithHandle(handle)
                self.teamsById[id] = nil
            }
        }

        let ref = Firebase(url: Global.FirebaseTeamsUrl)
        for teamId in self.teamIds {
            // Check if the team isn't already cached.
            if self.teamsById[teamId] == nil {
                validHandles[teamId] = ref.childByAppendingPath(teamId).observeEventType(.Value, withBlock: self.teamUpdated)
            }
        }
        self.teamHandlesById = validHandles
    }

    private func teamUpdated(snapshot: FDataSnapshot!) {
        let team = Team.createFromSnapshot(snapshot) as Team
        for id in self.teamIds {
            if id == team.id {
                // Team is still valid!
                self.teamsById[team.id] = team
                self.notifyListeners()
            }
        }
    }

    private func notifyListeners() {
        var valid = [WeakListener]()
        for weakListener in self.listeners {
            if let listener = weakListener.listener? {
                listener.authUserUpdated(self)
            }
            valid.append(weakListener)
        }
        self.listeners = valid
    }
}


private class WeakListener {
    weak var listener: AuthUserListener?
    init(listener: AuthUserListener) {
        self.listener = listener
    }
}