//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFlightCell.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class JRFlightCell: UITableViewCell, JRTicketCellProtocol {
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var logoIcon: UIImageView!
    @IBOutlet weak var flightNumberLabel: UILabel!
    @IBOutlet weak var departureTimeLabel: UILabel!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var departureDateLabel: UILabel!
    @IBOutlet weak var arrivalDateLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!

    class func flightNumberFormatter() -> NumberFormatter {
        var flightNumberFormatter: NumberFormatter?
        var onceToken: Int
        if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
            flightNumberFormatter = NumberFormatter()
            flightNumberFormatter?.groupingSize = 0
        }
        onceToken = 1
        return flightNumberFormatter!
    }

    class func dateFormatter() -> DateFormatter {
        var dateFormatter: DateFormatter?
        var onceToken: Int
        if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
            dateFormatter = DateFormatter.applicationUI()
            dateFormatter?.dateFormat = DateFormatter.dateFormat(fromTemplate: "d MMM, EE", options: kNilOptions, locale: dateFormatter?.locale)
        }
        onceToken = 1
        return dateFormatter!
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = UIEdgeInsetsMake(0.0, bounds.size.width, 0.0, 0.0)
    }

// MARK: Private methods
    func downloadAndSetupImage(for logo: UIImageView, for airline: JRSDKAirline) {
        let scale: CGFloat = UIScreen.main.scale()
        let size: CGSize = logoIcon.bounds.size.applying(CGAffineTransform(scaleX: scale, y: scale))
        let url = URL(string: JRSDKModelUtils.airlineLogoUrl(withIATA: airline.iata, size: size))
        logo.image = nil
        logo.highlightedImage = nil
        logo.isHidden = true
        logo.sd_setImage(with: url, placeholderImage: nil, completed: {(_ image: UIImage, _ error: Error?, _ cacheType: SDImageCacheType, _ imageURL: URL) -> Void in
            logo.isHidden = (error != nil)
        })
    }

// MARK: JRTicketCellProtocol methods
    func apply(_ flight: JRSDKFlight) {
        durationLabel.text = "\(AVIASALES_("JR_TICKET_DURATION")): \(DateUtil.duration(CInt(flight.duration), durationStyle: JRDateUtilDurationShortStyle))"
        departureTimeLabel.text = DateUtil.date(toTimeString: flight.departureDate)
        arrivalTimeLabel.text = DateUtil.date(toTimeString: flight.arrivalDate)
        departureDateLabel.text = JRFlightCell.dateFormatter().string(from: flight.departureDate)
        arrivalDateLabel.text = JRFlightCell.dateFormatter().string(from: flight.arrivalDate)
        originLabel.text = "\(flight.originAirport.city) \(flight.originAirport.iata)"
        destinationLabel.text = "\(flight.destinationAirport.city) \(flight.destinationAirport.iata)"
        let flightNumber = JRFlightCell.flightNumberFormatter().number(from: flight.number)
        flightNumberLabel.text = String.localizedString(withFormat: "%@ %@-%@", AVIASALES_("JR_TICKET_FLIGHT"), flight.airline.iata, JRFlightCell.flightNumberFormatter().string(from: flightNumber!))
        downloadAndSetupImage(for: logoIcon, for: flight.airline)
    }
}