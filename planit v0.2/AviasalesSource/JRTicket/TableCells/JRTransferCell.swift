//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRTransferCell.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class JRTransferCell: UITableViewCell, JRTicketCellProtocol {
    @IBOutlet weak var verticalDivider: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!

    func apply(_ nextFlight: JRSDKFlight) {
        let delayString: String = DateUtil.duration(CInt(nextFlight.delay), durationStyle: JRDateUtilDurationShortStyle)
        durationLabel.text = "\(AVIASALES_("JR_TICKET_TRANSFER")): \(delayString)"
        placeLabel.text = "\(nextFlight.originAirport.city) \(nextFlight.originAirport.iata)"
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = UIEdgeInsetsMake(0.0, bounds.size.width, 0.0, 0.0)
    }

// MARK: JRTicketCellProtocol methods
}