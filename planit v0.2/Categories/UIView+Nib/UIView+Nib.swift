//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  UIView+Nib.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

extension UIView {
    class func loadFromNib() -> UIView? {
        let componets: [String] = NSStringFromClass(self).components(separatedBy: ".")
        let array: [Any]? = Bundle.main.loadNibNamed(componets.last!, owner: nil, options: nil)
        return array?.first!
    }
}