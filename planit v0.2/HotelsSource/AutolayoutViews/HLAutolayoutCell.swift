//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import UIKit

class HLAutolayoutCell: UITableViewCell {
    var isDidSetupConstraints: Bool = false

    func setupConstraints() {
        // Implement in subclass
    }

    override func updateConstraints() {
        super.updateConstraints()
        if !isDidSetupConstraints {
            setupConstraints()
            isDidSetupConstraints = true
        }
    }
}