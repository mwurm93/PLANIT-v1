//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFilterItemsFactory.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

class JRFilterItemsFactory: NSObject {
    var filter: JRFilter?

    init(filter: JRFilter) {
        super.init()
        
        self.filter = filter
    
    }

    func createSectionsForSimpleMode() -> [Any] {
        var sections = [Any]()
        let firstTravelSegment: JRSDKTravelSegment? = filter.travelSegmentsBounds?.first?.travelSegment
        let lastTravelSegment: JRSDKTravelSegment? = (filter.travelSegmentsBounds?.count > 1) ? filter.travelSegmentsBounds?.last?.travelSegment : nil
        let stopoversItems: [JRFilterItemProtocol] = createStopoverItems(forFirstTravelSegment: firstTravelSegment, last: lastTravelSegment)
        if stopoversItems.count > 0 {
            sections.append(stopoversItems)
        }
        let priceItems: [JRFilterItemProtocol] = createPriceItems()
        if priceItems.count > 0 {
            sections.append(priceItems)
        }
        let durationsItems: [JRFilterItemProtocol] = createDurationsItems(forFirstTravelSegment: firstTravelSegment, last: lastTravelSegment)
        if durationsItems.count > 0 {
            sections.append(durationsItems)
        }
        let timesToItems: [JRFilterItemProtocol] = createDepartureArrivalItems(for: firstTravelSegment, forReturn: false)
        if timesToItems.count > 0 {
            sections.append(timesToItems)
        }
        if lastTravelSegment != nil {
            let timesFromItems: [JRFilterItemProtocol] = createDepartureArrivalItems(for: lastTravelSegment, forReturn: true)
            if timesFromItems.count > 0 {
                sections.append(timesFromItems)
            }
        }
        let airlinesItems: [JRFilterItemProtocol] = createAirlinesItems(forFirstTravelSegment: firstTravelSegment, last: lastTravelSegment)
        if airlinesItems.count > 0 {
            sections.append(airlinesItems)
        }
        let alliancesItems: [JRFilterItemProtocol] = createAlliancesItems(forFirstTravelSegment: firstTravelSegment, last: lastTravelSegment)
        if alliancesItems.count > 0 {
            sections.append(alliancesItems)
        }
        let airportsItems: [JRFilterItemProtocol] = createAirportsItems(forFirstTravelSegment: firstTravelSegment, last: lastTravelSegment)
        if airportsItems.count > 0 {
            sections.append(airportsItems)
        }
        let gatesItems: [JRFilterItemProtocol] = createGatesItems()
        if gatesItems.count > 0 {
            sections.append(gatesItems)
        }
        let paymentMethodsItems: [JRFilterItemProtocol] = createPaymentMethodsItems()
        if paymentMethodsItems.count > 0 {
            sections.append(paymentMethodsItems)
        }
        return sections
    }

    func createSectionsForComplexMode() -> [Any] {
        var sections = [Any]()
        let priceItems: [JRFilterItemProtocol] = createPriceItems()
        if priceItems.count > 0 {
            sections.append(priceItems)
        }
        let travelSegmentItems: [JRFilterItemProtocol] = createTravelSegmentItems()
        if travelSegmentItems.count > 0 {
            for item: JRFilterItemProtocol in travelSegmentItems {
                sections.append([item])
            }
        }
        let gatesItems: [JRFilterItemProtocol] = createGatesItems()
        if gatesItems.count > 0 {
            sections.append(gatesItems)
        }
        let paymentMethodsItems: [JRFilterItemProtocol] = createPaymentMethodsItems()
        if paymentMethodsItems.count > 0 {
            sections.append(paymentMethodsItems)
        }
        return sections
    }

