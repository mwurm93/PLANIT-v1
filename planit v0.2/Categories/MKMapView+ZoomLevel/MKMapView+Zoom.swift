//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import MapKit

extension MKMapView {
// MARK: - Map conversion methods

    func setCenterCoordinate(_ centerCoordinate: CLLocationCoordinate2D, zoom: Double, animated: Bool) {
        zoom = min(zoom, 28)
        let span: MKCoordinateSpan = coordinateSpan(with: self, centerCoordinate: centerCoordinate, andZoom: zoom)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(centerCoordinate, span)
        setRegion(region, animated: animated)
    }

    func zoom() -> Double {
        let region: MKCoordinateRegion = self.region
        let centerPixelX: Double = MKMapView.longitude(toPixelSpaceX: region.center.longitude)
        let topLeftPixelX: Double = MKMapView.longitude(toPixelSpaceX: region.center.longitude - region.span.longitudeDelta / 2)
        let scaledMapWidth: Double = (centerPixelX - topLeftPixelX) * 2
        let mapSizeInPixels: CGSize = bounds.size
        let zoomScale: Double = scaledMapWidth / mapSizeInPixels.width
        let zoomExponent: Double = log(zoomScale) / log(2)
        let zoom: Double = 20 - zoomExponent
        return zoom
    }

    class func longitude(toPixelSpaceX longitude: Double) -> Double {
        return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * .pi / 180.0)
    }

    class func latitude(toPixelSpaceY latitude: Double) -> Double {
        if latitude == 90.0 {
            return 0
        }
        if latitude == -90.0 {
            return MERCATOR_OFFSET * 2
        }
        return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * .pi / 180.0)) / (1 - sinf(latitude * .pi / 180.0))) / 2.0)
    }

    class func pixelSpaceX(toLongitude pixelX: Double) -> Double {
        return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / .pi
    }

    class func pixelSpaceY(toLatitude pixelY: Double) -> Double {
        return (.pi / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / .pi
    }

// MARK: - Helper methods
    func coordinateSpan(with mapView: MKMapView, centerCoordinate: CLLocationCoordinate2D, andZoom zoom: Double) -> MKCoordinateSpan {
            // convert center coordiate to pixel space
        let centerPixelX: Double = MKMapView.longitude(toPixelSpaceX: centerCoordinate.longitude)
        let centerPixelY: Double = MKMapView.latitude(toPixelSpaceY: centerCoordinate.latitude)
        let zoomExponent: Double = 20 - zoom
        let zoomScale: Double = pow(2, zoomExponent)
            // scale the map’s size in pixel space
        let mapSizeInPixels: CGSize = mapView.bounds.size
        let scaledMapWidth: Double = mapSizeInPixels.width * zoomScale
        let scaledMapHeight: Double = mapSizeInPixels.height * zoomScale
            // figure out the position of the top-left pixel
        let topLeftPixelX: Double = centerPixelX - (scaledMapWidth / 2)
        let topLeftPixelY: Double = centerPixelY - (scaledMapHeight / 2)
            // find delta between left and right longitudes
        let minLng: CLLocationDegrees = MKMapView.pixelSpaceX(toLongitude: topLeftPixelX)
        let maxLng: CLLocationDegrees = MKMapView.pixelSpaceX(toLongitude: topLeftPixelX + scaledMapWidth)
        let longitudeDelta: CLLocationDegrees = maxLng - minLng
            // find delta between top and bottom latitudes
        let minLat: CLLocationDegrees = MKMapView.pixelSpaceY(toLatitude: topLeftPixelY)
        let maxLat: CLLocationDegrees = MKMapView.pixelSpaceY(toLatitude: topLeftPixelY + scaledMapHeight)
        let latitudeDelta: CLLocationDegrees = -1 * (maxLat - minLat)
        return MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
    }

// MARK: - Public methods
}

let MERCATOR_OFFSET = 268435456
let MERCATOR_RADIUS = 85445659.44705395