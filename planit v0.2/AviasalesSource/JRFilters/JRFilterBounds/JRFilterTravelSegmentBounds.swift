//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFilterTravelSegmentBounds.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

class JRFilterTravelSegmentBounds: NSObject {
    var travelSegment: JRSDKTravelSegment?
    var isTransferToAnotherAirport: Bool = false
    private var _isFilterTransferToAnotherAirport: Bool = false
    var isFilterTransferToAnotherAirport: Bool {
        get {
            return _isFilterTransferToAnotherAirport
        }
        set(filterTransferToAnotherAirport) {
            if _isFilterTransferToAnotherAirport != filterTransferToAnotherAirport {
                _isFilterTransferToAnotherAirport = filterTransferToAnotherAirport
                NotificationCenter.default.post(name: kJRFilterBoundsDidChangeNotificationName, object: self)
            }
        }
    }
    var isOvernightStopover: Bool = false
    private var _isFilterOvernightStopover: Bool = false
    var isFilterOvernightStopover: Bool {
        get {
            return _isFilterOvernightStopover
        }
        set(filterOvernightStopover) {
            if _isFilterOvernightStopover != filterOvernightStopover {
                _isFilterOvernightStopover = filterOvernightStopover
                NotificationCenter.default.post(name: kJRFilterBoundsDidChangeNotificationName, object: self)
            }
        }
    }
    var maxDepartureTime = TimeInterval()
    var minDepartureTime = TimeInterval()
    private var _minFilterDepartureTime = TimeInterval()
    var minFilterDepartureTime: TimeInterval {
        get {
            return _minFilterDepartureTime
        }
        set(minFilterDepartureTime) {
            if _minFilterDepartureTime != minFilterDepartureTime {
                _minFilterDepartureTime = minFilterDepartureTime
                NotificationCenter.default.post(name: kJRFilterBoundsDidChangeNotificationName, object: self)
            }
        }
    }
    private var _maxFilterDepartureTime = TimeInterval()
    var maxFilterDepartureTime: TimeInterval {
        get {
            return _maxFilterDepartureTime
        }
        set(maxFilterDepartureTime) {
            if _maxFilterDepartureTime != maxFilterDepartureTime {
                _maxFilterDepartureTime = maxFilterDepartureTime
                NotificationCenter.default.post(name: kJRFilterBoundsDidChangeNotificationName, object: self)
            }
        }
    }
    var maxArrivalTime = TimeInterval()
    var minArrivalTime = TimeInterval()
    private var _minFilterArrivalTime = TimeInterval()
    var minFilterArrivalTime: TimeInterval {
        get {
            return _minFilterArrivalTime
        }
        set(minFilterArrivalTime) {
            if _minFilterArrivalTime != minFilterArrivalTime {
                _minFilterArrivalTime = minFilterArrivalTime
                NotificationCenter.default.post(name: kJRFilterBoundsDidChangeNotificationName, object: self)
            }
        }
    }
    private var _maxFilterArrivalTime = TimeInterval()
    var maxFilterArrivalTime: TimeInterval {
        get {
            return _maxFilterArrivalTime
        }
        set(maxFilterArrivalTime) {
            if _maxFilterArrivalTime != maxFilterArrivalTime {
                _maxFilterArrivalTime = maxFilterArrivalTime
                NotificationCenter.default.post(name: kJRFilterBoundsDidChangeNotificationName, object: self)
            }
        }
    }
    var maxDelaysDuration = JRSDKFlightDuration()
    var minDelaysDuration = JRSDKFlightDuration()
    private var _minFilterDelaysDuration = JRSDKFlightDuration()
    var minFilterDelaysDuration: JRSDKFlightDuration {
        get {
            return _minFilterDelaysDuration
        }
        set(minFilterDelaysDuration) {
            if _minFilterDelaysDuration != minFilterDelaysDuration {
                _minFilterDelaysDuration = minFilterDelaysDuration
                NotificationCenter.default.post(name: kJRFilterBoundsDidChangeNotificationName, object: self)
            }
        }
    }
    private var _maxFilterDelaysDuration = JRSDKFlightDuration()
    var maxFilterDelaysDuration: JRSDKFlightDuration {
        get {
            return _maxFilterDelaysDuration
        }
        set(maxFilterDelaysDuration) {
            if _maxFilterDelaysDuration != maxFilterDelaysDuration {
                _maxFilterDelaysDuration = maxFilterDelaysDuration
                NotificationCenter.default.post(name: kJRFilterBoundsDidChangeNotificationName, object: self)
            }
        }
    }
    var maxTotalDuration = JRSDKFlightDuration()
    var minTotalDuration = JRSDKFlightDuration()
    private var _filterTotalDuration = JRSDKFlightDuration()
    var filterTotalDuration: JRSDKFlightDuration {
        get {
            return _filterTotalDuration
        }
        set(filterTotalDuration) {
            if _filterTotalDuration != filterTotalDuration {
                _filterTotalDuration = filterTotalDuration
                NotificationCenter.default.post(name: kJRFilterBoundsDidChangeNotificationName, object: self)
            }
        }
    }
    var transfersCounts: NSOrderedSet<NSNumber>?
    private var _filterTransfersCounts: NSOrderedSet<NSNumber>?
    var filterTransfersCounts: NSOrderedSet<NSNumber>? {
        get {
            return _filterTransfersCounts
        }
        set(filterTransfersCounts) {
            if !Set<AnyHashable>().isEqual(Set<AnyHashable>()) {
                _filterTransfersCounts = filterTransfersCounts
                NotificationCenter.default.post(name: kJRFilterBoundsDidChangeNotificationName, object: self)
            }
        }
    }
    var airlines: NSOrderedSet<JRSDKAirline>?
    private var _filterAirlines: NSOrderedSet<JRSDKAirline>?
    var filterAirlines: NSOrderedSet<JRSDKAirline>? {
        get {
            return _filterAirlines
        }
        set(filterAirlines) {
            if !Set<AnyHashable>().isEqual(Set<AnyHashable>()) {
                _filterAirlines = filterAirlines
                NotificationCenter.default.post(name: kJRFilterBoundsDidChangeNotificationName, object: self)
            }
        }
    }
    var alliances: NSOrderedSet<JRSDKAlliance>?
    private var _filterAlliances: NSOrderedSet<JRSDKAlliance>?
    var filterAlliances: NSOrderedSet<JRSDKAlliance>? {
        get {
            return _filterAlliances
        }
        set(filterAlliances) {
            if !Set<AnyHashable>().isEqual(Set<AnyHashable>()) {
                _filterAlliances = filterAlliances
                NotificationCenter.default.post(name: kJRFilterBoundsDidChangeNotificationName, object: self)
            }
        }
    }
    var originAirports: NSOrderedSet<JRSDKAirport>?
    private var _filterOriginAirports: NSOrderedSet<JRSDKAirport>?
    var filterOriginAirports: NSOrderedSet<JRSDKAirport>? {
        get {
            return _filterOriginAirports
        }
        set(filterOriginAirports) {
            if !Set<AnyHashable>().isEqual(Set<AnyHashable>()) {
                _filterOriginAirports = filterOriginAirports
                NotificationCenter.default.post(name: kJRFilterBoundsDidChangeNotificationName, object: self)
            }
        }
    }
    var stopoverAirports: NSOrderedSet<JRSDKAirport>?
    private var _filterStopoverAirports: NSOrderedSet<JRSDKAirport>?
    var filterStopoverAirports: NSOrderedSet<JRSDKAirport>? {
        get {
            return _filterStopoverAirports
        }
        set(filterStopoverAirports) {
            if !Set<AnyHashable>().isEqual(Set<AnyHashable>()) {
                _filterStopoverAirports = filterStopoverAirports
                NotificationCenter.default.post(name: kJRFilterBoundsDidChangeNotificationName, object: self)
            }
        }
    }
    var destinationAirports: NSOrderedSet<JRSDKAirport>?
    private var _filterDestinationAirports: NSOrderedSet<JRSDKAirport>?
    var filterDestinationAirports: NSOrderedSet<JRSDKAirport>? {
        get {
            return _filterDestinationAirports
        }
        set(filterDestinationAirports) {
            if !Set<AnyHashable>().isEqual(Set<AnyHashable>()) {
                _filterDestinationAirports = filterDestinationAirports
                NotificationCenter.default.post(name: kJRFilterBoundsDidChangeNotificationName, object: self)
            }
        }
    }
    var transfersCountsWitnMinPrice = [NSNumber: NSNumber]()
    private(set) var isReset: Bool = false

