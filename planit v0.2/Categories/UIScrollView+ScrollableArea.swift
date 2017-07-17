//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import UIKit

extension UIScrollView {
    func hl_setScrollableArea(to view: UIView) {
        let panRec: UIPanGestureRecognizer? = panGestureRecognizer
        view.addGestureRecognizer(panRec!)
    }
}