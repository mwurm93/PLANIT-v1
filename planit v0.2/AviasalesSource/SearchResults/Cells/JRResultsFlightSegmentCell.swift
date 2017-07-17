//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRResultsFlightSegmentCell.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import AviasalesSDK
import UIKit

private let kCellHeight: CGFloat = 25
private let kSmallDepartureDateLeading: CGFloat = 15
private let kSmallFlightDurationTrailing: CGFloat = 9
private let kDepartureDateLeading: CGFloat = 21
private let kFlightDurationTrailing: CGFloat = 19

class JRResultsFlightSegmentCell: UITableViewCell {
    private var _flightSegment: JRSDKFlightSegment?
    var flightSegment: JRSDKFlightSegment? {
        get {
            return _flightSegment
        }
        set(flightSegment) {
            _flightSegment = flightSegment
            let firstFlight: JRSDKFlight? = flightSegment.flights.first
            let lastFlight: JRSDKFlight? = flightSegment.flights.last
            departureDateLabel.text = DateUtil.date(toDateString: firstFlight?.departureDate)
            let departureTime: String? = DateUtil.date(toTimeString: firstFlight?.departureDate)
            let arrivalTime: String? = DateUtil.date(toTimeString: lastFlight?.arrivalDate)
            let departureIATA: JRSDKIATA? = firstFlight?.originAirport?.iata
            let arrivalIATA: JRSDKIATA? = lastFlight?.destinationAirport?.iata
            departureLabel.text = "\(departureTime) \(departureIATA)"
            arrivingLabel.text = "\(arrivalTime) \(arrivalIATA)"
            let flightsCount: Int = flightSegment.flights.count
            if flightsCount == 1 {
                stopoverNumberLabel.isHidden = true
            }
            else {
                stopoverNumberLabel.isHidden = false
                stopoverNumberLabel.text = "\(Int(flightsCount - 1))"
            }
            flightDurationLabel.text = DateUtil.duration(flightSegment.totalDurationInMinutes(), durationStyle: JRDateUtilDurationShortStyle)
        }
    }
    private var _layoutParameters: JRSearchResultsFlightSegmentCellLayoutParameters?
    var layoutParameters: JRSearchResultsFlightSegmentCellLayoutParameters? {
        get {
            return _layoutParameters
        }
        set(layoutParameters) {
            _layoutParameters = layoutParameters
            departureDateWidth.constant = self.layoutParameters.departureDateWidth
            departureLabelWidth.constant = self.layoutParameters.departureLabelWidth
            arrivalLabelWidth.constant = self.layoutParameters.arrivalLabelWidth
            flightDurationWidth.constant = self.layoutParameters.flightDurationWidth
        }
    }

    @IBOutlet weak var departureDateLabel: UILabel!
    @IBOutlet weak var departureLabel: UILabel!
    @IBOutlet weak var stopoverNumberLabel: UILabel!
    @IBOutlet weak var arrivingLabel: UILabel!
    @IBOutlet weak var flightDurationLabel: UILabel!
    //Constraints
    @IBOutlet weak var departureDateWidth: NSLayoutConstraint!
    @IBOutlet weak var departureLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var arrivalLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var flightDurationWidth: NSLayoutConstraint!
    @IBOutlet weak var flightDurationTrailing: NSLayoutConstraint!
    @IBOutlet weak var departureDateLeading: NSLayoutConstraint!

// MARK: - Getters

    class func nibFileName() -> String {
        return "JRResultsFlightSegmentCell"
    }

    class func height() -> CGFloat {
        return kCellHeight
    }

    override func updateConstraints() {
        if bounds.size.width < 360 {
            departureDateLeading.constant = kSmallDepartureDateLeading
            flightDurationTrailing.constant = kSmallFlightDurationTrailing
        }
        else {
            departureDateLeading.constant = kDepartureDateLeading
            flightDurationTrailing.constant = kFlightDurationTrailing
        }
        super.updateConstraints()
    }

// MARK: - Setters
    override func setFrame(_ frame: CGRect) {
        let needToUpdateConstraints: Bool = frame.size.width != self.frame.size.width
        super.frame = frame
        if needToUpdateConstraints {
            setNeedsUpdateConstraints()
        }
    }
}