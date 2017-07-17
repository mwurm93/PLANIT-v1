//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  ASTSearchFormPassengersView.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class ASTSearchFormPassengersView: UIView {
    @IBOutlet var icons: [UIImageView]!
    @IBOutlet weak var adultsLabel: UILabel!
    @IBOutlet weak var childrenLabel: UILabel!
    @IBOutlet weak var infantsLabel: UILabel!
    @IBOutlet weak var travelClassLabel: UILabel!
    var tapAction: ((_ sender: UIView) -> Void)? = nil

    @IBOutlet var view: UIView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadFromNib()
    
    }

    func loadFromNib() {
        view = Bundle.main.loadNibNamed(NSStringFromClass(ASTSearchFormPassengersView), owner: self, options: nil)?.first
        view.frame = bounds
        addSubview(view as? UIView ?? UIView())
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        icons.makeObjectsPerformSelector(#selector(self.setTintColor), withObject: JRColorScheme.searchFormTintColor())
    }

    func animateTap(in view: UIView) {
        view.alpha = 0.5
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            view.alpha = 1.0
        })
    }

    @IBAction func viewTapped(_ sender: UIView) {
        animateTap(in: sender)
        if tapAction != nil {
            tapAction(sender)
        }
    }
}