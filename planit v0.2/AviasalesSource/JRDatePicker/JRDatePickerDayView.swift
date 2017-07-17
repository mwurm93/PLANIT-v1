//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRDatePickerDayView.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class JRDatePickerDayView: UIButton {
    var date: Date?
    private var _isTodayLabelHidden: Bool = false
    var isTodayLabelHidden: Bool {
        get {
            return _isTodayLabelHidden
        }
        set(todayLabelHidden) {
            _isTodayLabelHidden = todayLabelHidden
            if !_isTodayLabelHidden && !todayLabel {
                todayLabel = UILabel()
                todayLabel.text = NSLS("JR_DATE_PICKER_TODAY_DATE_TITLE").lowercased()
                todayLabel.font = UIFont.systemFont(ofSize: 9)
                todayLabel.textColor = JRColorScheme.darkText
                todayLabel.translatesAutoresizingMaskIntoConstraints = false
                todayLabel.textAlignment = .center
                todayLabel.adjustsFontSizeToFitWidth = true
                todayLabel.minimumScaleFactor = 0
                let labelSuperView: UIView? = self
                labelSuperView?.addSubview(todayLabel)
                todayLabel.autoAlignAxis(ALAxisHorizontal, toSameAxisOf: self, withOffset: 14.0)
                todayLabel.autoAlignAxis(toSuperviewAxis: ALAxisVertical)
            }
            updateTodayLabel()
        }
    }
    private var _isBackgroundImageViewHidden: Bool = false
    var isBackgroundImageViewHidden: Bool {
        get {
            return _isBackgroundImageViewHidden
        }
        set(hidden) {
            if !hidden {
                let image = UIImage(named: "searchFormButton")?.imageTinted(withColor: JRColorScheme.mainButtonBackgroundColor())
                backgroundImageView = UIImageView(image: image)
                let bgSuperView: UIView? = superview
                bgSuperView?.insertSubview(backgroundImageView, belowSubview: self)
                backgroundImageView.autoAlignAxis(ALAxisVertical, toSameAxisOf: self)
                backgroundImageView.autoAlignAxis(ALAxisHorizontal, toSameAxisOf: self)
            }
            else {
                backgroundImageView.removeFromSuperview()
            }
        }
    }

    var todayLabel: UILabel?
    var backgroundImageView: UIImageView?

    func setDate(_ date: Date, monthItem: JRDatePickerMonthItem) {
        self.date = date
        let title: String = monthItem.stateObject.weeksStrings[date]
        setTitle(title as? String ?? "", for: .normal)
    }

    override func setHighlighted(_ highlighted: Bool) {
        super.isHighlighted = highlighted
        updateHighlight()
    }

    override func setSelected(_ selected: Bool) {
        super.isSelected = selected
        updateHighlight()
    }

    func updateHighlight() {
        updateTodayLabel()
    }

    func updateTodayLabel() {
        let selectedOrHighlighted: Bool = isSelected || isHighlighted
        let shouldHideTodayLabel: Bool = selectedOrHighlighted || isTodayLabelHidden
        todayLabel?.isHidden = shouldHideTodayLabel
    }

    func accessibilityLabel() -> String {
        return DateUtil.dayMonthYearString(from: date)
    }
}