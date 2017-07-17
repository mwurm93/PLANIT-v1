//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation
import HotellookSDK

var hotelsRank = [String: NSNumber]()
var hotelsRank = [String: NSNumber]()
var hotelId: String = variant.hotel.hotelId
var variantBadges = [Any]()
var onlyRatingBadge: Bool? = hotelsBadges.array(forKey: variant.hotel.hotelId)?.count == 0 && !variant.searchInfo.isSearchByLocation && !variant.hasDiscount
var badges = [String: HDKBadge]()
var = [String]()
var hotelBadgeNames: [Any]? = hotelsBadges.array(forKey: variant.hotel.hotelId)
var badgesDomainObjects: [Any]? = hotelBadgeNames?.map({(_ name: String) -> HLPopularHotelBadge in
        return self.badge(by: name, badgesDictionary: badges)
    })
var userLocationSearch: Bool = (variant.searchInfo.locationPoint is HLSearchUserLocationPoint)
var pointType: DistancePointType = userLocationSearch ? DistancePointTypeUserLocation : DistancePointTypeCustomLocation
var searchLocationPoint: CLLocation? = variant.searchInfo.locationPoint.location
var hotelLocation = CLLocation(latitude: variant.hotel.latitude, longitude: variant.hotel.longitude)
var distance: Double? = searchLocationPoint?.distance(from: hotelLocation)
var hotelsRank = [String: NSNumber]()

class HLBadgeParser: NSObject {
    var = [String]()

    var = [String]()

    func fillBadges(for variants: [HLResultVariant], badgesDictionary badges: [String: HDKBadge], hotelsBadges NSDictionary: Any) {
    }
}