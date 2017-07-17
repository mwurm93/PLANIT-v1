//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRDatePickerStateObject.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

protocol JRDatePickerStateObjectActionDelegate: NSObjectProtocol {
    func dateWasSelected(_ date: Date)
}

class JRDatePickerStateObject: NSObject {
    var mode = JRDatePickerMode()
    var firstAvalibleForSearchDate: Date?
    var lastAvalibleForSearchDate: Date?
    var today: Date?
    var borderDate: Date?
    private var _firstSelectedDate: Date?
    var firstSelectedDate: Date? {
        get {
            return _firstSelectedDate
        }
        set(firstSelectedDate) {
            _firstSelectedDate = firstSelectedDate
            if _firstSelectedDate && secondSelectedDate {
                let result: ComparisonResult = _firstSelectedDate.compare(secondSelectedDate)
                if result == .orderedDescending {
                    secondSelectedDate = _firstSelectedDate
                }
            }
        }
    }
    var secondSelectedDate: Date?
    var monthItems = [Any]()
    var selectedDates = [Any]()
    var indexPathToScroll: IndexPath?
    private(set) var disabledDates = [Any]()
    private(set) var weeksStrings = [AnyHashable: Any]()
    private(set) weak var delegate: JRDatePickerStateObjectActionDelegate?

    init(delegate: JRDatePickerStateObjectActionDelegate?) {
        super.init()
        
        self.delegate = delegate
        weeksStrings = [AnyHashable: Any]()
        disabledDates = [Any]()
        monthItems = [Any]()
        firstAvalibleForSearchDate = DateUtil.firstAvalibleForSearchDate()
        lastAvalibleForSearchDate = DateUtil.nextYearDate(firstAvalibleForSearchDate)
    
    }

    func updateSelectedDatesRange() {
        if mode != JRDatePickerModeDefault {
            selectedDates = [Any]()
            if firstSelectedDate && secondSelectedDate {
                for item: JRDatePickerMonthItem in monthItems {
                    for week: [Any] in item.weeks {
                        for date: Date in week {
                            let lessThanFirstDate: Bool = date.compare(firstSelectedDate) == .orderedAscending
                            let moreThanSecondDate: Bool = date.compare(secondSelectedDate!) == .orderedDescending
                            if !(lessThanFirstDate || moreThanSecondDate) {
                                selectedDates.append(date)
                            }
                        }
                    }
                }
            }
        }
        var dateForSearch: Date? = mode == JRDatePickerModeDeparture ? firstSelectedDate : secondSelectedDate
        if dateForSearch == nil {
            dateForSearch = mode == JRDatePickerModeDeparture ? secondSelectedDate : firstSelectedDate
        }
        if dateForSearch == nil {
            dateForSearch = borderDate
        }
        if dateForSearch != nil {
            for item: JRDatePickerMonthItem in monthItems {
                for week: [Any] in item.weeks {
                    if week.contains(dateForSearch) && !item.prevDates.contains(dateForSearch) && !item.futureDates.contains(dateForSearch) {
                        indexPathToScroll = IndexPath(row: 0, section: (monthItems as NSArray).index(of: item))
                        break
                    }
                }
            }
        }
    }
}