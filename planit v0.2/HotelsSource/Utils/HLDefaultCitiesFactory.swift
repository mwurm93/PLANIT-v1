//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation
import HotellookSDK

class HLDefaultCitiesFactory: NSObject {
    class func defaultCity() -> HDKCity {
        let country: String? = NSLocale.currentLocale.object(forKey: NSLocaleCountryCode)
        return self.city(byCountry: country)
    }

    class func city(byCountry country: String) -> HDKCity {
        let filePath: String = Bundle.main.path(forResource: "HLDefaultCities", ofType: "plist")
        let cities = [AnyHashable: Any](contentsOfFile: filePath)
        let cityDict: [AnyHashable: Any] = cities[country.lowercased()] ?? cities["us"]
        let city: HDKCity? = self.city(fromDict: cityDict)
        return city!
    }

    class func city(fromDict dict: [AnyHashable: Any]) -> HDKCity {
        let cityId: String? = dict.string(forKey: "id")
        let name: String? = dict.string(forKey: "name")
        let countryName: String? = dict.string(forKey: "countryName")
        let hotelsCount: Int = dict.integer(forKey: "hotelsCount")
        let latitude: Double = dict.double(forKey: "latitude")
        let longitude: Double = dict.double(forKey: "longitude")
        let city = HDKCity(cityId: cityId, name: NSLS(name), latinName: nil, fullName: nil, countryName: NSLS(countryName), countryLatinName: nil, countryCode: nil, state: nil, latitude: latitude, longitude: longitude, hotelsCount: hotelsCount, cityCode: nil, points: [], seasons: [])
        return city
    }
}