    func createSections(for travelSegment: JRSDKTravelSegment) -> [Any] {
        var sections = [Any]()
        let stopoversItems: [JRFilterItemProtocol] = createStopoverItems(forFirstTravelSegment: travelSegment, lastTravelSegment: nil)
        if stopoversItems.count > 0 {
            sections.append(stopoversItems)
        }
        let durationsItems: [JRFilterItemProtocol] = createDurationsItems(forFirstTravelSegment: travelSegment, lastTravelSegment: nil)
        if durationsItems.count > 0 {
            sections.append(durationsItems)
        }
        let timesItems: [JRFilterItemProtocol] = createDepartureArrivalItems(for: travelSegment, forReturn: false)
        if timesItems.count > 0 {
            sections.append(timesItems)
        }
        let airlinesItems: [JRFilterItemProtocol] = createAirlinesItems(forFirstTravelSegment: travelSegment, lastTravelSegment: nil)
        if airlinesItems.count > 0 {
            sections.append(airlinesItems)
        }
        let alliancesItems: [JRFilterItemProtocol] = createAlliancesItems(forFirstTravelSegment: travelSegment, lastTravelSegment: nil)
        if alliancesItems.count > 0 {
            sections.append(alliancesItems)
        }
        let airportsItems: [JRFilterItemProtocol] = createAirportsItems(forFirstTravelSegment: travelSegment, lastTravelSegment: nil)
        if airportsItems.count > 0 {
            sections.append(airportsItems)
        }
        return sections
    }

// MARK: - Private methds
    func createPriceItems() -> [JRFilterItemProtocol] {
        let bounds: JRFilterTicketBounds? = filter.ticketBounds
        let item = JRFilterPriceItem(minValue: bounds?.minPrice, maxValue: bounds?.maxPrice, currentValue: bounds?.filterPrice)
        weak var weakItem: JRFilterPriceItem?? = item
        item?.filterAction = {() -> Void in
            bounds?.filterPrice = weakItem?.currentValue
        }
        return [item]
    }

    func createTravelSegmentItems() -> [JRFilterItemProtocol] {
        var items: [JRFilterItemProtocol] = [Any]()
        for travelSegmentBounds: JRFilterTravelSegmentBounds in filter.travelSegmentsBounds {
            let item = JRFilterTravelSegmentItem(travel: travelSegmentBounds.travelSegment)
            items.append(item)
        }
        return items
    }

    func createGatesItems() -> [JRFilterItemProtocol] {
        var items: [JRFilterItemProtocol] = [Any]()
        let bounds: JRFilterTicketBounds? = filter.ticketBounds
        if bounds?.gates?.count > 1 {
            let headerItem = JRFilterGatesHeaderItem(itemsCount: bounds?.gates?.count)
            items.append(headerItem)
            for gate: JRSDKGate in filter.ticketBounds?.gates {
                let item = JRFilterGateItem(gate: gate)
                item.isSelected = bounds?.filterGates?.contains(gate)
                weak var weakItem: JRFilterGateItem? = item
                item.filterAction = {() -> Void in
                    var gates: NSMutableOrderedSet<JRSDKGate>? = bounds?.filterGates?
                    if !weakItem?.isSelected && gates?.contains(gate) {
                        gates?.remove(at: gates?.index(of: gate)!)
                        bounds?.filterGates = gates?
                    }
                    else if weakItem?.isSelected && !gates?.contains(gate) {
                        gates?.append(gate)
                        bounds?.filterGates = gates?
                    }

                }
                items.append(item)
            }
        }
        return items
    }

    func createPaymentMethodsItems() -> [JRFilterItemProtocol] {
        var items: [JRFilterItemProtocol] = [Any]()
        let bounds: JRFilterTicketBounds? = filter.ticketBounds
        if bounds?.paymentMethods?.count > 1 {
            let headerItem = JRFilterPaymentMethodsHeaderItem(itemsCount: bounds?.paymentMethods?.count)
            items.append(headerItem)
            for paymentMethod: JRSDKPaymentMethod in filter.ticketBounds?.paymentMethods {
                let item = JRFilterPaymentMethodItem(paymentMethod: paymentMethod)
                item.isSelected = bounds?.filterPaymentMethods?.contains(paymentMethod)
                weak var weakItem: JRFilterPaymentMethodItem? = item
                item.filterAction = {() -> Void in
                    var paymentMethods: NSMutableOrderedSet<JRSDKPaymentMethod>? = bounds?.filterPaymentMethods?
                    if !weakItem?.isSelected && paymentMethods?.contains(paymentMethod) {
                        paymentMethods?.remove(at: paymentMethods?.index(of: paymentMethod)!)
                        bounds?.filterPaymentMethods = paymentMethods?
                    }
                    else if weakItem?.isSelected && !paymentMethods?.contains(paymentMethod) {
                        paymentMethods?.append(paymentMethod)
                        bounds?.filterPaymentMethods = paymentMethods?
                    }

                }
                items.append(item)
            }
        }
        return items
    }

