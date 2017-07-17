//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  ASTComplexSearchFormViewControllerProtocol.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

protocol ASTComplexSearchFormViewControllerProtocol: NSObjectProtocol {
    func update(with viewModel: ASTComplexSearchFormViewModel)

    func addRowAnimated(at index: Int, with viewModel: ASTComplexSearchFormViewModel)

    func removeRowAnimated(at index: Int, with viewModel: ASTComplexSearchFormViewModel)

    func showAirportPicker(with mode: JRAirportPickerMode, for index: Int)

    func showDatePicker(withBorderDate borderDate: Date, selectedDate: Date, for index: Int)

    func showPassengersPicker(with passengersInfo: ASTPassengersInfo)

    func showError(withMessage message: String)

    func showWaitingScreen(with searchInfo: JRSDKSearchInfo)
}