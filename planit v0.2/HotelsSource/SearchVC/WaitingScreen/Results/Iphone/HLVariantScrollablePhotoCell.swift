//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import UIKit

protocol HLShowHotelProtocol: NSObjectProtocol {
    func showFullHotelInfo(_ variant: HLResultVariant, visiblePhotoIndex: Int, indexChangedBlock block: @escaping (_ index: Int) -> Void, peeked: Bool)
}

class HLVariantScrollablePhotoCell: HLVariantCollectionViewCell, HLPhotoScrollViewDelegate {
    var visiblePhotoIndex: Int {
        get {
            return photoScrollView.currentPhotoIndex
        }
        set(index) {
            photoScrollView.scroll(toPhotoIndex: index, animated: false)
        }
    }
    private var _isScrollEnabled: Bool = false
    var isScrollEnabled: Bool {
        get {
            return photoScrollView.collectionView._isScrollEnabled
        }
        set(scrollEnabled) {
            photoScrollView.collectionView.isScrollEnabled = scrollEnabled
        }
    }

    @IBOutlet weak var photoScrollView: HLPhotoScrollView!

// MARK: - Public methods

    func resetContent() {
        let visibleCell: HLPhotoScrollCollectionCell? = (photoScrollView.visibleCell as? HLPhotoScrollCollectionCell)
        if (visibleCell? is HLPhotoScrollCollectionCell) {
            visibleCell?.photoView?.reset()
        }
        photoScrollView.collectionView.collectionViewLayout.invalidateLayout()
    }

    override func setup(with item: HLVariantItem) {
        super.setup(with: item)
        updatePhotosContent()
        visiblePhotoIndex = item.photoIndex
    }

    override func containerCollectionWillStartScroll() {
        super.containerCollectionWillStartScroll()
        photoScrollView.isUserInteractionEnabled = false
    }

    override func containerCollectionDidStopScroll() {
        super.containerCollectionDidStopScroll()
        photoScrollView.isUserInteractionEnabled = true
    }

    override func initialize() {
        super.initialize()
        photoScrollView.placeholderImage = UIImage.photoPlaceholder()
    }

// MARK: - Private methods
    func updatePhotosContent() {
        photoScrollView.delegate = self
        photoScrollView.backgroundColor = JRColorScheme.hotelBackgroundColor()
        photoScrollView.updateDataSource(withHotel: item.variant.hotel, imageSize: bounds.size, firstImage: nil)
        photoScrollView.relayoutContent()
    }

// MARK: - UIGestureRecognizerDelegate methods
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if photoScrollView.collectionView.isDecelerating || photoScrollView.collectionView.isDragging {
            return false
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }

// MARK: - HLGestureRecognizerDelegate methods
    override func recognizerFinished() {
        super.recognizerFinished()
        if selectionHandler != nil {
            selectionHandler(item.variant, visiblePhotoIndex)
        }
    }

// MARK: - HLPhotoCollectionViewDelegate methods
    func photoCollectionViewImageContentMode() -> UIViewContentMode {
        return (item.variant.hotel.photosIds.count == 0) ? .center : .scaleAspectFill
    }
}