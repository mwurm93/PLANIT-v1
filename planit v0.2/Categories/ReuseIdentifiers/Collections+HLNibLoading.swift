//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation

extension UITableView {
    func hl_registerNib(withName name: String) {
        register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
    }
}

extension UICollectionView {
    func hl_registerNib(withName name: String) {
        register(UINib(nibName: name, bundle: nil), forCellWithReuseIdentifier: name)
    }
}