//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
class HLPriceFilterCardCell: HLResultCardCell, PriceFilterViewDelegate {
    @IBOutlet weak var priceFilterView: PriceFilterView!

    override func awakeFromNib() {
        super.awakeFromNib()
        priceFilterView.delegate = self
    }

    override func setup(with filter: Filter) {
        super.setup(with: filter)
        priceFilterView.configure(with: filter)
    }

// MARK: - PriceFilterViewDelegate
    func filterApplied() {
        item.delegate?.filterUpdated(item.filter)
    }
}