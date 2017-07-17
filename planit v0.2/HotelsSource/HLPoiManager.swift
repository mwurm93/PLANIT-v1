//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import CoreLocation
import Foundation
import HotellookSDK

let HL_POI_ANNOTATION_ZPOSITION = -100
let HL_HOTEL_ANNOTATION_ZPOSITION = 100
let HL_SELECTED_ANNOTATION_ZPOSITION = 200
class HLPoiManager: NSObject {
    class func filterPoint(_ filter: Filter, variant: HLResultVariant) -> HDKLocationPoint? {
        let point: HDKLocationPoint? = filter.distanceLocationPoint
        if !(point? is HLGenericCategoryLocationPoint) {
            return point
        }
        let castedPoint: HLGenericCategoryLocationPoint? = (point as? HLGenericCategoryLocationPoint)
        var distance: CGFloat = CGFLOAT_MAX
        var nearestPointOfCategory: HDKLocationPoint? = nil
        for pointOfCategory: HDKLocationPoint in variant.hotel.importantPoiArray {
            if (pointOfCategory.category == castedPoint?.category) {
                if pointOfCategory.distanceToHotel < distance {
                    nearestPointOfCategory = pointOfCategory
                    distance = pointOfCategory.distanceToHotel
                }
            }
        }
        return nearestPointOfCategory
    }

    class func selectHotelDetailsPoints(_ variant: HLResultVariant, filter: Filter?) -> [HDKLocationPoint] {
        let filterSelectedPoint: HDKLocationPoint? = filter?.distanceLocationPoint
        let userLocation: CLLocation? = HLLocationManager.sharedManager().location
        let currentCity: HDKCity? = HLNearbyCitiesDetector.shared.nearbyCities.first
        let customSearchPoint: HDKSearchLocationPoint? = variant.searchInfo.locationPoint
        return self.selectHotelDetailsPoints(variant.hotel, filterSelectedPoint: filterSelectedPoint, userLocation: userLocation, customSearch: customSearchPoint, userCurrentCity: currentCity)
    }

    class func allPoints(_ hotel: HDKHotel, filter: Filter?) -> [HDKLocationPoint] {
        let city: HDKCity? = hotel.city
        var result: [HDKLocationPoint] = [Any](arrayLiteral: hotel.importantPoiArray)
        result = self.selectUniquePoint(from: result, whitelist: self.categoriesWhitelist(forSeasons: city?.seasons), allowMultipleEntriesFor: self.mapMultipleEntriesCategories(forSeasons: city?.seasons))?
        let centerPoi = HLCityLocationPoint(city: city)
        centerPoi.distanceToHotel = HLDistanceCalculator.getDistanceFrom(city, to: hotel)
        result.append(centerPoi)
        let point: HDKLocationPoint? = filter?.distanceLocationPoint
        if self.shouldAdd(point, toMapList: result) {
            result.append(point)
        }
        return result
    }

    class func filterPoints(_ points: [HDKLocationPoint]?, byCategories categories: [String]) -> [HDKLocationPoint] {
        return points?.filter({(_ point: HDKLocationPoint) -> Bool in
            return categories.contains(point?.category)!
        })!
    }

    class func allUniquePoints(forCities cities: [HDKCity]?) -> [HDKLocationPoint] {
        var `set` = Set<AnyHashable>()
        for city: HDKCity in cities {
            `set`.formUnion(Set(city?.points().map { $0 as! AnyHashable }))
        }
        return Array(`set`)
    }

    class func points(from points: [HDKLocationPoint], pointsCategory: String, seasonCategory: String, seasons: [HDKSeason]?) -> [HDKLocationPoint] {
        if self.seasons(seasons, haveCategory: seasonCategory) {
            return self.filterPoints(points, byCategories: [pointsCategory])
        }
        return []
    }