    func createStopoverItems(forFirstTravelSegment firstTravelSegment: JRSDKTravelSegment, last lastTravelSegment: JRSDKTravelSegment) -> [JRFilterItemProtocol] {
        var items: [JRFilterItemProtocol] = [Any]()
        let firstSegmentBounds: JRFilterTravelSegmentBounds? = filter?.travelSegmentBounds(for: firstTravelSegment)
        let lastSegmentBounds: JRFilterTravelSegmentBounds? = filter?.travelSegmentBounds(for: lastTravelSegment)
        var transfersCounts: NSMutableOrderedSet<NSNumber>? = firstSegmentBounds?.transfersCounts?
        var filterTransfersCounts: NSMutableOrderedSet<NSNumber>? = firstSegmentBounds?.filterTransfersCounts?
        var transfersCountsWitnMinPrice: [NSNumber: NSNumber]? = firstSegmentBounds?.transfersCountsWitnMinPrice?
        if lastSegmentBounds != nil {
            transfersCounts?.union(lastSegmentBounds?.transfersCounts)
            filterTransfersCounts?.union(lastSegmentBounds?.filterTransfersCounts)
            lastSegmentBounds?.transfersCountsWitnMinPrice?.enumerateKeysAndObjects(usingBlock: {(_ key: NSNumber, _ obj: NSNumber, _ stop: Bool) -> Void in
                let curMinPrice = transfersCountsWitnMinPrice[key]
                if !curMinPrice || CFloat(obj) > CFloat(curMinPrice) {
                    transfersCountsWitnMinPrice[key] = obj
                }
            })
        }
        if transfersCounts?.count > 1 {
            for transfersCount: NSNumber in transfersCounts {
                let minPrice: CGFloat = CFloat(transfersCountsWitnMinPrice[transfersCount])
                let item = JRFilterStopoverItem(stopoverCount: CInt(transfersCount), minPrice: minPrice)
                item.isSelected = filterTransfersCounts?.contains(transfersCount)
                weak var weakItem: JRFilterStopoverItem? = item
                item.filterAction = {() -> Void in
                    if !weakItem?.isSelected && filterTransfersCounts?.contains(transfersCount) {
                        filterTransfersCounts?.remove(at: filterTransfersCounts?.index(of: transfersCount)!)
                        firstSegmentBounds?.filterTransfersCounts = filterTransfersCounts?
                        lastSegmentBounds?.filterTransfersCounts = filterTransfersCounts?
                    }
                    else if weakItem?.isSelected && !filterTransfersCounts?.contains(transfersCount) {
                        filterTransfersCounts?.append(transfersCount)
                        firstSegmentBounds?.filterTransfersCounts = filterTransfersCounts?
                        lastSegmentBounds?.filterTransfersCounts = filterTransfersCounts?
                    }

                }
                items.append(item)
            }
        }
        return items
    }

