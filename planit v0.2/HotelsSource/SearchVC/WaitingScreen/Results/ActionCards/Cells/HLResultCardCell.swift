//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import UIKit

class HLResultCardCell: UICollectionViewCell {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    private var _item: HLActionCardItem?
    var item: HLActionCardItem? {
        get {
            return _item
        }
        set(item) {
            slider.removeTarget(self, action: nil, for: .allEvents)
            _item = item
            if self.item.topItem {
                closeButton.isHidden = true
                applyButton.isHidden = true
                slider.addTarget(self, action: #selector(self.apply), for: .touchCancel)
                slider.addTarget(self, action: #selector(self.apply), for: .touchUpInside)
                slider.addTarget(self, action: #selector(self.apply), for: .touchUpOutside)
                slider.addTarget(self, action: #selector(self.sliderValueChanged), for: .valueChanged)
            }
            else {
                closeButton.isHidden = false
                applyButton.isHidden = false
                slider.addTarget(self, action: #selector(self.sliderValueChanged), for: .valueChanged)
            }
            setup(withFilter: item.filter)
        }
    }
    var textColor: UIColor?
    var numberColor: UIColor?

    func setup(with filter: Filter) {
    }

    @IBAction func close() {
        item.delegate?.actionCardItemClosed(item)
    }

    @IBAction func apply() {
    }

    func sliderValueChanged() {
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        textColor = JRColorScheme.lightText
        numberColor = JRColorScheme.darkText
        applyButton.setTitleColor(JRColorScheme.darkText, for: .normal)
        applyButton.setTitleColor(JRColorScheme.lightText, for: .disabled)
        applyButton.setTitle(NSLS("HL_LOC_ACTION_CARD_APPLY_BUTTON"), for: .normal)
        slider.setMaximumTrackImage(JRColorScheme.sliderMinImage(), for: .normal)
        slider.setMinimumTrackImage(JRColorScheme.sliderMaxImage(), for: .normal)
        slider.setThumbImage(UIImage(named: "JRSliderImg"), for: .normal)
    }
}