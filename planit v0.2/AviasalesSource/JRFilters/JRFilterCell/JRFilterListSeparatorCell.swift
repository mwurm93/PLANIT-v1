//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFilterListSeparatorCell.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class JRFilterListSeparatorCell: UITableViewCell {
    @IBOutlet weak var separatorLabel: UILabel!
    private var _item: JRFilterListSeparatorItem?
    var item: JRFilterListSeparatorItem? {
        get {
            return _item
        }
        set(item) {
            _item = item
            separatorLabel.text = item.tilte()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = JRColorScheme.navigationBarBackgroundColor()
        backgroundColor = contentView.backgroundColor
    }
}