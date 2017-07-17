//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation
import MapKit

extension MKMapView {
    func hl_refreshAnnotations(animated: Bool) {
        if animated {
            let annotations: [MKAnnotation] = self.annotations
            removeAnnotations(annotations)
            addAnnotations(annotations)
        }
        else {
            // http://stackoverflow.com/a/1205230
            setCenter(region.center, animated: false)
        }
    }
}