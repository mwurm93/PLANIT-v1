//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRViewController.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

let kJRViewControllerTopHeight = 0.5
let kJRBaseMenuButtonImageName = "JRBaseMenuButton"
let kJRBaseBackButtonImageName = "back_icon"
class JRViewController: UIViewController {
    var isViewIsVisible: Bool = false

    weak var menuButton: UIButton?

    func shouldShowNavigationBar() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSStringFromClass(JRViewController)
        updateBackgroundColor()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar?.layer?.removeAllAnimations()
        if UIAccessibilityIsVoiceOverRunning() {
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil)
            if navigationItem.titleView {
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, navigationItem.titleView.accessibilityLabel)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isViewIsVisible = false
        if iPhone() {
            navigationController.navigationBar?.layer?.removeAllAnimations()
        }
    }

    func updateBackgroundColor() {
        view.backgroundColor = JRColorScheme.mainBackgroundColor()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewIsVisible = true
    }
}