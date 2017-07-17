//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation
import HotellookSDK

let kAppsFlyerLocationIdKey: String = "locationId"
let kAppsFlyerIataIdKey: String = "destination"
let kAppsFlyerHolelIdKey: String = "hotelId"
let kAppsFlyerHotelKey: String = "H"
let kAppsFlyerIataKey: String = "I"
let kAppsFlyerLocationKey: String = "L"
let kAppsFlyerAdultsKey: String = "adults"
let kAppsFlyerCheckInKey: String = "checkIn"
let kAppsFlyerCheckOutKey: String = "checkOut"
let kHotelWebsiteString: String = "hotelWebsite"
let kNonBreakingSpaceString: String = "\u{00a0}"

class StringUtils: NSObject {
    class func destinationString(by searchInfo: HLSearchInfo) -> String {
        var result: String? = nil
        switch searchInfo.searchInfoType {
            case HLSearchInfoTypeUserLocation:
                result = NSLS("HL_LOC_FILTERS_POINT_MY_LOCATION_TEXT")
            default:
                result = StringUtils.defaultDestinationString(by: searchInfo)
        }

        return result!
    }

    class func searchDestinationDescriptionString(by searchInfo: HLSearchInfo) -> String {
        var result: String? = nil
        switch searchInfo.searchInfoType {
            case HLSearchInfoTypeUserLocation:
                result = NSLS("HL_LOC_HOTELS_NEARBY_TEXT")
            default:
                result = StringUtils.defaultDestinationString(by: searchInfo)
        }

        return result!
    }

    class func datesDescriptionWithCheck(in checkIn: Date, checkOut: Date) -> String {
        let lang: String = NSLocale.currentLocale.localeIdentifier
        return self.datesDescriptionWithCheck(in: checkIn, checkOut: checkOut, localeIdentifier: lang)
    }

    class func ipadDatesDescriptionWithCheck(in checkIn: Date, checkOut: Date) -> String {
        let lang: String = NSLocale.currentLocale.localeIdentifier
        return self.ipadDatesDescriptionWithCheck(in: checkIn, checkOut: checkOut, localeIdentifier: lang)
    }

    class func intervalDescription(with start: Date, andDate finish: Date) -> String {
        let formatter: DateFormatter? = HDKDateUtil.standardFormatter()
        var template: String = "dd.MM"
        template = DateFormatter.dateFormat(fromTemplate: template, options: [], locale: NSLocale.currentLocale)
        formatter?.dateFormat = template
        let checkInDateDescription: String? = formatter?.string(from: start)
        let checkOutDateDescription: String? = formatter?.string(from: finish)
        return "\(checkInDateDescription)–\(checkOutDateDescription)"
    }

    class func shortCheck(inDateAndTime time: Date) -> String {
        return self.shortCheck(inDateAndTime: time, locale: NSLocale.currentLocale)
    }

    class func shortCheck(inDateAndTime time: Date, locale: NSLocale) -> String {
        return self.shortCheck(inOutDateAndTime: time, locale: locale, timePrefix: NSLS("HL_LOC_CHECKIN_AFTER"))
    }

    class func shortCheckOutDateAndTime(_ time: Date) -> String {
        return self.shortCheckOutDateAndTime(time, locale: NSLocale.currentLocale)
    }

    class func shortCheckOutDateAndTime(_ time: Date, locale: NSLocale) -> String {
        return self.shortCheck(inOutDateAndTime: time, locale: locale, timePrefix: NSLS("HL_LOC_CHECKOUT_BEFORE"))
    }

    class func longCheck(inDateAndTime time: Date) -> String {
        return self.longCheck(inDateAndTime: time, locale: NSLocale.currentLocale)
    }

    class func longCheck(inDateAndTime time: Date, locale: NSLocale) -> String {
        return self.longCheck(inOutDateAndTime: time, locale: locale, timePrefix: NSLS("HL_LOC_CHECKIN_AFTER"))
    }

    class func longCheckOutDateAndTime(_ time: Date) -> String {
        return self.longCheckOutDateAndTime(time, locale: NSLocale.currentLocale)
    }

