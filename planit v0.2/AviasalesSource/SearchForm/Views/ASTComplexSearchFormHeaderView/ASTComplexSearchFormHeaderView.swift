//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  ASTComplexSearchFormHeaderView.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class ASTComplexSearchFormHeaderView: UIView {
    @IBOutlet var view: UIView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadFromNib()
    
    }

    func loadFromNib() {
        view = Bundle.main.loadNibNamed(NSStringFromClass(ASTComplexSearchFormHeaderView), owner: self, options: nil)?.first
        view.frame = bounds
        addSubview(view as? UIView ?? UIView())
    }
}