//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRAirportPickerCellWithInformation.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//
//
//  JRAirportPickerCellWithInformation.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class JRAirportPickerCellWithInfo: JRTableViewCell {
    @IBOutlet weak var locationInfoLabel: UILabel!

    @IBOutlet weak var labelHorizontConstaint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    func startActivityIndicator() {
        activityIndicatorView.startAnimating()
        labelHorizontConstaint.constant = kJRAirportPickerCellWithInfoEnabledActivityIndicatorHorizontalSpace
    }

    func stopActivityIndicator() {
        activityIndicatorView.stopAnimating()
        labelHorizontConstaint.constant = kJRAirportPickerCellWithInfoDisabledActivityIndicatorHorizontalSpace
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        locationInfoLabel.text = NSLS("JR_AIRPORT_PICKER_SEARCHING_ON_SERVER_TEXT")
    }
}

let kJRAirportPickerCellWithInfoDisabledActivityIndicatorHorizontalSpace = 20
let kJRAirportPickerCellWithInfoEnabledActivityIndicatorHorizontalSpace = 48