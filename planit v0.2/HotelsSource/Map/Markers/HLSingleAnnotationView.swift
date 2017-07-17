//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import PureLayout

private let kCollapsedCenterOffset: CGPoint = [0.0, 0.0]
private let kPriceLabelHorizontalPadding: CGFloat = 5.0
private let kTopShadowHeight: CGFloat = 2.0
private let kBottomShadowHeight: CGFloat = 7.0
private let kRightShadowWidth: CGFloat = 2.0
private let kAnnotationViewHeight: CGFloat = 24 + kTopShadowHeight + kBottomShadowHeight

class HLSingleAnnotationView: TBClusterAnnotationView {
    weak var delegate: HLShowHotelProtocol?

    var leftImage: UIImage?
    var rightImage: UIImage?
    var ratingView: RatingView?
    var variantView: HLVariantScrollablePhotoCell?
    var infoViewLogic: HotelInfoViewLogic?
    var leftImageView: UIImageView?
    var rightImageView: UIImageView?
    var ratingWidthConstraint: NSLayoutConstraint?
    var priceLeadingConstraint: NSLayoutConstraint?
    var priceTrailingConstraint: NSLayoutConstraint?
    var priceVerticalConstraint: NSLayoutConstraint?

// MARK: - Override

    class func calloutHeight() -> CGFloat {
        return iPhone() ? 180.0 : 240.0
    }

    func expand(animated: Bool) {
        if variantView == nil {
            variantView = LOAD_VIEW_FROM_NIB_NAMED("HLVariantScrollablePhotoCell")
            variantView?.translatesAutoresizingMaskIntoConstraints = false
            variantView?.alpha = 0.0
            weakify(self)
            variantView?.selectionHandler = {(_ variant: HLResultVariant, _ index: Int) -> Void in
                strongify(self)
                self.delegate?.showFullHotelInfo(variant, visiblePhotoIndex: index, indexChangedBlock: {(_ index: Int) -> Void in
                    variantView?.visiblePhotoIndex = index
                }, peeked: false)
            }
        }
        let options: UIViewAnimationOptions = [.allowAnimatedContent, .layoutSubviews, .beginFromCurrentState]
        let duration: CGFloat = animated ? HL_CALLOUT_ANIMATION_DURATION : 0.0
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {() -> Void in
            self.hidePinContent()
        }, completion: {(_ finished: Bool) -> Void in
            self.addSubview(self.variantView!)
            UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {() -> Void in
                self.addCalloutContent()
            }, completion: {(_ finished: Bool) -> Void in
                if subviews.contains(self.variantView) {
                    UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {() -> Void in
                        self.showCalloutContent()
                    }) { _ in }
                }
                else {
                    self.collapse(animated: animated)
                }
            })
        })
    }

    func collapse(animated: Bool) {
        let options: UIViewAnimationOptions = [.allowAnimatedContent, .layoutSubviews, .beginFromCurrentState]
        let duration: CGFloat = animated ? HL_CALLOUT_ANIMATION_DURATION : 0.0
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {() -> Void in
            self.hideCalloutContent()
        }, completion: {(_ finished: Bool) -> Void in
            self.variantView?.removeFromSuperview()
            UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {() -> Void in
                self.removeCalloutContent()
            }, completion: {(_ finished: Bool) -> Void in
                UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {() -> Void in
                    self.showPinContent()
                }) { _ in }
            })
        })
    }

    func updateContentAndCollapseIfExpanded() {
        if isExpanded() {
            collapse(animated: false)
        }
        updateContent()
    }

    func photoRect() -> CGRect {
        return variantView?.frame!
    }

// MARK: - Private
    class func calloutSize() -> CGSize {
        let width: CGFloat = iPhone() ? 285.0 : 385.0
        return CGSize(width: width, height: self.calloutHeight())
    }

// MARK: - Public

    override func initialSetup() {
        leftImage = UIImage(named: "pinImageLeft.png")
        rightImage = UIImage(named: "pinImageRight.png")
        infoViewLogic = HotelInfoViewLogic()
        super.initialSetup()
        addRating()
        priceLabel.textColor = JRColorScheme.darkText
        clipsToBounds = true
        centerOffset = kCollapsedCenterOffset
        setupConstraints()
    }

    func addBackgroundView() {
        backgroundView = UIView()
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        leftImageView = UIImageView()
        let leftPinImage: UIImage? = leftImage?.resizableImage(withCapInsets: UIEdgeInsetsMake(4.0, 4.0, 10.0, 5.0), resizingMode: .stretch)
        leftImageView?.image() = leftPinImage
        rightImageView = UIImageView()
        let rightPinImage: UIImage? = rightImage?.resizableImage(withCapInsets: UIEdgeInsetsMake(4.0, 5.0, 10.0, 4.0), resizingMode: .stretch)
        rightImageView?.image() = rightPinImage
        backgroundView.addSubview(leftImageView!)
        backgroundView.addSubview(rightImageView!)
    }

    func addRatingView() {
        ratingView = RatingView()
        backgroundView.addSubview(ratingView!)
    }

    override func setVariants(_ variants: [Any]) {
        super.setVariants(variants)
        ratingView?.setup(withHotel: variant.hotel)
        updateContentAndCollapseIfExpanded()
    }

