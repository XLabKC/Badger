class User {
    let uid: String
    var first_name: String
    var last_name: String
    var full_name: String {
        return "\(first_name) \(last_name)"
    }
    var profile_images: [String]
    var email: String
    var status: String
    var followers: [String]
    var following: [String]
    var messages: [String]
    var uidRef: Firebase?
    var timestamp: NSDate

    init(uid: String, first_name: String, last_name: String, email: String, status: String)
    {
        self.uid = uid
        self.first_name = first_name
        self.last_name = last_name
        self.email = email
        self.status = status
        self.profile_images = []
        self.followers  = []
        self.following = []
        self.messages = []
        self.timestamp = NSDate()
    }

    class func createUserFromSnapshot(userSnapshot: FDataSnapshot) -> User {
        let uid = userSnapshot.name
        let first = userSnapshot.value.objectForKey("first_name") as String!
        let last = userSnapshot.value.objectForKey("last_name") as String!
        let status = userSnapshot.value.objectForKey("status") as String!
        let email = userSnapshot.value.objectForKey("email") as String!
        let user = User(uid: uid, first_name: first, last_name: last, email: email, status: status)

        user.profile_images = [
            userSnapshot.value.objectForKey("red_profile_image") as String!,
            userSnapshot.value.objectForKey("yellow_profile_image") as String!,
            userSnapshot.value.objectForKey("green_profile_image") as String!
        ]

        if let followerData = userSnapshot.value.objectForKey("followers") as? NSDictionary {
            for (uid, value) in followerData {
                if let uidString = uid as? String {
                    user.followers.append(uidString)
                }
            }
        }

        if let followingData = userSnapshot.value.objectForKey("following") as? NSDictionary {
            for (uid, value) in followingData {
                if let uidString = uid as? String {
                    user.following.append(uidString)
                }
            }
        }

        if let messageData = userSnapshot.value.objectForKey("messages") as? NSDictionary {
            for (id, value) in messageData {
                if let idString = id as? String {
                    user.messages.append(idString)
                }
            }
        }

        user.uidRef = userSnapshot.ref
        return user
    }
}