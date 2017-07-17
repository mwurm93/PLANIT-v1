//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation
import MapKit

private var nameAccordingToCategoryMap = [AnyHashable: Any]()
private var kDefaultMapPoiIcon: String = "poiDefaultIcon"
private var nameAccordingToCategoryList = [AnyHashable: Any]()
private var kDefaultListPoiIcon: String = "poiDefaultIconList"
private var reuseIdentifier: String = "poiAnnotationView"
private var kSaintPetersburgCityId: String = "12196"
private var kMoscowCityId: String = "12153"

class HLPoiIconSelector: NSObject {
    class func listPoiIcon(_ poi: HDKLocationPoint, city: HDKCity) -> UIImage {
        if nameAccordingToCategoryList == nil {
            nameAccordingToCategoryList = self.createNameAccordingToCategoryList()
        }
        var imageName: String? = nil
        if (poi.category == HDKLocationPointCategory.kMetroStation) {
            if (city.cityId == kSaintPetersburgCityId) {
                imageName = "poiMetroSpbIconList"
            }
            if (city.cityId == kMoscowCityId) {
                imageName = "poiMetroMoscowIconList"
            }
        }
        if imageName == nil {
            imageName = nameAccordingToCategoryList[poi.category] ?? kDefaultListPoiIcon
        }
        return UIImage(named: imageName!)!
    }

    class func mapPoiIcon(_ poi: HDKLocationPoint, city: HDKCity) -> UIImage {
        if nameAccordingToCategoryMap == nil {
            nameAccordingToCategoryMap = self.createNameAccordingToCategoryMap()
        }
        var imageName: String? = nil
        if (poi.category == HDKLocationPointCategory.kMetroStation) {
            if (city.cityId == kSaintPetersburgCityId) {
                imageName = "poiMetroSpbIcon"
            }
            if (city.cityId == kMoscowCityId) {
                imageName = "poiMetroMoscowIcon"
            }
        }
        if imageName == nil {
            imageName = nameAccordingToCategoryMap[poi.category] ?? kDefaultMapPoiIcon
        }
        return UIImage(named: imageName!)!
    }

    class func annotationView(_ annotation: PoiAnnotation, mapView: MKMapView, city: HDKCity) -> MKAnnotationView {
        var annotationView: MKAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation as? MKAnnotation ?? MKAnnotation(), reuseIdentifier: reuseIdentifier as? String ?? "")
            annotationView?.canShowCallout = true
        }
        annotationView?.layer?.zPosition = HL_POI_ANNOTATION_ZPOSITION
        let poi: HDKLocationPoint? = annotation.poi
        let poiImage: UIImage? = self.mapPoiIcon(poi, city: (city as? HDKCity))
        if poiImage != nil {
            annotationView?.image = poiImage
            return annotationView!
        }
        return nil
    }

    class func createNameAccordingToCategoryList() -> [AnyHashable: Any] {
        return [HDKLocationPointCategory.kAirport: "poiAirportIconList", HDKLocationPointCategory.kTrainStation: "poiStationIconList", HDKLocationPointCategory.kMetroStation: "poiMetroIconList", HDKLocationPointCategory.kBeach: "poiBeachIconList", "stadium": "poiStadiumIconList", HDKLocationPointCategory.kSkilift: "poiSkiIconList", HDKLocationPointCategory.kCityCenter: "poiCenterIconList", HDKLocationPointCategory.kUserLocation: "poiUserIconList"]
    }

    class func createNameAccordingToCategoryMap() -> [AnyHashable: Any] {
        return [HDKLocationPointCategory.kAirport: "poiAirportIcon", HDKLocationPointCategory.kTrainStation: "poiStationIcon", HDKLocationPointCategory.kMetroStation: "poiMetroIcon", HDKLocationPointCategory.kBeach: "poiBeachIcon", "stadium": "poiStadiumIcon", HDKLocationPointCategory.kSkilift: "poiSkiIcon", HDKLocationPointCategory.kCityCenter: "poiCenterIcon", HDKLocationPointCategory.kUserLocation: kDefaultMapPoiIcon]
    }
}