//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
class HLGroupAnnotationView: TBClusterAnnotationView {
    var backgroundImage: UIImageView?

// MARK: - Override

    override func addPriceLabel() {
        super.addPriceLabel()
        priceLabel.textColor = UIColor.white
        priceLabel.autoConstrainAttribute(ALAttributeHorizontal, toAttribute: ALAttributeHorizontal, of: priceLabel.superview, withOffset: -1.0)
        priceLabel.autoConstrainAttribute(ALAttributeVertical, toAttribute: ALAttributeVertical, of: priceLabel.superview)
    }

// MARK: - Private
    func addBackgroundView() {
        backgroundImage = UIImageView(image: UIImage(named: "groupPin1"))
        addSubview(backgroundImage!)
        backgroundView = backgroundImage
        backgroundImage?.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage?.autoCenterInSuperview()
    }

    func setVariants(_ variants: [Any]) {
        let hotelsWithRoomsCount: Int = countVariants(withRooms: variants)
        priceLabel.text = hotelsWithRoomsCount ? StringUtils.formattedNumberString(withNumber: hotelsWithRoomsCount) : ""
        if hotelsWithRoomsCount > 1000 {
            backgroundImage?.image() = UIImage(named: "groupPin4")
        }
        else if hotelsWithRoomsCount > 100 {
            backgroundImage?.image() = UIImage(named: "groupPin3")
        }
        else if hotelsWithRoomsCount > 10 {
            backgroundImage?.image() = UIImage(named: "groupPin2")
        }
        else if hotelsWithRoomsCount > 0 {
            backgroundImage?.image() = UIImage(named: "groupPin1")
        }
        else {
            backgroundImage?.image() = UIImage(named: "groupPin0")
        }

        var frame: CGRect = self.frame
        frame.size = backgroundImage?.image()?.size
        self.frame = frame
    }

    func countVariants(withRooms variants: [Any]) -> Int {
        let result: Int = 0
        for variant: HLResultVariant in variants {
            if variant.minPrice > 0 && variant.minPrice != UNKNOWN_MIN_PRICE {
                result += 1
            }
        }
        return result
    }
}