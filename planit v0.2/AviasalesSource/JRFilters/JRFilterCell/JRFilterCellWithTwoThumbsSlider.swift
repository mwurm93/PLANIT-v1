//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  ASFilterCellWithTwoThumbsSlider.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//
//
//  ASFilterCellWithTwoThumbsSlider.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

class JRFilterCellWithTwoThumbsSlider: UITableViewCell {
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellAttLabel: UILabel!
    @IBOutlet weak var cellSlider: NMRangeSlider!
    @IBOutlet var dayTimeButtons: [UIButton]!
    private var _item: JRFilterTwoThumbSliderItem?
    var item: JRFilterTwoThumbSliderItem? {
        get {
            return _item
        }
        set(item) {
            _item = item
            cellSlider.minimumValue = 0
            cellSlider.maximumValue = item.maxValue - item.minValue
            /* Bug in NMRangeSlider. Should set upperValue before lowerValue
                 https://github.com/muZZkat/NMRangeSlider/issues/39
                 */
            cellSlider.upperValue = item.currentMaxValue - item.minValue
            cellSlider.lowerValue = item.currentMinValue - item.minValue
            cellSlider.minimumRange = (cellSlider.maximumValue - cellSlider.minimumValue) / 10
            if item.needDayTimeShowButtons {
                setupDayTimeButtons()
            }
            else {
                for button: UIButton in dayTimeButtons {
                    button.isHidden = !item.needDayTimeShowButtons
                    button.isEnabled = item.needDayTimeShowButtons
                }
            }
            cellLabel.text = item.tilte()
            cellAttLabel.attributedText = item.attributedStringValue
        }
    }

    var dayTimeButtonWidthContraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset = UIEdgeInsetsMake(0.0, 21.0, 0.0, 0.0)
        cellSlider.tintColor = JRColorScheme.navigationBarBackgroundColor()
        cellLabel.textColor = JRColorScheme.darkText
        cellAttLabel.textColor = JRColorScheme.darkText
        dayTimeButtonWidthMultiplier = 1.0 / 4.0
        for dayTimeButton: UIButton in dayTimeButtons {
            dayTimeButton.setTitleColor(JRColorScheme.navigationBarBackgroundColor(), for: .normal)
            dayTimeButton.titleLabel.adjustsFontSizeToFitWidth = true
            dayTimeButton.titleLabel.minimumScaleFactor = 0.5
            dayTimeButton.layer.borderColor = JRColorScheme.navigationBarBackgroundColor().cgColor
            dayTimeButton.layer.borderWidth = JRPixel()
        }
    }

