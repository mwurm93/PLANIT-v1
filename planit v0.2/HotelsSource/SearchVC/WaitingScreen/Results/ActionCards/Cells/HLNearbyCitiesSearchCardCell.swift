//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import HotellookSDK

class HLNearbyCitiesSearchCardCell: HLResultCardCell {
    @IBOutlet weak var nearbyCitiesSearchButton: UIButton!
    @IBOutlet weak var nearbySearchDescriptionLabel: UILabel!

    @IBAction func nearbyCitiesSearchButtonPressed() {
        item.delegate?.nearbyCitiesSearchItemApplied(item)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        nearbyCitiesSearchButton.titleLabel.font = UIFont.systemFont(ofSize: 15.0)
        nearbyCitiesSearchButton.setTitleColor(JRColorScheme.mainButtonBackgroundColor(), for: .normal)
        nearbyCitiesSearchButton.setTitle(NSLS("HL_NEARBY_CITIES_SEARCH_CELL_BUTTON"), for: .normal)
    }

    override func setup(with filter: Filter) {
        super.setup(with: filter)
        nearbySearchDescriptionLabel.text = filter.searchResult.hasAnyRoomWithPrice() ? NSLS("HL_NEARBY_CITIES_SEARCH_CELL_FEW_DESCRIPTION") : NSLS("HL_NEARBY_CITIES_SEARCH_CELL_NOTHING_DESCRIPTION")
    }
}