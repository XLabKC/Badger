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

public enum TaskPriority: String {
    case High = "high"
    case Medium = "medium"
    case Low = "low"
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



    class func getString(root: AnyObject, key: String, backup: String) -> String {
        if let dictionary = root as? NSDictionary {
            if let value = dictionary.objectForKey(key) as? String {
                return value
            }
        }
        return backup
    }

    class func getBool(root: AnyObject, key: String, backup: Bool) -> Bool {
        if let dictionary = root as? NSDictionary {
            if let value = dictionary.objectForKey(key) as? Bool {
                return value
            }
        }
        return backup
    }

    class func getDictionary(root: AnyObject, key: String) -> NSDictionary? {
        if let dictionary = root as? NSDictionary {
            if let value = dictionary.objectForKey(key) as? NSDictionary {
                return value
            }
        }
        return nil
    }

    class func saveAccessToken(auth: GTMOAuth2Authentication) {
        NSUserDefaults.standardUserDefaults().setObject(auth.accessToken, forKey: "access_token")
        NSUserDefaults.standardUserDefaults().setObject(auth.expirationDate, forKey: "access_token_expiration")
    }
}
