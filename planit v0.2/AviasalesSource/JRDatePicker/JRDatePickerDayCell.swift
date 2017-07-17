//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRDatePickerDayCell.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

private let kDateViewTagOffset: Int = 1000
private let kNumberOfDaysInWeek: Int = 7

class JRDatePickerDayCell: UITableViewCell {
    var dates = [Any]()
    var datePickerItem: JRDatePickerMonthItem?
    var layoutAttributeView: UIView?
    var dateTextColor: UIColor?
    var dateSelectedColor: UIColor?
    var dateDisabledColor: UIColor?
    var dateHighlightedColor: UIColor?

    func setDatePickerItem(_ datePickerItem: JRDatePickerMonthItem, dates: [Any]) {
        self.dates = dates
        self.datePickerItem = datePickerItem
        update()
        disableClip(forViewSubviews: self)
    }

    func initialSetup() {
        selectionStyle = []
        backgroundColor = UIColor.clear
        disableClip(forViewSubviews: self)
        dateTextColor = JRColorScheme.darkText
        dateSelectedColor = JRColorScheme.mainButtonBackgroundColor()
        dateDisabledColor = JRColorScheme.inactiveLightTextColor()
        dateHighlightedColor = JRColorScheme.mainButtonBackgroundColor()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier as? String ?? "")
        
        initialSetup()
    
    }

    func createDateView(withTag dateViewTag: Int, dateViewSuperview: UIView, indexOfDate: Int) -> JRDatePickerDayView {
        let dateView: JRDatePickerDayView? = LOAD_VIEW_FROM_NIB_NAMED("JRDatePickerDayView")
        dateView?.translatesAutoresizingMaskIntoConstraints = false
        dateView?.tag = dateViewTag
        dateViewSuperview.addSubview(dateView!)
        let fraction: CGFloat = 1.0 / kNumberOfDaysInWeek
        var leftToRightMultiplier: CGFloat = fraction * indexOfDate
        var secondLeftToRightAttribute: NSLayoutAttribute = .right
        if leftToRightMultiplier == 0.0 {
            secondLeftToRightAttribute = .left
            leftToRightMultiplier = 1.0
        }
        dateViewSuperview.addConstraint(JRConstraintMake(dateView, .left, .equal, dateViewSuperview, secondLeftToRightAttribute, leftToRightMultiplier, 0))
        dateViewSuperview.addConstraint(JRConstraintMake(dateView, .width, .equal, dateViewSuperview, .width, fraction, 0))
        dateViewSuperview.addConstraint(JRConstraintMake(dateView, .height, .equal, dateView, .width, 1, 0))
        dateViewSuperview.addConstraint(JRConstraintMake(dateView, .top, .equal, dateViewSuperview, .top, 1, 0))
        return dateView!
    }

    func dateView(for date: Date) -> JRDatePickerDayView {
        let shouldHideCell: Bool = datePickerItem.prevDates.contains(date) || datePickerItem.futureDates.contains(date)
        let indexOfDate: Int = (dates as NSArray).index(of: date)
        let dateViewTag: Int = indexOfDate + kDateViewTagOffset
        let dateViewSuperview: UIView? = contentView
        let viewWithTag: Any? = dateViewSuperview?.viewWithTag(dateViewTag)
        var dateView: JRDatePickerDayView? = viewWithTag
        if !dateView && !shouldHideCell {
            dateView = createDateView(withTag: dateViewTag, dateViewSuperview: dateViewSuperview, indexOfDate: indexOfDate)
        }
        dateView?.todayLabelHidden = true
        dateView?.isHidden = shouldHideCell
        if shouldHideCell {
            dateView?.backgroundImageViewHidden = true
            return nil
        }
        else {
            return dateView!
        }
    }

    func setupDateView(_ dateView: JRDatePickerDayView, date: Date) {
        dateView.setDate(date, monthItem: datePickerItem)
        dateView.addTarget(self, action: #selector(self.dateViewAction), for: .touchUpInside)
        let isSelectedDate: Bool = datePickerItem.stateObject.firstSelectedDate.isEqual(to: date) || datePickerItem.stateObject.secondSelectedDate.isEqual(to: date)
        dateView.isSelected = isSelectedDate
        dateView.backgroundImageViewHidden = !isSelectedDate
        let enabled: Bool = datePickerItem.stateObject.disabledDates.contains(date) && date.compare(datePickerItem.stateObject.lastAvalibleForSearchDate) == .orderedAscending
        let selected: Bool = datePickerItem.stateObject.selectedDates.contains(date)
        if !enabled {
            dateView.setTitleColor(dateDisabledColor, for: .normal)
        }
        else if selected {
            dateView.setTitleColor(dateSelectedColor, for: .normal)
        }
        else {
            dateView.setTitleColor(dateTextColor, for: .normal)
        }

        dateView.setTitleColor(dateHighlightedColor, for: .highlighted)
        dateView.isEnabled = enabled
        dateView.todayLabelHidden = date != datePickerItem.stateObject.today
    }

    func update() {
        for button: UIButton in contentView.subviews {
            if (button is UIButton) {
                button.isHighlighted = false
                button.isSelected = false
            }
        }
        for date: Date in dates {
            let dateView: JRDatePickerDayView? = self.dateView(for: date)
            if dateView != nil {
                dateView?.backgroundImageViewHidden = true
                setupDateView(dateView, date: date)
            }
        }
    }

    func dateViewAction(_ dateViewAction: JRDatePickerDayView) {
        datePickerItem.stateObject.delegate?.dateWasSelected(dateViewAction.date)
    }

    func disableClip(forViewSubviews superview: UIView) {
        superview.clipsToBounds = false
        superview.isOpaque = true
        superview.backgroundColor = UIColor.clear
        for view: UIView in superview.subviews {
            disableClip(forViewSubviews: view)
        }
    }
}