//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation

class HLVariantPhotoCell: HLVariantCollectionViewCell {
    @IBOutlet weak var bottomGradientView: UIImageView!
    @IBOutlet weak var photoView: HLPhotoView!

    override func setup(with item: HLVariantItem) {
        super.setup(with: item)
        let placeholder = UIImage.photoPlaceholder()
        if self.item.variant.hotel.photosIds.count > 0 {
            let url = HLUrlUtils.firstHotelPhotoURL(byHotel: self.item.variant.hotel, withSizeInPoints: bounds.size)
            photoView.setImageWith(url, placeholder: placeholder, animated: true)
        }
        else {
            photoView.imageContentMode = .center
            photoView.setImage(placeholder, needDelay: false, animated: true)
        }
    }

    override func initialize() {
        super.initialize()
        photoView.imageContentMode = .scaleAspectFill
        photoView.placeholderContentMode = .center
    }

    override func resetContent() {
        super.resetContent()
        photoView.reset()
    }

// MARK: - HLGestureRecognizerDelegate methods
    override func recognizerFinished() {
        super.recognizerFinished()
        selectionHandler(item.variant, 0)
    }
}