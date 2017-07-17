//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFilterListHeaderCell.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class JRFilterListHeaderCell: UITableViewCell {
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var openIndicator: UIImageView!
    @IBOutlet weak var alphaView: UIView!
    private var _item: JRFilterListHeaderItem?
    var item: JRFilterListHeaderItem? {
        get {
            return _item
        }
        set(item) {
            _item = item
            expanded = item.isExpanded
            openIndicator.transform = CGAffineTransform(scaleX: 1.0, y: item.isExpanded ? 1.0 : -1.0)
            headerTitle.text = item.tilte
        }
    }
    private var _isExpanded: Bool = false
    var isExpanded: Bool {
        get {
            return _isExpanded
        }
        set(expanded) {
            setExpanded(expanded, animated: false)
        }
    }

    var isAnimationPerform: Bool = false

    func setExpanded(_ expanded: Bool, animated: Bool) {
        isExpanded = expanded
        item.isExpanded = expanded
        let duration: TimeInterval = animated ? 0.2 : 0.0
        UIView.animate(withDuration: duration, animations: {() -> Void in
            openIndicator.transform = CGAffineTransform(scaleX: 1.0, y: isExpanded ? 1.0 : -1.0)
        })
    }
}