//- mark Private methds
    func morningButton() -> UIButton {
        return dayTimeButtons[0]
    }

    func dayButton() -> UIButton {
        return dayTimeButtons[1]
    }

    func eveningButton() -> UIButton {
        return dayTimeButtons[2]
    }

    func setupDayTimeButtons() {
        let minDate = Date(timeIntervalSince1970: item.minValue)
        let maxDate = Date(timeIntervalSince1970: item.maxValue)
        let minComponent: DateComponents? = DateUtil.components(from: minDate)
        let maxComponent: DateComponents? = DateUtil.components(from: maxDate)
        morningButton().setTitle(NSLS("JR_FILTER_DAY_TIME_MORNING"), for: .normal)
        dayButton().setTitle(NSLS("JR_FILTER_DAY_TIME_DAY"), for: .normal)
        eveningButton().setTitle(NSLS("JR_FILTER_DAY_TIME_EVENING"), for: .normal)
        eveningButton().isHidden = false
        dayButton().isHidden = eveningButton().isHidden
        morningButton().isHidden = dayButton().isHidden
        eveningButton().isEnabled = false
        dayButton().isEnabled = eveningButton().isEnabled
        morningButton().isEnabled = dayButton().isEnabled
        if minComponent?.hour >= 0 && minComponent?.hour < 11 && maxComponent?.hour >= 19 && maxComponent?.hour <= 23 {
            morningButton().isEnabled = true
            dayButton().isEnabled = true
            eveningButton().isEnabled = true
        }
        else if minComponent?.hour >= 0 && minComponent?.hour < 10 && maxComponent?.hour >= 11 && maxComponent?.hour < 19 {
            morningButton().isEnabled = true
            dayButton().isEnabled = true
        }
        else if minComponent?.hour >= 11 && minComponent?.hour < 18 && maxComponent?.hour >= 19 && maxComponent?.hour <= 23 {
            dayButton().isEnabled = true
            eveningButton().isEnabled = true
        }

        updateDayTimeButtons()
    }

    func setDayTimeButtonWidthMultiplier(_ multiplier: CGFloat) {
        if dayTimeButtonWidthContraint != nil {
            contentView.removeConstraint(dayTimeButtonWidthContraint!)
            dayTimeButtonWidthContraint = nil
        }
        if cellSlider != nil {
            dayTimeButtonWidthContraint = JRConstraintMake(dayTimeButtons[1] as? NSLayoutConstraint ?? NSLayoutConstraint(), .width, .greaterThanOrEqual, contentView, .width, multiplier, 0)
            contentView.addConstraint(dayTimeButtonWidthContraint!)
        }
    }

    @IBAction func onDayTimeButtonsClicked(_ sender: Any) {
        if sender == morningButton() {
            setMorningDeparture()
        }
        else if sender == dayButton() {
            setDayDeparture()
        }
        else if sender == eveningButton() {
            setEveningDeparture()
        }

        sliderValueChanged(cellSlider)
    }

    @IBAction func sliderValueChanged(_ sender: NMRangeSlider) {
        item.currentMinValue = (NSTimeInterval)
        cellSlider.lowerValue + item.minValue
        item.currentMaxValue = (NSTimeInterval)
        cellSlider.upperValue + item.minValue
        item.filterAction()
        cellAttLabel.attributedText = item.attributedStringValue
        updateDayTimeButtons()
    }

    func updateDayTimeButtons() {
        let minDate = Date(timeIntervalSince1970: item.minValue)
        let morningBorderComponents: DateComponents? = DateUtil.components(from: minDate)
        morningBorderComponents?.hour = 12
        morningBorderComponents?.minute = 0
        let morningBorderDate: Date? = DateUtil.date(from: morningBorderComponents!)
        let eveningBorderComponents: DateComponents? = DateUtil.components(from: minDate)
        eveningBorderComponents?.hour = 18
        eveningBorderComponents?.minute = 0
        let eveningBorderDate: Date? = DateUtil.date(from: eveningBorderComponents!)
        if morningButton().isEnabled {
            morningButton().isSelected = item.currentMaxValue < morningBorderDate?.timeIntervalSince1970
        }
        if dayButton().isEnabled {
            dayButton().isSelected = (item.currentMaxValue < eveningBorderDate?.timeIntervalSince1970) && (item.currentMinValue >= morningBorderDate?.timeIntervalSince1970)
        }
        if eveningButton().isEnabled {
            eveningButton().isSelected = item.currentMinValue >= eveningBorderDate?.timeIntervalSince1970
        }
    }

    func setMorningDeparture() {
        let minDate = Date(timeIntervalSince1970: item.minValue)
        let maxFilterComponent: DateComponents? = DateUtil.components(from: minDate)
        maxFilterComponent?.hour = 12
        maxFilterComponent?.minute = 0
        let filterMaxDepartureTime: Date? = DateUtil.date(from: maxFilterComponent!)
        cellSlider.lowerValue = cellSlider.minimumValue
        cellSlider.upperValue = cellSlider.maximumValue
        cellSlider.upperValue = filterMaxDepartureTime?.timeIntervalSince1970 - item.minValue - 60.0
    }

    func setDayDeparture() {
        let minDate = Date(timeIntervalSince1970: item.minValue)
        let maxDate = Date(timeIntervalSince1970: item.maxValue)
        let minFilterComponent: DateComponents? = DateUtil.components(from: minDate)
        let maxFilterComponent: DateComponents? = DateUtil.components(from: maxDate)
        if minFilterComponent?.hour <= 12 {
            if minFilterComponent?.hour != 12 {
                minFilterComponent?.minute = 0
            }
            minFilterComponent?.hour = 12
        }
        if maxFilterComponent?.hour >= 18 {
            if maxFilterComponent?.hour != 18 {
                maxFilterComponent?.minute = 0
            }
            maxFilterComponent?.hour = 18
        }
        let filterMinDepartureTime: Date? = DateUtil.date(from: minFilterComponent!)
        let filterMaxDepartureTime: Date? = DateUtil.date(from: maxFilterComponent!)
        cellSlider.lowerValue = cellSlider.minimumValue
        cellSlider.upperValue = cellSlider.maximumValue
        cellSlider.lowerValue = filterMinDepartureTime?.timeIntervalSince1970 - item.minValue
        cellSlider.upperValue = filterMaxDepartureTime?.timeIntervalSince1970 - item.minValue - 60.0
    }

    func setEveningDeparture() {
        let minDate = Date(timeIntervalSince1970: item.minValue)
        let minFilterComponent: DateComponents? = DateUtil.components(from: minDate)
        minFilterComponent?.hour = 18
        minFilterComponent?.minute = 0
        let filterMinDepartureTime: Date? = DateUtil.date(from: minFilterComponent!)
        cellSlider.lowerValue = cellSlider.minimumValue
        cellSlider.upperValue = cellSlider.maximumValue
        cellSlider.lowerValue = filterMinDepartureTime?.timeIntervalSince1970 - item.minValue
    }
}