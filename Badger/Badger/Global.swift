struct Global {
    static let FirebaseUrl = "https://fiery-inferno-4698.firebaseio.com"
    static let FirebaseUsersUrl = Global.FirebaseUrl + "/users"
    static let FirebaseMessagesUrl = Global.FirebaseUrl + "/messages"
    static let FirebaseNewMessagesUrl = Global.FirebaseUrl + "/new_messages"
    static let GoogleClientId = "23462386449-gplp919jh4jhu9tj6185mg7koc2eej7n.apps.googleusercontent.com"
    static var AuthData: FAuthData?
}

class Helpers {
    class func statusToColor(status:String) -> UIColor {
        switch status {
        case "red":
            return UIColor.redColor()
        case "yellow":
            return UIColor.yellowColor()
        default:
            return UIColor.greenColor()
        }
    }
}