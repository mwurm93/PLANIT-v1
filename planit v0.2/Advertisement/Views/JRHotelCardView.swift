//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRHotelCardView.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 14.06.17.
//  Copyright © 2017 Go Travel Un LImited. All rights reserved.
//

import UIKit

class JRHotelCardView: UIView {
    var buttonAction: ((_: Void) -> Void)? = nil

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

// MARK: - Setup
    func setupView() {
        backgroundColor = JRColorScheme.mainBackgroundColor()
        containerView.layer?.cornerRadius = 6.0
        setupLabels()
        setupActionButton()
    }

    func setupLabels() {
        titleLabel.text = NSLS("JR_SEARCH_RESULTS_HOTEL_CARD_TITLE")
        titleLabel.textColor = JRColorScheme.darkText
        subtitleLabel.text = NSLS("JR_SEARCH_RESULTS_HOTEL_CARD_SUBTITLE")
        subtitleLabel.textColor = JRColorScheme.darkText
    }

    func setupActionButton() {
        actionButton.layer.borderWidth = 1.0
        actionButton.layer.cornerRadius = 4.0
        actionButton.layer.borderColor = JRColorScheme.navigationBarBackgroundColor().cgColor
        actionButton.setTitle(NSLS("JR_SEARCH_RESULTS_HOTEL_CARD_BUTTON_TITLE"), for: .normal)
    }

// MARK: - Actions
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        if buttonAction != nil {
            buttonAction()
        }
    }
}