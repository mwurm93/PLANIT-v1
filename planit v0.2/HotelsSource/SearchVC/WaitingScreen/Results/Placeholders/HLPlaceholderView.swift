//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import UIKit

protocol HLPlaceholderViewDelegate: NSObjectProtocol {
    func dropFilters()

    func moveToNewSearch()
}

class HLPlaceholderView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var topImageConstraint: NSLayoutConstraint!
    weak var delegate: HLPlaceholderViewDelegate?

    @IBAction func searchAction() {
        if delegate?.responds(to: #selector(self.moveToNewSearch)) {
            delegate?.moveToNewSearch()
        }
    }

    @IBAction func dropFilters() {
        if delegate?.responds(to: #selector(self.dropFilters)) {
            delegate?.dropFilters()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        //    self.titleLabel.font = [UIFont appMediumFontWithSize:20.0];
        //    self.descriptionLabel.font = [UIFont appRegularFontWithSize:14.0];
        //    self.button.titleLabel.font = [UIFont appMediumFontWithSize:14.0];
        //    [self.button setTitleColor:[[ColorScheme current] mainAppColor] forState:UIControlStateNormal];
    }

    override func updateConstraints() {
        super.updateConstraints()
        if iPad() {
            let orientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
            topImageConstraint.constant = UIInterfaceOrientationIsPortrait(orientation) ? -5.0 : -75.0
        }
    }

// MARK: - Actions
}