//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  ASTContainerSearchFormViewController.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

enum ASTContainerSearchFormSearchType : Int {
    case simple = 0
    case complex = 1
}


class ASTContainerSearchFormViewController: UIViewController, HotelsSearchDelegate {
    @IBOutlet weak var searchFormTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    var simpleSearchFormViewController: ASTSimpleSearchFormViewController?
    var complexSearchFormViewController: ASTComplexSearchFormViewController?
    weak var currentChildViewController: ASTContainerSearchFormChildViewControllerProtocol?
    @IBOutlet weak var searchButtonBottomLayoutConstraint: NSLayoutConstraint!

// MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        InteractionManager.shared.ticketsSearchForm = self
        setup()
        showChildViewController(simpleSearchFormViewController)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchButtonBottomLayoutConstraint.constant = (bottomLayoutGuide.characters.count ?? 0)
    }

// MARK: - Setup
    func setupViewController() {
        view.backgroundColor = JRColorScheme.searchFormBackgroundColor()
        setupNavigationItems()
        setupSegmentedControl()
        setupSearchButton()
        setupChildViewControllers()
    }

    func setupSegmentedControl() {
        searchFormTypeSegmentedControl.tintColor = JRColorScheme.searchFormTintColor()
        searchFormTypeSegmentedControl.setTitle(NSLS("JR_SEARCH_FORM_SIMPLE_SEARCH_SEGMENT_TITLE"), forSegmentAt: .simple)
        searchFormTypeSegmentedControl.setTitle(NSLS("JR_SEARCH_FORM_COMPLEX_SEARCH_SEGMENT_TITLE"), forSegmentAt: .complex)
    }

    func setupSearchButton() {
        searchButton.tintColor = JRColorScheme.mainButtonTitleColor()
        searchButton.backgroundColor = JRColorScheme.mainButtonBackgroundColor()
        searchButton.layer.cornerRadius = 20.0
        let attributedString = NSAttributedString(string: NSLS("JR_SEARCH_FORM_SEARCH_BUTTON"), attributes: [NSFontAttributeName: UIFont(name: ".SFUIText-Bold", size: 16.0)])
        searchButton.setAttributedTitle(attributedString as? NSAttributedString ?? NSAttributedString(), for: .normal)
    }

    func setupNavigationItems() {
        navigationItem.title = NSLS("JR_SEARCH_FORM_TITLE")
        navigationItem.backBarButtonItem = UIBarButtonItem.backBarButtonItem
    }

    func setupChildViewControllers() {
        simpleSearchFormViewController = ASTSimpleSearchFormViewController()
        complexSearchFormViewController = ASTComplexSearchFormViewController()
    }

// MARK: - Container Managment
    func showSimpleSearchForm() {
        switch(complexSearchFormViewController, to: simpleSearchFormViewController)
    }

    func showComplexSearchForm() {
        switch(simpleSearchFormViewController, to: complexSearchFormViewController)
    }

    func switch(_ viewControllerToHide: ASTContainerSearchFormChildViewControllerProtocol, toViewController viewControllerToShow: ASTContainerSearchFormChildViewControllerProtocol) {
        hideChildViewController(viewControllerToHide)
        showChildViewController(viewControllerToShow)
    }

    func hideChildViewController(_ viewController: ASTContainerSearchFormChildViewControllerProtocol) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }

    func showChildViewController(_ viewController: ASTContainerSearchFormChildViewControllerProtocol) {
        addChildViewController(viewController as? UIViewController ?? UIViewController())
        viewController.view.frame = containerView.bounds
        containerView?.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
        currentChildViewController = viewController
    }

// MARK: - Actions
    @IBAction func searchFormTypeSegmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case .simple:
                showSimpleSearchForm()
            case .complex:
                showComplexSearchForm()
        }

    }

    @IBAction func searchButtonTapped(_ sender: UIButton) {
        let currencyCode: String = InteractionManager.shared.currency.code.lowercased()
        if !(currencyCode == AviasalesSDK.sharedInstance.currencyCode) {
            AviasalesSDK.sharedInstance.updateCurrencyCode(currencyCode)
        }
        currentChildViewController?.performSearch()
    }

// MARK: - HotelsSearchDelegate
    func updateSearchInfo(withDestination destination: JRSDKAirport, checkIn: Date, checkOut: Date, passengers: ASTPassengersInfo) {
        showSimpleSearchForm()
        searchFormTypeSegmentedControl.selectedSegmentIndex = .simple
        simpleSearchFormViewController?.updateSearchInfo(withDestination: destination, checkIn: checkIn, checkOut: checkOut, passengers: passengers)
        navigationController?.popToRootViewController(animated: false)
        tabBarController?.selectedViewController = navigationController
    }
}