    func createDurationsItems(forFirstTravelSegment firstTravelSegment: JRSDKTravelSegment, last lastTravelSegment: JRSDKTravelSegment) -> [JRFilterItemProtocol] {
        var items: [JRFilterItemProtocol] = [Any]()
        let firstSegmentBounds: JRFilterTravelSegmentBounds? = filter?.travelSegmentBounds(for: firstTravelSegment)
        let lastSegmentBounds: JRFilterTravelSegmentBounds? = filter?.travelSegmentBounds(for: lastTravelSegment)
        var minTotalDuration: JRSDKFlightDuration? = firstSegmentBounds?.minTotalDuration
        var maxTotalDuration: JRSDKFlightDuration? = firstSegmentBounds?.maxTotalDuration
        var filterTotalDuration: JRSDKFlightDuration? = firstSegmentBounds?.filterTotalDuration
        var minDelaysDuration: JRSDKFlightDuration? = firstSegmentBounds?.minDelaysDuration
        var maxDelaysDuration: JRSDKFlightDuration? = firstSegmentBounds?.maxDelaysDuration
        var minFilterDelaysDuration: JRSDKFlightDuration? = firstSegmentBounds?.minFilterDelaysDuration
        var maxFilterDelaysDuration: JRSDKFlightDuration? = firstSegmentBounds?.maxFilterDelaysDuration
        if lastSegmentBounds != nil {
            minTotalDuration = min(minTotalDuration, lastSegmentBounds?.minTotalDuration)
            maxTotalDuration = max(maxTotalDuration, lastSegmentBounds?.maxTotalDuration)
            filterTotalDuration = max(filterTotalDuration, lastSegmentBounds?.filterTotalDuration)
            minDelaysDuration = min(minDelaysDuration, lastSegmentBounds?.minDelaysDuration)
            maxDelaysDuration = max(maxDelaysDuration, lastSegmentBounds?.maxDelaysDuration)
            minFilterDelaysDuration = min(minFilterDelaysDuration, lastSegmentBounds?.minFilterDelaysDuration)
            maxFilterDelaysDuration = max(maxFilterDelaysDuration, lastSegmentBounds?.maxFilterDelaysDuration)
        }
        if minTotalDuration != maxTotalDuration {
            let totalDurationItem = JRFilterTotalDurationItem(minValue: minTotalDuration, maxValue: maxTotalDuration, currentValue: filterTotalDuration)
            weak var weakTotalDurationItem: JRFilterTotalDurationItem? = totalDurationItem
            totalDurationItem.filterAction = {() -> Void in
                firstSegmentBounds?.filterTotalDuration = weakTotalDurationItem?.currentValue
                lastSegmentBounds?.filterTotalDuration = weakTotalDurationItem?.currentValue
            }
            items.append(totalDurationItem)
        }
        if minDelaysDuration != maxDelaysDuration {
            let transferDurationItem = JRFilterDelaysDurationItem(minValue: minDelaysDuration, maxValue: maxDelaysDuration, currentMinValue: minFilterDelaysDuration, currentMaxValue: maxFilterDelaysDuration)
            weak var weakTransferDurationItem: JRFilterDelaysDurationItem? = transferDurationItem
            transferDurationItem.filterAction = {() -> Void in
                firstSegmentBounds?.minFilterDelaysDuration = weakTransferDurationItem?.currentMinValue
                firstSegmentBounds?.maxFilterDelaysDuration = weakTransferDurationItem?.currentMaxValue
                lastSegmentBounds?.minFilterDelaysDuration = weakTransferDurationItem?.currentMinValue
                lastSegmentBounds?.maxFilterDelaysDuration = weakTransferDurationItem?.currentMaxValue
            }
            items.append(transferDurationItem)
        }
        return items
    }

    func createDepartureArrivalItems(for travelSegment: JRSDKTravelSegment, forReturn isReturn: Bool) -> [JRFilterItemProtocol] {
        var items: [JRFilterItemProtocol] = [Any]()
        let travelSegmentBounds: JRFilterTravelSegmentBounds? = filter?.travelSegmentBounds(for: travelSegment)
        if travelSegmentBounds?.minDepartureTime != travelSegmentBounds?.maxDepartureTime {
            let departureItem = JRFilterDepartureTimeItem(minValue: travelSegmentBounds?.minDepartureTime, maxValue: travelSegmentBounds?.maxDepartureTime, currentMinValue: travelSegmentBounds?.minFilterDepartureTime, currentMaxValue: travelSegmentBounds?.maxFilterDepartureTime)
            weak var weakDepartureItem: JRFilterDepartureTimeItem?? = departureItem
            departureItem?.filterAction = {() -> Void in
                travelSegmentBounds?.minFilterDepartureTime = weakDepartureItem?.currentMinValue
                travelSegmentBounds?.maxFilterDepartureTime = weakDepartureItem?.currentMaxValue
            }
            departureItem?.isReturn = isReturn
            items.append(departureItem)
        }
        if travelSegmentBounds?.minArrivalTime != travelSegmentBounds?.maxArrivalTime {
            let arrivalItem = JRFilterArrivalTimeItem(minValue: travelSegmentBounds?.minArrivalTime, maxValue: travelSegmentBounds?.maxArrivalTime, currentMinValue: travelSegmentBounds?.minFilterArrivalTime, currentMaxValue: travelSegmentBounds?.maxFilterArrivalTime)
            weak var weakArrivalItem: JRFilterArrivalTimeItem?? = arrivalItem
            arrivalItem?.filterAction = {() -> Void in
                travelSegmentBounds?.minFilterArrivalTime = weakArrivalItem?.currentMinValue
                travelSegmentBounds?.maxFilterArrivalTime = weakArrivalItem?.currentMaxValue
            }
            arrivalItem?.isReturn = isReturn
            items.append(arrivalItem)
        }
        return items
    }

