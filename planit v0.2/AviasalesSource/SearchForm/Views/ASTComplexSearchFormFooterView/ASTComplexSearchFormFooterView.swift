//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  ASTComplexSearchFormFooterView.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class ASTComplexSearchFormFooterView: UIView {
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    var addAction: ((_ sender: UIButton) -> Void)? = nil
    var removeAction: ((_ sender: UIButton) -> Void)? = nil

    @IBOutlet var view: UIView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadFromNib()
    
    }

    func loadFromNib() {
        view = Bundle.main.loadNibNamed(NSStringFromClass(ASTComplexSearchFormFooterView), owner: self, options: nil)?.first
        view.frame = bounds
        addSubview(view as? UIView ?? UIView())
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        removeButton.layer.cornerRadius = 4.0
        addButton.layer.cornerRadius = removeButton.layer.cornerRadius
        removeButton.layer.borderWidth = 1.0
        addButton.layer.borderWidth = removeButton.layer.borderWidth
        removeButton.tintColor = JRColorScheme.searchFormTintColor()
        addButton.tintColor = removeButton.tintColor
        removeButton.layer.borderColor = JRColorScheme.searchFormTintColor().cgColor
        addButton.layer.borderColor = removeButton.layer.borderColor
    }

// MARK: - Actions
    @IBAction func addButtonTapped(_ sender: UIButton) {
        if addAction != nil {
            addAction(sender)
        }
    }

    @IBAction func removeButtonTapped(_ sender: UIButton) {
        if removeAction != nil {
            removeAction(sender)
        }
    }
}