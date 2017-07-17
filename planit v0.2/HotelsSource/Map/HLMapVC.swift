//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import UIKit

let HL_MAP_CALLOUT_ANIMATION_DURATION = 0.2
private let HLSingleAnnotationViewReuseID: String = "singleAnnotationView"
private let HLGroupAnnotationViewReuseID: String = "groupAnnotationView"

class HLMapVC: TBMapViewController, HLShowHotelProtocol, HLMapViewDelegate, FiltersVCDelegate, HLNearbyCitiesDetectionDelegate, UIViewControllerPreviewingDelegate, PeekHotelVCDelegate, HLLocateMeMapViewDelegate {
    var searchInfo: HLSearchInfo?
    var filter: Filter?
    var isClusteringEnabled: Bool = false
    @IBOutlet weak var filtersButton: UIButton!

    var variants = [Any]()
    var peekedVariant: HLResultVariant?
    var expandedAnnotation: HLSingleAnnotationView?
    var isShouldAnimateFiltersOnViewDidAppear: Bool = false
    var isDidSetInitialRegion: Bool = false
    var poiAnnotations = [PoiAnnotation]()
    @IBOutlet weak var locateMeMapView: HLLocateMeMapView!

    func mapEdgeInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }

    func variantsFiltered(_ variants: [Any], animated: Bool) {
        let shouldReloadTree: Bool = !(self.variants as NSArray).isEqual(to: variants) || minPricesChanged(from: self.variants, to: variants)
        if shouldReloadTree {
            reloadTree(withVariants: variants)
        }
        let windowIsEmpty: Bool? = !view.window
        let presentedViewControllerIsOnScreen: Bool = presentedViewController && !presentedViewController.isBeingDismissed
        if presentedViewControllerIsOnScreen || windowIsEmpty {
            isShouldAnimateFiltersOnViewDidAppear = true
        }
        let resultsController: HLCommonResultsVC? = self.resultsController()
        resultsController?.setNeedsUpdateContent()
    }

    @IBAction func showFullFilters() {
        let filtersVC: HLFiltersVC? = HLIphoneFiltersVC(nibName: "HLIphoneFiltersVC", bundle: nil)
        filtersVC?.searchInfo = searchInfo
        filtersVC?.filter = filter
        filtersVC?.delegate = self
        navigationController?.pushViewController(filtersVC!, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addSearchInfoView(searchInfo)
        isClusteringEnabled = true
        locateMeMapView.delegate = self
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(self.deselectAnnotation))
        tapRec.delaysTouchesBegan = false
        mapView?.addGestureRecognizer(tapRec as? UIGestureRecognizer ?? UIGestureRecognizer())
        mapView.gestureRecognizerDelegate = self
        HLLocationManager.sharedManager().hasUserGrantedLocationAccess(onCompletion: {(_ accessGranted: Bool) -> Void in
            mapView.showsUserLocation = accessGranted
        })
        registerForCurrentCityNotifications()
        registerForPreviewing(with: self, sourceView: view)
        setupFilterButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetPoiAnnotations()
        if !isDidSetInitialRegion {
            isClusteringEnabled = false
            view.layoutIfNeeded()
            isClusteringEnabled = true
            showInitialRegion(forVariants: variants)
            isDidSetInitialRegion = true
        }
    }

    deinit {
        unregisterNotificationResponse()
    }

    func setupFilterButton() {
        filtersButton.setTitle(NSLS("HL_FILTER_BUTTON_TITLE_LABEL"), for: .normal)
        let markImage = UIImage(named: "filtersButtonActive")
        filtersButton.setImage(markImage, for: .selected)
        filtersButton.setImage(markImage, for: [.highlighted, .selected])
    }

    func deselectAnnotation() {
        mapView?.deselectAnnotation(expandedAnnotation?.annotation, animated: false)
        expandedAnnotation?.collapse(animated: true)
        expandedAnnotation = nil
    }

// MARK: - HLLocateMeMapViewDelegate
    func locateMeMapView(_ locateMeMapView: HLLocateMeMapView, shouldShowUserLocation userLocation: CLLocation) {
        mapView.showsUserLocation = true
        locateMeAction()
    }

