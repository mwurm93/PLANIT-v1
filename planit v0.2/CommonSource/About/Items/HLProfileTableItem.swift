//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation

typealias ProfileItemAction = () -> Void
typealias ProfileItemActivateBlock = () -> Bool

class HLProfileTableItem: NSObject {
    var title: String = ""
    var cellIdentifier: String = ""
    var accessibilityIdentifier: String?
    var action: ProfileItemAction?
    var isActive: Bool = false
    var height: CGFloat = 0.0

    init(title: String, action: ProfileItemAction, active: Bool) {
        super.init()

        self.title = title
        self.action = action
        isActive = active
        height = 44.0
    
    }
}