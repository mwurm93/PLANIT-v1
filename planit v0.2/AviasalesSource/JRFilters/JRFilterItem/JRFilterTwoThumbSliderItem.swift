//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFilterTwoThumbSliderItem.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

class JRFilterTwoThumbSliderItem: NSObject, JRFilterItemProtocol {
    private(set) var minValue = TimeInterval()
    private(set) var maxValue = TimeInterval()
    var isNeedDayTimeShowButtons: Bool {
        return false
    }
    var currentMinValue = TimeInterval()
    var currentMaxValue = TimeInterval()
    var filterAction: (() -> Void)? = nil

    init(minValue: TimeInterval, maxValue: TimeInterval, currentMinValue: TimeInterval, currentMaxValue curentMaxValue: TimeInterval) {
        super.init()
        
        self.minValue = minValue
        self.maxValue = maxValue
        self.currentMinValue = currentMinValue
        currentMaxValue = curentMaxValue
    
    }

//- mark JRFilterItemProtocol
    func tilte() -> String {
        return ""
    }

    func attributedStringValue() -> NSAttributedString {
        return NSAttributedString(string: "")
    }
}

class JRFilterDelaysDurationItem: JRFilterTwoThumbSliderItem {
//- mark JRFilterItemProtocol

    func tilte() -> String {
        return NSLS("JR_FILTER_DELAY_DURATION")
    }

    func attributedStringValue() -> NSAttributedString {
        let minTimeString: String = DateUtil.duration(currentMinValue, durationStyle: JRDateUtilDurationLongStyle)
        let maxTimeString: String = DateUtil.duration(currentMaxValue, durationStyle: JRDateUtilDurationLongStyle)
        let text: String = "\(NSLS("JR_FILTER_TOTAL_DURATION_FROM")) \(minTimeString) \n \(NSLS("JR_FILTER_TOTAL_DURATION_PRIOR_UP_TO")) \(maxTimeString)"
        return NSAttributedString(string: text)
    }
}

class JRFilterArrivalTimeItem: JRFilterTwoThumbSliderItem {
    var isReturn: Bool = false

//- mark JRFilterItemProtocol

    func tilte() -> String {
        return isReturn ? NSLS("JR_FILTER_RETURN_ARRIVAL_TIME") : NSLS("JR_FILTER_ARRIVAL_TIME")
    }

    func attributedStringValue() -> NSAttributedString {
        let minTime: String = DateUtil.date(toTimeString: Date(timeIntervalSince1970: currentMinValue))
        let maxTime: String = DateUtil.date(toTimeString: Date(timeIntervalSince1970: currentMaxValue))
        let minDate = DateUtil.dayMonthString(fromDate: Date(timeIntervalSince1970: currentMinValue))
        let maxDate = DateUtil.dayMonthString(fromDate: Date(timeIntervalSince1970: currentMaxValue))
        let text: String = "\(NSLS("JR_FILTER_TOTAL_TIME_FROM")) \(minTime) \(minDate) \n \(NSLS("JR_FILTER_TOTAL_DURATION_PRIOR_TO")) \(maxTime) \(maxDate)"
        return NSAttributedString(string: text)
    }
}

class JRFilterDepartureTimeItem: JRFilterTwoThumbSliderItem {
    var isReturn: Bool = false

    func needDayTimeShowButtons() -> Bool {
        return true
    }

//- mark JRFilterItemProtocol
    func tilte() -> String {
        return isReturn ? NSLS("JR_FILTER_RETURN_DEPARTURE_TIME") : NSLS("JR_FILTER_DEPARTURE_TIME")
    }

    func attributedStringValue() -> NSAttributedString {
        let minDate: String = DateUtil.date(toTimeString: Date(timeIntervalSince1970: currentMinValue))
        let maxDate: String = DateUtil.date(toTimeString: Date(timeIntervalSince1970: currentMaxValue))
        let text: String = "\(NSLS("JR_FILTER_TOTAL_TIME_FROM")) \(minDate) \n \(NSLS("JR_FILTER_TOTAL_DURATION_PRIOR_TO")) \(maxDate)"
        return NSAttributedString(string: text)
    }
}