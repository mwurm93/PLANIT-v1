//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFilterTravelSegmentCell.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

class JRFilterTravelSegmentCell: UITableViewCell {
    @IBOutlet weak var flightDirectionLabel: UILabel!
    @IBOutlet weak var deparureDateLabel: UILabel!
    private var _item: JRFilterTravelSegmentItem?
    var item: JRFilterTravelSegmentItem? {
        get {
            return _item
        }
        set(item) {
            _item = item
            flightDirectionLabel.text = item.tilte()
            deparureDateLabel.text = item.detailsTitle()
        }
    }
}