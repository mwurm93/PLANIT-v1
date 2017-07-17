//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  ASTSimpleSearchFormAirportTableViewCell.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class ASTSimpleSearchFormAirportTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var iataLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.tintColor = JRColorScheme.searchFormTintColor()
    }
}