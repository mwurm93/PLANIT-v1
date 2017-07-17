//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import UIKit

typealias CellSelectionBlock = (_ variant: HLResultVariant, _ index: Int) -> Void
let kStarsOffset: CGFloat = 2.0
let kPriceTextFontSize: CGFloat = 16.0
let kPriceValueFontSize: CGFloat = 20.0

class HLVariantCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate, HLGestureRecognizerDelegate {
    private(set) var tapRecognizer: HLTapGestureRecognizer?
    private(set) var item: HLVariantItem?
    var selectionHandler = CellSelectionBlock()
    var isLazyLoadingContent: Bool = false
    private var _isBadgesEnabled: Bool = false
    var isBadgesEnabled: Bool {
        get {
            return _isBadgesEnabled
        }
        set(badgesEnabled) {
            _isBadgesEnabled = badgesEnabled
            if !_isBadgesEnabled {
                removeTextBadges()
            }
        }
    }

    @IBOutlet var lightningConstraint: NSLayoutConstraint!
    @IBOutlet weak var hotelInfoView: HLHotelInfoView!
    @IBOutlet weak var oldPriceView: UILabel!
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var redPriceBackgroundView: UIView!
    @IBOutlet weak var lightningView: UIImageView!
    var isLockTapGesture: Bool = false
    var item: HLVariantItem?
    var bookingsCountLabel: UILabel?
    @IBOutlet weak var priceLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var durationLabelBottomConstraint: NSLayoutConstraint!