    func createAirlinesItems(forFirstTravelSegment firstTravelSegment: JRSDKTravelSegment, last lastTravelSegment: JRSDKTravelSegment) -> [JRFilterItemProtocol] {
        var items: [JRFilterItemProtocol] = [Any]()
        let firstSegmentBounds: JRFilterTravelSegmentBounds? = filter?.travelSegmentBounds(for: firstTravelSegment)
        let lastSegmentBounds: JRFilterTravelSegmentBounds? = filter?.travelSegmentBounds(for: lastTravelSegment)
        var airlines: NSMutableOrderedSet<JRSDKAirline>? = firstSegmentBounds?.airlines?
        var filterAirlines: NSMutableOrderedSet<JRSDKAirline>? = firstSegmentBounds?.filterAirlines?
        if lastSegmentBounds != nil {
            airlines?.union(lastSegmentBounds?.airlines)
            filterAirlines?.union(lastSegmentBounds?.filterAirlines)
        }
        if airlines?.count > 1 {
            let headerItem = JRFilterAirlinesHeaderItem(itemsCount: airlines?.count)
            items.append(headerItem)
            for airline: JRSDKAirline in airlines {
                let item = JRFilterAirlineItem(airline: airline)
                item.isSelected = filterAirlines?.contains(airline)
                weak var weakItem: JRFilterAirlineItem? = item
                item.filterAction = {() -> Void in
                    if !weakItem?.isSelected && filterAirlines?.contains(airline) {
                        filterAirlines?.remove(at: filterAirlines?.index(of: airline)!)
                        firstSegmentBounds?.filterAirlines = filterAirlines?
                        lastSegmentBounds?.filterAirlines = filterAirlines?
                    }
                    else if weakItem?.isSelected && !filterAirlines?.contains(airline) {
                        filterAirlines?.append(airline)
                        firstSegmentBounds?.filterAirlines = filterAirlines?
                        lastSegmentBounds?.filterAirlines = filterAirlines?
                    }

                }
                items.append(item)
            }
        }
        return items
    }

    func createAlliancesItems(forFirstTravelSegment firstTravelSegment: JRSDKTravelSegment, last lastTravelSegment: JRSDKTravelSegment) -> [JRFilterItemProtocol] {
        var items: [JRFilterItemProtocol] = [Any]()
        let firstSegmentBounds: JRFilterTravelSegmentBounds? = filter?.travelSegmentBounds(for: firstTravelSegment)
        let lastSegmentBounds: JRFilterTravelSegmentBounds? = filter?.travelSegmentBounds(for: lastTravelSegment)
        var alliances: NSMutableOrderedSet<JRSDKAlliance>? = firstSegmentBounds?.alliances?
        var filterAlliances: NSMutableOrderedSet<JRSDKAlliance>? = firstSegmentBounds?.filterAlliances?
        if lastSegmentBounds != nil {
            alliances?.union(lastSegmentBounds?.alliances)
            filterAlliances?.union(lastSegmentBounds?.filterAlliances)
        }
        if alliances?.count > 1 {
            let headerItem = JRFilterAllianceHeaderItem(itemsCount: alliances?.count)
            items.append(headerItem)
            for alliance: JRSDKAlliance in alliances {
                let item = JRFilterAllianceItem(alliance: alliance)
                item.isSelected = filterAlliances?.contains(alliance)
                weak var weakItem: JRFilterAllianceItem? = item
                item.filterAction = {() -> Void in
                    if !weakItem?.isSelected && filterAlliances?.contains(alliance) {
                        filterAlliances?.remove(at: filterAlliances?.index(of: alliance)!)
                        firstSegmentBounds?.filterAlliances = filterAlliances?
                        lastSegmentBounds?.filterAlliances = filterAlliances?
                    }
                    else if weakItem?.isSelected && !filterAlliances?.contains(alliance) {
                        filterAlliances?.append(alliance)
                        firstSegmentBounds?.filterAlliances = filterAlliances?
                        lastSegmentBounds?.filterAlliances = filterAlliances?
                    }

                }
                items.append(item)
            }
        }
        return items
    }

