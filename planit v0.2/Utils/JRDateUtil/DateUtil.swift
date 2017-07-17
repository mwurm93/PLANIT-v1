//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  DateUtil.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

let DateUtilSystemTimeZoneDidChangeNotification = "DateUtilSystemTimeZoneDidChangeNotification"
enum JRDateUtilDurationStyle : Int {
    case jrDateUtilDurationShortStyle = 0
    case jrDateUtilDurationLongStyle = 1
}


class DateUtil: NSObject {
    static var willEnterForegroundNotificationObserver: Any? = nil
    static var user24HourTimeCyclePreference: Bool = false

    class func gregorianCalendar() -> Calendar {
        var gregorianCalendar: Calendar?
        if gregorianCalendar == nil {
            var onceToken: Int
            if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
                gregorianCalendar = Calendar(calendarIdentifier: .gregorian)
                gregorianCalendar?.locale = NSLocale.currentLocale
                gregorianCalendar?.timeZone = self.gmtTimeZone()
            }
        onceToken = 1
        }
        return gregorianCalendar!
    }

    class func systemCalendar() -> Calendar {
        return Calendar.autoupdatingCurrentCalendar
    }

    class func enusposixLocale() -> NSLocale {
        var ENUSPOSIXLocale: NSLocale?
        if ENUSPOSIXLocale == nil {
            var onceToken: Int
            if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
                ENUSPOSIXLocale = NSLocale(localeIdentifier: "en_US_POSIX")
            }
        onceToken = 1
        }
        return ENUSPOSIXLocale!
    }

    class func applicationLocale() -> NSLocale {
        var applicationLocale: NSLocale?
        if applicationLocale == nil {
            var onceToken: Int
            if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
                // TODO: generate app locale
                applicationLocale = NSLocale.currentLocale
            }
        onceToken = 1
        }
        return applicationLocale!
    }

    class func gmtTimeZone() -> NSTimeZone {
        var GMTTimeZone: NSTimeZone?
        if GMTTimeZone == nil {
            var onceToken: Int
            if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
                GMTTimeZone = NSTimeZone.timeZone(withAbbreviation: "GMT")
            }
        onceToken = 1
        }
        return GMTTimeZone!
    }

    class func systemTimeZone() -> NSTimeZone {
        NotificationCenter.default.addObserver(forName: DateUtilSystemTimeZoneDidChangeNotification, object: nil, queue: OperationQueue.mainQueue, usingBlock: {(_ note: Notification) -> Void in
            NSTimeZone.resetSystemTimeZone()
            NotificationCenter.default.post(name: DateUtilSystemTimeZoneDidChangeNotification, object: nil)
        })
        return NSTimeZone.systemTimeZone
    }

    class func isSameDayAndMonthAndYear(_ date1: Date, with date2: Date) -> Bool {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        formatter?.dateFormat = "dd-yyyy-MM"
        return (formatter?.string(from: date1) == formatter?.string(from: date2))!
    }

    class func isSameMonthAndYear(_ date1: Date, with date2: Date) -> Bool {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        formatter?.dateFormat = "yyyy-MM"
        return (formatter?.string(from: date1) == formatter?.string(from: date2))!
    }

    class func isTodayDate(_ date: Date) -> Bool {
        return self.date(date, isEqualToDateIgnoringTime: DateUtil.today())
    }

    class func isYesterdayDate(_ date: Date) -> Bool {
        return self.date(date, isEqualToDateIgnoringTime: DateUtil.prevDay(forDate: DateUtil.today()))
    }

    class func dayMonthYearComponents(from date: Date) -> [Any] {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        let dateString: String = self.dayNumber(from: date)
        formatter?.dateFormat = "MMM"
        var monthString: String? = formatter?.string(from: date)
        if (monthString?.characters.count ?? 0) > 3 {
            monthString = (monthString? as NSString).substring(with: NSRange(location: 0, length: 3))
        }
        let year: String = self.date(toYearString: date)
        if dateString && monthString && year {
            return [dateString, monthString, year]
        }
        else {
            return nil
        }
    }

    class func season(for date: Date) -> Date {
        let calendar = DateUtil.gregorianCalendar()
        let comps: DateComponents? = calendar.components([.month, .year], from: date)
        if comps?.month < 3 {
            comps?.year -= 1
        }
        comps?.month %= 12
        comps?.month /= 3
        comps?.month *= 3
        if comps?.month == 0 {
            comps?.month = 12
        }
        return calendar.date(from: comps!)!
    }

    class func addNumberOfDays(_ daysToAdd: Int, to date: Date) -> Date {
        let now: Date? = date
        let components = DateComponents()
        components.day = daysToAdd
        let newDate: Date? = DateUtil.gregorianCalendar().date(byAdding: components, to: now!, options: [])
        return newDate!
    }

    class func adjustGMTDate(_ date: Date, for timeZone: NSTimeZone) -> Date {
        var dateFormatter: DateFormatter?
        if dateFormatter == nil {
            dateFormatter = DateFormatter.usposix()
        }
        dateFormatter?.dateFormat = "z"
        dateFormatter?.timeZone = timeZone as? TimeZone ?? TimeZone()
        let timeZoneString: String? = dateFormatter?.string(from: date)
        dateFormatter?.timeZone = NSTimeZone.timeZone(withAbbreviation: "GMT")
        dateFormatter?.dateFormat = "dd MM yyyy HH:mm:ss"
        let dateString: String? = dateFormatter?.string(from: date)
        dateFormatter?.dateFormat = "dd MM yyyy HH:mm:ss z"
        var newDate: Date?
        let startStringForFormatter: String = "\(dateString) \(timeZoneString)"
        newDate = dateFormatter?.date(from: startStringForFormatter)
        return newDate!
    }

    class func adjustDate(toGMT date: Date, originalDateTimeZone: NSTimeZone) -> Date {
        if !(date is Date) {
            return nil
        }
        var dateFormatter: DateFormatter?
        if dateFormatter == nil {
            dateFormatter = DateFormatter.usposix()
        }
        let gmtTimeZone = NSTimeZone.timeZone(withAbbreviation: "GMT")
        dateFormatter?.dateFormat = "z"
        dateFormatter?.timeZone = gmtTimeZone as? TimeZone ?? TimeZone()
        let timeZoneString: String? = dateFormatter?.string(from: date)
        dateFormatter?.timeZone = originalDateTimeZone as? TimeZone ?? TimeZone()
        dateFormatter?.dateFormat = "dd MM yyyy HH:mm:ss"
        let dateString: String? = dateFormatter?.string(from: date)
        dateFormatter?.dateFormat = "dd MM yyyy HH:mm:ss z"
        dateFormatter?.timeZone = gmtTimeZone as? TimeZone ?? TimeZone()
        var newDate: Date?
        let startStringForFormatter: String = "\(dateString) \(timeZoneString)"
        newDate = dateFormatter?.date(from: startStringForFormatter)
        return newDate!
    }

    class func beginningOfWeek() -> Date {
        let today: Date? = DateUtil.today()
        let gregorian = DateUtil.gregorianCalendar()
        let weekdayComponents: DateComponents? = gregorian.components(.weekday, from: today!)
        let componentsToSubtract = DateComponents()
        componentsToSubtract.day = 0 - (weekdayComponents?.weekday - DateUtil.gregorianCalendar().firstWeekday)
        let beginningOfWeek: Date? = gregorian.date(byAdding: componentsToSubtract, to: today!, options: [])
        return beginningOfWeek!
    }

    class func date(from components: DateComponents) -> Date {
        return self.gregorianCalendar().date(from: components)!
    }

    class func date(fromDate date: String, andTime time: String) -> Date {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.usposix()
        }
        formatter?.dateFormat = "yyyy-MM-dd HH:mm"
        let dateTimeString: String = "\(date) \(time)"
        return formatter?.date(from: dateTimeString)!
    }

    class func date(fromDateString date: String) -> Date {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.usposix()
        }
        formatter?.dateFormat = "yyyy-MM-dd"
        return formatter?.date(from: date)!
    }

    class func firstAvalibleForSearchDate() -> Date {
        return DateUtil.resetTime(forDate: Date(), timeZone: NSTimeZone.timeZone(withName: "US/Samoa"))
    }

    class func firstDayOfMonth(_ date: Date) -> Date {
        let gregorian = DateUtil.gregorianCalendar()
        let components: DateComponents? = gregorian.components(([.day, .month, .year]), from: date)
        components?.day = 1
        return gregorian.date(from: components!)!
    }

    class func gmtTimeZoneResetTime(for date: Date) -> Date {
        let gregorian = DateUtil.gregorianCalendar()
        let components: DateComponents? = gregorian.components(([.hour, .minute, .day, .month, .year]), from: date)
        components?.hour = 0
        components?.minute = 0
        return gregorian.date(from: components!)!
    }

    class func nextDay(for date: Date) -> Date {
        let gregorian = DateUtil.gregorianCalendar()
        let components: DateComponents? = gregorian.components([.year, .month, .day], from: date)
        components?.day += 1
        let res: Date? = gregorian.date(from: components!)
        return res!
    }

    class func nextMonth(for date: Date) -> Date {
        let gregorian = DateUtil.gregorianCalendar()
        let components: DateComponents? = gregorian.components([.year, .month], from: date)
        components?.month += 1
        let res: Date? = gregorian.date(from: components!)
        return res!
    }

    class func nextYearDate(_ date: Date) -> Date {
        let gregorian = DateUtil.gregorianCalendar()
        let components: DateComponents? = gregorian.components([.year, .month, .day], from: date)
        components?.year += 1
        let res: Date? = gregorian.date(from: components!)
        return res!
    }

    class func prevDay(for date: Date) -> Date {
        let gregorian = DateUtil.gregorianCalendar()
        let components: DateComponents? = gregorian.components([.year, .month, .day], from: date)
        components?.day -= 1
        let res: Date? = gregorian.date(from: components!)
        return res!
    }

    class func resetTime(for date: Date) -> Date {
        let gregorian = DateUtil.gregorianCalendar()
        let components: DateComponents? = gregorian.components(([.hour, .minute, .day, .month, .year]), from: date)
        components?.hour = 0
        components?.minute = 0
        return gregorian.date(from: components!)!
    }

    class func systemTimeZoneResetTime(for date: Date) -> Date {
        return self.resetTime(for: date, timeZone: NSTimeZone.systemTimeZone)
    }

    class func today() -> Date {
        let date = Date()
        let result: Date? = self.systemTimeZoneResetTime(for: date)
        return result!
    }

    class func components(from date: Date) -> DateComponents {
        let timeComps: Int = ([.year, .month, .day, .hour, .minute, .weekday])
        let components: DateComponents? = self.gregorianCalendar().components(timeComps as? NSCalendar.Unit ?? NSCalendar.Unit(), from: date)
        return components!
    }

    class func monthNumber(_ date: Date) -> Int {
        let gregorian = DateUtil.gregorianCalendar()
        let components: DateComponents? = gregorian.components((.month), from: date)
        return components?.month!
    }

    class func dayOfMonthNumber(_ date: Date) -> Int {
        let gregorian = DateUtil.gregorianCalendar()
        let components: DateComponents? = gregorian.components((.day), from: date)
        return components?.day!
    }

    class func datesIntervalString(withSameMonth fromDate: Date, to toDate: Date) -> String {
        var datesString: String = ""
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        if fromDate {
            datesString = "\(DateUtil.dayMonthString(from: fromDate)), \(DateUtil.day(from: fromDate)), \(DateUtil.date(toYearString: fromDate))"
        }
        if fromDate && toDate {
            formatter?.dateFormat = "Myyy"
            if (formatter?.string(from: fromDate) == formatter?.string(from: toDate)) {
                datesString = "\(DateUtil.dayNumber(from: fromDate)), \(DateUtil.day(from: fromDate)) — \(DateUtil.dayMonthString(from: toDate)), \(DateUtil.day(from: toDate)), \(DateUtil.date(toYearString: toDate))"
                return datesString.lowercased()
            }
            formatter?.dateFormat = "yyyy"
            if (formatter?.string(from: fromDate) == formatter?.string(from: toDate)) {
                datesString = "\(DateUtil.dayMonthString(from: fromDate)), \(DateUtil.day(from: fromDate)) — \(DateUtil.dayMonthString(from: toDate)), \(DateUtil.day(from: toDate)), \(DateUtil.date(toYearString: toDate))"
                return datesString.lowercased()
            }
            datesString = "\(DateUtil.dayMonthString(from: fromDate)), \(DateUtil.day(from: fromDate)), \(DateUtil.date(toYearString: fromDate)) — \(DateUtil.dayMonthString(from: toDate)), \(DateUtil.day(from: toDate)), \(DateUtil.date(toYearString: toDate))"
        }
        return datesString.lowercased()
    }

    class func date(toTimeString date: Date) -> String {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUITime()
        }
        if willEnterForegroundNotificationObserver == nil {
                //TODO не работает смена формата времени
            let update24HourTimeCyclePreference: ((_: Void) -> Void)?? = {() -> Void in
                    formatter?.dateStyle = .none
                    formatter?.timeStyle = .short
                    let prevFormatterLocale: NSLocale? = formatter?.locale
                    formatter?.locale = NSLocale.currentLocale
                    let stringFromDate: String? = formatter?.string(from: Date())
                    let amRange: NSRange? = (stringFromDate? as NSString).range(of: formatter?.amSymbol)
                    let pmRange: NSRange? = (stringFromDate? as NSString).range(of: formatter?.pmSymbol)
                    if amRange?.location != NSNotFound || pmRange?.location != NSNotFound {
                        self.user24HourTimeCyclePreference = false
                    }
                    else {
                        self.user24HourTimeCyclePreference = true
                    }
                    formatter?.locale = prevFormatterLocale
                }
            willEnterForegroundNotificationObserver = NotificationCenter.default.addObserver(forName: UIApplicationDidBecomeActiveNotification, object: nil, queue: OperationQueue.mainQueue, usingBlock: {(_ note: Notification) -> Void in
                update24HourTimeCyclePreference()
            })
            update24HourTimeCyclePreference()
        }
        if user24HourTimeCyclePreference || (AVIASALES__("LANGUAGE", nil) == "ru") {
            formatter?.dateFormat = "HH:mm"
            return formatter?.string(from: date)!
        }
        else {
            formatter?.dateFormat = "hh:mma"
            let stringFromDate: String? = formatter?.string(from: date)
            return stringFromDate!
        }
    }

    class func date(toDateString date: Date) -> String {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        formatter?.dateFormat = DateFormatter.dateFormat(fromTemplate: "d MMM", options: kNilOptions, locale: formatter?.locale)
        return formatter?.string(from: date)!
    }

    class func date(toYearString date: Date) -> String {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        formatter?.dateFormat = "yyyy"
        let stringFromDate: String? = formatter?.string(from: date)
        return stringFromDate!
    }

    class func day(from date: Date) -> String {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        formatter?.dateFormat = "EEE"
        let dayCapitalized: String? = (formatter?.string(from: date)? as NSString).replacingCharacters(in: NSRange(location: 0, length: 1), with: (formatter?.string(from: date) as? NSString)?.substring(to: 1)?.capitalized)
        return dayCapitalized!
    }

    class func dayFullMonthString(from date: Date) -> String {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        formatter?.dateFormat = DateFormatter.dateFormat(fromTemplate: "dMMMM", options: kNilOptions, locale: formatter?.locale)
        return formatter?.string(from: date)!
    }

    class func dayFullMonthYearString(from date: Date) -> String {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        formatter?.dateFormat = DateFormatter.dateFormat(fromTemplate: "dMMMMyyyy", options: kNilOptions, locale: formatter?.locale)
        return formatter?.string(from: date)!
    }

    class func shortDayMonthYearString(from date: Date) -> String {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        formatter?.dateFormat = DateFormatter.dateFormat(fromTemplate: "ddMMyyyy", options: kNilOptions, locale: formatter?.locale)
        return formatter?.string(from: date)!
    }

    class func dayMonthString(from date: Date) -> String {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        formatter?.dateFormat = DateFormatter.dateFormat(fromTemplate: "dMMM", options: kNilOptions, locale: formatter?.locale)
        return formatter?.string(from: date)!
    }

    class func dayMonthYearString(from date: Date) -> String {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        formatter?.dateFormat = DateFormatter.dateFormat(fromTemplate: "dMMMyyyy", options: kNilOptions, locale: formatter?.locale)
        return formatter?.string(from: date)!
    }

    class func dayMonthYearWeekdayString(from date: Date) -> String {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        formatter?.dateFormat = DateFormatter.dateFormat(fromTemplate: "dMMMyyyyEEE", options: kNilOptions, locale: formatter?.locale)
        return formatter?.string(from: date)!
    }

    class func fullDayMonthYearWeekdayString(from date: Date) -> String {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        formatter?.dateFormat = DateFormatter.dateFormat(fromTemplate: "dMMMMyyyyEEEE", options: kNilOptions, locale: formatter?.locale)
        return formatter?.string(from: date)!
    }

    class func rawDayNumber(from date: Date) -> String {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        formatter?.dateFormat = "d"
        let dateString: String? = formatter?.string(from: date)
        return dateString!
    }

    class func dayNumber(from date: Date) -> String {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        formatter?.dateFormat = DateFormatter.dateFormat(fromTemplate: "d", options: kNilOptions, locale: formatter?.locale)
        let dateString: String? = formatter?.string(from: date)
        return dateString!
    }

    class func duration(_ duration: Int, durationStyle: JRDateUtilDurationStyle) -> String {
        let hoursInteger: Int = duration / 60
        var minutesInteger: Int = duration % 60
        var format: String? = nil
        if durationStyle == .jrDateUtilDurationLongStyle {
            format = NSLS("LONG_TIME_FORMAT")
            minutesInteger -= minutesInteger % 5
        }
        else {
            format = NSLS("SHORT_TIME_FORMAT")
        }
        let hours: String = hoursInteger <= 9 ? "0\(Int(hoursInteger))" : "\()"
        let minutes: String = minutesInteger <= 9 ? "0\(Int(minutesInteger))" : "\()"
        return String(format: format, hours, minutes)
    }

    class func fastDayMonthString(_ date: Date) -> String {
        if !(date is Date) {
            return nil
        }

        var timeinfo: tm?
        let buffer = [CChar](repeating: CChar(), count: 80)
        var rawtime: time_t = date.timeIntervalSince1970
        timeinfo = gmtime(rawtime)
        strftime(buffer, 80, "%d%m", timeinfo)
        let timeInfoString = String(cString: buffer, encoding: String.Encoding.utf8)
        return timeInfoString
    }

    class func fullDay(from date: Date) -> String {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        formatter?.dateFormat = "EEEE"
        let dayCapitalized: String? = (formatter?.string(from: date)? as NSString).replacingCharacters(in: NSRange(location: 0, length: 1), with: (formatter?.string(from: date) as? NSString)?.substring(to: 1)?.capitalized)
        return dayCapitalized!
    }

    class func monthName(_ date: Date) -> String {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        let gregorian = DateUtil.gregorianCalendar()
        let components: DateComponents? = gregorian.components((.month), from: date)
        let monthArr: [Any]? = formatter?.standaloneMonthSymbols
        return monthArr[components?.month - 1]!
    }

    class func shortDatesIntervalString(withSameMonth fromDate: Date, to toDate: Date) -> String {
        var datesString: String = ""
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        if fromDate {
            datesString = DateUtil.dayMonthString(from: fromDate)
        }
        if fromDate && toDate {
            formatter?.dateFormat = "Myyy"
            if (formatter?.string(from: fromDate) == formatter?.string(from: toDate)) {
                datesString = "\(DateUtil.dayNumber(from: fromDate)) — \(DateUtil.dayMonthString(from: toDate))"
                return datesString.lowercased()
            }
            datesString = "\(DateUtil.dayMonthString(from: fromDate)) — \(DateUtil.dayMonthString(from: toDate))"
            return datesString.lowercased()
        }
        return datesString.lowercased()
    }

    class func stringForSpeakDayMonthYearDay(ofWeek date: Date) -> String {
        var formatter: DateFormatter?
        if formatter == nil {
            formatter = DateFormatter.applicationUI()
        }
        formatter?.dateFormat = "dd MMMM yyyy, EEEE"
        return formatter?.string(from: date)!
    }

    class func borderDate() -> Date {
        let localDate = Date()
        let lastAvailableTimeZone = NSTimeZone.timeZone(withName: "UTC-14")
        let offsetSeconds: TimeInterval? = lastAvailableTimeZone?.secondsFromGMT
        let borderDate = localDate.date(byAddingTimeInterval: offsetSeconds!)
        let gregorian = DateUtil.gregorianCalendar()
        let components: DateComponents? = gregorian.components(([.hour, .minute, .day, .month, .year]), from: borderDate)
        components?.hour = 0
        components?.minute = 0
        return gregorian.date(from: components!)!
    }

    class func hl_daysBetweenDate(_ date: Date, andOtherDate otherDate: Date) -> Int {
        let cal = DateUtil.gregorianCalendar()
        let normDate: Date? = self.resetTime(for: date)
        let normOtherDate: Date? = self.resetTime(for: otherDate)
        let components: DateComponents? = cal.components(.day, from: normDate!, to: normOtherDate!, options: [])
        return components?.day!
    }

    class func dateIn30Days(_ date: Date) -> Date {
        let cal = DateUtil.gregorianCalendar()
        let components: DateComponents? = cal.components([.year, .month, .day], from: date)
        components?.day += 30
        return cal.date(from: components!)!
    }

    class func firstDayOfNextMonth(for date: Date) -> Date {
        let cal = DateUtil.gregorianCalendar()
        let components: DateComponents? = cal.components([.year, .month], from: date)
        components?.month += 1
        let res: Date? = cal.date(from: components!)
        return res!
    }

    class func setTimeFor(_ date: Date, time: Date) -> Date {
        let calendar = DateUtil.gregorianCalendar()
        return calendar.date(bySettingHour: time.hour, minute: time.minute, second: time.second, of: date, options: [])!
    }

    class func time(inMinutesOf date: Date) -> Int {
        let gregorian = DateUtil.gregorianCalendar()
        let components: DateComponents? = gregorian.components(([.hour, .minute]), from: date)
        let hours: Int? = components?.hour
        let minutes: Int? = components?.minute
        let result: Int = hours * 60 + minutes
        return result
    }

    class func getTimeFor(_ date: Date) -> Date {
        let gregorian = DateUtil.gregorianCalendar()
        let components: DateComponents? = gregorian.components(([.hour, .minute]), from: date)
        return gregorian.date(byAdding: components!, to: Date.distantPast, options: [])!
    }

    class func resetTime(for date: Date, timeZone: NSTimeZone) -> Date {
        let gregorian = DateUtil.gregorianCalendar()
        let components: DateComponents? = gregorian.components(([.hour, .minute, .day, .month, .year]), from: timeZone ? date.date(byAddingTimeInterval: timeZone.secondsFromGMT) : date)
        components?.hour = 0
        components?.minute = 0
        return gregorian.date(from: components!)!
    }

    class func dateNumber(toNSDate dateNumber_: NSNumber, forMonth month_: Date) -> Date {
        let gregorian = DateUtil.gregorianCalendar()
        let components: DateComponents? = gregorian.components([.year, .month, .day], from: month_)
        components?.day = CInt(dateNumber_)
        //NSDate *dateWithNumber = [firstDateOfMonth dateByAddingTimeInterval:86400*[dateNumber_ intValue]];//-1];
        return gregorian.date(from: components!)!
        //dateWithNumber;
    }

    class func prevMonth(for date: Date) -> Date {
        let gregorian = DateUtil.gregorianCalendar()
        let components: DateComponents? = gregorian.components([.year, .month], from: date)
        components?.month -= 1
        let res: Date? = gregorian.date(from: components!)
        return res!
    }

    class func systemTimeZoneNextYearDate(_ date: Date) -> Date {
        let gregorian = DateUtil.gregorianCalendar()
        let components: DateComponents? = gregorian.components(([.hour, .minute, .day, .month, .year]), from: date.date(byAddingTimeInterval: NSTimeZone.systemTimeZone.secondsFromGMT))
        components?.year += 1
        let res: Date? = gregorian.date(from: components!)
        return res!
    }

    class func daysBetweenDate(_ date: Date, andOtherDate otherDate: Date) -> Int {
        let time: TimeInterval = date.timeIntervalSince(otherDate)
        return fabs(time / 60 / 60 / 24)
    }

    class func date(_ date: Date, isEqualToDateIgnoringTime aDate: Date) -> Bool {
        var dateComponents: NSCalendar.Unit
        dateComponents = ([.year, .month, .day, .weekOfYear, .hour, .minute, .second, .weekday, .weekdayOrdinal])
        let components1: DateComponents? = DateUtil.gregorianCalendar().components(dateComponents, from: date)
        let components2: DateComponents? = DateUtil.gregorianCalendar().components(dateComponents, from: aDate)
        return (components1?.year == components2?.year) && (components1?.month == components2?.month) && (components1?.day == components2?.day)!
    }

    class func isTomorrowDate(_ date: Date) -> Bool {
        return self.date(date, isEqualToDateIgnoringTime: DateUtil.nextDay(for: DateUtil.today()))
    }

// MARK: - Hotellook stuff
}

extension NSDateFormatter {
    class func usposixDateFormatter() -> DateFormatter {
        let posixFormatter = DateFormatter()
        posixFormatter.calendar = DateUtil.gregorianCalendar()
        posixFormatter.locale = DateUtil.enusposixLocale()
        posixFormatter.timeZone = DateUtil.gmtTimeZone()
        return posixFormatter
    }

    class func applicationUIDateFormatter() -> DateFormatter {
        let applicationUIDateFormatter = DateFormatter.usposixDateFormatter()
        applicationUIDateFormatter.locale = NSLocale(localeIdentifier: AVIASALES__("LANGUAGE", NSLocale.currentLocale.localeIdentifier))
        applicationUIDateFormatter.calendar = DateUtil.systemCalendar()
        return applicationUIDateFormatter
    }

    class func applicationUITime() -> DateFormatter {
        let applicationUITimeFormatter = DateFormatter.applicationUIDateFormatter()
        return applicationUITimeFormatter
    }
}

let kDateFormatterThreadDictionaryKey = "JRDateFomatter"