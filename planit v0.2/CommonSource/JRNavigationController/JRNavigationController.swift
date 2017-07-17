//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRNavigationController.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

let kJRNavigationControllerDefaultTextSize = 17
class JRNavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    var isAllowedIphoneAutorotate: Bool = false

    var screenshotAlertsButton: UIButton?
    var screenshotPopoversButton: UIButton?

    func removeAllViewControllersExceptCurrent() {
        viewControllers = [viewControllers.last]
    }

    func setupNavigationBar() {
        navigationBar.barTintColor = JRColorScheme.navigationBarBackgroundColor()
        navigationBar.tintColor = JRColorScheme.navigationBarItemColor()
        navigationBar.isTranslucent = false
        navigationBar.setBackgroundImage(UIImage(), for: UIBarMetricsDefault)
        navigationBar.shadowImage = UIImage()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: JRColorScheme.navigationBarItemColor(), NSFontAttributeName: UIFont.systemFont(ofSize: 15.0, weight: .medium)]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        if iPhone() {
            delegate = self
            interactivePopGestureRecognizer?.delegate = self
        }
    }

// MARK: UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if (viewController is JRViewController) {
            setNavigationBarHidden(!(viewController as? JRViewController)?.shouldShowNavigationBar(), animated: animated)
        }
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UIScreenEdgePanGestureRecognizer) {
            let point: CGPoint = gestureRecognizer.location(in: view)
            let subview: UIView? = view.hitTest(point, with: nil)
            let subviewIsSlider: Bool = (subview? is HLRangeSlider) || (subview? is UISlider)
            let isInteractivePopForRootVC: Bool? = gestureRecognizer == interactivePopGestureRecognizer && viewControllers.count <= 1
            if subviewIsSlider || isInteractivePopForRootVC {
                return false
            }
        }
        return true
    }

    func disablesAutomaticKeyboardDismissal() -> Bool {
        return false
    }

// MARK: autorotation
    func shouldAutorotate() -> Bool {
        if iPhone() && !isAllowedIphoneAutorotate {
            return false
        }
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if iPhone() && !isAllowedIphoneAutorotate {
            return .portrait
        }
        return super.supportedInterfaceOrientations
    }
}