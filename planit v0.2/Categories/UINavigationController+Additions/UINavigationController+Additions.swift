//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  UINavigationController+Additions.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

extension UINavigationController {
    func replaceTopViewController(with viewController: UIViewController) {
        let viewControllers: [Any] = self.viewControllers
        viewControllers.removeLast()
        viewControllers.append(viewController)
        setViewControllers(viewControllers as? [UIViewController] ?? [UIViewController](), animated: true)
    }
}