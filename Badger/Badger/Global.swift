struct Global {
    static let FirebaseUrl = "https://fiery-inferno-4698.firebaseio.com"
    static let FirebaseUsersUrl = Global.FirebaseUrl + "/users"
    static let FirebaseMessagesUrl = Global.FirebaseUrl + "/messages"
    static let FirebaseNewMessagesUrl = Global.FirebaseUrl + "/new_messages"
    static let GoogleClientId = "23462386449-gplp919jh4jhu9tj6185mg7koc2eej7n.apps.googleusercontent.com"
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

    class func colorize (hex: Int, alpha: Float = 1.0) -> UIColor {
        let red = Float((hex & 0xFF0000) >> 16) / 255.0
        let green = Float((hex & 0xFF00) >> 8) / 255.0
        let blue = Float((hex & 0xFF)) / 255.0
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha:CGFloat(alpha))
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

    class func interpolateColors(start: UIColor, end: UIColor, progress: CGFloat) -> UIColor {
        let startComp = CGColorGetComponents(start.CGColor)
        let endComp = CGColorGetComponents(end.CGColor)

        // Calculate the colors.
        let red = (1.0 - progress) * startComp[0] + progress * endComp[0]
        let green = (1.0 - progress) * startComp[1] + progress * endComp[1]
        let blue = (1.0 - progress) * startComp[2] + progress * endComp[2]

        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}