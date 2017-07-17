//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFilterTravelSegmentItem.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

class JRFilterTravelSegmentItem: NSObject, JRFilterItemProtocol {
    private(set) var travelSegment: JRSDKTravelSegment?
    var filterAction: (() -> Void)? = nil

    init(travelSegment: JRSDKTravelSegment) {
        super.init()
        
        self.travelSegment = travelSegment
    
    }

//- mark JRFilterItemProtocol
    func tilte() -> String {
        return "\(travelSegment.originAirport.iata) – \(travelSegment.destinationAirport.iata)"
    }

    func detailsTitle() -> String {
        return DateUtil.fullDayMonthYearWeekdayString(from: travelSegment.departureDate)
    }

    func attributedStringValue() -> NSAttributedString {
        return NSAttributedString(string: "")
    }
}