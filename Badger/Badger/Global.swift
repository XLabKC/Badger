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

}

class Color {
    class func getHSB(color: UIColor) -> (h: CGFloat, s: CGFloat, b: CGFloat, alpha: CGFloat) {
        var h: CGFloat = 0.0
        var s: CGFloat = 0.0
        var b: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &alpha)
        return (h, s, b, alpha)
    }

    class func getRGB(color: UIColor) -> (r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        color.getRed(&r, green: &g, blue: &b, alpha: &alpha)
        return (r, g, b, alpha)
    }

    class func interpolateRGBBetween(start: UIColor, end: UIColor, progress: CGFloat) -> UIColor {
        let startRGB = Color.getRGB(start)
        let endRGB = Color.getRGB(end)

        // Calculate the colors.
        let red = (1.0 - progress) * startRGB.r + progress * endRGB.r
        let green = (1.0 - progress) * startRGB.g + progress * endRGB.g
        let blue = (1.0 - progress) * startRGB.b + progress * endRGB.b
        let alpha = (1.0 - progress) * startRGB.alpha + progress * endRGB.alpha

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    class func interpolateHSBBetween(start: UIColor, end: UIColor, progress: CGFloat) -> UIColor {
        var startHSB = Color.getHSB(start)
        var endHSB = Color.getHSB(end)

        // Check if we need to wrap around the hue.
        let diff = startHSB.h - endHSB.h
        if (diff < -0.5) {
            // Going over the seam counter-clockwise.
            startHSB.h += 1.0
        } else if (diff > 0.5) {
            // Going over the seam clockwise.
            endHSB.h += 1.0
        }

        // Calculate the colors.
        let h = (1.0 - progress) * startHSB.h + progress * endHSB.h
        let s = (1.0 - progress) * startHSB.s + progress * endHSB.s
        let b = (1.0 - progress) * startHSB.b + progress * endHSB.b
        let a = (1.0 - progress) * startHSB.alpha + progress * endHSB.alpha

        return UIColor(hue: h % 1, saturation: s, brightness: b, alpha: a)
    }
}