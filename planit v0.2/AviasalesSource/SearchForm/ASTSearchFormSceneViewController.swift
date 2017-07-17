//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  ASTSearchFormSceneViewController.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class ASTSearchFormSceneViewController: UIViewController {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!

// MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

// MARK: - Setup
    func setupViewController() {
        applyStyle()
        setupNavigationItems()
        instantiateChild()
    }

    func applyStyle() {
        view.backgroundColor = JRColorScheme.searchFormBackgroundColor()
        shadowView.backgroundColor = JRColorScheme.searchFormBackgroundColor()
        shadowView.applyShadowLayer()
    }

    func setupNavigationItems() {
        navigationItem.title = NSLS("JR_SEARCH_FORM_TITLE")
        navigationItem.backBarButtonItem = UIBarButtonItem.backBarButtonItem
    }

    func instantiateChildViewController() {
        let containerSearchFormViewController = ASTContainerSearchFormViewController()
        addChildViewController(containerSearchFormViewController as? UIViewController ?? UIViewController())
        containerView?.addSubview(containerSearchFormViewController.view)
        containerSearchFormViewController.view.translatesAutoresizingMaskIntoConstraints = false
        containerView?.addConstraints(JRConstraintsMakeScaleToFill(containerSearchFormViewController.view, containerView))
        containerSearchFormViewController.didMove(toParentViewController: self)
    }
}