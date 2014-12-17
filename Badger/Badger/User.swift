@objc class User: DataEntity {
    let uid: String
    let provider: String
    let createdAt: NSDate
    var firstName = ""
    var lastName = ""
    var profileImages: [UserStatus: String] = [:]
    var headerImage = "DefaultUserBackground"
    var email = ""
    var status: UserStatus
    var followerIds: [String: Bool] = [:]
    var followingIds: [String: Bool] = [:]
    var teamIds: [String: Bool] = [:]
    var activeTaskCount = 0
    var completedTaskCount = 0

    var fullName: String {
        return "\(firstName) \(lastName)"
    }

    var ref: Firebase {
        return User.createRef(self.uid)
    }

    init(uid: String, provider: String) {
        self.uid = uid
        self.provider = provider
        self.createdAt = NSDate()
        self.firstName = ""
        self.lastName = ""
        self.email = ""
        self.status = .Free
        self.profileImages = [
            .Free: "DefaultUserProfile",
            .Unavailable: "DefaultUserProfile",
            .Occupied: "DefaultUserProfile",
            .Unknown: "DefaultUserProfile"
        ]
    }

    init(uid: String, json: Dictionary<String, AnyObject>) {
        self.uid = uid
        self.provider = json["provider"] as String
        self.createdAt = NSDate(fromJavascriptTimestamp: json["created_at"] as NSNumber)
        self.firstName = json["first_name"] as String
        self.lastName = json["last_name"] as String
        self.email = json["email"] as String
        self.activeTaskCount = json["active_task_count"] as Int
        self.completedTaskCount = json["completed_task_count"] as Int
        var status = UserStatus(rawValue: json["status"] as String)
        if status == nil {
            status = .Unknown
        }
        self.status = status!
        self.profileImages[.Free] = json["free_profile_image"] as? String
        self.profileImages[.Unavailable] = json["unavailable_profile_image"] as? String
        self.profileImages[.Occupied] = json["occupied_profile_image"] as? String
        self.headerImage = json["header_image"] as String

        if let teams = json["teams"] as? Dictionary<String, Bool> {
            self.teamIds = teams
        }
        if let followers = json["followers"] as? Dictionary<String, Bool> {
            self.followerIds = followers
        }
        if let following = json["following"] as? Dictionary<String, Bool> {
            self.followingIds = following
        }
    }

    func toJson() -> Dictionary<String, AnyObject> {
        return [
            "provider": self.provider,
            "created_at": NSDate.javascriptTimestampFromDate(self.createdAt) as NSNumber,
            "first_name": self.firstName,
            "last_name": self.lastName,
            "email": self.email,
            "status": self.status.rawValue,
            "free_profile_image": self.profileImages[.Free]!,
            "unavailable_profile_image": self.profileImages[.Unavailable]!,
            "occupied_profile_image": self.profileImages[.Occupied]!,
            "header_image": self.headerImage,
            "active_task_count": self.activeTaskCount,
            "completed_task_count": self.completedTaskCount,
            "following": self.followingIds,
            "followers": self.followerIds,
            "teams": self.teamIds
        ]
    }

    func getKey() -> String {
        return self.uid
    }

    class func createFromSnapshot(snapshot: FDataSnapshot) -> DataEntity {
        let uid = snapshot.key
        return User(uid: uid, json: snapshot.value as Dictionary<String, AnyObject>)
    }

    class func createRef(uid: String) -> Firebase {
        return Firebase(url: Global.FirebaseUsersUrl).childByAppendingPath(uid)
    }
}