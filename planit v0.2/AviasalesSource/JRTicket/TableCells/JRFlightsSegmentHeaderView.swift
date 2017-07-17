//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFlightsSegmentHeaderView.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class JRFlightsSegmentHeaderView: UITableViewHeaderFooterView {
    private var _flightSegment: JRSDKFlightSegment?
    var flightSegment: JRSDKFlightSegment? {
        get {
            return _flightSegment
        }
        set(flightSegment) {
            _flightSegment = flightSegment
            updateContent()
        }
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var separatorLineHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        separatorLineHeightConstraint.constant = 1.0 / UIScreen.main.scale()
        updateContent()
    }

// MARK: Public methods

// MARK: Private methods
    func updateContent() {
        if flightSegment == nil {
            return
        }
        let airports = [Any]() /* capacity: flightSegment.flights.count */
        airports.append(flightSegment.flights.first?.originAirport?.iata)
        for flight: JRSDKFlight in flightSegment.flights {
            airports.append(flight.destinationAirport.iata)
        }
        let originFlightSegment: String? = flightSegment.flights.first?.originAirport?.city
        let destinationFlightSegment: String? = flightSegment.flights.last?.destinationAirport?.city
        nameLabel.text = "\(originFlightSegment) - \(destinationFlightSegment)"
        directionLabel.text = (airports as NSArray).componentsJoined(byString: " • ")
        durationLabel.text = DateUtil.duration(flightSegment.totalDurationInMinutes, durationStyle: JRDateUtilDurationShortStyle)
    }
}