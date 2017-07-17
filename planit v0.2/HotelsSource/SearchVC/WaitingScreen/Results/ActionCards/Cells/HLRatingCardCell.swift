//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
class HLRatingCardCell: HLResultCardCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionLabel.text = NSLS("HL_LOC_FILTER_RATING_CRITERIA")
        slider.setMaximumTrackImage(JRColorScheme.sliderMaxImage(), for: .normal)
        slider.setMinimumTrackImage(JRColorScheme.sliderMinImage(), for: .normal)
    }

    override @IBAction func apply() {
        super.apply()
        let value: CGFloat = slider.value * 100
        if item.filter.currentMinRating != value {
            item.filter.currentMinRating = value
            item.delegate?.filterUpdated(item.filter)
        }
    }

    override func setup(with filter: Filter) {
        super.setup(with: filter)
        let value: Int = item.filter.currentMinRating
        slider.value = value / 100.0
        updateValueLabel(value)
    }

    override func sliderValueChanged() {
        super.sliderValueChanged()
        let value: CGFloat = slider.value * 100.0
        updateValueLabel(value)
    }

    func updateValueLabel(_ value: Int) {
        valueLabel.attributedText = StringUtils.attributedRatingString(for: value, textColor: JRColorScheme.lightText, number: JRColorScheme.lightText)
    }
}