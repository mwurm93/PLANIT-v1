//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFilterItemProtocol.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

protocol JRFilterItemProtocol: NSObjectProtocol {
    func tilte() -> String
    var filterAction: (() -> Void)? = nil { get set }

    func detailsTitle() -> String

    func attributedStringValue() -> NSAttributedString
}