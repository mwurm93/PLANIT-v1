//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation

extension NSString {
    func hl_firstLetterCapitalizedString() -> String {
        return (self.characters.count ?? 0) > 0 ? (self as? NSString)?.substring(to: 1)?.uppercased()? + ((self as? NSString)?.substring(from: 1)) : self
    }
}