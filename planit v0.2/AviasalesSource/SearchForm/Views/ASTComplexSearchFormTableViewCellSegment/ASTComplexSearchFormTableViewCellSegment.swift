//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  ASTComplexSearchFormTableViewCellSegment.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class ASTComplexSearchFormTableViewCellSegment: UIView {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    var tapAction: ((_ sender: UIView) -> Void)? = nil

    @IBOutlet var view: UIView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadViewFromNib()
    
    }

    func loadViewFromNib() {
        view = Bundle.main.loadNibNamed(NSStringFromClass(ASTComplexSearchFormTableViewCellSegment), owner: self, options: nil)?.first
        view.frame = bounds
        addSubview(view as? UIView ?? UIView())
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.tintColor = JRColorScheme.searchFormTintColor()
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