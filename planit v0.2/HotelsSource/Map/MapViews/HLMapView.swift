//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import HotellookSDK
import MapKit

let HL_CITY_REGION_SPAN = 0.075
let HL_VARIANTS_SPAN_COEFF_H = 1.2
let HL_VARIANTS_SPAN_COEFF_V = 1.2
private var kMapSpanCoeff: CGFloat = 1.2

protocol HLMapViewDelegate: NSObjectProtocol {
    func mapShouldReactOnTouch(at point: CGPoint) -> Bool

    func mapWillReceiveTouch(on view: MKAnnotationView)
}

class HLMapView: MKMapView, UIGestureRecognizerDelegate {
    weak var gestureRecognizerDelegate: HLMapViewDelegate?

    class func defaultInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(30.0, 30.0, 50.0, 30.0)
    }

    func center(on variant: HLResultVariant) {
        let coord: CLLocationCoordinate2D? = CLLocationCoordinate2DMake(variant.hotel.latitude, variant.hotel.longitude)
        var pinPosition: CGPoint = convert(coord!, toPointTo: self)
        pinPosition.y -= ceil(HLSingleAnnotationView.calloutHeight() / 2.0)
        let newCenterCoord: CLLocationCoordinate2D = convert(pinPosition, toCoordinateFrom: self)
        setCenter(newCenterCoord, animated: true)
    }

    func show(_ city: HDKCity) {
        let region: MKCoordinateRegion = self.region(for: city)
        setRegion(region, animated: true)
    }

    func setRegionForVariants(_ variantsArray: [Any], insets: UIEdgeInsets, animated: Bool) {
        let region: MKCoordinateRegion = self.region(forVariants: variantsArray)
        setRegion(region, insets: insets, animated: animated)
    }

    func setRegionForUserLocation() {
        let region: MKCoordinateRegion = regionForUserLocation()
        setRegion(region, animated: true)
    }

    func setRegionForUserAndTheCity(_ city: HDKCity) {
        let region: MKCoordinateRegion = self.region(forUserAndCity: city)
        setRegion(region, animated: true)
    }

    func canUngroupVariants(_ variants: [Any]) -> Bool {
        let limitValue: Double = 0.0015
        var minLat: Double = DBL_MAX
        var maxLat: Double = -DBL_MAX
        var minLon: Double = DBL_MAX
        var maxLon: Double = -DBL_MAX
        for variant: HLResultVariant in variants {
            let hotel: HDKHotel? = variant.hotel
            if HLMapRegionCalculator.isHotelCoordinateValid(hotel) {
                let lat: Float? = hotel?.latitude
                let lon: Float? = hotel?.longitude
                minLat = min(minLat, lat)
                maxLat = max(maxLat, lat)
                minLon = min(minLon, lon)
                maxLon = max(maxLon, lon)
            }
            if (maxLat - minLat > limitValue) || (maxLon - minLon) > limitValue {
                return true
            }
        }
        return false
    }

    func setRegion(_ region: MKCoordinateRegion, insets: UIEdgeInsets, animated: Bool) {
        let rect: MKMapRect = mapRect(for: region)
        setVisibleMapRect(rect, edgePadding: insets, animated: animated)
    }

// MARK: - Public

    override init() {
        super.init()
        
        initialize()
    
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }

    func initialize() {
        showsUserLocation = false
        isRotateEnabled = false
        let gestureRec: [Any] = gestureRecognizers
        for rec: UIGestureRecognizer in gestureRec {
            rec.delegate = self
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent) -> UIView? {
        let resultView: UIView? = super.hitTest(point, with: event as? UIEvent ?? UIEvent())
        if gestureRecognizerDelegate && gestureRecognizerDelegate?.mapShouldReactOnTouch(at: point) == false {
            isScrollEnabled = false
            lockAllGestureRecognizers(true)
        }
        else {
            isScrollEnabled = true
            lockAllGestureRecognizers(false)
        }
        return resultView!
    }

    func mapRect(for region: MKCoordinateRegion) -> MKMapRect {
        let a: MKMapPoint? = MKMapPointForCoordinate(CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta / 2, region.center.longitude - region.span.longitudeDelta / 2))
        let b: MKMapPoint? = MKMapPointForCoordinate(CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta / 2, region.center.longitude + region.span.longitudeDelta / 2))
        return MKMapRectMake(min(a?.x, b?.x), min(a?.y, b?.y), abs(a?.x - b?.x), abs(a?.y - b?.y))!
    }

// MARK: - Region calculations
    func region(for city: HDKCity) -> MKCoordinateRegion {
        let coord: CLLocationCoordinate2D? = CLLocationCoordinate2DMake(city.latitude, city.longitude)
        let span: MKCoordinateSpan = MKCoordinateSpanMake(HL_CITY_REGION_SPAN, HL_CITY_REGION_SPAN)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(coord, span)
        return region
    }

    func region(forVariants variantsArray: [HLResultVariant]) -> MKCoordinateRegion {
        var locations = [Any]()
        for variant: HLResultVariant in variantsArray {
            if HLMapRegionCalculator.isHotelCoordinateValid(variant.hotel) {
                locations.append(CLLocation(latitude: variant.hotel.latitude, longitude: variant.hotel.longitude))
            }
        }
        return HLMapRegionCalculator.regionContainingLocations(locations, spanHorizontal: HL_VARIANTS_SPAN_COEFF_H, spanVertical: HL_VARIANTS_SPAN_COEFF_V)
    }

    func regionForUserLocation() -> MKCoordinateRegion {
        let coord: CLLocationCoordinate2D = HLLocationManager.sharedManager().location.coordinate
        let span: MKCoordinateSpan = MKCoordinateSpanMake(HL_CITY_REGION_SPAN, HL_CITY_REGION_SPAN)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(coord, span)
        return region
    }

    func region(forUserAndCity city: HDKCity) -> MKCoordinateRegion {
        let userLoc: CLLocation? = HLLocationManager.sharedManager().location
        if userLoc != nil {
            let cityLoc = CLLocation(latitude: city.latitude, longitude: city.longitude)
            var result: MKCoordinateRegion = HLMapRegionCalculator.regionContainingLocations([userLoc, cityLoc], spanCoeff: kMapSpanCoeff)
            result = regionThatFits(result)
            if !HLMapRegionCalculator.coordinateRegion(result, containsCoordinate: cityLoc.coordinate) {
                result = regionForUserLocation()
            }
            return result
        }
        return region(for: city)
    }

// MARK: - Private methods
    func lockAllGestureRecognizers(_ lock: Bool) {
        for rec: UIGestureRecognizer in gestureRecognizers {
            rec.isEnabled = !lock
        }
    }

// MARK: - UIGestureRecognizerDelegate
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UILongPressGestureRecognizer) {
            return false
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view? is MKAnnotationView) {
            gestureRecognizerDelegate?.mapWillReceiveTouch(on: (touch.view as? MKAnnotationView))
        }
        return true
    }
}