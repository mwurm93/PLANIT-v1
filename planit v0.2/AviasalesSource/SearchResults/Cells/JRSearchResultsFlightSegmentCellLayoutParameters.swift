//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRSearchResultsFlightSegmentCellLayoutParameters.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

class JRSearchResultsFlightSegmentCellLayoutParameters: NSObject {
    private(set) var departureDateWidth: CGFloat = 0.0
    private(set) var departureLabelWidth: CGFloat = 0.0
    private(set) var arrivalLabelWidth: CGFloat = 0.0
    private(set) var flightDurationWidth: CGFloat = 0.0

    convenience init(tickets: [JRSDKTicket], font: UIFont) {
        var departureDateWidth: CGFloat = 0
        var departureLabelWidth: CGFloat = 0
        var arrivalLabelWidth: CGFloat = 0
        var flightDurationWidth: CGFloat = 0
        let computer = JRStringsWidthComputer(font: font)
        for ticket: JRSDKTicket in tickets {
            for flightSegment: JRSDKFlightSegment in ticket.flightSegments {
                let firstFlight: JRSDKFlight? = flightSegment.flights.first
                let lastFlight: JRSDKFlight? = flightSegment.flights.last
                let departureDate: String? = DateUtil.date(toDateString: firstFlight?.departureDate)
                let departureTime: String? = DateUtil.date(toTimeString: firstFlight?.departureDate)
                let arrivalTime: String? = DateUtil.date(toTimeString: lastFlight?.arrivalDate)
                let departureIATA: JRSDKIATA? = firstFlight?.originAirport?.iata
                let arrivalIATA: JRSDKIATA? = lastFlight?.destinationAirport?.iata
                let departureLabel: String = "\(departureTime) \(departureIATA)"
                let arrivalLabel: String = "\(arrivalTime) \(arrivalIATA)"
                let flightDuration: String = DateUtil.duration(flightSegment.totalDurationInMinutes(), durationStyle: JRDateUtilDurationShortStyle)
                departureDateWidth = max(departureDateWidth, computer.width(with: departureDate))
                departureLabelWidth = max(departureLabelWidth, computer.width(with: departureLabel))
                arrivalLabelWidth = max(arrivalLabelWidth, computer.width(with: arrivalLabel))
                flightDurationWidth = max(flightDurationWidth, computer.width(with: flightDuration))
            }
        }
        return JRSearchResultsFlightSegmentCellLayoutParameters(departureDateWidth: ceil(departureDateWidth), departureLabelWidth: ceil(departureLabelWidth), arrivalLabelWidth: ceil(arrivalLabelWidth), flightDurationWidth: ceil(flightDurationWidth))
    }

    init(departureDateWidth: CGFloat, departureLabelWidth: CGFloat, arrivalLabelWidth: CGFloat, flightDurationWidth: CGFloat) {
        super.init()

        self.departureDateWidth = departureDateWidth
        self.departureLabelWidth = departureLabelWidth
        self.arrivalLabelWidth = arrivalLabelWidth
        self.flightDurationWidth = flightDurationWidth
    
    }
}