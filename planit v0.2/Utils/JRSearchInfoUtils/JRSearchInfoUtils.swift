//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRSearchInfoUtils.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

private func formattedDate(date: Date, includeMonth: Bool, includeYear: Bool, numberRepresentation: Bool) -> String {
    var format: String
    if numberRepresentation {
        format = "dd.MM"
    }
    else {
        if includeMonth && includeYear {
            format = "dd MMM yyyy"
        }
        else if includeMonth {
            format = "dd MMM"
        }
        else {
            format = "dd"
        }
    }
    let formatter = DateFormatter.applicationUI()
    formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: format, options: kNilOptions, locale: formatter.locale)
    return formatter.string(from: date)
}

class JRSearchInfoUtils: NSObject {
    class func getDirectionIATAs(for searchInfo: JRSDKSearchInfo) -> [Any] {
        var iatas = [Any]()
        for travelSegment: JRSDKTravelSegment in searchInfo.travelSegments {
            let originIATA: String = travelSegment.originAirport.iata
            if originIATA != "" {
                iatas.append(originIATA)
            }
            let destinationIATA: String = travelSegment.destinationAirport.iata
            if destinationIATA != "" {
                iatas.append(destinationIATA)
            }
        }
        if JRSDKModelUtils.searchInfoIsDirectReturnFlight(searchInfo) && iatas.count > 2 {
            var directReturnIATAs: [Any]? = nil
            let directReturnIATAsRange = NSRange(location: 0, length: 2)
            directReturnIATAs = iatas[directReturnIATAsRange.location..<directReturnIATAsRange.location + directReturnIATAsRange.length]
            return directReturnIATAs!
        }
        else {
            return iatas
        }
    }

    class func getMainIATAs(for searchInfo: JRSDKSearchInfo) -> [Any] {
        var iatasForSearchInfo: [Any] = self.getDirectionIATAs(for: searchInfo)
        var mainIATAsForSearchInfo = [Any]()
        for iata: String in iatasForSearchInfo {
            let mainIATA: String = AviasalesSDK.sharedInstance.airportsStorage().mainIATA(by: iata)
            if mainIATA != "" {
                mainIATAsForSearchInfo.append(mainIATA)
            }
        }
        return mainIATAsForSearchInfo
    }

    class func dates(for searchInfo: JRSDKSearchInfo) -> [Any] {
        var dates = [Any]()
        for travelSegment: JRSDKTravelSegment in searchInfo.travelSegments {
            let departureDate: Date? = travelSegment.departureDate
            if departureDate != nil {
                dates.append(departureDate)
            }
        }
        return dates
    }

    class func shortDirectionIATAString(for searchInfo: JRSDKSearchInfo) -> String {
        let iatas: [Any] = self.getDirectionIATAs(for: searchInfo)
        let separator: String = JRSDKModelUtils.searchInfoIsComplex(searchInfo) ? " … " : " — "
        return "\(iatas.first) \(separator) \(iatas.last)"
    }

    class func fullDirectionIATAString(for searchInfo: JRSDKSearchInfo) -> String {
        var directionString = String()
        for travelSegment: JRSDKTravelSegment in searchInfo.travelSegments {
            if travelSegment != searchInfo.travelSegments.first {
                directionString += "  "
            }
            directionString += "\(travelSegment.originAirport.iata)—\(travelSegment.destinationAirport.iata)"
        }
        return directionString
    }

    class func fullDirectionCityString(for searchInfo: JRSDKSearchInfo) -> String {
        let iatas: [Any] = self.getDirectionIATAs(for: searchInfo)
        var directionString = String()
        for i in 0..<iatas.count {
            let iata: String = iatas[i]
            let airport: JRSDKAirport? = AviasalesSDK.sharedInstance.airportsStorage().findAnything(byIATA: iata)
            let airportCity: String? = airport?.city ? airport?.city : iata
            directionString += airportCity!
            if i != iatas.count - 1 {
                directionString += " — "
            }
        }
        return directionString
    }

    class func datesIntervalString(with searchInfo: JRSDKSearchInfo) -> String {
        var datesString: String
        let firstDate: Date? = searchInfo.travelSegments.first?.departureDate
        let lastDate: Date? = searchInfo.travelSegments.count > 1 ? searchInfo.travelSegments.last?.departureDate : nil
        if lastDate != nil {
            datesString = "\(iPhone() ? DateUtil.dayMonthString(from: firstDate) : DateUtil.dayFullMonthYearString(from: firstDate)) — \(iPhone() ? DateUtil.dayMonthString(from: lastDate) : DateUtil.dayFullMonthYearString(from: lastDate))"
        }
        else {
            datesString = "\(iPhone() ? DateUtil.dayFullMonthString(from: firstDate) : DateUtil.dayFullMonthYearString(from: firstDate))"
        }
        return datesString
    }

    class func passengersCountString(with searchInfo: JRSDKSearchInfo) -> String {
        let passengers: Int = searchInfo.adults + searchInfo.children + searchInfo.infants
        let format: String = NSLSP("JR_SEARCHINFO_PASSENGERS", passengers)
        return String(format: format, passengers)
    }

