//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import UIKit

class HLShowMorePricesCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    var separatorView: SeparatorView?

    func setShouldShowSeparator(_ shouldShowSeparator: Bool) {
        separatorView?.isHidden = !shouldShowSeparator
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.systemFont(ofSize: 17.0)
        titleLabel.textColor = JRColorScheme.mainButtonBackgroundColor()
        separatorView = SeparatorView()
        separatorView?.attach(toView: self, edge: ALEdgeBottom, insets: UIEdgeInsetsMake(0, 15, 0, 15))
    }
}