struct Global {
    static let FirebaseUrl = "https://fiery-inferno-4698.firebaseio.com"
    static let FirebaseUsersUrl = Global.FirebaseUrl + "/users"
    static let FirebaseTasksUrl = Global.FirebaseUrl + "/tasks"
    static let FirebaseTeamsUrl = Global.FirebaseUrl + "/teams"
    static let FirebaseNewTasksUrl = Global.FirebaseUrl + "/new_tasks"
}

struct Colors {
    static let UnavailableStatus = Color.colorize(0xFF5C78, alpha: 1)
    static let UnknownStatus = Color.colorize(0x8A9693, alpha: 1)
    static let FreeStatus = Color.colorize(0x50E3C2, alpha: 1)
    static let OccupiedStatus = Color.colorize(0xFFDB7B, alpha: 1)
    static let NavHeaderTitle = Color.colorize(0x1B3DA3, alpha: 1)
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

    class func statusToText(user: User?, status: UserStatus) -> String {
        switch status {
        case .Unavailable:
            return "Unavailable"
        case .Free:
            return "Free"
        case .Occupied:
            return "Occupied"
        default:
            return "Unknown"
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

    class func getInt(root: AnyObject, key: String, backup: Int) -> Int {
        if let dictionary = root as? NSDictionary {
            if let value = dictionary.objectForKey(key) as? Int {
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

    class func getDate(root: AnyObject, key: String) -> NSDate {
        if let dictionary = root as? NSDictionary {
            if let value = dictionary.objectForKey(key) as? NSNumber {
                return NSDate(fromJavascriptTimestamp: value)
            }
        }
        return NSDate()
    }

    class func createRevealViewController(uid: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuVC = storyboard.instantiateViewControllerWithIdentifier("MenuViewController") as UITableViewController
        let frontVC = storyboard.instantiateViewControllerWithIdentifier("ProfileNavigationViewController") as UINavigationController
        let revealVC = SWRevealViewController(rearViewController: menuVC, frontViewController: frontVC)
        revealVC.draggableBorderWidth = 20
        revealVC.rearViewRevealWidth = -54

        // Set uid for profile.
        if let profileVC = frontVC.topViewController as? ProfileViewController {
            profileVC.setUid(uid)
        }
        return revealVC
    }

    class func createTitleLabel(title: String) -> UILabel {
        let label = UILabel(frame: CGRectMake(0, 0, 100, 30))
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont(name: "OpenSans", size: 17.0)
        label.textAlignment = .Center
        label.textColor = Colors.NavHeaderTitle
        label.text = title
        return label
    }

    class func saveAccessToken(auth: GTMOAuth2Authentication) {
        NSUserDefaults.standardUserDefaults().setObject(auth.accessToken, forKey: "access_token")
        NSUserDefaults.standardUserDefaults().setObject(auth.expirationDate, forKey: "access_token_expiration")
    }

    class func diffArrays<T>(start: [T], end: [T], section: Int, compare: (T, T) -> Bool) -> (inserts: [NSIndexPath], deletes: [NSIndexPath]) {
        var inserts = [NSIndexPath]()
        var deletes = [NSIndexPath]()
        var startIndex = 0
        var withDeletes = [T]()

        for (i, a) in enumerate(start) {
            var found = false
            for var j = startIndex; j < end.count; j++ {
                if compare(a, end[j]) {
                    startIndex = j
                    withDeletes.append(a)
                    found = true
                    break
                }
            }
            if !found {
                deletes.append(NSIndexPath(forRow: i, inSection: section))
            }
        }

        var cur = 0
        for (i, b) in enumerate(end) {
            if cur < withDeletes.count && compare(b, withDeletes[cur]) {
                cur++
            } else {
                inserts.append(NSIndexPath(forRow: i, inSection: section))
            }
        }
        return (inserts: inserts, deletes: deletes)
    }

//    class func diffArrays<T>(start: [T], end: [T], section: Int, compare: (T, T) -> Bool) -> (inserts: [NSIndexPath], deletes: [NSIndexPath], movesFrom: [NSIndexPath], movesTo: [NSIndexPath]) {
//        var accounted = [Bool](count: end.count, repeatedValue: false)
//        var inserts = [NSIndexPath]()
//        var deletes = [NSIndexPath]()
//        var movesFrom = [NSIndexPath]()
//        var movesTo = [NSIndexPath]()
//
//        for (i, a) in enumerate(start) {
//            if compare(a, end[i]) {
//                accounted[i] = true
//            } else {
//                // Item has moved or does not exist.
//                for (j, b) in enumerate(end) {
//                    // Item has moved.
//                    if compare(a, b) {
//                        movesFrom.append(NSIndexPath(forRow: i, inSection: section))
//                        movesTo.append(NSIndexPath(forRow: j, inSection: section))
//                        accounted[j] = true
//                        continue
//                    }
//                }
//                // Item has been deleted.
//                deletes.append(NSIndexPath(forRow: i, inSection: section))
//            }
//        }
//        for (i, val) in enumerate(accounted) {
//            if !accounted[i] {
//                inserts.append(NSIndexPath(forRow: i, inSection: section))
//            }
//        }
//
//        return (inserts: inserts, deletes: deletes, movesFrom: movesFrom, movesTo: movesTo)
//    }
}