    func initialize() {
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        isLockTapGesture = false
        isBadgesEnabled = true
        tapRecognizer = HLTapGestureRecognizer()
        tapRecognizer?.stateDelegate = self
        tapRecognizer?.delegate = self
        tapRecognizer?.minimumPressDuration = 0.1
        addGestureRecognizer(tapRecognizer!)
        NotificationCenter.default.addObserver(self, selector: #selector(self.containerCollectionWillStartScroll), name: "HLVariantsCollectionContentNotificationWillStartScroll", object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.containerCollectionDidStopScroll), name: "HLVariantsCollectionContentNotificationDidStopScroll", object: nil)
    }

    func resetContent() {
        // implement in subclass
    }

    func setup(with item: HLVariantItem) {
        self.item = item
        hotelInfoView.hotel = item.variant.hotel
        updateDiscountViews()
        drawBadges()
        updatePrice()
    }

    func drawBadges() {
        if !isBadgesEnabled {
            return
        }
        layoutIfNeeded()
        let badgesOrigin = CGPoint(x: 15.0, y: 15.0)
        let leftInset: CGFloat = 15.0
        drawTextBadges(variant.badges, widthLimit: bounds.width - leftInset, startOrigin: badgesOrigin)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        resetContent()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }

    override func setBounds(_ bounds: CGRect) {
        super.bounds = bounds
        contentView.frame = bounds
        drawBadges()
    }

// MARK: - Public

// MARK: - Private methods
    func addBookingsCountLabel() {
        if bookingsCountLabel == nil {
            bookingsCountLabel = UILabel()
            bookingsCountLabel?.font = UIFont.systemFont(ofSize: 10)
            bookingsCountLabel?.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
            bookingsCountLabel?.numberOfLines = 0
            addSubview(bookingsCountLabel!)
            bookingsCountLabel?.autoPinEdge(ALEdgeBottom, toEdge: ALEdgeTop, of: redPriceBackgroundView, withOffset: -10.0)
            bookingsCountLabel?.autoPinEdge(ALEdgeRight, toEdge: ALEdgeRight, of: redPriceBackgroundView, withOffset: -10.0)
        }
        bookingsCountLabel?.text = "id: \(variant.hotel.hotelId)\nrank: \(Int(variant.hotel.rank))\norders: \(Int(variant.hotel.popularity2))"
    }

    func variant() -> HLResultVariant {
        return item._variant
    }

    func updatePrice() {
        let roomsAvailability: HLRoomsAvailability = variant().roomsAvailability
        priceLabel.font = UIFont.boldSystemFont(ofSize: kPriceTextFontSize)
        priceLabelTopConstraint.constant = 4.0
        durationLabelBottomConstraint.constant = 5.0
        if roomsAvailability == HLRoomsAvailabilityHasRooms {
            priceLabel.font = UIFont.systemFont(ofSize: kPriceValueFontSize, weight: .bold)
            priceLabel.attributedText = priceString()
        }
        else if roomsAvailability == HLRoomsAvailabilitySold {
            priceLabel.text = NSLS("HL_LOC_ROOMS_SOLD")
            durationLabel.text = NSLS("HL_LOC_ROOMS_SOLD_SUBTITLE")
            priceLabelTopConstraint.constant = 7.0
            durationLabelBottomConstraint.constant = 4.0
        }
        else if roomsAvailability == HLRoomsAvailabilityNoRooms {
            priceLabel.text = NSLS("HL_LOC_NO_ROOMS")
            durationLabel.text = NSLS("HL_LOC_NO_ROOMS_SUBTITLE")
            priceLabelTopConstraint.constant = 8.0
            durationLabelBottomConstraint.constant = 7.0
        }

        setupPriceBackground(for: variant())
    }

    func priceString() -> NSAttributedString {
        return StringUtils.attributedPriceString(with: variant(), currency: variant().searchInfo.currency, font: priceLabel.font)
    }

    func oldPriceString() -> NSAttributedString {
        let priceAttrStr: NSAttributedString? = StringUtils.attributedPriceString(with: variant().oldMinPrice, currency: variant().searchInfo.currency, font: oldPriceView.font)
        return StringUtils.strikethroughAttributedString(priceAttrStr)
    }

    func updateDiscountViews() {
        setupPriceBackground(for: variant())
        var shouldShowLighting: Bool = false
        oldPriceView.text = nil
        let type: HDKHighlightType = variant().highlightType
        switch type {
            case HDKHighlightTypeNone:
                durationLabel.text = StringUtils.durationDescription(withDays: variant().duration)
            case HDKHighlightTypeMobile, HDKHighlightTypePrivate:
                shouldShowLighting = true
                durationLabel.text = NSLS("HL_SPECIAL_PRICE_TITLE")
            case HDKHighlightTypeDiscount:
                durationLabel.text = ""
                oldPriceView.attributedText = oldPriceString()
        }

        lightningView.isHidden = !shouldShowLighting
        lightningConstraint.isActive = shouldShowLighting
    }

    func setupPriceBackground(for variant: HLResultVariant) {
        redPriceBackgroundView.backgroundColor = priceBackgroundColor(for: variant)
    }

    func priceBackgroundColor(for variant: HLResultVariant) -> UIColor {
        let alpha: CGFloat = 0.7
        let discountAlpha: CGFloat = 1.0
        if shouldPriceHaveGrayBackground(variant) {
            return JRColorScheme.priceBackgroundColor().withAlphaComponent(alpha)
        }
        else if variant.highlightType == HDKHighlightTypeDiscount {
            return JRColorScheme.discountColor().withAlphaComponent(discountAlpha)
        }
        else {
            return UIColor(red: 208.0 / 255, green: 2.0 / 255, blue: 27.0 / 255, alpha: alpha)
        }

    }

    func shouldPriceHaveGrayBackground(_ variant: HLResultVariant) -> Bool {
        return (variant.roomsAvailability == HLRoomsAvailabilitySold) || (variant.roomsAvailability == HLRoomsAvailabilityNoRooms) || (variant.roomsAvailability == HLRoomsAvailabilityHasRooms) && (variant.highlightType == HDKHighlightTypeNone)
    }

    func deselectAnimation() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .beginFromCurrentState, animations: {() -> Void in
            selectionView.alpha = 0.0
        }) { _ in }
    }

    func selectAnimation() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .beginFromCurrentState, animations: {() -> Void in
            selectionView.alpha = 0.3
        }) { _ in }
    }

// MARK: - UIGestureRecognizerDelegate methods
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if isLockTapGesture {
            return false
        }
        let point: CGPoint = gestureRecognizer.location(in: self)
        let subview: UIView? = hitTest(point, with: nil)
        return !(subview? is UIButton)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if isLockTapGesture {
            return false
        }
        let point: CGPoint = touch.location(in: self)
        let subview: UIView? = hitTest(point, with: nil)
        return !(subview? is UIButton)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

// MARK: - HLGestureRecognizerDelegate methods
    func recognizerCancelled() {
        tapRecognizer?.removeTarget(self, action: #selector(self.selectAnimation))
        deselectAnimation()
    }

    func recognizerFinished() {
        tapRecognizer?.removeTarget(self, action: #selector(self.selectAnimation))
        deselectAnimation()
    }

    func recognizerStarted() {
        tapRecognizer?.addTarget(self, action: #selector(self.selectAnimation))
    }
}

extension HLVariantCollectionViewCell {
    func containerCollectionWillStartScroll() {
        tapRecognizer?.isEnabled = false
        isLockTapGesture = true
    }

    func containerCollectionDidStopScroll() {
        tapRecognizer?.isEnabled = true
        isLockTapGesture = false
    }
}