//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import MapKit

class TBClusterAnnotationView: MKAnnotationView {
    var backgroundView: UIView?
    var priceLabel: UILabel?
    var variants = [Any]()

    func initialSetup() {
        backgroundColor = UIColor.clear
        addBackground()
        addPriceLabel()
    }

    func addBackgroundView() {
    }

    func addPriceLabel() {
        priceLabel = UILabel()
        priceLabel?.translatesAutoresizingMaskIntoConstraints = false
        priceLabel?.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        priceLabel?.textAlignment = .center
        backgroundView?.addSubview(priceLabel!)
    }

    override init(annotation: MKAnnotation, reuseIdentifier: String) {
        super.init(annotation: annotation as? MKAnnotation ?? MKAnnotation(), reuseIdentifier: reuseIdentifier as? String ?? "")
        
        initialSetup()
    
    }
}