    class func longCheckOutDateAndTime(_ time: Date, locale: NSLocale) -> String {
        return self.longCheck(inOutDateAndTime: time, locale: locale, timePrefix: NSLS("HL_LOC_CHECKOUT_BEFORE"))
    }

    class func guestsDescription(withAdultsCount adultsCount: Int, kidsCount: Int) -> String {
        let adultLocString: String = NSLSP("HL_LOC_GUEST_ADULT", adultsCount)
        let adultString: String = "\(Int(adultsCount)) \(adultLocString)"
        if kidsCount > 0 {
            let kidsLocString: String = NSLSP("HL_LOC_GUEST_KID", kidsCount)
            let kidsString: String = "\(Int(kidsCount)) \(kidsLocString)"
            return "\(adultString), \(kidsString)"
        }
        else {
            return adultString
        }
    }

    class func kidAgeText(withAge age: Int) -> String {
        if age == 0 {
            return NSLS("HL_KIDS_PICKER_LESS_THAN_ONE_YEAR_TITLE")
        }
        let format: String = NSLSP("HL_LOC_YEAR", age)
        let text: String = "\(Int(age)) \(format)"
        return text
    }

    class func durationDescription(withDays days: Int) -> String {
        let nightString: String = NSLSP("HL_LOC_NIGHT", days)
        let result: String = "\(Int(days)) \(nightString)"
        return result
    }

    class func userSettingsDurationWithPrefix(withDays days: Int) -> String {
        let nightString: String = NSLSP("HL_LOC_FOR_NIGHT", days)
        let result = String(format: nightString, Int(days))
        return result
    }

    class func searchInfoString(bySearchInfo info: HLSearchInfo?) -> String? {
        if info == nil {
            return nil
        }
        let datesText: String? = StringUtils.intervalDescription(with: info?.checkInDate, andDate: info?.checkOutDate)
        let passengersText: String? = StringUtils.guestsDescription(withGuestsCount: info?.adultsCount + info?.kidAgesArray?.count)
        return "\(datesText), \(passengersText)"
    }

    class func cityFullName(_ city: HDKCity?) -> String? {
        if (city?.fullName?.characters.count ?? 0) > 0 {
            return city?.fullName
        }
        if (city?.name?.characters.count ?? 0) > 0 {
            return city?.name
        }
        return nil
    }

    class func cityName(_ city: HDKCity?) -> String? {
        if (city?.name?.characters.count ?? 0) > 0 {
            return city?.name
        }
        if (city?.fullName?.characters.count ?? 0) > 0 {
            return city?.fullName
        }
        return nil
    }

    class func cityName(withStateAndCountry city: HDKCity?) -> String {
        if ((city?.name?.characters.count ?? 0) == 0 || (city?.countryName?.characters.count ?? 0) == 0) && city?.fullName {
            return city?.fullName!
        }
        var result = String()
        if (city?.name?.characters.count ?? 0) > 0 {
            result = city?.name
            if (city?.state?.characters.count ?? 0) > 0 {
                result += ", \(city?.state)"
            }
            if (city?.countryName?.characters.count ?? 0) > 0 {
                result += ", \(city?.countryName)"
            }
        }
        return result
    }

    class func searchInfoDescription(_ searchInfo: HLSearchInfo) -> String {
        var locationDescription: String? = nil
        switch searchInfo.searchInfoType {
            case HLSearchInfoTypeUserLocation, HLSearchInfoTypeCustomLocation, HLSearchInfoTypeAirport:
                locationDescription = searchInfo.locationPoint.title
            case HLSearchInfoTypeCity:
                locationDescription = StringUtils.cityName(withStateAndCountry: searchInfo.city)
            case HLSearchInfoTypeCityCenterLocation:
                locationDescription = StringUtils.cityName(withStateAndCountry: searchInfo.locationPoint.city)
            default:
                break
        }

        let datesText: String = StringUtils.intervalDescription(with: searchInfo.checkInDate, andDate: searchInfo.checkOutDate)
        let passengersText: String = StringUtils.guestsDescription(withGuestsCount: searchInfo.adultsCount + searchInfo.kidAgesArray.count)
        let result: String = "\(locationDescription), \(datesText); \(passengersText)"
        return result
    }

