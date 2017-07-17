//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import HotellookSDK

class HLProfileCurrencyItem: HLProfileTableItem {
    var currency: HDKCurrency?

    override init(title: String, action: ProfileItemAction, active: Bool) {
        super.init(title: title, action: action, active: active)

        cellIdentifier = HLProfileCurrencyCell.hl_reuseIdentifier()
    
    }
}