// MARK: - Private
    func resetPoiAnnotations() {
        if poiAnnotations.count > 0 {
            mapView?.removeAnnotations(poiAnnotations as? [MKAnnotation] ?? [MKAnnotation]())
            for annotation: PoiAnnotation in poiAnnotations {
                ungroupableAnnotations.remove(at: ungroupableAnnotations.index(of: annotation)!)
            }
            poiAnnotations = nil
        }
        poiAnnotations = createPoiAnnotations()
        mapView?.addAnnotations(poiAnnotations as? [MKAnnotation] ?? [MKAnnotation]())
        ungroupableAnnotations += poiAnnotations
    }

    func createPoiAnnotations() -> [PoiAnnotation] {
        var annotations = [Any]()
        let filterSelectedPoint: HDKLocationPoint? = filter?.distanceLocationPoint
        if !(filterSelectedPoint? is HLGenericCategoryLocationPoint) {
            let filterSelectedAnnotation = PoiAnnotation.init(filterSelectedPoint)
            annotations.append(filterSelectedAnnotation)
        }
        let airportAnnotations: [PoiAnnotation]? = searchInfo?.cityByCurrentSearchType?.airports()?.map({(_ point: HDKLocationPoint) -> PoiAnnotation in
                return PoiAnnotation.init(point)
            })
        if airportAnnotations?.count > 0 {
            annotations += airportAnnotations
        }
        return annotations
    }

    func showMapGroupContents(_ variants: [Any]) {
        let detailsVC = HLMapGroupDetailsVC(nibName: "HLMapGroupDetailsVC", bundle: nil)
        detailsVC.variants = variants
        detailsVC.delegate = self
        navigationController?.pushViewController(detailsVC as? UIViewController ?? UIViewController(), animated: true)
    }

    func showInitialRegion(forVariants variants: [Any]) {
        if variants.count == 0 {
            mapView?.showCity(searchInfo?.city ?? searchInfo?.locationPoint?.nearbyCities?.first)
        }
        else {
            mapView?.setRegionForVariants(variants, insets: mapEdgeInsets(), animated: false)
        }
    }

    func expandSingleAnotationView(_ view: HLSingleAnnotationView) {
        view.expand(animated: true)
        expandedAnnotation?.layer?.zPosition = HL_POI_ANNOTATION_ZPOSITION
        expandedAnnotation = view
        expandedAnnotation?.layer?.zPosition = HL_SELECTED_ANNOTATION_ZPOSITION
        mapView?.bringSubview(toFront: expandedAnnotation!)
    }

    func singleVariantAnnotationView(_ annotation: TBClusterAnnotation, mapView: MKMapView) -> MKAnnotationView {
        var annotationView: HLSingleAnnotationView? = (mapView.dequeueReusableAnnotationView(withIdentifier: HLSingleAnnotationViewReuseID) as? HLSingleAnnotationView)
        if annotationView == nil {
            annotationView = HLSingleAnnotationView(annotation: annotation, reuseIdentifier: HLSingleAnnotationViewReuseID)
            annotationView?.delegate = self
        }
        annotationView?.variants = annotation.variants
        return annotationView!
    }

    func groupAnnotationView(_ annotation: TBClusterAnnotation, mapView: MKMapView) -> MKAnnotationView {
        var annotationView: HLGroupAnnotationView? = (mapView.dequeueReusableAnnotationView(withIdentifier: HLGroupAnnotationViewReuseID) as? HLGroupAnnotationView)
        if annotationView == nil {
            annotationView = HLGroupAnnotationView(annotation: annotation, reuseIdentifier: HLGroupAnnotationViewReuseID)
        }
        annotationView?.variants = annotation.variants
        return annotationView!
    }

    func shouldCloseSelectedAnnotation() -> Bool {
        return UIApplication.shared.applicationState != .background
    }

    func expandedAnnotationContains(_ variant: HLResultVariant) -> Bool {
        return expandedAnnotation?.variants?.first! == variant!
    }

