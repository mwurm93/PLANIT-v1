//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFilterListHeaderItem.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

class JRFilterListHeaderItem: NSObject, JRFilterItemProtocol {
    var isExpanded: Bool = false

    var itemsCount: Int = 0

    init(itemsCount count: Int) {
        super.init()
        
        itemsCount = count
    
    }

    func tilte() -> String {
        return ""
    }
}

class JRFilterGatesHeaderItem: JRFilterListHeaderItem {
    func tilte() -> String {
        return "\(NSLS("JR_FILTER_GATES")) \(Int(itemsCount))"
    }
}

class JRFilterPaymentMethodsHeaderItem: JRFilterListHeaderItem {
    func tilte() -> String {
        return "\(NSLS("JR_FILTER_PAYMENT_METHODS")) \(Int(itemsCount))"
    }
}

class JRFilterAirlinesHeaderItem: JRFilterListHeaderItem {
    func tilte() -> String {
        return "\(NSLS("JR_FILTER_AIRLINES")) \(Int(itemsCount))"
    }
}

class JRFilterAllianceHeaderItem: JRFilterListHeaderItem {
    func tilte() -> String {
        return "\(NSLS("JR_FILTER_ALLIANCES")) \(Int(itemsCount))"
    }
}

class JRFilterAirportsHeaderItem: JRFilterListHeaderItem {
    func tilte() -> String {
        return "\(NSLS("JR_FILTER_AIRPORTS")) \(Int(itemsCount))"
    }
}