//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import PureLayout
import UIKit

class HLMapGroupDetailsCell: UICollectionViewCell {
    private var _variant: HLResultVariant?
    var variant: HLResultVariant? {
        get {
            return _variant
        }
        set(variant) {
            _variant = variant
            let variantItem = HLVariantItem(variant: variant)
            variantView.setup(with: variantItem)
        }
    }
    weak var delegate: HLShowHotelProtocol?

    var variantView: HLVariantScrollablePhotoCell?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        variantView = LOAD_VIEW_FROM_NIB_NAMED("HLVariantScrollablePhotoCell")
        variantView?.isScrollEnabled = false
        weakify(self)
        variantView?.selectionHandler = {(_ variant: HLResultVariant, _ index: Int) -> Void in
            strongify(self)
            self.delegate?.showFullHotelInfo(self.variant, visiblePhotoIndex: index, indexChangedBlock: {(_ index: Int) -> Void in
                variantView?.visiblePhotoIndex = index
            }, peeked: false)
        }
        addSubview(variantView!)
        variantView?.autoPinEdgesToSuperviewEdges()
    
    }
}