//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import HotellookSDK

extension HDKCity {
    func airports() -> [HDKLocationPoint] {
        return HLPoiManager.filterPoints(points(), byCategories: [HDKLocationPointCategory.kAirport])
    }
}