//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  ASTSimpleSearchFormViewControllerProtocol.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

protocol ASTSimpleSearchFormViewControllerProtocol: NSObjectProtocol {
    func update(with viewModel: ASTSimpleSearchFormViewModel)

    func showAirportPicker(with mode: JRAirportPickerMode)

    func showDatePicker(with mode: JRDatePickerMode, borderDate: Date, firstDate: Date, secondDate: Date)

    func showPassengersPicker(with passengersInfo: ASTPassengersInfo)

    func showError(withMessage message: String)

    func showWaitingScreen(with searchInfо: JRSDKSearchInfo)
}