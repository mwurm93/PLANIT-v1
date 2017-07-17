//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  ASTComplexSearchFormViewController.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class ASTComplexSearchFormViewController: UIViewController, ASTContainerSearchFormChildViewControllerProtocol, ASTComplexSearchFormViewControllerProtocol {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var footerView: ASTComplexSearchFormFooterView!
    @IBOutlet weak var passengersView: ASTSearchFormPassengersView!
    @IBOutlet weak var passengersViewHeightConstraint: NSLayoutConstraint!
    var presenter: ASTComplexSearchFormPresenter?
    var viewModel: ASTComplexSearchFormViewModel?

    override init() {
        super.init()
        
        presenter = ASTComplexSearchFormPresenter(viewController: self)
    
    }

// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        presenter?.handleViewDidLoad()
    }

// MARK: - Setup
    func setupViewController() {
        setupLayoutVariables()
        setupTableView()
        registerNibs()
    }

    func setupLayoutVariables() {
        passengersViewHeightConstraint.constant = deviceSizeTypeValue(45.0, 55.0, 85.0, 95.0, 95.0)
    }

    func registerNibs() {
        tableView.register(UINib(nibName: ASTComplexSearchFormTableViewCell.hl_reuseIdentifier(), bundle: Bundle.main), forCellReuseIdentifier: ASTComplexSearchFormTableViewCell.hl_reuseIdentifier())
    }

    func setupTableView() {
        tableView.tableFooterView = footerView
    }

// MARK: - Update
    func updateFooterView() {
        weak var weakSelf: ASTComplexSearchFormViewController? = self
        let footerViewModel: ASTComplexSearchFormFooterViewModel? = viewModel?.footerViewModel
        footerView.addButton.isEnabled = footerViewModel?.shouldEnableAdd
        footerView.addAction = {(_ sender: UIButton) -> Void in
            weakSelf?.self.presenter?.handleAddTravelSegment()
        }
        footerView.removeButton.isEnabled = footerViewModel?.shouldEnableRemove
        footerView.removeAction = {(_ sender: UIButton) -> Void in
            weakSelf?.self.presenter?.handleRemoveTravelSegment()
        }
    }

    func updatePassengersView() {
        let passengersViewModel: ASTComplexSearchFormPassengersViewModel? = viewModel?.passengersViewModel
        passengersView.adultsLabel.text = passengersViewModel?.adults
        passengersView.childrenLabel.text = passengersViewModel?.children
        passengersView.infantsLabel.text = passengersViewModel?.infants
        passengersView.travelClassLabel.text = passengersViewModel?.travelClass
        weak var weakSelf: ASTComplexSearchFormViewController? = self
        passengersView.tapAction = {(_ sender: UIView) -> Void in
            weakSelf?.self.presenter?.handlePickPassengers()
        }
    }

// MARK: - ASTComplexSearchFormViewControllerProtocol
    func update(with viewModel: ASTComplexSearchFormViewModel) {
        self.viewModel = viewModel
        tableView.reloadData()
        updateFooterView()
        updatePassengersView()
    }

    func addRowAnimated(at index: Int, with viewModel: ASTComplexSearchFormViewModel) {
        self.viewModel = viewModel
        let indexPath = IndexPath(row: index, section: 0)
        tableView.insertRows(at: [indexPath], with: .right)
        updateFooterView()
    }

    func removeRowAnimated(at index: Int, with viewModel: ASTComplexSearchFormViewModel) {
        self.viewModel = viewModel
        let indexPath = IndexPath(row: index, section: 0)
        tableView.deleteRows(at: [indexPath], with: .left)
        updateFooterView()
    }

    func showAirportPicker(with mode: JRAirportPickerMode, for index: Int) {
        showAirportPickerViewController(with: mode, for: index)
    }

    func showDatePicker(withBorderDate borderDate: Date, selectedDate: Date, for index: Int) {
        showDatePickerViewController(withBorderDate: borderDate, selectedDate: selectedDate, for: index)
    }

    func showPassengersPicker(with passengersInfo: ASTPassengersInfo) {
        showPassengersPickerViewController(with: passengersInfo)
    }

    func showError(withMessage message: String) {
        showErrorAlert(withMessage: message)
    }

    func showWaitingScreen(with searchInfо: JRSDKSearchInfo) {
        showWaitingScreenViewController(withSeachInfo: searchInfо)
    }

