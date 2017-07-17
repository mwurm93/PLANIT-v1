//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFilterListCell.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//
//
//  JRFilterCheckboxCell.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import AXRatingView

class JRFilterCheckboxCell: UITableViewCell {
    var averageRateView: AXRatingView?
    @IBOutlet weak var selectedIndicator: UIButton!
    @IBOutlet weak var listItemLabel: UILabel!
    @IBOutlet weak var listItemDetailLabel: UILabel!
    @IBOutlet weak var averageRateViewContainer: UIView!
    private var _item: JRFilterCheckBoxItem?
    var item: JRFilterCheckBoxItem? {
        get {
            return _item
        }
        set(item) {
            _item = item
            checked = item.isSelected
            averageRateView?.isHidden = !item.showAverageRate
            averageRateView?.value = item.rating
            listItemLabel.text = item.tilte
            listItemDetailLabel.attributedText = item.attributedStringValue
            selectedIndicator.isSelected = item.isSelected
        }
    }
    private var _isChecked: Bool = false
    var isChecked: Bool {
        get {
            return _isChecked
        }
        set(checked) {
            _isChecked = checked
            selectedIndicator.isSelected = checked
            item.isSelected = checked
            item.filterAction()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset = UIEdgeInsetsMake(0.0, 44.0, 0.0, 0.0)
        listItemLabel.numberOfLines = 3
        listItemDetailLabel.textColor = JRColorScheme.darkText
        averageRateView = AXRatingView()
        averageRateView?.markFont = UIFont.systemFont(ofSize: 15)
        averageRateView?.baseColor = JRColorScheme.ratingStarDefaultColor()
        averageRateView?.highlightColor = JRColorScheme.ratingStarSelectedColor()
        averageRateView?.numberOfStar = 5
        averageRateView?.isUserInteractionEnabled = false
        averageRateView?.frame = averageRateViewContainer.bounds
        averageRateViewContainer.addSubview(averageRateView!)
        averageRateViewContainer.backgroundColor = UIColor.clear
        selectedIndicator.tintColor = JRColorScheme.navigationBarBackgroundColor()
    }

//- mark Public methds
}