    func createAirportsItems(forFirstTravelSegment firstTravelSegment: JRSDKTravelSegment, last lastTravelSegment: JRSDKTravelSegment) -> [JRFilterItemProtocol] {
        var items: [JRFilterItemProtocol] = [Any]()
        var airportsItems: [JRFilterItemProtocol] = [Any]()
        let originAirportsItems: [JRFilterItemProtocol] = createOriginAirportsItems(forFirstTravelSegment: firstTravelSegment, last: lastTravelSegment)
        let stopoverAirportsItems: [JRFilterItemProtocol] = createStopoverAirportsItems(forFirstTravelSegment: firstTravelSegment, last: lastTravelSegment)
        let destinationAirportsItems: [JRFilterItemProtocol] = createDestinationAirportsItems(forFirstTravelSegment: firstTravelSegment, last: lastTravelSegment)
        var count: Int = 0
        if originAirportsItems.count > 1 {
            let separatorItem = JRFilterListSeparatorItem(title: NSLS("JR_FILTER_AIRPORTS_ORIGIN"))
            airportsItems.append(separatorItem)
            airportsItems += originAirportsItems
            count += originAirportsItems.count
        }
        if stopoverAirportsItems.count > 1 {
            let separatorItem = JRFilterListSeparatorItem(title: NSLS("JR_FILTER_AIRPORTS_STOPOVER"))
            airportsItems.append(separatorItem)
            airportsItems += stopoverAirportsItems
            count += stopoverAirportsItems.count
        }
        if destinationAirportsItems.count > 1 {
            let separatorItem = JRFilterListSeparatorItem(title: NSLS("JR_FILTER_AIRPORTS_DESTINATION"))
            airportsItems.append(separatorItem)
            airportsItems += destinationAirportsItems
            count += destinationAirportsItems.count
        }
        if count > 0 {
            let headerItem = JRFilterAirportsHeaderItem(itemsCount: count)
            items.append(headerItem)
            items += airportsItems
        }
        return items
    }

    func createOriginAirportsItems(forFirstTravelSegment firstTravelSegment: JRSDKTravelSegment, last lastTravelSegment: JRSDKTravelSegment) -> [JRFilterItemProtocol] {
        var items: [JRFilterItemProtocol] = [Any]()
        let firstSegmentBounds: JRFilterTravelSegmentBounds? = filter?.travelSegmentBounds(for: firstTravelSegment)
        let lastSegmentBounds: JRFilterTravelSegmentBounds? = filter?.travelSegmentBounds(for: lastTravelSegment)
        var originAirports: NSMutableOrderedSet<JRSDKAirport>? = firstSegmentBounds?.originAirports?
        var filterOriginAirports: NSMutableOrderedSet<JRSDKAirport>? = firstSegmentBounds?.filterOriginAirports?
        if lastSegmentBounds != nil {
            originAirports?.union(lastSegmentBounds?.originAirports)
            filterOriginAirports?.union(lastSegmentBounds?.filterOriginAirports)
        }
        for airport: JRSDKAirport in originAirports {
            let item = JRFilterAirportItem(airport: airport)
            item.isSelected = filterOriginAirports?.contains(airport)
            weak var weakItem: JRFilterAirportItem? = item
            item.filterAction = {() -> Void in
                if !weakItem?.isSelected && filterOriginAirports?.contains(airport) {
                    filterOriginAirports?.remove(at: filterOriginAirports?.index(of: airport)!)
                    firstSegmentBounds?.filterOriginAirports = filterOriginAirports?
                    lastSegmentBounds?.filterOriginAirports = filterOriginAirports?
                }
                else if weakItem?.isSelected && !filterOriginAirports?.contains(airport) {
                    filterOriginAirports?.append(airport)
                    firstSegmentBounds?.filterOriginAirports = filterOriginAirports?
                    lastSegmentBounds?.filterOriginAirports = filterOriginAirports?
                }

            }
            items.append(item)
        }
        return items
    }