    class func attributedRangeValueTextWithPercentFormat(forMinValue minValue: CGFloat, maxValue: CGFloat) -> NSAttributedString {
        let textFont = UIFont.systemFont(ofSize: 12.0)
        let numberFont = UIFont.systemFont(ofSize: 12.0)
        let textColor: UIColor? = JRColorScheme.lightText
        let numberColor: UIColor? = JRColorScheme.darkText
        let lowerString = String(format: "%.0f%%", floorf(minValue * 100.0))
        let lowerAttributedString = NSAttributedString(string: lowerString, attributes: [NSFontAttributeName: numberFont])
        let upperString = String(format: "%.0f%%", ceilf(maxValue * 100.0))
        let upperAttributedString = NSAttributedString(string: upperString, attributes: [NSFontAttributeName: numberFont])
        let str = String(format: NSLS("HL_LOC_FILTER_RANGE"), "lowerValue", "upperValue")
        var range = NSMutableAttributedString(string: str)
        range.addAttribute(NSFontAttributeName, value: textFont, range: NSRangeFromString(str))
        range.addAttribute(NSForegroundColorAttributeName, value: textColor!, range: NSRangeFromString(str))
        range.replaceCharacters(in: (range.string as NSString).range(of: "lowerValue"), with: lowerAttributedString)
        range.replaceCharacters(in: (range.string as NSString).range(of: "upperValue"), with: upperAttributedString)
        range.addAttribute(NSForegroundColorAttributeName, value: numberColor!, range: (range.string as NSString).range(of: lowerAttributedString.string))
        range.addAttribute(NSForegroundColorAttributeName, value: numberColor!, range: (range.string as NSString).range(of: upperAttributedString.string, options: .backwards))
        return range
    }

    class func strikethroughAttributedString(_ attributedString: NSAttributedString) -> NSAttributedString {
        var attributeString = NSMutableAttributedString(attributedString: attributedString)
        attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSRange(location: 0, length: (attributeString.characters.count ?? 0)))
        return attributeString
    }

    class func discountString(forDiscount discount: Int) -> String {
        return "\(labs(discount))%% \(NSLS("HL_DISCOUNT"))"
    }

    class func roomsAvailableString(withCount count: Int) -> String {
        var title: String = NSLSP("HL_HOTEL_DETAIL_AVAILABLE_ROOMS_COUNT_OPTION_BASED", count)
        title = String(format: title, count)
        return title
    }

    class func hotelsCountDescription(withHotels count: Int) -> String {
        let formattedCount = StringUtils.formattedNumberString(withNumber: count)
        let hotelWordString: String = NSLSP("HL_LOC_SEARCH_FORM_HOTEL", count)
        return "\(formattedCount) \(hotelWordString)"
    }

    class func filteredHotelsDescription(withFiltered filtered: Int, total: Int) -> String {
        var title: String? = nil
        if filtered > 0 {
            let countStr = StringUtils.formattedNumberString(withNumber: filtered)
            let totalStr = StringUtils.formattedNumberString(withNumber: total)
            title = NSLSP("HL_LOC_FILTER_HOTELS_FOUND", filtered)
            title = String(format: title, countStr, totalStr)
        }
        else {
            title = NSLS("HL_FILTER_HOTELS_NOT_FOUND")
        }
        return title!
    }

    class func photoCounterString(_ count: Int, totalCount: Int) -> String {
        return "\(Int(count + 1))/\(Int(totalCount))"
    }

    class func shortRatingString(_ rating: Int) -> String {
        return self.shortRatingString(rating, locale: NSLocale.currentLocale)
    }

    class func shortRatingString(_ rating: Int, locale: NSLocale) -> String {
        return rating == 100 ? "10" : String(format: "%.1f", rating / 10.0)
    }

