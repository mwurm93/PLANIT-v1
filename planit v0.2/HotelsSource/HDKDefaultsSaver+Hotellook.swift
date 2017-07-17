//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import HotellookSDK

let HL_MAX_RECENT_CITIES_COUNT = 10
let HL_MAX_RECENT_GOOGLE_POINTS = 10
let HL_MAX_RECENT_NAME_FILTERS_COUNT = 10
let kRecentSelectedPoints: String = "googleRecentSelectedPoints"
let kDefaultsLastSelectedCities: String = "lastSelectedCities"
let kDefaultsLastSelectedNameFilters: String = "lastSelectedNameFilters"

extension HDKDefaultsSaver {
    class func getRecentSearchDestinations() -> [Any] {
        var recentDestinations: [Any]? = nil
        defer {
        }
        do {
            recentDestinations = self.loadObject(withKey: kDefaultsLastSelectedCities)
        } catch let exception {
        } 
        return recentDestinations!
    }

    class func addRecentSearchDestination(_ object: Any) {
        var newRecentSearchDestinations = self.getRecentSearchDestinations() ?? [Any]()
        if newRecentSearchDestinations.contains(object) {
            newRecentSearchDestinations.remove(at: newRecentSearchDestinations.index(of: object)!)
        }
        newRecentSearchDestinations.insert(object, at: 0)
        let result: [Any] = newRecentSearchDestinations[NSRange(location: 0, length: min(HL_MAX_RECENT_CITIES_COUNT, newRecentSearchDestinations.count)).location..<NSRange(location: 0, length: min(HL_MAX_RECENT_CITIES_COUNT, newRecentSearchDestinations.count)).location + NSRange(location: 0, length: min(HL_MAX_RECENT_CITIES_COUNT, newRecentSearchDestinations.count)).length]
        self.saveObject(result, forKey: kDefaultsLastSelectedCities)
    }

    class func getRecentFilterPoints(for city: HDKCity) -> [Any] {
        let key: String = self.googlePointsKey(for: city)
        let points: [Any] = self.loadObject(withKey: key)
        return points
    }

    class func addRecentFilterPoint(_ point: HDKLocationPoint, for city: HDKCity) {
        if (point is HLCityLocationPoint) {
            return
        }
        let key: String = self.googlePointsKey(for: city)
        var points: [Any] = self.loadObject(withKey: key)
        if points == nil {
            points = [Any]()
        }
        if points.contains(point) {
            points.remove(at: points.index(of: point)!)
        }
        points.insert(point, at: 0)
        let result: [Any] = points[NSRange(location: 0, length: min(HL_MAX_RECENT_GOOGLE_POINTS, points.count)).location..<NSRange(location: 0, length: min(HL_MAX_RECENT_GOOGLE_POINTS, points.count)).location + NSRange(location: 0, length: min(HL_MAX_RECENT_GOOGLE_POINTS, points.count)).length]
        self.saveObject(result, forKey: key)
    }

    class func getRecentSelectedNameFilter() -> [Any] {
        return self.loadObject(withKey: kDefaultsLastSelectedNameFilters)
    }

    class func addRecentSelectedNameFilter(_ object: Any) {
        var newFilters: [Any] = self.getRecentSelectedNameFilter()
        if newFilters == nil {
            newFilters = [Any]()
        }
        if newFilters.contains(object) {
            newFilters.remove(at: newFilters.index(of: object)!)
        }
        newFilters.insert(object, at: 0)
        let result: [Any] = newFilters[NSRange(location: 0, length: min(HL_MAX_RECENT_NAME_FILTERS_COUNT, newFilters.count)).location..<NSRange(location: 0, length: min(HL_MAX_RECENT_NAME_FILTERS_COUNT, newFilters.count)).location + NSRange(location: 0, length: min(HL_MAX_RECENT_NAME_FILTERS_COUNT, newFilters.count)).length]
        self.saveObject(result, forKey: kDefaultsLastSelectedNameFilters)
    }

    class func googlePointsKey(for city: HDKCity) -> String {
        var key: String = kRecentSelectedPoints
        key = key + (city.cityId)
        return key
    }
}