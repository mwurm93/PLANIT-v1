//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import UIKit

class HLAutolayoutView: UIView {
    var isDidSetupConstraints: Bool = false

    func setupConstraints() {
        // Implement in subclass
    }

    func initialize() {
        // Implement in subclass
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateConstraintsIfNeeded()
    }

    override func updateConstraints() {
        super.updateConstraints()
        if !isDidSetupConstraints {
            setupConstraints()
            isDidSetupConstraints = true
        }
    }
}