// MARK: - Price Formatting
    class func priceString(with variant: HLResultVariant) -> String {
        var stringToReturn: String? = nil
        if variant.rooms.count == 0 {
            stringToReturn = "—"
        }
        else if variant.searchInfo.currency {
            stringToReturn = variant.searchInfo.currency.formatter?.string(from: (variant.minPrice))?
            let shouldReplaceSpaceWithNonBreaking: Bool = (variant.searchInfo.currency.symbol.characters.count ?? 0) == 1
            if shouldReplaceSpaceWithNonBreaking {
                stringToReturn = stringToReturn?.replacingOccurrences(of: " ", with: kNonBreakingSpaceString)
            }
        }
        else {
            stringToReturn = self.formattedNumberString(withNumber: variant.minPrice)
        }

        return stringToReturn!
    }

    class func priceString(withPrice price: Float, currency: HDKCurrency) -> String {
        return currency != nil ? currency.formatter?.string(from: (price)) : self.formattedNumberString(withNumber: price)!
    }

    class func formattedNumberString(withNumber number: Int) -> String {
        var nf: NumberFormatter? = nil
        if nf == nil {
            nf = NumberFormatter()
            nf?.usesGroupingSeparator = true
            nf?.groupingSize = 3
        }
        return nf?.string(from: Int(number))!
    }

    class func attributedPriceString(with variant: HLResultVariant, currency: HDKCurrency, font: UIFont) -> NSAttributedString {
        return self.attributedPriceString(with: variant, currency: currency, font: font, noPriceColor: nil)
    }

    class func attributedPriceString(with variant: HLResultVariant, currency: HDKCurrency, font: UIFont, noPriceColor color: UIColor?) -> NSAttributedString {
        if variant.rooms.count > 0 {
            return self.attributedPriceString(with: variant.minPrice, currency: currency, font: font)
        }
        else {
            let string: String = "—"
            var result = NSMutableAttributedString(string: string)
            result.addAttribute(NSFontAttributeName, value: font, range: NSRange(location: 0, length: (string.characters.count ?? 0)))
            if color != nil {
                result.addAttribute(NSForegroundColorAttributeName, value: color!, range: (NSRange(location: 0, length: (string.characters.count ?? 0))))
            }
            return result
        }
    }

    class func attributedPriceString(withPrice price: Float, currency: HDKCurrency, font: UIFont) -> NSAttributedString {
        let priceString = self.priceString(withPrice: price, currency: currency)
        var result = NSMutableAttributedString(string: priceString)
        result.addAttribute(NSFontAttributeName, value: font, range: NSRange(location: 0, length: (priceString.characters.count ?? 0)))
        return result
    }

// MARK: - URL handling
    class func params(fromUrlAbsoluteString urlString: String) -> [AnyHashable: Any] {
        var params: [Any] = urlString.components(separatedBy: "?")
        urlString = params.last
        params = urlString.components(separatedBy: "://")
        urlString = params.last
        var dict = [AnyHashable: Any]()
        let pairs: [Any] = urlString.components(separatedBy: "&")
        for pair: String in pairs {
            let elements: [Any] = pair.components(separatedBy: "=")
            if elements.count > 1 {
                let key: String? = elements[0] as? String ?? "".removingPercentEncoding
                let val: String? = elements[1] as? String ?? "".removingPercentEncoding
                dict[key] = val
            }
        }
        return dict
    }

    class func params(fromAppsFlyerString appsFlyerString: String) -> [AnyHashable: Any] {
        let paramsArray: [Any] = appsFlyerString.components(separatedBy: "-")
        if paramsArray.count < 5 {
            return [:]
        }
        let mapDict: [AnyHashable: Any] = [kAppsFlyerHotelKey: kAppsFlyerHolelIdKey, kAppsFlyerLocationKey: kAppsFlyerLocationIdKey, kAppsFlyerIataKey: kAppsFlyerIataIdKey]
        let type: String = paramsArray[0]
        let identifier: String = paramsArray[1]
        let checkInDateString: String = paramsArray[2]
        let checkOutDateString: String = paramsArray[3]
        let adultsCount: String = paramsArray[4]
        let identifierName: String = mapDict[type]
        if identifierName == "" {
            return [:]
        }
        var params = [AnyHashable: Any]()
        params[identifierName] = identifier
        params[kAppsFlyerCheckInKey] = self.dateString(fromAppsFlyerString: checkInDateString)
        params[kAppsFlyerCheckOutKey] = self.dateString(fromAppsFlyerString: checkOutDateString)
        params[kAppsFlyerAdultsKey] = adultsCount
        return params
    }

