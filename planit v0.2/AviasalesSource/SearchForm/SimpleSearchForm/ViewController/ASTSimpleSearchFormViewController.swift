//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  ASTSimpleSearchFormViewController.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

private let separatorLeftInset: CGFloat = 76.0
private let separatorRightInset: CGFloat = 20.0

class ASTSimpleSearchFormViewController: UIViewController, ASTContainerSearchFormChildViewControllerProtocol, ASTSimpleSearchFormViewControllerProtocol {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var passengersView: ASTSearchFormPassengersView!
    @IBOutlet weak var swapButton: UIButton!
    @IBOutlet weak var swapButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var passengersViewHeightConstraint: NSLayoutConstraint!
    var presenter: ASTSimpleSearchFormPresenter?
    var viewModel: ASTSimpleSearchFormViewModel?
    var tableViewSectionHeaderHeight: CGFloat = 0.0
    var tableViewSectionFooterHeight: CGFloat = 0.0
    var tableViewRowHeight: CGFloat = 0.0
    var swapButtonTopInsetDelta: CGFloat = 0.0

    func updateSearchInfo(withDestination destination: JRSDKAirport, checkIn: Date, checkOut: Date, passengers: ASTPassengersInfo) {
        presenter?.updateSearchInfo(withDestination: destination, checkIn: checkIn, checkOut: checkOut, passengers: passengers)
    }

    override init() {
        super.init()
        
        presenter = ASTSimpleSearchFormPresenter(viewController: self)
    
    }

// MARK: - Public

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
        setupSwapButton()
    }

    func setupLayoutVariables() {
        tableViewSectionHeaderHeight = deviceSizeTypeValue(1.0, 5.0, 20.0, 20.0, 20.0)
        tableViewSectionFooterHeight = deviceSizeTypeValue(5.0, 10.0, 20.0, 20.0, 20.0)
        tableViewRowHeight = deviceSizeTypeValue(55.0, 60.0, 65.0, 65.0, 65.0)
        swapButtonTopInsetDelta = deviceSizeTypeValue(14.0, 10.0, 8.0, 8.0, 8.0)
        passengersViewHeightConstraint.constant = deviceSizeTypeValue(45.0, 55.0, 85.0, 95.0, 95.0)
    }

    func setupTableView() {
        tableView.rowHeight = tableViewRowHeight
    }

    func setupSwapButton() {
        swapButton.tintColor = JRColorScheme.searchFormTintColor()
        swapButtonTopConstraint.constant = tableViewSectionHeaderHeight + tableViewRowHeight + swapButtonTopInsetDelta - swapButton.bounds.height / 2.0
    }

//makr - Update
    func updatePassengersView() {
        let passengersViewModel: ASTSimpleSearchFormPassengersViewModel? = viewModel?.passengersViewModel
        passengersView.adultsLabel.text = passengersViewModel?.adults
        passengersView.childrenLabel.text = passengersViewModel?.children
        passengersView.infantsLabel.text = passengersViewModel?.infants
        passengersView.travelClassLabel.text = passengersViewModel?.travelClass
        weak var weakSelf: ASTSimpleSearchFormViewController? = self
        passengersView.tapAction = {(_ sender: UIView) -> Void in
            weakSelf?.self.presenter?.handlePickPassengers()
        }
    }

// MARK: - ASTSimpleSearchFormViewControllerProtocol
    func update(with viewModel: ASTSimpleSearchFormViewModel) {
        self.viewModel = viewModel
        tableView.reloadData()
        updatePassengersView()
    }

    func showAirportPicker(with mode: JRAirportPickerMode) {
        showAirportPickerViewController(with: mode)
    }

    func showDatePicker(with mode: JRDatePickerMode, borderDate: Date, firstDate: Date, secondDate: Date) {
        showDatePickerViewController(with: mode, borderDate: borderDate, firstDate: firstDate, secondDate: secondDate)
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionViewModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sectionViewModels[section].cellViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel: ASTSimpleSearchFormCellViewModel? = viewModel.sectionViewModels[indexPath.section].cellViewModels[indexPath.row]
        return buildCell(from: cellViewModel)
    }

// MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewSectionHeaderHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableViewSectionFooterHeight
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let separatorView = ASTSimpleSearchFormSeparatorView()
        separatorView.style = ASTSearchFormSeparatorViewStyleBottom
        separatorView.leftInset = separatorLeftInset
        separatorView.rightInset = separatorRightInset
        separatorView.backgroundColor = JRColorScheme.searchFormBackgroundColor()
        separatorView.separatorColor = JRColorScheme.searchFormSeparatorColor()
        return separatorView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellViewModel: ASTSimpleSearchFormCellViewModel? = viewModel.sectionViewModels[indexPath.section].cellViewModels[indexPath.row]
        presenter?.handleSelect(cellViewModel)
    }

// MARK: - Cells
    func buildCell(from cellViewModel: ASTSimpleSearchFormCellViewModel) -> UITableViewCell {
        switch cellViewModel.type {
            case ASTSimpleSearchFormCellViewModelTypeOrigin, ASTSimpleSearchFormCellViewModelTypeDestination:
                return buildAirportCell(fromCellViewModel: (cellViewModel as? ASTSimpleSearchFormAirportCellViewModel))!
            case ASTSimpleSearchFormCellViewModelTypeDeparture, ASTSimpleSearchFormCellViewModelTypeReturn:
                return buildDateCell(fromCellViewModel: (cellViewModel as? ASTSimpleSearchFormDateCellViewModel))!
        }

    }

    func buildAirportCell(from cellViewModel: ASTSimpleSearchFormAirportCellViewModel) -> ASTSimpleSearchFormAirportTableViewCell {
        let cell = ASTSimpleSearchFormAirportTableViewCell.loadFromNib()
        cell.selectionStyle = []
        cell.cityLabel.alpha = cellViewModel.placeholder ? 0.6 : 1.0
        cell.iconImageView.image = UIImage(named: cellViewModel.icon)
        cell.hintLabel.text = cellViewModel.hint
        cell.cityLabel.text = cellViewModel.city
        cell.iataLabel.text = cellViewModel.iata
        return cell
    }

    func buildDateCell(from cellViewModel: ASTSimpleSearchFormDateCellViewModel) -> ASTSimpleSearchFormDateTableViewCell {
        let cell = ASTSimpleSearchFormDateTableViewCell.loadFromNib()
        cell.selectionStyle = []
        cell.dateLabel.alpha = cellViewModel.placeholder ? 0.6 : 1.0
        cell.iconImageView.image = UIImage(named: cellViewModel.icon)
        cell.hintLabel.text = cellViewModel.hint
        cell.dateLabel.text = cellViewModel.date
        cell.returnLabel.isHidden = cellViewModel.shouldHideReturnCheckbox
        cell.returnButton.isHidden = cell.returnLabel.isHidden
        cell.returnButton.isSelected = cellViewModel.shouldSelectReturnCheckbox
        weak var weakSelf: ASTSimpleSearchFormViewController? = self
        cell.returnButtonAction = {(_ sender: UIButton) -> Void in
            weakSelf?.self.presenter?.handleSwitchReturnCheckbox()
        }
        return cell
    }

// MARK: - Navigation
    func showAirportPickerViewController(with mode: JRAirportPickerMode) {
        weak var weakSelf: ASTSimpleSearchFormViewController? = self
        let airportPickerViewController = JRAirportPickerVC(mode: mode, selectionBlock: {(_ selectedAirport: JRSDKAirport) -> Void in
                weakSelf?.self.presenter?.handleSelect(selectedAirport, with: mode)
            })
        pushOrPresentBasedOnDeviceType(withViewController: airportPickerViewController, animated: true)
    }

    func showDatePickerViewController(with mode: JRDatePickerMode, borderDate: Date, firstDate: Date, secondDate: Date) {
        weak var weakSelf: ASTSimpleSearchFormViewController? = self
        let datePickerViewController = JRDatePickerVC(mode: mode, borderDate: borderDate, firstDate: firstDate, secondDate: secondDate, selectionBlock: {(_ selectedDate: Date) -> Void in
                weakSelf?.self.presenter?.handleSelect(selectedDate, with: mode)
            })
        pushOrPresentBasedOnDeviceType(withViewController: datePickerViewController, animated: true)
    }

    func showPassengersPickerViewController(with passengersInfo: ASTPassengersInfo) {
        weak var weakSelf: ASTSimpleSearchFormViewController? = self
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

// MARK: - Actions
    @IBAction func swapButtonTapped(_ sender: UIButton) {
        presenter?.handleSwapAirports()
    }
}