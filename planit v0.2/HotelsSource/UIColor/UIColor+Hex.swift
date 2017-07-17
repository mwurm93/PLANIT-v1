//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  UIColor+Hex.swift
//
//
//  UIColor+Hex
//

extension UIColor {
    convenience init(css: String) {
        if (css.characters.count ?? 0) == 0 {
            return UIColor.black
        }
        if css[0] == "#" {
            css = (css as? NSString)?.substring(from: 1)
        }
        var a: String
        var r: String
        var g: String
        var b: String
        let len: Int = (css.characters.count ?? 0)
        if len == 6 {
            r = (css as NSString).substring(with: NSRange(location: 0, length: 2))
            g = (css as NSString).substring(with: NSRange(location: 2, length: 2))
            b = (css as NSString).substring(with: NSRange(location: 4, length: 2))
        }
        else if len == 8 {
            r = (css as NSString).substring(with: NSRange(location: 2, length: 2))
            g = (css as NSString).substring(with: NSRange(location: 4, length: 2))
            b = (css as NSString).substring(with: NSRange(location: 6, length: 2))
        }
        else if len == 3 {
            r = (css as NSString).substring(with: NSRange(location: 0, length: 1))
            r = r + (a)
            g = (css as NSString).substring(with: NSRange(location: 1, length: 1))
            g = g + (a)
            b = (css as NSString).substring(with: NSRange(location: 2, length: 1))
            b = b + (a)
        }
        else if len == 4 {
            a = (css as NSString).substring(with: NSRange(location: 0, length: 1))
            a = a + (a)
            r = (css as NSString).substring(with: NSRange(location: 1, length: 1))
            r = r + (a)
            g = (css as NSString).substring(with: NSRange(location: 2, length: 1))
            g = g + (a)
            b = (css as NSString).substring(with: NSRange(location: 3, length: 1))
            b = b + (a)
        }
        else if len == 5 || len == 7 {
            css = "0" + (css)
            if len == 5 {

            }
        }
        else if len < 3 {
            css = css.paddingTheLeft(toLength: 3, withString: "0", startingAtIndex: 0)
        }
        else if len > 8 {
            css = (css as? NSString)?.substring(from: len - 8)
        }
        else {
            a = "FF"
            r = "00"
            g = "00"
            b = "00"
        }

        // parse each component separately. This gives more accurate results than
        // throwing it all together in one string and use scanf on the global string.
        a = "0x" + (a)
        r = "0x" + (r)
        g = "0x" + (g)
        b = "0x" + (b)
        var av: uint
        var rv: uint
        var gv: uint
        var bv: uint
        sscanf(a.cString(using: String.Encoding.ascii), "%x", av)
        sscanf(r.cString(using: String.Encoding.ascii), "%x", rv)
        sscanf(g.cString(using: String.Encoding.ascii), "%x", gv)
        sscanf(b.cString(using: String.Encoding.ascii), "%x", bv)
        return UIColor(red: rv / 255.0, green: gv / 255.0, blue: bv / 255.0, alpha: av / 255.0)
    }

    convenience init(hex: Int) {
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat
        var alpha: CGFloat
        red = (CGFloat)((hex >> 16) & 0xff) / (CGFloat(0xff))
        green = (CGFloat)((hex >> 8) & 0xff) / (CGFloat(0xff))
        blue = (CGFloat)((hex >> 0) & 0xff) / (CGFloat(0xff))
        alpha = hex > 0xffffff ? (CGFloat)((hex >> 24) & 0xff) / (CGFloat(0xff)) : 1
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    func hex() -> uint {
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat
        var alpha: CGFloat
        if !getRed((red as? UnsafeMutablePointer<CGFloat> ?? UnsafeMutablePointer<CGFloat>()), green: (green as? UnsafeMutablePointer<CGFloat> ?? UnsafeMutablePointer<CGFloat>()), blue: (blue as? UnsafeMutablePointer<CGFloat> ?? UnsafeMutablePointer<CGFloat>()), alpha: (alpha as? UnsafeMutablePointer<CGFloat> ?? UnsafeMutablePointer<CGFloat>())) {
            getWhite(red as? UnsafeMutablePointer<CGFloat> ?? UnsafeMutablePointer<CGFloat>(), alpha: alpha as? UnsafeMutablePointer<CGFloat> ?? UnsafeMutablePointer<CGFloat>())
            green = red
            blue = red
        }
        red = roundf(red * 255.0)
        green = roundf(green * 255.0)
        blue = roundf(blue * 255.0)
        alpha = roundf(alpha * 255.0)
        return ((alpha as? uint) << 24) | ((red as? uint) << 16) | ((green as? uint) << 8) | (blue as? uint)!
    }

    func hexString() -> String {
        return String(format: "0x%08x", hex())
    }

    func cssString() -> String {
        let hex: uint = self.hex()
        if (hex & 0xff000000) == 0xff000000 {
            return String(format: "#%06x", hex & 0xffffff)
        }
        return String(format: "#%08x", hex)
    }
}

extension NSString {
    // taken from http://stackoverflow.com/questions/964322/padding-string-to-left-with-objective-c

    func stringByPaddingTheLeft(toLength newLength: Int, with padString: String, startingAt padIndex: Int) -> String {
        if (self.characters.count ?? 0) <= newLength {
            return "".padding(toLength: newLength - (self.characters.count ?? 0), withPad: padString, startingAt: padIndex) + (self)
        }
        else {

        }
    }
}