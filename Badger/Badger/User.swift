@objc class User: DataEntity {
    let uid: String
    var firstName: String
    var lastName: String
    var profileImages: [UserStatus: String] = [:]
    var headerImage: String
    var email: String
    var status: UserStatus
    var followerIds: [String] = []
    var followingIds: [String] = []
    var teamIds: [String] = []
    var timestamp: NSDate
    var activeTaskCount: Int
    var completedTaskCount: Int

    var fullName: String {
        return "\(firstName) \(lastName)"
    }

    var ref: Firebase {
        return User.createRef(self.uid)
    }

    init(uid: String, firstName: String, lastName: String, email: String, status: UserStatus, profileImages: [UserStatus: String], headerImage: String, followerIds: [String], followingIds: [String], teamIds: [String], activeTaskCount: Int, completedTaskCount: Int)
    {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.status = status
        self.timestamp = NSDate()
        self.profileImages = profileImages
        self.headerImage = headerImage
        self.followerIds = followerIds
        self.followingIds = followingIds
        self.teamIds = teamIds
        self.activeTaskCount = activeTaskCount
        self.completedTaskCount = completedTaskCount
    }

    class func createFromSnapshot(userSnapshot: FDataSnapshot) -> DataEntity {
        let uid = userSnapshot.key
        let first = Helpers.getString(userSnapshot.value, key: "first_name", backup: "John")
        var last = Helpers.getString(userSnapshot.value, key: "last_name", backup: "Doe")
        let status = Helpers.getString(userSnapshot.value, key: "status", backup: "unknown")
        let email = Helpers.getString(userSnapshot.value, key: "email", backup: "Unknown")
        let activeTasks = Helpers.getInt(userSnapshot.value, key: "active_task_count", backup: 0)
        let completedTasks = Helpers.getInt(userSnapshot.value, key: "completed_task_count", backup: 0)
        var userStatus = UserStatus(rawValue: status)
        if userStatus == nil {
            userStatus = .Unknown
        }
        let profileImages: [UserStatus: String] = [
            .Unavailable: Helpers.getString(userSnapshot.value, key: "unavailable_profile_image", backup: "Unknown"),
            .Free: Helpers.getString(userSnapshot.value, key: "free_profile_image", backup: "Unknown"),
            .Occupied: Helpers.getString(userSnapshot.value, key: "occupied_profile_image", backup: "Unknown"),
            .Unknown: "Unknown"
        ]
        let headerImage = Helpers.getString(userSnapshot.value, key: "headerImage", backup: "DefaultBackground")
        var followerIds = [String]()
        if let followerData = Helpers.getDictionary(userSnapshot.value, key: "followers")? {
            for (uid, value) in followerData {
                if let uidString = uid as? String {
                    followerIds.append(uidString)
                }
            }
        }
        var followingIds = [String]()
        if let followingData = Helpers.getDictionary(userSnapshot.value, key: "following")? {
            for (uid, value) in followingData {
                if let uidString = uid as? String {
                    followingIds.append(uidString)
                }
            }
        }
        var teamIds = [String]()
        if let teamData = Helpers.getDictionary(userSnapshot.value, key: "teams")? {
            for (id, value) in teamData {
                if let idString = id as? String {
                    teamIds.append(idString)
                }
            }
        }
        let user = User(uid: uid, firstName: first, lastName: last, email: email, status: userStatus!, profileImages: profileImages, headerImage: headerImage, followerIds: followerIds, followingIds: followingIds, teamIds: teamIds, activeTaskCount: activeTasks, completedTaskCount: completedTasks)
        return user
    }

    class func createRef(uid: String) -> Firebase {
        return Firebase(url: Global.FirebaseUsersUrl).childByAppendingPath(uid)
    }
}