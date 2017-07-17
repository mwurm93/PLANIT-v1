//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  UINavigationItem+JRCustomBarItems.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

let kJRCustomBarItemsNegativeSeperatorWidth = 10
extension UINavigationItem {
    class func barItem(withImageName imageName: String, selectedImageName: String, buttonClass: AnyClass, target: Any, action: Selector) -> UIBarButtonItem {
        let btn: Any? = buttonClass()
        let button: UIButton? = (btn as? UIButton)
        button?.adjustsImageWhenHighlighted = false
        let image = UIImage(named: imageName)
        let selectedImage = selectedImageName ? UIImage(named: selectedImageName) : nil
        button?.setImage(image, for: .normal)
        if selectedImage != nil {
            button?.setImage(UIImage(named: selectedImageName), for: .selected)
        }
        button?.setupButtonStates = true
        button?.addTarget(target, action: action, for: .touchUpInside)
        button?.frame = CGRect(x: 0, y: 0, width: max(image?.size?.width, selectedImage?.size?.width), height: max(image?.size?.height, selectedImage?.size?.height))
        let barButton = UIBarButtonItem(customView: button!)
        return barButton
    }

    class func barItem(withImageName imageName: String, selectedImageName: String, target: Any, action: Selector) -> UIBarButtonItem {
        return self.barItem(withImageName: imageName, selectedImageName: selectedImageName, buttonClass: UIButton.self, target: target, action: action)
    }

    class func barItem(withImageName imageName: String, target: Any, action: Selector) -> UIBarButtonItem {
        return self.barItem(withImageName: imageName, selectedImageName: nil, buttonClass: UIButton.self, target: target, action: action)
    }

    class func barItem(withTitle title: String, target: Any, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setTitle(title as? String ?? "", for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.showsTouchWhenHighlighted = true
        let barButton = UIBarButtonItem(customView: button as? UIView ?? UIView())
        return barButton
    }
}