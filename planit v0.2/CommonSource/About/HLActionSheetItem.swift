//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation

class HLActionSheetItem: NSObject {
    var title: String = ""
    var selectionBlock: ((_: Void) -> Void)? = nil

    init(title: String, selectionBlock: @escaping (_: Void) -> Void) {
        super.init()
        
        self.title = title
        self.selectionBlock = selectionBlock
    
    }
}