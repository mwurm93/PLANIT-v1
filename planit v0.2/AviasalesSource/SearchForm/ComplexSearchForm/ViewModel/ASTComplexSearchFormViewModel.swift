//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  ASTComplexSearchFormViewModel.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

class ASTComplexSearchFormCellSegmentViewModel: NSObject {
    var isPlaceholder: Bool = false
    var icon: String = ""
    var title: String = ""
    var subtitle: String = ""
}

class ASTComplexSearchFormCellViewModel: NSObject {
    var origin: ASTComplexSearchFormCellSegmentViewModel?
    var destination: ASTComplexSearchFormCellSegmentViewModel?
    var departure: ASTComplexSearchFormCellSegmentViewModel?
}

class ASTComplexSearchFormFooterViewModel: NSObject {
    var isShouldEnableAdd: Bool = false
    var isShouldEnableRemove: Bool = false
}

class ASTComplexSearchFormPassengersViewModel: NSObject {
    var adults: String = ""
    var children: String = ""
    var infants: String = ""
    var travelClass: String = ""
}

class ASTComplexSearchFormViewModel: NSObject {
    var cellViewModels = [ASTComplexSearchFormCellViewModel]()
    var footerViewModel: ASTComplexSearchFormFooterViewModel?
    var passengersViewModel: ASTComplexSearchFormPassengersViewModel?
}