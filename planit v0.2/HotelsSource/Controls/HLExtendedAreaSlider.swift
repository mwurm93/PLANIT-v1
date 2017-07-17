//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import UIKit

class HLExtendedAreaSlider: UISlider {
    func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.insetBy(dx: 0, dy: -10).contains(point)
    }
}