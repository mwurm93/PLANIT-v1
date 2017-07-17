//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import HotellookSDK

class HLProfileCurrencyCell: HLProfileCell {
    @IBOutlet weak var currencyLabel: UILabel!

    override func setup(with item: HLProfileCurrencyItem) {
        super.setup(with: item)
        currencyLabel.text = item.currency.code
        currencyLabel.textColor = JRColorScheme.navigationBarBackgroundColor()
    }
}