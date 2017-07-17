//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation

extension NSString {
    func hl_height(withAttributes attributes: [AnyHashable: Any], width: CGFloat, maxHeight: CGFloat) -> CGFloat {
        let rect: CGRect = boundingRect(withSize: CGSize(width: width, height: maxHeight), options: ([.usesLineFragmentOrigin, .usesFontLeading]), attributes: attributes, context: nil)
        return ceil(rect.size.height)
    }

    func hl_height(withAttributes attributes: [AnyHashable: Any], width: CGFloat) -> CGFloat {
        return hl_height(withAttributes: attributes, width: width, maxHeight: CGFLOAT_MAX)
    }

    func hl_width(withAttributes attributes: [AnyHashable: Any], height: CGFloat) -> CGFloat {
        let rect: CGRect = boundingRect(withSize: CGSize(width: CGFLOAT_MAX, height: height), options: ([.usesLineFragmentOrigin, .usesFontLeading]), attributes: attributes, context: nil)
        return ceil(rect.size.width)
    }
}

extension NSAttributedString {
    func hl_height(withWidth width: CGFloat, maxHeight: CGFloat) -> CGFloat {
        let rect: CGRect = boundingRect(withSize: CGSize(width: width, height: maxHeight), options: ([.usesLineFragmentOrigin, .usesFontLeading]), context: nil)
        return ceil(rect.size.height)
    }

    func hl_width(withHeight height: CGFloat) -> CGFloat {
        let rect: CGRect = boundingRect(withSize: CGSize(width: CGFLOAT_MAX, height: height), options: ([.usesLineFragmentOrigin, .usesFontLeading]), context: nil)
        return ceil(rect.size.width)
    }

    func hl_height(withWidth width: CGFloat) -> CGFloat {
        return hl_height(withWidth: width, maxHeight: CGFLOAT_MAX)
    }
}