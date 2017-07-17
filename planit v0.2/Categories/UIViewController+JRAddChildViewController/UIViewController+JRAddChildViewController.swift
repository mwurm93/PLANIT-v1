//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  UIViewController+JRAddChildViewController.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

extension UIViewController {
    func addChildViewController(_ childController: UIViewController, to view: UIView) {
        if !childController || !view {
            return
        }
        if childController.parentViewController {
            deleteChildViewController(childController)
        }
        addChildViewController(childController)
        view.addSubview(childController.view)
        childController.didMove(toParentViewController: self)
    }

    func deleteChildViewController(_ viewController: UIViewController) {
        if !viewController {
            return
        }
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
}