// MARK: - ASTContainerSearchFormChildViewControllerProtocol
    func performSearch() {
        presenter?.handleSearch()
    }

// MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel: ASTComplexSearchFormCellViewModel? = viewModel.cellViewModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ASTComplexSearchFormTableViewCell.hl_reuseIdentifier(), for: indexPath)
        setupCell(cell, at: indexPath.row, with: cellViewModel)
        return cell
    }

// MARK: - Cells
    func setupCell(_ cell: ASTComplexSearchFormTableViewCell, at index: Int, with cellViewModel: ASTComplexSearchFormCellViewModel) {
        setupCellSegment(cell.origin, type: ASTComplexSearchFormCellSegmentTypeOrigin, at: index, withCellSegmentViewModel: cellViewModel.origin)
        setupCellSegment(cell.destination, type: ASTComplexSearchFormCellSegmentTypeDestination, at: index, withCellSegmentViewModel: cellViewModel.destination)
        setupCellSegment(cell.departure, type: ASTComplexSearchFormCellSegmentTypeDeparture, at: index, withCellSegmentViewModel: cellViewModel.departure)
    }

    func setupCellSegment(_ cellSegment: ASTComplexSearchFormTableViewCellSegment, type: ASTComplexSearchFormCellSegmentType, at index: Int, with cellSegmentViewModel: ASTComplexSearchFormCellSegmentViewModel) {
        cellSegment.iconImageView.isHidden = !cellSegmentViewModel.placeholder
        cellSegment.subtitleLabel.isHidden = cellSegmentViewModel.placeholder
        cellSegment.titleLabel.isHidden = cellSegment.subtitleLabel.isHidden
        cellSegment.iconImageView.image = UIImage(named: cellSegmentViewModel.icon)
        cellSegment.titleLabel.text = cellSegmentViewModel.title
        cellSegment.subtitleLabel.text = cellSegmentViewModel.subtitle
        weak var weakSelf: ASTComplexSearchFormViewController? = self
        cellSegment.tapAction = {(_ sender: UIView) -> Void in
            weakSelf?.self.presenter?.handleSelectCellSegment(with: type, at: index)
        }
    }

// MARK: - Navigation
    func showAirportPickerViewController(with mode: JRAirportPickerMode, for index: Int) {
        weak var weakSelf: ASTComplexSearchFormViewController? = self
        let airportPickerViewController = JRAirportPickerVC(mode: mode, selectionBlock: {(_ selectedAirport: JRSDKAirport) -> Void in
                weakSelf?.self.presenter?.handleSelect(selectedAirport, with: mode, at: index)
            })
        pushOrPresentBasedOnDeviceType(withViewController: airportPickerViewController, animated: true)
    }

    func showDatePickerViewController(withBorderDate borderDate: Date, selectedDate: Date, for index: Int) {
        weak var weakSelf: ASTComplexSearchFormViewController? = self
        let datePickerViewController = JRDatePickerVC(mode: JRDatePickerModeDefault, borderDate: borderDate, firstDate: selectedDate, secondDate: nil, selectionBlock: {(_ selectedDate: Date) -> Void in
                weakSelf?.self.presenter?.handleSelect(selectedDate, at: index)
            })
        pushOrPresentBasedOnDeviceType(withViewController: datePickerViewController, animated: true)
    }

    func showPassengersPickerViewController(with passengersInfo: ASTPassengersInfo) {
        weak var weakSelf: ASTComplexSearchFormViewController? = self
        let passengersPickerViewController = ASTPassengersPickerViewController(passengersInfo: passengersInfo, selection: {(_ selectedPassengersInfo: ASTPassengersInfo) -> Void in
                weakSelf?.self.presenter?.handleSelect(selectedPassengersInfo)
            })
        passengersPickerViewController?.modalPresentationStyle = .overFullScreen
        passengersPickerViewController?.modalTransitionStyle = .crossDissolve
        present(passengersPickerViewController!, animated: true) { _ in }
    }

    func showWaitingScreenViewController(withSeachInfo searchInfo: JRSDKSearchInfo) {
        let waitingScreenViewController = ASTWaitingScreenViewController(searchInfo: searchInfo)
        navigationController?.pushViewController(waitingScreenViewController as? UIViewController ?? UIViewController(), animated: true)
    }
}