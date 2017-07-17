//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
class HLNoFilterResultsPlaceholderView: HLPlaceholderView {
    override func layoutSubviews() {
        let navbarHeight: CGFloat = 64
        if iPhone35Inch() {
            topImageConstraint.constant = 50.0 + navbarHeight
        }
        else if iPhone4Inch() {
            topImageConstraint.constant = 134.0 + navbarHeight
        }
        else if iPhone47Inch() {
            topImageConstraint.constant = 183.0 + navbarHeight
        }
        else if iPhone55Inch() {
            topImageConstraint.constant = 211.0 + navbarHeight
        }

        super.layoutSubviews()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.systemFont(ofSize: 20.0)
        button.titleLabel.font = UIFont.systemFont(ofSize: 14.0)
        titleLabel.text = NSLS("HL_NO_FILTER_RESULTS_TITLE")
        descriptionLabel.text = NSLS("HL_NO_FILTER_RESULTS_DESCRIPTION")
        button.setTitle(NSLS("HL_NO_FILTER_RESULTS_BUTTON"), for: .normal)
        button.setTitleColor(JRColorScheme.mainButtonBackgroundColor(), for: .normal)
    }
}