//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
class HLNoSearchResultsPlaceholderView: HLPlaceholderView {
    override func updateConstraints() {
        super.updateConstraints()
        if iPhone35Inch() {
            topImageConstraint.constant = 85.0
        }
        else if iPhone4Inch() {
            topImageConstraint.constant = 128.0
        }
        else if iPhone47Inch() {
            topImageConstraint.constant = 178.0
        }
        else if iPhone55Inch() {
            topImageConstraint.constant = 212.0
        }
        else if iPad() {
            let orientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
            topImageConstraint.constant = UIInterfaceOrientationIsPortrait(orientation) ? 200 : 130
        }

        titleLabel.text = NSLS("HL_NO_RESULTS_TITLE")
        descriptionLabel.text = NSLS("HL_NO_RESULTS_DESCRIPTION")
        button.setTitle(NSLS("HL_NEW_SEARCH_BUTTON"), for: .normal)
        button.setTitleColor(JRColorScheme.mainButtonBackgroundColor(), for: .normal)
    }
}