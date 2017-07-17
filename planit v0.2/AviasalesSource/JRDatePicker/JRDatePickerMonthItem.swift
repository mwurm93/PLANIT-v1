//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRDatePickerMonthItem.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

class JRDatePickerMonthItem: NSObject {
    weak var stateObject: JRDatePickerStateObject?
    private(set) var prevDates = [Any]()
    private(set) var futureDates = [Any]()
    private(set) var weeks = [Any]()
    private(set) var weekdays = [Any]()
    private(set) var firstDayOfMonth: Date?

    convenience init(firstDateOfMonth firstDayOfMonth: Date, stateObject: JRDatePickerStateObject) {
        return JRDatePickerMonthItem(firstDateOfMonth: firstDayOfMonth, stateObject: stateObject)
    }

    init(firstDateOfMonth firstDayOfMonth: Date, stateObject: JRDatePickerStateObject) {
        super.init()
        
        self.stateObject = stateObject
        self.firstDayOfMonth = firstDayOfMonth
        prepareDatesForCurrrentMonth()
    
    }

    func getPreviousDates(_ firstDate: Date, firstWeekday: Int) -> [Any] {
        var prevDates = [Any]()
        var i = firstWeekday
        while i > DateUtil.gregorianCalendar().firstWeekday {
            let prevDate: Date? = prevDates.count ? prevDates.first : firstDate
            let newDate: Date? = DateUtil.prevDay(for: prevDate)
            prevDates.insert(newDate, at: 0)
            i -= 1
        }
        return prevDates
    }

    func getDatesInThisMonth() -> [Any] {
        var datesThisMonth = [Any]()
        let rangeOfDaysThisMonth: NSRange = DateUtil.gregorianCalendar().range(of: .day, in: .month, for: firstDayOfMonth)
        let unitFlags: UInt = ([.day, .month, .year, .era])
        let components: DateComponents? = DateUtil.gregorianCalendar().components(unitFlags as? NSCalendar.Unit ?? NSCalendar.Unit(), from: firstDayOfMonth)
        for i in rangeOfDaysThisMonth.location..<NSMaxRange(rangeOfDaysThisMonth) {
            components?.day = i
            let dayInMonth: Date? = DateUtil.gregorianCalendar().date(from: components!)
            datesThisMonth.append(dayInMonth)
        }
        return datesThisMonth
    }

    func getFutureDates(forLastWeek lastWeek: [Any]) -> [Any] {
        var futureDates = [Any]()
        for i in lastWeek.count..<7 {
            let newDate: Date? = futureDates.count ? DateUtil.nextDay(forDate: futureDates.last) : DateUtil.nextMonth(for: firstDayOfMonth)
            futureDates.append(newDate)
        }
        return futureDates
    }

    func getWeeksForDates(inFinalArray finalArray: [Any]) -> [AnyHashable: Any] {
        var weeks = [AnyHashable: Any]()
        var weekCount = 0
        for day: Date in finalArray {
            var week: [Any] = weeks[String(weekCount)]
            if !CInt(weekCount) {
                var formatter: DateFormatter?
                if formatter == nil {
                    formatter = DateFormatter.applicationUI()
                }
                formatter?.dateFormat = "EE"
                weekdays.append(formatter?.string(from: day)?.capitalized)
            }
            if week.isEmpty {
                week = [Any]()
                weeks[String(weekCount)] = week
            }
            week.append(day)
            if week.count == 7 {
                weekCount = (CInt(weekCount) + 1)
            }
        }
        var lastWeek: [Any] = weeks[String(weekCount)]
        if lastWeek.count != 7 {
            futureDates = getFutureDates(forLastWeek: lastWeek)
            lastWeek += futureDates
        }
        return weeks
    }

    func setupDatePickerItem(withWeeksDictionary weeksDictionary: [AnyHashable: Any]) {
        weeks = [Any]()
        let weekKeys: [Any] = (weeksDictionary.keys as NSArray).sortedArray(comparator: {(_ a: String, _ b: String) -> ComparisonResult in
                return a.caseInsensitiveCompare(b)
            })
        for key: String in weekKeys {
            weeks.append(weeksDictionary[key])
        }
        let today = DateUtil.systemTimeZoneResetTime(forDate: Date())
        for week: [Any] in weeks {
            for date: Date in week {
                if !prevDates.contains(date) && !futureDates.contains(date) {
                    if !stateObject.today && date.compare(today) == .orderedSame {
                        stateObject.today = date
                    }
                    (stateObject.weeksStrings)[date] = DateUtil.rawDayNumber(from: date)
                    let borderCompare: ComparisonResult = stateObject.borderDate.compare(date)
                    if borderCompare == .orderedSame {
                        stateObject.borderDate = date
                    }
                    let disabledDate: Bool = borderCompare != .orderedDescending
                    if disabledDate {
                        stateObject.disabledDates.append(date)
                    }
                }
            }
        }
    }

    func prepareDatesForCurrrentMonth() {
        var datesInThisMonth: [Any] = getDatesInThisMonth()
        let firstDate: Date? = datesInThisMonth.first
        var firstWeekday: Int = DateUtil.gregorianCalendar().components(.weekday, from: firstDate!).weekday
        if firstWeekday < DateUtil.gregorianCalendar().firstWeekday {
            firstWeekday = 8
        }
        prevDates = getPreviousDates(firstDate, firstWeekday: firstWeekday)
        var finalArray = [Any](arrayLiteral: prevDates)
        finalArray += datesInThisMonth
        weekdays = [Any]()
        var weeksDictionary: [AnyHashable: Any] = getWeeksForDates(inFinalArray: finalArray)
        setupDatePickerItem(withWeeksDictionary: weeksDictionary)
    }
}