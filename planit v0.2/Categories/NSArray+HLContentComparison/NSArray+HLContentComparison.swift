//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation

extension NSArray {
    func hl_isContentEqual(toArray array: [Any]) -> Bool {
        let selfSet = NSCountedSet(array: self)
        let otherSet = NSCountedSet(array: array)
        return selfSet.isEqual(otherSet)
    }
}