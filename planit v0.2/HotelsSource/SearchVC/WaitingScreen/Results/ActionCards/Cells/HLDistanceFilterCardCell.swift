//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
class HLDistanceFilterCardCell: HLResultCardCell {
    @IBOutlet var sliderToLabelConstraint: NSLayoutConstraint!
    @IBOutlet var labelToSuperviewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var sliderToSuperviewTrailingConstraint: NSLayoutConstraint!

    override @IBAction func apply() {
        super.apply()
        var value: CGFloat = slider.value
        let distanceItem: HLDistanceFilterCardItem? = self.distanceItem
        value = HLSliderCalculator.calculateExpValue(withSliderValue: value, minValue: distanceItem?.minValue, maxValue: distanceItem?.maxValue)
        item.filter.distanceLocationPoint = (item as? HLDistanceFilterCardItem)?.originPoint()
        if !IS_FLOAT_EQUALS_WITH_ACCURACY(item.filter.currentMaxDistance, value, 0.1) {
            item.filter.currentMaxDistance = value
            if item.topItem {
                item.delegate?.filterUpdated(item.filter)
            }
            else {
                item.delegate?.distanceItemApplied(self.distanceItem)
            }
        }
    }

    override @IBAction func close() {
        item.delegate?.distanceItemClosed(distanceItem)
        super.close()
    }

    override func setup(with filter: Filter) {
        super.setup(with: filter)
        let point: HDKLocationPoint? = (item as? HLDistanceFilterCardItem)?.originPoint()
        descriptionLabel.text = point?.actionCardDescription
        setPresetFilterValue(filter, item: (item as? HLDistanceFilterCardItem), point: point)
    }

    override func updateConstraints() {
        if sliderToSuperviewTrailingConstraint == nil {
            var sliderToSuperviewTrailingConstraintConstant: CGFloat = labelToSuperviewTrailingConstraint.constant + sliderToLabelConstraint.constant
            sliderToSuperviewTrailingConstraintConstant += attributedDistanceString(withValue: 1000000.0).hl_width(withHeight: CGFLOAT_MAX)
            sliderToSuperviewTrailingConstraint = slider.autoPinEdge(toSuperviewEdge: ALEdgeTrailing, withInset: sliderToSuperviewTrailingConstraintConstant)
        }
        super.updateConstraints()
    }

    override func sliderValueChanged() {
        super.sliderValueChanged()
        var value: CGFloat = slider.value
        let distanceItem: HLDistanceFilterCardItem? = self.distanceItem
        value = HLSliderCalculator.calculateExpValue(withSliderValue: value, minValue: distanceItem?.minValue, maxValue: distanceItem?.maxValue)
        updateValueLabel(value)
        (item as? HLDistanceFilterCardItem)?.currentValue = value
        updateApplyButton()
    }

    func updateApplyButton() {
        let filterValue: CGFloat? = distanceItem?.filter?.currentMaxDistance
        let cardValue: CGFloat? = distanceItem?.currentValue
        applyButton.isEnabled = !IS_FLOAT_EQUALS(cardValue, filterValue)
    }

    func updateValueLabel(_ value: CGFloat) {
        valueLabel.attributedText = attributedDistanceString(withValue: value)
    }

    func attributedDistanceString(withValue value: CGFloat) -> NSAttributedString {
        return StringUtils.attributedDistanceString(value, textColor: textColor, numberColor: numberColor)
    }

    func setPresetFilterValue(_ filter: Filter, item: HLDistanceFilterCardItem, point: HDKLocationPoint) {
        let distanceItem: HLDistanceFilterCardItem? = self.distanceItem
        let presetFilterValue: CGFloat? = distanceItem?.currentValue
        let value: CGFloat? = HLSliderCalculator.calculateSliderLogValue(withValue: presetFilterValue, minValue: distanceItem?.minValue, maxValue: distanceItem?.maxValue)
        slider.value = value
        updateValueLabel(presetFilterValue)
        updateApplyButton()
    }

    func distanceItem() -> HLDistanceFilterCardItem {
        return (item as? HLDistanceFilterCardItem)!
    }
}