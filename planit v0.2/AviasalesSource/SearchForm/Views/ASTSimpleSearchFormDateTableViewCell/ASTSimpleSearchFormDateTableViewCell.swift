//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  ASTSimpleSearchFormDateTableViewCell.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class ASTSimpleSearchFormDateTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var returnLabel: UILabel!
    var returnButtonAction: ((_ sender: UIButton) -> Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.tintColor = JRColorScheme.searchFormTintColor()
        returnButton.tintColor = JRColorScheme.searchFormTintColor()
        returnLabel.textColor = JRColorScheme.searchFormTintColor()
    }

    @IBAction func returnButtonTapped(_ sender: UIButton) {
        if returnButtonAction != nil {
            returnButtonAction(sender)
        }
    }
}