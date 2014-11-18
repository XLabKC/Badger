struct Global {
    static let FirebaseUrl = "https://fiery-inferno-4698.firebaseio.com"
    static let FirebaseUsersUrl = Global.FirebaseUrl + "/users"
    static let FirebaseMessagesUrl = Global.FirebaseUrl + "/messages"
    static let FirebaseNewMessagesUrl = Global.FirebaseUrl + "/new_messages"
    static let GoogleClientId = "23462386449-gplp919jh4jhu9tj6185mg7koc2eej7n.apps.googleusercontent.com"
}

struct Colors {
    static let UnavailableStatus = Color.colorize(0xFF5C78, alpha: 1)
    static let UnknownStatus = Color.colorize(0x8A9693, alpha: 1)
    static let FreeStatus = Color.colorize(0x50E3C2, alpha: 1)
    static let OccupiedStatus = Color.colorize(0xFFDB7B, alpha: 1)
}


public enum UserStatus: String {
    case Unavailable = "unavailable"
    case Free = "free"
    case Occupied = "occupied"
    case Unknown = "unknown"
}


class Helpers {
    class func statusToColor(status: UserStatus) -> UIColor {
        switch status {
        case .Unknown:
            return Colors.UnknownStatus
        case .Unavailable:
            return Colors.UnavailableStatus
        case .Free:
            return Colors.FreeStatus
        case .Occupied:
            return Colors.OccupiedStatus
        }
    }

    class func imageWithColor(image: UIImage, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale);
        var context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, image.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        var rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        CGContextClipToMask(context, rect, image.CGImage);
        color.setFill();
        CGContextFillRect(context, rect);
        var newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }

}