    class func travelClassString(with searchInfo: JRSDKSearchInfo) -> String {
        return self.travelClassString(withTravel: searchInfo.travelClass)
    }

    class func travelClassString(with travelClass: JRSDKTravelClass) -> String {
        switch travelClass {
            case JRSDKTravelClassBusiness:
                return NSLS("JR_SEARCHINFO_BUSINESS")
            case JRSDKTravelClassPremiumEconomy:
                return NSLS("JR_SEARCHINFO_PREMIUM_ECONOMY")
            case JRSDKTravelClassFirst:
                return NSLS("JR_SEARCHINFO_FIRST")
            default:
                return NSLS("JR_SEARCHINFO_ECONOMY")
        }

    }

    class func formattedIatas(for searchInfo: JRSDKSearchInfo) -> String {
        let iatas = [Any]()
        for travelSegment: JRSDKTravelSegment in searchInfo.travelSegments {
            iatas.append(travelSegment.originAirport.iata)
        }
        let lastIata: JRSDKIATA? = searchInfo.travelSegments.last?.destinationAirport?.iata
        if !(iatas[0] == lastIata) {
            iatas.append(lastIata)
        }
        var result: String
        if iatas.count > 2 {
            result = "\(iatas[0]) – … –  \(iatas[iatas.count - 1])"
        }
        else {
            result = "\(iatas[0]) — \(iatas[iatas.count - 1])"
        }
        return result
    }

    class func formattedDates(for searchInfo: JRSDKSearchInfo) -> String {
        let firstTravelSegment: JRSDKTravelSegment? = searchInfo.travelSegments.first
        if firstTravelSegment?.departureDate == nil {
            return nil
        }
        let calendar = Calendar.current
        let necessaryDateComponents: NSCalendar.Unit = [.day, .month, .year]
        let departureDateComponents: DateComponents? = calendar.components(necessaryDateComponents, from: firstTravelSegment?.departureDate)
        let currentYear: DateComponents? = calendar.components(.year, from: Date())
        if searchInfo.travelSegments.count == 1 {
            return formattedDate(firstTravelSegment?.departureDate, true, departureDateComponents?.year != currentYear?.year, false)!
        }
        let lastTravelSegment: JRSDKTravelSegment? = searchInfo.travelSegments.last
        let returnDateComponents: DateComponents? = calendar.components(necessaryDateComponents, from: lastTravelSegment?.departureDate)
        var departureIncludeYear: Bool = false
        var returnIncludeYear: Bool? = returnDateComponents?.year != currentYear?.year
        if returnDateComponents?.year != departureDateComponents?.year {
            departureIncludeYear = true
            returnIncludeYear = true
        }
        let numberRepresentation: Bool = searchInfo.travelSegments.count > 2
        let formattedDeparture: String? = formattedDate(firstTravelSegment?.departureDate, true, departureIncludeYear, numberRepresentation)
        let formattedReturn: String? = formattedDate(lastTravelSegment?.departureDate, true, returnIncludeYear, numberRepresentation)
        return "\(formattedDeparture)\(" - ")\(formattedReturn)"
    }

    class func formattedDatesExcludeYearComponent(for searchInfo: JRSDKSearchInfo) -> String {
        let firstTravelSegment: JRSDKTravelSegment? = searchInfo.travelSegments.first
        if firstTravelSegment?.departureDate == nil {
            return nil
        }
        if searchInfo.travelSegments.count == 1 {
            return formattedDate(firstTravelSegment?.departureDate, true, false, false)!
        }
        let lastTravelSegment: JRSDKTravelSegment? = searchInfo.travelSegments.last
        let formattedDeparture: String? = formattedDate(firstTravelSegment?.departureDate, true, false, false)
        let formattedReturn: String? = formattedDate(lastTravelSegment?.departureDate, true, false, false)
        return "\(formattedDeparture)\(" - ")\(formattedReturn)"
    }

    class func formattedIatasAndDates(for searchInfo: JRSDKSearchInfo) -> String {
        let formattedIatas: String = self.formattedIatas(for: searchInfo)
        let formattedDates: String = self.formattedDates(for: searchInfo)
        return "\(formattedIatas), \(formattedDates)"
    }

    class func formattedIatasAndDatesExcludeYearComponent(for searchInfo: JRSDKSearchInfo) -> String {
        let formattedIatas: String = self.formattedIatas(for: searchInfo)
        let formattedDates: String = self.formattedDatesExcludeYearComponent(for: searchInfo)
        return "\(formattedIatas), \(formattedDates)"
    }

    class func passengersCountAndTravelClassString(with searchInfo: JRSDKSearchInfo) -> String {
        let passengersCountStringWithSearchInfo = JRSearchInfoUtils.passengersCountString(with: searchInfo)
        return "\(passengersCountStringWithSearchInfo), \(JRSearchInfoUtils.travelClassString(with: searchInfo).lowercased())"
    }
}