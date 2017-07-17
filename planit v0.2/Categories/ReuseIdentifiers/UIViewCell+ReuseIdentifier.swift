//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import UIKit

extension UITableViewCell {
    class func hl_reuseIdentifier() -> String {
        return NSStringFromClass(UITableViewCell).components(separatedBy: ".").last!
    }
}

extension UICollectionViewCell {
    class func hl_reuseIdentifier() -> String {
        return NSStringFromClass(UICollectionViewCell).components(separatedBy: ".").last!
    }
}

extension UICollectionReusableView {
    class func hl_reuseIdentifier() -> String {
        return NSStringFromClass(UICollectionReusableView).components(separatedBy: ".").last!
    }
}