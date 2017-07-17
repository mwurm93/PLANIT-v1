//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  UIApplication+TopMostViewController.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//
//
//  UIApplication+TopMostViewController.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

extension UIWindow {
    func topMostController() -> UIViewController {
        var topController: UIViewController? = rootViewController
        while topController?.presentedViewController {
            topController = topController?.presentedViewController
        }
        return topController!
    }

    func topMostControllerIsModal() -> Bool {
        if topMostController().presentingViewController != nil {
            return true
        }
        return false
    }
}