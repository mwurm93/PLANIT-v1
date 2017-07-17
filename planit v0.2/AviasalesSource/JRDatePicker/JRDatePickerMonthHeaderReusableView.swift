//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRDatePickerMonthHeaderReusableView.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

private let kWeekDayLabelTagOffset: Int = 1000

class JRDatePickerMonthHeaderReusableView: UITableViewHeaderFooterView {
    private var _monthItem: JRDatePickerMonthItem?
    var monthItem: JRDatePickerMonthItem? {
        get {
            return _monthItem
        }
        set(monthItem) {
            _monthItem = monthItem
            updateView()
        }
    }

    @IBOutlet weak var monthYearLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        monthYearLabel.textColor = JRColorScheme.darkText
        for i in 0..<7 {
            let labelTag: Int = i + kWeekDayLabelTagOffset
            let weekdayLabel: UILabel? = (withTag(labelTag) as? UILabel)
            weekdayLabel?.textColor = JRColorScheme.lightText
        }
        updateView()
    }

    func getMonthYearString() -> String {
        let date: Date? = monthItem.firstDayOfMonth
        var monthYearString: String? = nil
        if date != nil {
            let monthName: String = DateUtil.monthName(date)
            let year: String = DateUtil.dayMonthYearComponents(from: date)[2]
            monthYearString = "\(monthName) \(year)".uppercased()
        }
        return monthYearString!
    }

    func updateView() {
        var monthYearString: String
        monthYearString = getMonthYearString()
        monthYearLabel.text = monthYearString as? String ?? ""
        for weekday: String in monthItem.weekdays {
            let labelTag: Int = (monthItem.weekdays as NSArray).index(of: weekday) + kWeekDayLabelTagOffset
            let weekdayLabel: UILabel? = (withTag(labelTag) as? UILabel)
            weekdayLabel?.text = weekday.lowercased()
        }
    }
}