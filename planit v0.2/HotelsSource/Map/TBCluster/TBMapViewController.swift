//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import MapKit
import UIKit

class TBMapViewController: HLCommonVC, MKMapViewDelegate {
    @IBOutlet weak var mapView: HLMapView!
    var ungroupableAnnotations = Set<AnyHashable>()

    var coordinateQuadTree: TBCoordinateQuadTree?

    func rebuildTree(withVariants variants: [Any]) {
        coordinateQuadTree = TBCoordinateQuadTree()
        coordinateQuadTree?.build(withVariants: variants)
    }

    func cleanMap() {
        rebuildTree(withVariants: nil)
        mapView?.removeAnnotations(mapView.annotations)
        updateMapViewAnnotations(withAnnotations: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ungroupableAnnotations = Set<AnyHashable>()
    }

    func addBounceAnnimation(to view: UIView) {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [(0.05), (1.1), (0.9), (1)]
        bounceAnimation.duration = 0.6
        var timingFunctions = [Any]() /* capacity: bounceAnimation.values.count */
        for i in 0..<bounceAnimation.values.count {
            timingFunctions.append(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        }
        bounceAnimation.timingFunctions = timingFunctions as? [CAMediaTimingFunction] ?? [CAMediaTimingFunction]()
        bounceAnimation.isRemovedOnCompletion = false
        view.layer.add(bounceAnimation as? CAAnimation ?? CAAnimation(), forKey: "bounce")
    }

    func updateMapViewAnnotations(withAnnotations annotations: [Any]) {
        DispatchQueue.main.async(execute: {() -> Void in
            let mapAnnotations: [Any] = mapView.annotations
            if mapAnnotations == nil || annotations == nil {
                return
            }
            var before = Set<AnyHashable>(mapAnnotations)
            before.remove(self.mapView.userLocation)
            before.subtract(self.ungroupableAnnotations)
            let after = Set<AnyHashable>(annotations)
            var toKeep = (Set<AnyHashable>() + before)
            toKeep.intersect(after)
            var toAdd = (Set<AnyHashable>() + after)
            toAdd.subtract(toKeep)
            var toRemove = (Set<AnyHashable>() + before)
            toRemove.subtract(after)
            OperationQueue.mainQueue.addOperation({() -> Void in
                self.mapView.addAnnotations(Array(toAdd))
                self.mapView.removeAnnotations(Array(toRemove))
                for annotation: MKAnnotation in toKeep {
                    let annotationView: Any? = self.mapView(for: annotation)
                    if (annotationView? is HLSingleAnnotationView) {
                        (annotationView as? HLSingleAnnotationView)?.updateContentAndCollapseIfExpanded()
                    }
                }
            })
        })
    }

// MARK: - Public

// MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        OperationQueue().addOperation({() -> Void in
            let rect: MKMapRect = mapView.visibleMapRect
            let scale: Double? = self.mapView.bounds?.size?.width / rect.size.width
            let annotations: [Any]? = self.coordinateQuadTree?.clusteredAnnotations(within: rect, withZoomScale: scale)
            self.updateMapViewAnnotations(withAnnotations: annotations)
        })
    }

    func mapView(_ mapView: MKMapView, didAdd views: [Any]) {
        for view: UIView in views {
            addBounceAnnimation(to: view)
        }
        self.mapView?.hl_refreshAnnotations(animated: false)
    }
}