    init(travelSegment: JRSDKTravelSegment) {
        super.init()
        
        self.travelSegment = travelSegment
        isTransferToAnotherAirport = false
        isOvernightStopover = false
        maxDepartureTime = 0.0
        minDepartureTime = CGFLOAT_MAX
        maxArrivalTime = 0.0
        minArrivalTime = CGFLOAT_MAX
        maxDelaysDuration = 0.0
        minDelaysDuration = NSIntegerMax
        maxTotalDuration = 0.0
        minTotalDuration = NSIntegerMax
        transfersCounts = NSOrderedSet()
        airlines = NSOrderedSet()
        alliances = NSOrderedSet()
        originAirports = NSOrderedSet()
        stopoverAirports = NSOrderedSet()
        destinationAirports = NSOrderedSet()
        transfersCountsWitnMinPrice = [AnyHashable: Any]()
        reset()
    
    }

    func resetBounds() {
        isFilterTransferToAnotherAirport = isTransferToAnotherAirport
        isFilterOvernightStopover = isOvernightStopover
        filterTotalDuration = maxTotalDuration
        minFilterDelaysDuration = minDelaysDuration
        maxFilterDelaysDuration = maxDelaysDuration
        minFilterDepartureTime = minDepartureTime
        maxFilterDepartureTime = maxDepartureTime
        minFilterArrivalTime = minArrivalTime
        maxFilterArrivalTime = maxArrivalTime
        filterTransfersCounts = transfersCounts?
        filterAlliances = alliances?
        filterAirlines = airlines?
        filterOriginAirports = originAirports?
        filterStopoverAirports = stopoverAirports?
        filterDestinationAirports = destinationAirports?
        NotificationCenter.default.post(name: kJRFilterBoundsDidResetNotificationName, object: self)
    }

    func isReset() -> Bool {
        let isReset: Bool = isFilterOvernightStopover == isOvernightStopover && isFilterTransferToAnotherAirport == isTransferToAnotherAirport && filterTotalDuration == maxTotalDuration && minFilterDepartureTime == minDepartureTime && maxFilterDepartureTime == maxDepartureTime && minFilterDepartureTime == minDepartureTime && maxFilterDepartureTime == maxDepartureTime && minFilterArrivalTime == minArrivalTime && maxFilterArrivalTime == maxArrivalTime && minFilterDelaysDuration == minDelaysDuration && maxFilterDelaysDuration == maxDelaysDuration && Set<AnyHashable>().isEqual(Set<AnyHashable>()) && Set<AnyHashable>().isEqual(Set<AnyHashable>()) && Set<AnyHashable>().isEqual(Set<AnyHashable>()) && Set<AnyHashable>().isEqual(Set<AnyHashable>()) && Set<AnyHashable>().isEqual(Set<AnyHashable>()) && Set<AnyHashable>().isEqual(Set<AnyHashable>())
        return isReset
    }
}