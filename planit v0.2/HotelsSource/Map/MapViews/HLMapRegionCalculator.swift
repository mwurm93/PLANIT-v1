//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation
import HotellookSDK
import MapKit

class HLMapRegionCalculator: NSObject {
    class func regionContainingLocations(_ locations: [CLLocation], spanCoeff: CGFloat) -> MKCoordinateRegion {
        return self.regionContainingLocations(locations, spanHorizontal: spanCoeff, spanVertical: spanCoeff)
    }

    class func regionContainingLocations(_ locations: [CLLocation], spanHorizontal: CGFloat, spanVertical: CGFloat) -> MKCoordinateRegion {
        var minLat: Double = DBL_MAX
        var maxLat: Double = -DBL_MAX
        var minLon: Double = DBL_MAX
        var maxLon: Double = -DBL_MAX
        for loc: CLLocation in locations {
            let lat: Float? = loc.coordinate.latitude
            let lon: Float? = loc.coordinate.longitude
            minLat = min(minLat, lat)
            maxLat = max(maxLat, lat)
            minLon = min(minLon, lon)
            maxLon = max(maxLon, lon)
        }
        let coord: CLLocationCoordinate2D = CLLocationCoordinate2DMake((maxLat + minLat) / 2.0, (maxLon + minLon) / 2.0)
        let span: MKCoordinateSpan = MKCoordinateSpanMake((maxLat - minLat) * spanHorizontal, (maxLon - minLon) * spanVertical)
        return MKCoordinateRegionMake(coord, span)
    }

    class func coordinateRegion(_ region: MKCoordinateRegion, containsCoordinate coordinate: CLLocationCoordinate2D) -> Bool {
        return coordinate.latitude > region.center.latitude - (region.span.latitudeDelta / 2.0) && coordinate.latitude < region.center.latitude + (region.span.latitudeDelta / 2.0) && coordinate.longitude > region.center.longitude - (region.span.longitudeDelta / 2.0) && coordinate.longitude < region.center.longitude + (region.span.longitudeDelta / 2.0)!
    }

    class func isHotelCoordinateValid(_ hotel: HDKHotel) -> Bool {
        if (hotel is HDKHotel) == false {
            return false
        }
        return (fabs(hotel.latitude) > 0.00001 || fabs(hotel.longitude) > 0.00001) && fabs(hotel.latitude) < 90.0 && fabs(hotel.longitude) < 180.0!
    }
}