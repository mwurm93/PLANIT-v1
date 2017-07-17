//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRDatePickerStateObject.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 10/02/14.
//
//
//
//  JRDatePickerStateObject.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 10/02/14.
//
//

import Foundation
import HotellookSDK

enum HLDatePickerMode : Int {
    case modeDeparture
    case modeReturn
    case modeDefault
}


protocol HLDatePickerStateObjectActionDelegate: NSObjectProtocol {
    func dateWasSelected(_ date: Date)

    func showRestrictionToast()
}

class HLDatePickerStateObject: NSObject, NSCopying {
    var mode = JRDatePickerMode()
    var firstAvalibleForSearchDate: Date?
    var lastAvalibleForSearchDate: Date?
    var today: Date?
    var borderDate: Date?
    var firstSelectedDate: Date?
    var secondSelectedDate: Date?
    var monthItems = [Any]()
    var selectedDates = [Any]()
    var improperlySelectedDates = [Any]()
    var indexPathToScroll: IndexPath?
    private(set) var disabledDates = Set<AnyHashable>()
    private(set) var weeksStrings = [AnyHashable: Any]()
    weak var delegate: HLDatePickerStateObjectActionDelegate?

    init(delegate: HLDatePickerStateObjectActionDelegate?) {
        super.init()
        
        self.delegate = delegate
        weeksStrings = [AnyHashable: Any]()
        disabledDates = Set<AnyHashable>()
        monthItems = [Any]()
        firstAvalibleForSearchDate = DateUtil.today()
        lastAvalibleForSearchDate = DateUtil.nextYearDate(firstAvalibleForSearchDate)
    
    }

    func updateSelectedDatesRange() {
        if mode != JRDatePickerModeDefault {
            selectedDates = [Any]()
            improperlySelectedDates = [Any]()
            if firstSelectedDate && secondSelectedDate {
                let dayIn30days: Date? = DateUtil.dateIn30Days(firstSelectedDate)
                for item: JRDatePickerMonthItem in monthItems {
                    for week: [Any] in item.weeks {
                        for date: Date in week {
                            let lessThanFirstDate: Bool = date.compare(firstSelectedDate!) == .orderedAscending
                            let moreThanSecondDate: Bool = date.compare(secondSelectedDate!) == .orderedDescending
                            let moreThan30DaysFromFrirstDate: Bool = HDKDateUtil.isDate(dayIn30days, before: date)
                            if !lessThanFirstDate && !moreThanSecondDate && !moreThan30DaysFromFrirstDate {
                                selectedDates.append(date)
                            }
                            if !lessThanFirstDate && !moreThanSecondDate && moreThan30DaysFromFrirstDate {
                                improperlySelectedDates.append(date)
                            }
                        }
                    }
                }
            }
            else if firstSelectedDate != nil {
                selectedDates.append(firstSelectedDate)
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

    func select(_ date: Date) {
        if HDKDateUtil.isDate(date, before: borderDate) {
            return
        }
        if firstSelectedDate && secondSelectedDate {
            newDateWithBothDatesExisting = date
        }
        else if firstSelectedDate != nil {
            newDateWithOneDateExisting = date
        }
        else {
            firstSelectedDate = date
        }

        if firstSelectedDate != nil && secondSelectedDate != nil {
            let dayIn30Days: Date? = DateUtil.dateIn30Days(firstSelectedDate)
            if HDKDateUtil.isDate(dayIn30Days, before: secondSelectedDate) {
                delegate?.showRestrictionToast()
            }
        }
    }

    func areDatesSelectedProperly() -> Bool {
        if firstSelectedDate == nil {
            return false
        }
        if secondSelectedDate == nil {
            return false
        }
        if HDKDateUtil.isDate(firstSelectedDate, before: borderDate) {
            return false
        }
        if HDKDateUtil.isDate(secondSelectedDate, before: firstSelectedDate) {
            return false
        }
        let dayIn30days: Date? = DateUtil.dateIn30Days(firstSelectedDate)
        if HDKDateUtil.isDate(dayIn30days, before: secondSelectedDate) {
            return false
        }
        return true
    }

    func restrictCheckoutDate() {
        if secondSelectedDate != nil {
            let dayIn30Days: Date? = DateUtil.dateIn30Days(firstSelectedDate)
            if HDKDateUtil.isDate(dayIn30Days, before: secondSelectedDate) {
                secondSelectedDate = dayIn30Days
            }
        }
    }

// MARK: -
// MARK: Private
    func setNewDateWithOneDateExisting(_ date: Date) {
        if DateUtil.isSameDayAndMonthAndYear(date, with: firstSelectedDate) {
            return
        }
        if HDKDateUtil.isDate(date, before: firstSelectedDate) {
            firstSelectedDate = date
        }
        else {
            secondSelectedDate = date
        }
    }

    func setNewDateWithBothDatesExisting(_ date: Date) {
        firstSelectedDate = date
        secondSelectedDate = nil
    }

// MARK: -
// MARK: Public

// MARK: - NSCopying
    func copy(with zone: NSZone) -> Any {
        let copy = HLDatePickerStateObject(delegate: delegate)
        if copy != nil {
            copy.mode = mode
            copy.firstAvalibleForSearchDate = firstAvalibleForSearchDate
            copy.lastAvalibleForSearchDate = lastAvalibleForSearchDate
            copy.today = today
            copy.borderDate = borderDate
            copy.firstSelectedDate = firstSelectedDate
            copy.secondSelectedDate = secondSelectedDate
            copy.monthItems = monthItems
            copy.selectedDates = selectedDates
            copy.improperlySelectedDates = improperlySelectedDates
            copy.indexPathToScroll = indexPathToScroll
        }
        return copy
    }
}