    func createStopoverAirportsItems(forFirstTravelSegment firstTravelSegment: JRSDKTravelSegment, last lastTravelSegment: JRSDKTravelSegment) -> [JRFilterItemProtocol] {
        var items: [JRFilterItemProtocol] = [Any]()
        let firstSegmentBounds: JRFilterTravelSegmentBounds? = filter?.travelSegmentBounds(for: firstTravelSegment)
        let lastSegmentBounds: JRFilterTravelSegmentBounds? = filter?.travelSegmentBounds(for: lastTravelSegment)
        var stopoverAirports: NSMutableOrderedSet<JRSDKAirport>? = firstSegmentBounds?.stopoverAirports?
        var filterStopoverAirports: NSMutableOrderedSet<JRSDKAirport>? = firstSegmentBounds?.filterStopoverAirports?
        if lastSegmentBounds != nil {
            stopoverAirports?.union(lastSegmentBounds?.destinationAirports)
            filterStopoverAirports?.union(lastSegmentBounds?.filterDestinationAirports)
        }
        for airport: JRSDKAirport in stopoverAirports {
            let item = JRFilterAirportItem(airport: airport)
            item.isSelected = filterStopoverAirports?.contains(airport)
            weak var weakItem: JRFilterAirportItem? = item
            item.filterAction = {() -> Void in
                if !weakItem?.isSelected && filterStopoverAirports?.contains(airport) {
                    filterStopoverAirports?.remove(at: filterStopoverAirports?.index(of: airport)!)
                    firstSegmentBounds?.filterStopoverAirports = filterStopoverAirports?
                    lastSegmentBounds?.filterStopoverAirports = filterStopoverAirports?
                }
                else if weakItem?.isSelected && !filterStopoverAirports?.contains(airport) {
                    filterStopoverAirports?.append(airport)
                    firstSegmentBounds?.filterStopoverAirports = filterStopoverAirports?
                    lastSegmentBounds?.filterStopoverAirports = filterStopoverAirports?
                }

            }
            items.append(item)
        }
        return items
    }

    func createDestinationAirportsItems(forFirstTravelSegment firstTravelSegment: JRSDKTravelSegment, last lastTravelSegment: JRSDKTravelSegment) -> [JRFilterItemProtocol] {
        var items: [JRFilterItemProtocol] = [Any]()
        let firstSegmentBounds: JRFilterTravelSegmentBounds? = filter?.travelSegmentBounds(for: firstTravelSegment)
        let lastSegmentBounds: JRFilterTravelSegmentBounds? = filter?.travelSegmentBounds(for: lastTravelSegment)
        var destinationAirports: NSMutableOrderedSet<JRSDKAirport>? = firstSegmentBounds?.destinationAirports?
        var filterDestinationAirports: NSMutableOrderedSet<JRSDKAirport>? = firstSegmentBounds?.filterDestinationAirports?
        if lastSegmentBounds != nil {
            destinationAirports?.union(lastSegmentBounds?.destinationAirports)
            filterDestinationAirports?.union(lastSegmentBounds?.filterDestinationAirports)
        }
        for airport: JRSDKAirport in destinationAirports {
            let item = JRFilterAirportItem(airport: airport)
            item.isSelected = filterDestinationAirports?.contains(airport)
            weak var weakItem: JRFilterAirportItem? = item
            item.filterAction = {() -> Void in
                if !weakItem?.isSelected && filterDestinationAirports?.contains(airport) {
                    filterDestinationAirports?.remove(at: filterDestinationAirports?.index(of: airport)!)
                    firstSegmentBounds?.filterDestinationAirports = filterDestinationAirports?
                    lastSegmentBounds?.filterDestinationAirports = filterDestinationAirports?
                }
                else if weakItem?.isSelected && !filterDestinationAirports?.contains(airport) {
                    filterDestinationAirports?.append(airport)
                    firstSegmentBounds?.filterDestinationAirports = filterDestinationAirports?
                    lastSegmentBounds?.filterDestinationAirports = filterDestinationAirports?
                }

            }
            items.append(item)
        }
        return items
    }
}