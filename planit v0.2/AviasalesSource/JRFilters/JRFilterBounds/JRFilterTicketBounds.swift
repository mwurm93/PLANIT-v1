//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFilterTicketBounds.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

class JRFilterTicketBounds: NSObject {
    var isMobileWebOnly: Bool = false
    private var _isFilterMobileWebOnly: Bool = false
    var isFilterMobileWebOnly: Bool {
        get {
            return _isFilterMobileWebOnly
        }
        set(filterMobileWebOnly) {
            if isFilterMobileWebOnly != filterMobileWebOnly {
                _isFilterMobileWebOnly = filterMobileWebOnly
                NotificationCenter.default.post(name: kJRFilterBoundsDidChangeNotificationName, object: self)
            }
        }
    }
    var minPrice: CGFloat = 0.0
    // In USD
    var maxPrice: CGFloat = 0.0
    // In USD
    private var _filterPrice: CGFloat = 0.0
    var filterPrice: CGFloat {
        get {
            return _filterPrice
        }
        set(filterPrice) {
            if self.filterPrice != filterPrice {
                _filterPrice = filterPrice
                NotificationCenter.default.post(name: kJRFilterBoundsDidChangeNotificationName, object: self)
            }
        }
    }
    // In USD
    var gates: NSOrderedSet<JRSDKGate>?
    private var _filterGates: NSOrderedSet<JRSDKGate>?
    var filterGates: NSOrderedSet<JRSDKGate>? {
        get {
            return _filterGates
        }
        set(filterGates) {
            if !self.filterGates.isEqual(filterGates) {
                _filterGates = filterGates
                NotificationCenter.default.post(name: kJRFilterBoundsDidChangeNotificationName, object: self)
            }
        }
    }
    var paymentMethods: NSOrderedSet<JRSDKPaymentMethod>?
    private var _filterPaymentMethods: NSOrderedSet<JRSDKPaymentMethod>?
    var filterPaymentMethods: NSOrderedSet<JRSDKPaymentMethod>? {
        get {
            return _filterPaymentMethods
        }
        set(filterPaymentMethods) {
            if self.filterPaymentMethods != filterPaymentMethods {
                _filterPaymentMethods = filterPaymentMethods
                NotificationCenter.default.post(name: kJRFilterBoundsDidChangeNotificationName, object: self)
            }
        }
    }
    private(set) var isReset: Bool = false

    func resetBounds() {
        filterPrice = maxPrice
        filterGates = gates?
        filterPaymentMethods = paymentMethods?
        isFilterMobileWebOnly = isMobileWebOnly
        NotificationCenter.default.post(name: kJRFilterBoundsDidResetNotificationName, object: self)
    }

    override init() {
        super.init()
        
        gates = NSOrderedSet()
        paymentMethods = NSOrderedSet()
        maxPrice = 0.0
        minPrice = CGFLOAT_MAX
        resetBounds()
    
    }

    func isReset() -> Bool {
        let isReset: Bool? = (filterPrice == maxPrice) && (filterGates.count == gates?.count) && (filterPaymentMethods.count == paymentMethods?.count) && !isFilterMobileWebOnly
        return isReset!
    }
}