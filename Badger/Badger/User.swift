class User {
    let uid: String
    var firstName: String
    var lastName: String
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    var profileImages: [UserStatus: String] = [:]
    var headerImage: String
    var email: String
    var status: UserStatus
    var followerIds: [String] = []
    var followingIds: [String] = []
    var teamIds: [String] = []
    var ref: Firebase?
    var timestamp: NSDate
    var activeTasks: Int

    init(uid: String, firstName: String, lastName: String, email: String, status: UserStatus, profileImages: [UserStatus: String], headerImage: String, followerIds: [String], followingIds: [String], teamIds: [String], activeTasks: Int, ref: Firebase?)
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
        self.ref = ref
        self.activeTasks = activeTasks
    }

    class func createUserFromSnapshot(userSnapshot: FDataSnapshot) -> User {
        let uid = userSnapshot.key
        let first = Helpers.getString(userSnapshot.value, key: "first_name", backup: "John")
        var last = Helpers.getString(userSnapshot.value, key: "last_name", backup: "Doe")
        let status = Helpers.getString(userSnapshot.value, key: "status", backup: "unknown")
        let email = Helpers.getString(userSnapshot.value, key: "email", backup: "Unknown")
        let activeTasks = Helpers.getInt(userSnapshot.value, key: "active_tasks", backup: 0)
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
        let user = User(uid: uid, firstName: first, lastName: last, email: email, status: userStatus!, profileImages: profileImages, headerImage: headerImage, followerIds: followerIds, followingIds: followingIds, teamIds: teamIds, activeTasks: activeTasks, ref: userSnapshot.ref)
        return user
    }
}