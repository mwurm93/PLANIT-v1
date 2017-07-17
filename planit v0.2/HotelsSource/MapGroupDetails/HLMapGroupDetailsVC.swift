//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
class HLMapGroupDetailsVC: HLCommonVC, HLShowHotelProtocol, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private var _variants = [Any]()
    var variants: [Any] {
        get {
            return _variants
        }
        set(variants) {
            _variants = VariantsSorter.sortVariants(byPrice: variants)
        }
    }
    weak var delegate: HLShowHotelProtocol?

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionBottomConstraint: NSLayoutConstraint!
    var selectedIndex: Int = 0
    var itemsSpacing: CGFloat = 0.0
    var isShouldUpdateSelectedIndexOnScrollViewDidScroll: Bool = false
    var hotelDetailsDecorator: HLHotelDetailsDecorator?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        isShouldUpdateSelectedIndexOnScrollViewDidScroll = true
        itemsSpacing = 20.0
        automaticallyAdjustsScrollViewInsets = false
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = .horizontal
        collectionLayout.minimumInteritemSpacing = itemsSpacing
        collectionLayout.minimumLineSpacing = 20.0
        collectionView.collectionViewLayout = collectionLayout
        collectionView?.register(HLMapGroupDetailsCell.self, forCellWithReuseIdentifier: "HLMapGroupDetailsCell")
        collectionView.scrollsToTop = false
        collectionViewHeightConstraint.constant = cellHeight()
        collectionViewTopConstraint.constant = collectionViewTopConstant()
        updateCountLabel(withIndex: 0)
        setupDescriptionLabel()
        descriptionBottomConstraint.constant = descriptionBottomConstant()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateVisibleCells(withContentOffset: 0.0)
        hotelDetailsDecorator = nil
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionViewTopConstraint.constant = collectionViewTopConstant()
        collectionView?.setNeedsLayout()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        isShouldUpdateSelectedIndexOnScrollViewDidScroll = false
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
        selectedIndex = visibleIndex(forOffset: collectionView.contentOffset)
        coordinator.animate(alongsideTransition: {(_ context: UIViewControllerTransitionCoordinatorContext) -> Void in
            let newX: CGFloat = (self.selectedIndex) * (self.cellWidth() + self.itemsSpacing)
            collectionView.contentOffset = CGPoint(x: newX, y: 0.0)
        }, completion: {(_ context: UIViewControllerTransitionCoordinatorContext) -> Void in
            isSelf.isShouldUpdateSelectedIndexOnScrollViewDidScroll = true
            self.updateSelectionView(with: self.selectedIndex)
        })
    }

    func setupDescriptionLabel() {
        if iPhone35Inch() {
            descriptionLabel.text = NSLS("HL_LOC_MAP_GROUP_DESCRIPTION_SHORT")
            descriptionLabel.numberOfLines = 1
        }
        else {
            descriptionLabel.text = NSLS("HL_LOC_MAP_GROUP_DESCRIPTION_LONG")
            descriptionLabel.numberOfLines = 0
        }
    }

    func updateCountLabel(with index: Int) {
        countLabel.text = "\(Int(index + 1)) \(NSLS("HL_LOC_FROM_CONJUCTION")) \(UInt(variants.count))"
    }

// MARK: - Device-related constraints
    func cellWidth() -> CGFloat {
        return iPhone() ? 270.0 : 385.0
    }

    func cellHeight() -> CGFloat {
        return iPhone() ? 171.0 : 240.0
    }

    func collectionViewTopConstant() -> CGFloat {
        if iPad() {
            let orientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
            return UIInterfaceOrientationIsLandscape(orientation) ? 180.0 : 300.0
        }
        if iPhone35Inch() {
            return 82.0
        }
        else if iPhone4Inch() {
            return 150.0
        }
        else if iPhone47Inch() {
            return 150.0
        }
        else {
            return 180.0
        }

    }

    func descriptionBottomConstant() -> CGFloat {
        if iPhone35Inch() || iPhone4Inch() {
            return 20.0
        }
        return 40.0
    }

    func horizontalSideOffset() -> CGFloat {
        return (collectionView.frame?.size?.width - cellWidth()) / 2.0!
    }

// MARK: - UICollectionViewDataSource Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return variants.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HLMapGroupDetailsCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "HLMapGroupDetailsCell", for: indexPath)
        cell?.variant = variants[indexPath.row]
        cell?.layer?.cornerRadius = 5.0
        cell?.clipsToBounds = true
        cell?.backgroundColor = UIColor.white
        cell?.delegate = self
        return cell!
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth(), height: cellHeight())
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: horizontalSideOffset(), height: collectionViewTopConstant())
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: horizontalSideOffset(), height: 0.0)
    }

// MARK: - UIScrollViewDelegate Methods
    func visibleIndex(forOffset offset: CGPoint) -> Int {
        let offsetX: CGFloat = offset.x
        let itemSize: CGSize = collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: IndexPath(item: 0, section: 0))
        var index: Int = (NSInteger)(offsetX / (itemSize.width + itemsSpacing) + 0.5)
        index = min(max(0, index), variants.count - 1)
        return index
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isShouldUpdateSelectedIndexOnScrollViewDidScroll {
            return
        }
        let index: Int = visibleIndex(forOffset: scrollView.contentOffset)
        updateSelectionView(with: index)
        updateVisibleCells(withContentOffset: scrollView.contentOffset.x)
    }

    func updateVisibleCells(withContentOffset offset: CGFloat) {
        for path: IndexPath in collectionView.indexPathsForVisibleItems {
            let cell: UICollectionViewCell? = collectionView?.cellForItem(at: path)
            cell?.alpha = alphaForCell(atIndexPath: path, withOffset: offset)
        }
    }

    func alphaForCell(at path: IndexPath, withOffset offset: CGFloat) -> CGFloat {
        let attr: UICollectionViewLayoutAttributes? = collectionView?.layoutAttributesForItem(at: path)
        var offsetX: CGFloat? = attr?.frame?.origin?.x
        offsetX = offsetX - offset
        var alpha: CGFloat = 1.0
        if offsetX < horizontalSideOffset() {
            alpha = 0.4 + max(0.6 * (offsetX + cellWidth()) / cellWidth(), 0.0)
        }
        else {
            alpha = 0.4 + max(0.6 * (collectionView.frame?.size?.width - offsetX) / cellWidth(), 0.0)
        }
        return alpha
    }

    func updateSelectionView(with index: Int) {
        selectedIndex = index
        updateCountLabel(with: index)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: CGPoint) {
        let targetX: CGFloat = targetContentOffset.x
        var index: Int = visibleIndex(forOffset: CGPoint(x: targetX, y: 0.0))
        if velocity.x > 0 {
            index += 1
        }
        else if velocity.x < 0 {
            index -= 1
        }

        index = min(max(0, index), variants.count - 1)
        let newX: CGFloat = (index) * (cellWidth() + itemsSpacing)
        targetContentOffset.x = newX
    }

// MARK: - HLShowHotelProtocol Methods
    func showFullHotelInfo(_ variant: HLResultVariant, visiblePhotoIndex: Int, indexChangedBlock block: @escaping (_ index: Int) -> Void, peeked: Bool) {
        delegate?.showFullHotelInfo(variant, visiblePhotoIndex: visiblePhotoIndex, indexChangedBlock: (block as? ), peeked: peeked)
    }
}