    class func seasons(_ seasons: [HDKSeason], haveCategory category: String) -> Bool {
        for season: HDKSeason in seasons {
            if (season.category == category) {
                return true
            }
        }
        return false
    }

// MARK: - Private
    class func selectHotelDetailsPoints(_ hotel: HDKHotel, filterSelectedPoint filterPoint: HDKLocationPoint, userLocation: CLLocation, customSearch customSearchPoint: HDKSearchLocationPoint, userCurrentCity currentCity: HDKCity) -> [HDKLocationPoint] {
        let city: HDKCity? = hotel.city
        var result: [HDKLocationPoint] = [Any](arrayLiteral: hotel.importantPoiArray)
        result = self.selectUniquePoint(from: result, whitelist: self.categoriesWhitelist(forSeasons: city?.seasons), allowMultipleEntriesFor: nil)?
        if city?.name {
            let centerPoi = HLCityLocationPoint(city: city)
            centerPoi.distanceToHotel = HLDistanceCalculator.getDistanceFrom(city, to: hotel)
            result.append(centerPoi)
        }
        var shouldAddCustomSearchPoint: Bool = customSearchPoint != nil
        if (customSearchPoint is HLSearchAirportLocationPoint) {
            let airportLocationPoint: HLSearchAirportLocationPoint? = (customSearchPoint as? HLSearchAirportLocationPoint)
            shouldAddCustomSearchPoint = result.hl_firstMatch({(_ locationPoint: HDKLocationPoint) -> Bool in
                return locationPoint.category == HDKLocationPointCategory.kAirport && (locationPoint.pointId == airportLocationPoint?.airport?.airportId)!
            }) != nil
        }
        if shouldAddCustomSearchPoint {
            let customPoint = HDKLocationPoint(name: NSLS("HL_LOC_SEARCH_POINT_TEXT"), location: customSearchPoint.location)
            customPoint.distanceToHotel = HLDistanceCalculator.getDistanceFrom(customPoint, to: hotel)
            result.append(customPoint)
        }
        if self.shouldAdd(filterPoint, toDetailsList: result) {
            filterPoint.distanceToHotel = HLDistanceCalculator.getDistanceFrom(filterPoint, to: hotel)
            result.append(filterPoint)
        }
        return self.sortedPoints(byDistance: result)
    }

    class func categoriesWhitelist(forSeasons seasons: [HDKSeason]) -> Set<AnyHashable> {
        var result = Set<AnyHashable>([HDKLocationPointCategory.kMetroStation, "stadium", HDKLocationPointCategory.kTrainStation, HDKLocationPointCategory.kAirport, HDKLocationPointCategory.kUserLocation, HDKLocationPointCategory.kCityCenter])
        if self.seasons(seasons, haveCategory: HDKLocationPointCategory.kBeach) {
            result.insert(HDKLocationPointCategory.kBeach)
        }
        if self.seasons(seasons, haveCategory: HDKSeason.kSkiSeasonCategory) {
            result.insert(HDKLocationPointCategory.kSkilift)
        }
        return result
    }

    class func mapMultipleEntriesCategories(forSeasons seasons: [HDKSeason]) -> Set<AnyHashable> {
        var result = Set<AnyHashable>([HDKLocationPointCategory.kAirport, HDKLocationPointCategory.kTrainStation])
        if self.seasons(seasons, haveCategory: HDKLocationPointCategory.kBeach) {
            result.insert(HDKLocationPointCategory.kBeach)
        }
        if self.seasons(seasons, haveCategory: HDKSeason.kSkiSeasonCategory) {
            result.insert(HDKLocationPointCategory.kSkilift)
        }
        return result
    }

    class func selectUniquePoint(from sourceArray: [HDKLocationPoint], whitelist whitelistSet: Set<AnyHashable>, allowMultipleEntriesFor multipleEntriesSet: Set<AnyHashable>) -> [HDKLocationPoint] {
        let sortedArray: [Any] = self.sortedPoints(byDistance: sourceArray)
        var result = [Any]()
        var takenCategories = Set<AnyHashable>()
        for point: HDKLocationPoint in sortedArray {
            let category: String? = point?.category
            if !category || multipleEntriesSet.containsObject(category) {
                result.append(point)
            }
            else {
                if !takenCategories.containsObject(category) && whitelistSet.containsObject(category) {
                    takenCategories.insert(category)
                    result.append(point)
                }
            }
        }
        return result
    }

    class func sortedPoints(byDistance points: [HDKLocationPoint]) -> [Any] {
        return (points as NSArray).sortedArray(comparator: {(_ point1: HDKLocationPoint, _ point2: HDKLocationPoint) -> ComparisonResult in
            return (point1.distanceToHotel < point2.distanceToHotel) ? .orderedAscending : .orderedDescending
        })
    }

    class func shouldAddPoint(_ point: HDKLocationPoint?, toMapList list: [HDKLocationPoint]) -> Bool {
        return (point && !(point? is HLGenericCategoryLocationPoint) && !list.contains(point))
    }

    class func shouldAdd(_ point: HDKLocationPoint, toDetailsList list: [HDKLocationPoint]) -> Bool {
        return (point && !(point is HLGenericCategoryLocationPoint) && !self.list(list, containsPointWithNameEqualTo: point))
    }

    class func list(_ list: [HDKLocationPoint], containsPointWithNameEqualTo point: HDKLocationPoint) -> Bool {
        for p: HDKLocationPoint in list {
            if (p.name == point.name) {
                return true
            }
        }
        return false
    }

// MARK: - Point selection screen
}