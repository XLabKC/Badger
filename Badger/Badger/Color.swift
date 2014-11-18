
class Color {

    class func colorize (hex: Int, alpha: Float = 1.0) -> UIColor {
        let red = Float((hex & 0xFF0000) >> 16) / 255.0
        let green = Float((hex & 0xFF00) >> 8) / 255.0
        let blue = Float((hex & 0xFF)) / 255.0
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha:CGFloat(alpha))
    }

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