// MARK: - Layout
    func setupConstraints() {
        backgroundView.autoPinEdgesToSuperviewEdges()
        leftImageView?.autoMatchDimension(ALDimensionWidth, toDimension: ALDimensionWidth, of: rightImageView)
        leftImageView?.autoPinEdge(toSuperviewEdge: ALEdgeTop)
        leftImageView?.autoPinEdge(toSuperviewEdge: ALEdgeLeading)
        leftImageView?.autoPinEdge(toSuperviewEdge: ALEdgeBottom)
        leftImageView?.autoPinEdge(ALEdgeTrailing, toEdge: ALEdgeLeading, of: rightImageView)
        rightImageView?.autoPinEdge(toSuperviewEdge: ALEdgeTrailing)
        rightImageView?.autoPinEdge(toSuperviewEdge: ALEdgeTop)
        rightImageView?.autoPinEdge(toSuperviewEdge: ALEdgeBottom)
        ratingView?.autoPinEdge(toSuperviewEdge: ALEdgeTop, withInset: kTopShadowHeight)
        ratingView?.autoPinEdge(toSuperviewEdge: ALEdgeBottom, withInset: kBottomShadowHeight)
        ratingView?.autoPinEdge(toSuperviewEdge: ALEdgeLeading, withInset: 0.0)
        ratingWidthConstraint = ratingView?.autoSetDimension(ALDimensionWidth, toSize: ratingViewWidth())
        priceLeadingConstraint = priceLabel.autoPinEdge(ALEdgeLeading, toEdge: ALEdgeTrailing, of: ratingView, withOffset: priceLeading())
        priceTrailingConstraint = priceLabel.autoPinEdge(toSuperviewEdge: ALEdgeTrailing, withInset: priceTrailing())
        priceLabel.autoAlignAxis(ALAxisHorizontal, toSameAxisOf: priceLabel.superview, withOffset: -3.0)
    }

    func recalculateConstraints() {
        ratingWidthConstraint?.constant = ratingViewWidth()
        priceLeadingConstraint?.constant = priceLeading()
        priceTrailingConstraint?.constant = -priceTrailing()
        priceVerticalConstraint?.constant = hasPrice() ? 0 : -1
    }

    func recalculateSize() {
        let size = systemLayoutSizeFitting(CGSize(width: CGFLOAT_MAX, height: kAnnotationViewHeight), withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
        var frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        frame = TBCenterRect(frame, center)
        self.frame = frame
    }

    func ratingViewWidth() -> CGFloat {
        return showsRating() ? 26.0 : 0.0
    }

    func priceLeading() -> CGFloat {
        if showsRating() {
            return kPriceLabelHorizontalPadding + additionalWidthForNoPrice()
        }
        else {
            return kPriceLabelHorizontalPadding + kRightShadowWidth + additionalWidthForNoPrice()
        }
    }

    func priceTrailing() -> CGFloat {
        return kPriceLabelHorizontalPadding + kRightShadowWidth + additionalWidthForNoPrice()
    }

    func additionalWidthForNoPrice() -> CGFloat {
        return hasPrice() ? 0 : 1
    }

    func showsRatingView() -> Bool {
        return variant.hotel.rating > 0 && variant.filteredRooms.count > 0!
    }

    func hidePinContent() {
        priceLabel.alpha = 0.0
        ratingView?.alpha = 0.0
    }

    func showPinContent() {
        priceLabel.alpha = 1.0
        ratingView?.alpha = 1.0
    }

    func addCalloutContent() {
        let size: CGSize = HLSingleAnnotationView.calloutSize()
        frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        centerOffset = CGPoint(x: 0.0, y: -size.height / 2.0 + kAnnotationViewHeight / 2.0)
        if !subviews.contains(variantView) {
            addSubview(variantView!)
        }
        variantView?.autoPinEdgesToSuperviewEdges(withInsets: UIEdgeInsetsMake(5, 5, 10, 5))
        layoutIfNeeded()
        let variantItem = HLVariantItem(variant: variant())
        variantView?.setup(with: variantItem)
    }

    func removeCalloutContent() {
        centerOffset = kCollapsedCenterOffset
        updateContent()
    }

    func showCalloutContent() {
        variantView?.alpha = 1.0
    }

    func hideCalloutContent() {
        variantView?.alpha = 0.0
    }

    func isExpanded() -> Bool {
        return variantView?.superview != nil!
    }

    func variant() -> HLResultVariant {
        return variants.last!
    }

    func configurePriceLabel() {
        let priceString: NSAttributedString? = StringUtils.attributedPriceString(with: variant(), currency: variant().searchInfo.currency, font: priceLabel.font, noPriceColor: UIColor.black)
        priceLabel.attributedText = priceString
    }

    func hasPrice() -> Bool {
        return variant().rooms.count > 0
    }

    func updateContent() {
        configurePriceLabel()
        recalculateConstraints()
        recalculateSize()
    }
}

let HL_CALLOUT_ANIMATION_DURATION = 0.2
private func TBCenterRect(rect: CGRect, center: CGPoint) -> CGRect {
    return CGRect(x: center.x - rect.size.width / 2.0, y: center.y - rect.size.height / 2.0, width: rect.size.width, height: rect.size.height)
}