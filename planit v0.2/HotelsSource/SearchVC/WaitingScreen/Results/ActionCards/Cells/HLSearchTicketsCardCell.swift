//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import HotellookSDK

class HLSearchTicketsCardCell: HLResultCardCell {
    @IBOutlet weak var searchTicketsButton: UIButton!
    @IBOutlet weak var searchTicketsDescriptionLabel: UILabel!

    @IBAction func searchTicketsAction() {
        item.delegate?.searchTickets()
        item.delegate?.actionCardItemClosed(item)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        searchTicketsButton.titleLabel.font = UIFont.systemFont(ofSize: 15.0)
        searchTicketsButton.setTitleColor(JRColorScheme.mainButtonBackgroundColor(), for: .normal)
        searchTicketsButton.setTitle(NSLS("HL_TICKETS_SEARCH_CELL_BUTTON"), for: .normal)
        searchTicketsDescriptionLabel.text = NSLS("HL_TICKETS_SEARCH_CELL_TITLE")
    }
}