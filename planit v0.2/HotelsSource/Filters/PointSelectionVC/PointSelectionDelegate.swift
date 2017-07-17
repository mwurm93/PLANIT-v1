//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import HotellookSDK

protocol PointSelectionDelegate: NSObjectProtocol {
    func openPointSelectionScreen()
    func locationPointSelected(_ point: HDKLocationPoint)
}