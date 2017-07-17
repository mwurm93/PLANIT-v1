//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation

extension NSMutableArray<ObjectType> {
    func addIfNotNil(_ object: ObjectType) {
    }
}

extension NSMutableArray {
    func addIfNotNil(_ object: Any) {
        if object != nil {
            append(object)
        }
    }
}