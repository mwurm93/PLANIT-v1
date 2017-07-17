//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  UIView+NSLS.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

extension UIView {
    @IBInspectable var nslsKey: String = ""

    func nslsKey() -> String {
        return nil
    }

    func setNSLSKey(_ NSLSKey: String) {
        let localizedString: String = NSLS(NSLSKey)
        let strongSelf: Any? = self
        if (strongSelf? is UILabel) {
            let label: UILabel? = strongSelf
            label?.text = localizedString as? String ?? ""
        }
        else if (strongSelf? is UIButton) {
            let button: UIButton? = strongSelf
            button?.setTitle(localizedString as? String ?? "", for: .normal)
        }

    }
}