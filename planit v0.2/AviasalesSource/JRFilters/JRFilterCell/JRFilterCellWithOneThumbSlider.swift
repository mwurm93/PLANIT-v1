//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  ASFilterCellWithOneThumbSlider.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//
//
//  ASFilterCellWithOneThumbSlider.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

class JRFilterCellWithOneThumbSlider: UITableViewCell {
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellAttLabel: UILabel!
    @IBOutlet weak var cellSlider: UISlider!
    private var _item: JRFilterOneThumbSliderItem?
    var item: JRFilterOneThumbSliderItem? {
        get {
            return _item
        }
        set(item) {
            _item = item
            cellSlider.minimumValue = item.minValue
            cellSlider.maximumValue = item.maxValue
            cellSlider.value = item.currentValue
            cellAttLabel.attributedText = item.attributedStringValue
            cellLabel.text = item.tilte()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset = UIEdgeInsetsMake(0.0, 21.0, 0.0, 0.0)
        cellSlider.tintColor = JRColorScheme.navigationBarBackgroundColor()
        cellLabel.textColor = JRColorScheme.darkText
        cellAttLabel.textColor = JRColorScheme.darkText
    }

// MARK: - Public methds

// MARK: - Actions
    @IBAction func valueDidChanged(_ sender: Any) {
        item.currentValue = cellSlider.value
        item.filterAction()
        cellAttLabel.attributedText = item.attributedStringValue
    }
}