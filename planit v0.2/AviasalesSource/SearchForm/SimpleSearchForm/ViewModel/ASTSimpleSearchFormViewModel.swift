//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  ASTSimpleSearchFormViewModel.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

enum ASTSimpleSearchFormCellViewModelType : Int {
    case origin
    case destination
    case departure
    case return
}


class ASTSimpleSearchFormCellViewModel: NSObject {
    var type = ASTSimpleSearchFormCellViewModelType(rawValue: 0)!
}

class ASTSimpleSearchFormAirportCellViewModel: ASTSimpleSearchFormCellViewModel {
    var city: String = ""
    var iata: String = ""
    var icon: String = ""
    var hint: String = ""
    var isPlaceholder: Bool = false
}

class ASTSimpleSearchFormDateCellViewModel: ASTSimpleSearchFormCellViewModel {
    var date: String = ""
    var icon: String = ""
    var hint: String = ""
    var isPlaceholder: Bool = false
    var isShouldHideReturnCheckbox: Bool = false
    var isShouldSelectReturnCheckbox: Bool = false
}

class ASTSimpleSearchFormSectionViewModel: NSObject {
    var cellViewModels = [ASTSimpleSearchFormCellViewModel]()
}

class ASTSimpleSearchFormPassengersViewModel: NSObject {
    var adults: String = ""
    var children: String = ""
    var infants: String = ""
    var travelClass: String = ""
}

class ASTSimpleSearchFormViewModel: NSObject {
    var sectionViewModels = [ASTSimpleSearchFormSectionViewModel]()
    var passengersViewModel: ASTSimpleSearchFormPassengersViewModel?
}