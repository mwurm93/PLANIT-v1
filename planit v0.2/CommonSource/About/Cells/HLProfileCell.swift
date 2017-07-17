//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import UIKit

class HLProfileCell: UITableViewCell, HLProfileCellProtocol {
    var item: HLProfileTableItem?

    @IBOutlet weak var titleLabel: UILabel!

    func setup(with item: HLProfileTableItem) {
        self.item = item
        titleLabel.text = item.title
        accessibilityIdentifier = item.accessibilityIdentifier
    }
}