// MARK: - UIViewControllerPreviewingDelegate
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController {
        let locationOnMap: CGPoint? = mapView?.convert(location, from: view as? UIView)
        let annotationView: HLSingleAnnotationView? = annotation(at: locationOnMap)
        peekedVariant = annotationView?.variants?.first
        if peekedVariant != nil {
            if expandedAnnotationContains(peekedVariant) {
                previewingContext.sourceRect = view.convert(annotationView?.photoRect, from: annotationView as? UIView)
            }
            else {
                previewingContext.sourceRect = CGRect(x: location.x, y: location.y, width: 1.0, height: 1.0)
            }
            return createPeekHotelVC(peekedVariant, filter: filter)
        }
        return nil
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        showPeekDetails()
    }

    func annotation(at point: CGPoint) -> HLSingleAnnotationView {
        for ann: MKAnnotation in mapView.annotations {
            let annView: MKAnnotationView? = mapView?.view(for: ann)
            if (annView? is HLSingleAnnotationView) && annView?.frame.contains(point) {
                return (annView as? HLSingleAnnotationView)!
            }
        }
        return nil
    }

    func createPeekHotelVC(_ variant: HLResultVariant, filter: Filter) -> PeekHotelVC {
        let peekVC = PeekHotelVC(nibName: "PeekTableVC", bundle: nil)
        peekVC.shouldAddMapCell = expandedAnnotationContains(peekedVariant)
        peekVC.variant = variant
        peekVC.filter = self.filter
        let peekWidth: CGFloat = UIScreen.main.bounds.size.width
        peekVC.preferredContentSize = CGSize(width: peekWidth, height: peekVC.height(for: peekedVariant, peekWidth: peekWidth))
        peekVC.viewControllerToShowBrowser = self
        peekVC.delegate = self
        return peekVC
    }

// MARK: - Actions
    @IBAction func locateMeAction() {
        let currentCity: HDKCity? = HLNearbyCitiesDetector.shared.nearbyCities.first
        let searchInfoCity: HDKCity? = searchInfo?.city ?? searchInfo?.locationPoint?.city ?? searchInfo?.locationPoint?.nearbyCities?.first
        if currentCity == nil {
            HLLocationManager.sharedManager().requestUserLocation(withLocationDestination: kShowCurrentLocationOnMap)
        }
        else if searchInfoCity && !searchInfoCity?.isEqual(currentCity) {
            mapView?.regionForUserAndTheCity = searchInfoCity
            locateMeMapView.locateMeButton.isSelected = true
        }
        else {
            mapView?.setRegionForUserLocation()
            locateMeMapView.locateMeButton.isSelected = true
        }

    }

// MARK: - HLShowHotelProtocol
    func showFullHotelInfo(_ variant: HLResultVariant, visiblePhotoIndex: Int, indexChangedBlock block: @escaping (_ index: Int) -> Void, peeked: Bool) {
        let decorator = HLHotelDetailsDecorator(variant: variant, photoIndex: 0, photoIndexUpdater: block, filter: filter)
        navigationController?.pushViewController(decorator.detailsVC, animated: true)
    }

// MARK: - HLResultsVCDelegate methods

    func resultsController() -> HLCommonResultsVC {
        let controllersCount: Int? = navigationController.viewControllers?.count
        if controllersCount < 2 {
            return nil
        }
        let vc: UIViewController? = navigationController.viewControllers[controllersCount - 2]
        if (vc? is HLCommonResultsVC) {
            return (vc as? HLCommonResultsVC)!
        }
        return nil
    }

    func reloadTree(withVariants variants: [Any]) {
        self.variants = variants
        rebuildTree(withVariants: variants)
        mapView(mapView, regionWillChangeAnimated: true)
        mapView(mapView, regionDidChangeAnimated: true)
    }

    func minPricesChanged(from oldVariants: [Any], to newVariants: [Any]) -> Bool {
        var pricesChanged: Bool = false
        if oldVariants.count != newVariants.count {
            pricesChanged = true
        }
        else {
            for i in 0..<oldVariants.count {
                let oldVariant: HLResultVariant? = oldVariants[i]
                let newVariant: HLResultVariant? = newVariants[i]
                if oldVariant?.minPrice != newVariant?.minPrice {
                    pricesChanged = true
                    break
                }
            }
        }
        return pricesChanged
    }

// MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if shouldCloseSelectedAnnotation() {
            locateMeMapView.locateMeButton.isSelected = false
            deselectAnnotation()
        }
    }

    override func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if isClusteringEnabled {
            super.mapView(mapView, regionDidChangeAnimated: animated)
        }
        isClusteringEnabled = true
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView {
        if (annotation is MKUserLocation) {
            let pin = MKAnnotationView()
            pin.image = UIImage(named: "userLocationPin")
            return pin
        }
        if (annotation is PoiAnnotation) {
            return HLMapViewConfigurator.view(for: annotation, mapView: mapView, city: searchInfo?.cityByCurrentSearchType)!
        }
        if (annotation is TBClusterAnnotation) {
            let clusterAnnotation: TBClusterAnnotation? = (annotation as? TBClusterAnnotation)
            var view: MKAnnotationView?
            if clusterAnnotation?.variants?.count == 1 {
                view = singleVariantAnnotationView(clusterAnnotation, mapView: mapView)
            }
            else {
                view = groupAnnotationView(clusterAnnotation, mapView: mapView)
            }
            view?.layer?.zPosition = HL_HOTEL_ANNOTATION_ZPOSITION
            return view!
        }
        return nil
    }

    override func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        super.mapView(mapView, didAdd: views)
        for view: MKAnnotationView in views {
            if (view? is TBClusterAnnotationView) {
                mapView.bringSubview(toFront: view!)
            }
            else {
                mapView.sendSubview(toBack: view!)
                view?.isEnabled = false
            }
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if (view.annotation? is TBClusterAnnotation) {
            let clusterAnnotation: TBClusterAnnotation? = (view.annotation as? TBClusterAnnotation)
            let variants: [Any]? = clusterAnnotation?.variants
            if variants?.count > 1 {
                if self.mapView?.canUngroupVariants(variants) {
                    self.mapView?.setRegionForVariants(variants, insets: mapEdgeInsets(), animated: true)
                }
                else {
                    self.mapView?.setCenter(clusterAnnotation?.coordinate, animated: true)
                    isClusteringEnabled = false
                    showMapGroupContents(variants)
                }
            }
            else if expandedAnnotation != view {
                isClusteringEnabled = false
                let variant: HLResultVariant? = variants?.last
                let annView: HLSingleAnnotationView? = (view as? HLSingleAnnotationView)
                self.mapView?.center(on: variant)
                expandSingleAnotationView(annView)
            }
        }
        view.layer.zPosition = HL_SELECTED_ANNOTATION_ZPOSITION
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if (view.annotation? is PoiAnnotation) {
            view.isEnabled = false
            mapView.sendSubview(toBack: view as? UIView ?? UIView())
            view.layer.zPosition = HL_POI_ANNOTATION_ZPOSITION
        }
        else {
            view.layer.zPosition = HL_HOTEL_ANNOTATION_ZPOSITION
        }
    }

// MARK: - HLMapViewDelegate Methods
    func mapShouldReactOnTouch(at point: CGPoint) -> Bool {
        let rect: CGRect? = expandedAnnotation?.frame
        if rect.contains(point) {
            return false
        }
        deselectAnnotation()
        return true
    }

    func mapWillReceiveTouch(on view: MKAnnotationView) {
        if (view.annotation? is PoiAnnotation) {
            view.isEnabled = true
        }
    }

// MARK: - HLNearbyCitiesDetectionDelegate methods
    func nearbyCitiesDetectionStarted(_ notification: Notification) {
        locateMeMapView.startLoadingRoutine()
    }

    func nearbyCitiesDetected(_ notification: Notification) {
        locateMeMapView.endLoadingRoutine()
        if notification.userInfo[kCurrentLocationDestinationKey]?.isEqual(kShowCurrentLocationOnMap) {
            locateMeAction()
        }
    }

    func nearbyCitiesDetectionFailed(_ notification: Notification) {
        locateMeMapView.endLoadingRoutine()
    }

    func nearbyCitiesDetectionCancelled(_ notification: Notification) {
        nearbyCitiesDetectionFailed(notification)
    }

    func locationServicesAccessFailed(_ notification: Notification) {
        nearbyCitiesDetectionFailed(notification)
    }

    func locationDetectionFailed(_ notification: Notification) {
        nearbyCitiesDetectionFailed(notification)
    }

// MARK: - PeekHotelVCDelegate
    func showPeekDetails() {
        showFullHotelInfo(peekedVariant, visiblePhotoIndex: 0, indexChangedBlock: nil, peeked: true)
    }

// MARK: - FiltersVCDelegate
    func didFilterVariants() {
        variantsFiltered(filter.filteredVariants, animated: true)
    }

    func locationPointSelected(_ point: HDKLocationPoint) {
        filter.distanceLocationPoint = point
        filter?.filter()
    }

    func openPointSelectionScreen() {
    }

    func showSelectionViewController(_ selectionVC: FilterSelectionVC) {
    }
}