// MARK: - Distance formatting
    class func attributedDistanceString(_ meters: CGFloat) -> NSAttributedString {
        return self.attributedDistanceString(meters, textColor: JRColorScheme.lightText, number: JRColorScheme.darkText)
    }

    class func attributedDistanceString(_ meters: CGFloat, textColor: UIColor, number numberColor: UIColor) -> NSAttributedString {
        let textFont = UIFont.systemFont(ofSize: 12.0)
        let numberFont = UIFont.systemFont(ofSize: 12.0)
        let valueString: String = StringUtils.roundedDistance(withMeters: meters)
        let attrValueString = NSAttributedString(string: valueString)
        let str: String = "\(NSLS("HL_LOC_FILTER_TO_STRING")) \("lowerValue")"
        var result = NSMutableAttributedString(string: str)
        result.addAttribute(NSFontAttributeName, value: textFont, range: NSRange(location: 0, length: (str.characters.count ?? 0)))
        result.addAttribute(NSForegroundColorAttributeName, value: textColor, range: NSRange(location: 0, length: (str.characters.count ?? 0)))
        result.replaceCharacters(in: (result.string as NSString).range(of: "lowerValue"), with: attrValueString)
        result.addAttribute(NSForegroundColorAttributeName, value: numberColor, range: (result.string as NSString).range(of: attrValueString.string))
        result.addAttribute(NSFontAttributeName, value: numberFont, range: (result.string as NSString).range(of: attrValueString.string))
        return result
    }

    class func roundedDistance(withMeters meters: CGFloat) -> String {
        var result: String? = nil
        if !HLLocaleInspector.shouldUseMetricSystem() || meters >= 1000 {
            result = self.shortDistanceString(withKilometers: meters / 1000.0)
        }
        else {
            meters = 10 * round(meters / 10.0)
            result = "%.f \(meters)"
        }
        return result!
    }

// MARK: - Points Name formatting
    class func locationPointName(_ point: HDKLocationPoint?) -> String {
        if (point? is HLCityLocationPoint) {
            var cityCenterString: String? = point?.name
            if (cityCenterString?.characters.count ?? 0) > 0 {
                cityCenterString = cityCenterString?.hl_firstLetterCapitalized()
            }
            return "\(cityCenterString) (\(point as? HLCityLocationPoint)?.cityName())"!
        }
        return self.capitalizedFirstLetterString(point?.name)!
    }

    class func guestsDescription(withGuestsCount count: Int) -> String {
        let format: String = NSLSP("HL_LOC_GUEST", count)
        let text: String = "\(Int(count)) \(format)"
        return text
    }

    class func adultGuestsDescription(withCount adultsCount: Int) -> String {
        if adultsCount > 0 {
            let adultLocString: String = NSLSP("HL_LOC_GUEST_ADULT", adultsCount)
            return "\(Int(adultsCount)) \(adultLocString)"
        }
        else {
            return ""
        }
    }

    class func childGuestsDescription(withCount kidsCount: Int) -> String {
        if kidsCount > 0 {
            let kidsLocString: String = NSLSP("HL_LOC_GUEST_KID", kidsCount)
            return "\(Int(kidsCount)) \(kidsLocString)"
        }
        else {
            return ""
        }
    }

