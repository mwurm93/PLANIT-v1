//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
private var kFreeSpaceBetweenButtons: CGFloat = 15.0

class HLIphoneMapVC: HLMapVC, UIGestureRecognizerDelegate, PriceFilterViewDelegate {
    @IBOutlet weak var priceFilterView: PriceFilterView!
    @IBOutlet weak var priceFilterViewContainer: UIView!
    @IBOutlet weak var filterButtonWidth: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        priceFilterViewContainer = priceFilterView.superview
        mapView.gestureRecognizerDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filter?.refreshPriceBounds()
        filter.delegate = self
        filtersButton.isSelected = filter.canDropFilters
        if filter.allVariantsHaveSamePrice {
            priceFilterViewContainer.isHidden = true
        }
        else {
            priceFilterViewContainer.isHidden = false
            priceFilterView.configure(withFilter: filter)
            priceFilterView.delegate = self
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        filterButtonWidth.constant = (view.bounds.size.width - 3 * kFreeSpaceBetweenButtons) / 2.0
    }

// MARK: - Override
    override func mapEdgeInsets() -> UIEdgeInsets {
        let insets: UIEdgeInsets = super.mapEdgeInsets()
        insets.top = priceFilterViewContainer.frame.maxY
        return insets
    }

// MARK: - PriceFilterViewDelegate
    func filterApplied() {
        filter?.filter
    }

// MARK: - HLResultsVCDelegate methods
    override func variantsFiltered(_ variants: [Any], animated: Bool) {
        super.variantsFiltered(variants, animated: animated)
        filtersButton.isSelected = filter.canDropFilters
    }
}