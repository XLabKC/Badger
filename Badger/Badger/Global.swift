struct Global {
    static let FirebaseUrl = "https://fiery-inferno-4698.firebaseio.com"
    static let FirebaseUsersUrl = "\(Global.FirebaseUrl)/users"
    static let FirebaseTasksUrl = "\(Global.FirebaseUrl)/tasks"
    static let FirebaseTeamsUrl = "\(Global.FirebaseUrl)/teams"
    static let FirebasePushNewTaskUrl = "\(Global.FirebaseUrl)/push_new_task"
    static let FirebasePushCompletedTaskUrl = "\(Global.FirebaseUrl)/push_completed_task"
    static let FirebasePushStatusUpdatedUrl = "\(Global.FirebaseUrl)/push_status_updated"
    static let FirebaseActiveTasksUrl = "\(Global.FirebaseUrl)/active_tasks"
    static let FirebaseCompletedTasksUrl = "\(Global.FirebaseUrl)/completed_tasks"

    static let DefaultUserProfileUrl = "DefaultUserProfile"
    static let DefaultTeamLogoUrl = "DefaultTeamLogo"
    static let DefaultBackgroundUrl = "DefaultBackground"
}

struct Colors {
    static let UnavailableStatus = Color.colorize(0xFF5C78, alpha: 1)
    static let UnknownStatus = Color.colorize(0x8A9693, alpha: 1)
    static let FreeStatus = Color.colorize(0x50E3C2, alpha: 1)
    static let OccupiedStatus = Color.colorize(0xFFDB7B, alpha: 1)
    static let HighlightPurple = Color.colorize(0x8E7EFF, alpha: 1)
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

    class func createTitleLabel(title: String) -> UILabel {
        let label = UILabel(frame: CGRectMake(0, 0, 100, 30))
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont(name: "OpenSans", size: 17.0)
        label.textAlignment = .Center
        label.textColor = Colors.HighlightPurple
        label.text = title
        return label
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

    class func calculateTextViewHeight(textView: UITextView, minVerticalPadding: CGFloat, minTextHeight: CGFloat) -> CGFloat {
        var frame = textView.bounds

        // Take account of the padding added around the text.
        var textContainerInsets = textView.textContainerInset
        var contentInsets = textView.contentInset

        var leftRightPadding = textContainerInsets.left + textContainerInsets.right + textView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right

        var topBottomPadding = CGFloat(textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom) + textView.superview!.frame.height - frame.height

        frame.size.width -= leftRightPadding;

        var textToMeasure = textView.text as NSString
        if textToMeasure.hasSuffix("\n") {
            textToMeasure = "\(textToMeasure)-" as NSString
        }

        // NSString class method: boundingRectWithSize:options:attributes:context is
        // available only on ios7.0 sdk.
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping

        var attributes = [
            NSFontAttributeName: textView.font,
            NSParagraphStyleAttributeName: paragraphStyle
        ]

        var size = textToMeasure.boundingRectWithSize(CGSizeMake(frame.width, CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
        size.size.height = size.height < minTextHeight ? minTextHeight : size.height
        topBottomPadding = topBottomPadding < minVerticalPadding ? minVerticalPadding : topBottomPadding
        
        return ceil(size.height + topBottomPadding)
    }
}