// MARK: - Hotels
    class func hotelAddress(forHotel hotel: HDKHotel?) -> String {
        let addressString: String = hotel?.address ?? ""
        let detailsString: String = self.hotelAddressDetails(hotel) ?? ""
        var result: String = addressString
        if (result.characters.count ?? 0) > 0 && (detailsString.characters.count ?? 0) > 0 {
            result += ", \(detailsString)"
        }
        else {
            result += detailsString
        }
        return result
    }

    class func hotelAddressDetails(_ hotel: HDKHotel?) -> String? {
        let districtName: String? = hotel?.firstDistrictName
        if (districtName?.characters.count ?? 0) == 0 {
            return nil
        }
        let cityName: String? = self.cityName(hotel?.city)
        return (cityName?.characters.count ?? 0) > 0 ? "\(districtName), \(cityName)" : districtName
    }

    class func checkInTime(from date: Date) -> String {
        return "\(NSLS("HL_LOC_CHECKIN_AFTER")) \(self.timeString(from: date))"
    }

    class func checkOutTime(from date: Date) -> String {
        return "\(NSLS("HL_LOC_CHECKOUT_BEFORE")) \(self.timeString(from: date))"
    }

    class func accommodationSummaryCheckInString(for date: Date, shortMonth: Bool) -> String {
        let dateString = self.accommodationSummaryDateString(for: date, shortMonth: shortMonth, locale: NSLocale.currentLocale)
        return "\(NSLS("HL_HOTEL_DETAIL_INFORMATION_CHECKIN")) \(dateString)"
    }

    class func accommodationSummaryCheckOutString(for date: Date, shortMonth: Bool) -> String {
        let dateString = self.accommodationSummaryDateString(for: date, shortMonth: shortMonth, locale: NSLocale.currentLocale)
        return "\(NSLS("HL_HOTEL_DETAIL_INFORMATION_CHECKOUT")) \(dateString)"
    }

    class func defaultDestinationString(by searchInfo: HLSearchInfo) -> String {
        var result: String? = nil
        switch searchInfo.searchInfoType {
            case HLSearchInfoTypeHotel:
                result = searchInfo.hotel.name
            case HLSearchInfoTypeCity:
                let name: String? = StringUtils.cityName(searchInfo.city)
                if (name?.characters.count ?? 0) > 0 {
                    result = name
                }
                else {
                    result = NSLS("HL_LOC_CITY_PLACEHOLDER_TEXT")
                }
            case HLSearchInfoTypeCityCenterLocation:
                let name: String? = StringUtils.cityName(searchInfo.locationPoint.city) ?? ""
                result = String(format: NSLS("HL_LOC_NEARBY_CITIES_SEARCH_DESTINATION_TEXT"), name)
            case HLSearchInfoTypeCustomLocation:
                result = NSLS("HL_LOC_POINT_ON_MAP_TEXT")
            case HLSearchInfoTypeAirport:
                result = searchInfo.locationPoint.title
            default:
                break
        }

        return result!
    }

    class func shortDateDescription(_ date: Date, localeIdentifier: String) -> String {
        if !date {
            return "…"
        }
        let locale = NSLocale(localeIdentifier: localeIdentifier)
        let formatter: DateFormatter? = HDKDateUtil.standardFormatter()
        formatter?.locale = locale as? Locale ?? Locale()
        var dayDesc: String? = nil
        let indexToSubString: Int = min(2, (localeIdentifier.characters.count ?? 0))
        let lang: String? = (localeIdentifier as? NSString)?.substring(to: indexToSubString)
        let useExtendedDescription: Bool = HLLocaleInspector.shared().isLanguageRussian(lang) || iPhone47Inch() || iPhone55Inch()
        var template: String = useExtendedDescription ? "EEdMMMM" : "EEdMMM"
        template = DateFormatter.dateFormat(fromTemplate: template, options: [], locale: locale as? Locale ?? Locale())
        formatter?.dateFormat = template
        dayDesc = formatter?.string(from: date)
        return dayDesc!
    }

    class func ipadShortDateDescription(_ date: Date, localeIdentifier: String) -> String {
        let formatter: DateFormatter? = HDKDateUtil.standardFormatter()
        formatter?.locale = NSLocale(localeIdentifier: localeIdentifier)
        formatter?.dateStyle = .short
        return formatter?.string(from: date)!
    }

    class func shortDateDescription(_ date: Date) -> String {
        let lang: String = NSLocale.currentLocale.localeIdentifier
        return self.shortDateDescription(date, localeIdentifier: lang)
    }

    class func datesDescriptionWithCheck(in checkIn: Date, checkOut: Date, localeIdentifier lang: String) -> String {
        return "\(self.shortDateDescription(checkIn, localeIdentifier: lang)) – \(self.shortDateDescription(checkOut, localeIdentifier: lang))"
    }

    class func ipadDatesDescriptionWithCheck(in checkIn: Date, checkOut: Date, localeIdentifier lang: String) -> String {
        return "\(self.ipadShortDateDescription(checkIn, localeIdentifier: lang)) – \(self.ipadShortDateDescription(checkOut, localeIdentifier: lang))"
    }

    class func bestPriceString(withDays days: Int) -> String {
        let duration: String = StringUtils.durationDescription(withDays: days)
        return "\(NSLS("HL_HOTEL_DETAIL_CTA_HEADER_TITLE"))\(duration)"
    }

