//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import CoreLocation
import Foundation
import HotellookSDK
import MapKit

class HLDistanceCalculator: NSObject {
    class func getDistanceFrom(_ hotel: HDKHotel, to location: CLLocation) -> Double {
        let hotelLocation = CLLocation(latitude: hotel.latitude, longitude: hotel.longitude)
        return hotelLocation.distance(from: location)
    }

    class func getDistanceFrom(_ point: HDKLocationPoint, to hotel: HDKHotel) -> Double {
        let loc1 = CLLocation(latitude: hotel.latitude, longitude: hotel.longitude)
        return loc1.distance(from: point.location)
    }

    class func getDistanceFromUser(to hotel: HDKHotel) -> Double {
        let location = CLLocation(latitude: hotel.latitude, longitude: hotel.longitude)
        return HLDistanceCalculator.shared().getDistanceFromUser(to: location)
    }

    class func getDistanceFrom(_ city: HDKCity, to hotel: HDKHotel) -> Double {
        let loc1 = CLLocation(latitude: hotel.latitude, longitude: hotel.longitude)
        let loc2 = CLLocation(latitude: city.latitude, longitude: city.longitude)
        return loc1.distance(from: loc2)
    }

    class func getDistanceFrom(_ hotel: HDKHotel, toPointsOfCategory category: String, undefinedDistance: CGFloat) -> CGFloat {
        var distance: CGFloat = undefinedDistance
        let filteredPoints: [Any] = HLPoiManager.filterPoints(hotel.importantPoiArray, byCategories: [category])
        for point: HDKLocationPoint in filteredPoints {
            distance = min(distance, self.getDistanceFrom(point, to: hotel))
        }
        return distance
    }

    class func convertKilometers(toMiles kilometers: Double) -> Double {
        return kilometers
        //	return kilometers/HL_MILE_LENGTH;
    }

    class func convertMeters(toKilometers meters: Double) -> Double {
        return meters / 1000.0
    }

    class func calculateDistances(fromVariants variants: [Any], to point: HDKLocationPoint) {
        for variant: HLResultVariant in variants {
            let distance: CGFloat = HLDistanceCalculator.getDistanceFrom(point, to: variant.hotel)
            variant.distanceToCurrentLocationPoint = distance
        }
    }

    class func shared() -> HLDistanceCalculator {
        var calculator: HLDistanceCalculator? = nil
        var onceToken: Int
        if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
            calculator = HLDistanceCalculator()
        }
        onceToken = 1
        return calculator!
    }

    func getDistanceFromUser(to location: CLLocation) -> Double {
        //	HLLocationManager * manager = [HLLocationManager sharedManager];
        //	CLLocation * currentLocation = [manager location];
        //	if(currentLocation){
        //		return [location distanceFromLocation:currentLocation];
        //	}
        //	else{
        return -1
        //	}
    }
}