// MARK: - CheckInOut Date formatting
    class func shortCheck(inOutDateAndTime time: Date, locale: NSLocale, timePrefix: String) -> String {
        let dateFormatter: DateFormatter? = HDKDateUtil.standardFormatter()
        dateFormatter?.dateFormat = "dd MMM"
        dateFormatter?.locale = locale
        let dateString: String? = dateFormatter?.string(from: time)
        let timeFormatter: DateFormatter? = HDKDateUtil.standardFormatter()
        timeFormatter?.timeStyle = .short
        timeFormatter?.dateStyle = .none
        timeFormatter?.locale = locale
        let timeString: String? = timeFormatter?.string(from: time)
        return "\(dateString), \(timePrefix) \(timeString)"
    }

    class func longCheck(inOutDateAndTime time: Date, locale: NSLocale, timePrefix: String) -> String {
        let shortString: String = self.shortCheck(inOutDateAndTime: time, locale: locale, timePrefix: timePrefix)
        let formatter: DateFormatter? = HDKDateUtil.standardFormatter()
        formatter?.dateFormat = "EEEE"
        formatter?.locale = locale as? Locale ?? Locale()
        let dayOfWeek: String? = formatter?.string(from: time)
        return "\(dayOfWeek), \(shortString)"
    }

// MARK: -

// MARK: - Price Formatting

// MARK: - URL handling

    class func dateString(fromAppsFlyerString appsFlyerString: String) -> String {
        var result: String? = nil
        if (appsFlyerString.characters.count ?? 0) == 8 {
            let day: String = (appsFlyerString as NSString).substring(with: NSRange(location: 0, length: 2))
            let month: String = (appsFlyerString as NSString).substring(with: NSRange(location: 2, length: 2))
            let year: String = (appsFlyerString as NSString).substring(with: NSRange(location: 4, length: 4))
            result = "\(year)-\(month)-\(day)"
        }
        return result!
    }

// MARK: - Distance formatting

    class func distanceUnitAbbreviation() -> String {
        return HLLocaleInspector.shouldUseMetricSystem() ? NSLS("HL_LOC_KILOMETERS_ABBREVIATION") : NSLS("HL_LOC_MILES_ABBREVIATION")
    }

    class func shortDistanceString(withKilometers distance: CGFloat) -> String {
        let unitAbbreviation: String = self.distanceUnitAbbreviation()
        if !HLLocaleInspector.shouldUseMetricSystem() {
            distance = HLDistanceCalculator.convertKilometers(toMiles: distance)
        }
        let result: String = "%.1f \(distance)"
        return result
    }

// MARK: - Points Name formatting

    class func capitalizedFirstLetterString(_ string: String) -> String {
        if (string.characters.count ?? 0) == 0 {
            return string
        }
        return "\(string as? NSString)?.substring(to: 1)?.uppercased()\(string as? NSString)?.substring(from: 1)"!
    }

// MARK: - Hotels

    class func timeString(from date: Date) -> String {
        return self.timeString(from: date, locale: NSLocale.currentLocale)
    }

    class func timeString(from date: Date, locale: NSLocale) -> String {
        let timeFormatter: DateFormatter? = HDKDateUtil.standardFormatter()
        timeFormatter?.timeStyle = .short
        timeFormatter?.dateStyle = .none
        timeFormatter?.locale = locale
        return timeFormatter?.string(from: date)!
    }

    class func accommodationSummaryDateString(for date: Date, shortMonth: Bool, locale: NSLocale) -> String {
        let dateFormatter: DateFormatter? = HDKDateUtil.standardFormatter()
        dateFormatter?.dateFormat = "d \(shortMonth ? "MMM" : "MMMM"), EE"
        dateFormatter?.locale = locale
        return dateFormatter?.string(from: date)!
    }
}