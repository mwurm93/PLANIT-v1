//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFilterBoundsBuilder.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

class JRFilterBoundsBuilder: NSObject {
    private(set) var isSimpleSearch: Bool = false
    private(set) var ticketBounds: JRFilterTicketBounds?
    private(set) var travelSegmentsBounds = [Any]()

    var tickets: NSOrderedSet<JRSDKTicket>?
    var searchInfo: JRSDKSearchInfo?
    var ticketBounds: JRFilterTicketBounds?
    var travelSegmentsBounds = [Any]()

    init(searchResults tickets: NSOrderedSet<JRSDKTicket>, for searchInfo: JRSDKSearchInfo) {
        super.init()
        
        self.tickets = tickets
        self.searchInfo = searchInfo
        isSimpleSearch = JRSDKModelUtils.isSimpleSearch(searchInfo)
        createBounds()
        process()
        sortBoundsContent()
    
    }

// MARK: - Private methds
    func createBounds() {
        ticketBounds = JRFilterTicketBounds()
        var travelSegmentsBounds = [Any]()
        for travelSegment: JRSDKTravelSegment in searchInfo.travelSegments {
            let travelSegmentBounds = JRFilterTravelSegmentBounds(travelSegment: travelSegment)
            travelSegmentsBounds.append(travelSegmentBounds)
        }
        self.travelSegmentsBounds = travelSegmentsBounds
    }

    func process() {
        var allPaymentMethods: NSMutableOrderedSet<JRSDKPaymentMethod>? = NSMutableOrderedSet()
        var gatesByMainID: [String: JRSDKGate] = [AnyHashable: Any]()
        for ticket: JRSDKTicket in tickets {
            let curMinPrice: CGFloat? = CFloat(ticket.proposals.first?.price?.priceInUSD())
            let curMaxPrice: CGFloat? = CFloat(ticket.proposals.last?.price?.priceInUSD())
            ticketBounds?.minPrice = min(curMinPrice, ticketBounds?.minPrice)
            ticketBounds?.maxPrice = max(curMaxPrice, ticketBounds?.maxPrice)
            for travelSegment: JRSDKTravelSegment in searchInfo.travelSegments {
                let indexOfTravelSegment: Int = (searchInfo.travelSegments as NSArray).index(of: travelSegment)
                let flightSegment = ticket.flightSegments[indexOfTravelSegment] as? JRSDKFlightSegment ?? JRSDKFlightSegment()
                let travelSegmentBounds = travelSegmentsBounds[indexOfTravelSegment] as? JRFilterTravelSegmentBounds ?? JRFilterTravelSegmentBounds()
                processFlightSegment(flightSegment, with: travelSegmentBounds, minPrice: curMinPrice)
            }
            for proposal: JRSDKProposal in ticket.proposals {
                let gate: JRSDKGate? = proposal.gate
                allPaymentMethods?.union(gate?.paymentMethods)
                gatesByMainID[gate?.mainGateID] = gate
            }
        }
        ticketBounds?.paymentMethods = allPaymentMethods?
        ticketBounds?.gates = NSOrderedSet(array: gatesByMainID.allValues)
    }

    func processFlightSegment(_ flightSegment: JRSDKFlightSegment, with travelSegmentBounds: JRFilterTravelSegmentBounds, minPrice: CGFloat) {
        var transfersCountsWitnMinPrice: [NSNumber: NSNumber] = travelSegmentBounds.transfersCountsWitnMinPrice
        var allAlliances: NSMutableOrderedSet<JRSDKAlliance>? = travelSegmentBounds.alliances
        var allAirlines: NSMutableOrderedSet<JRSDKAirline>? = travelSegmentBounds.airlines
        var originAirports: NSMutableOrderedSet<JRSDKAirport>? = travelSegmentBounds.originAirports
        var stopoverAirports: NSMutableOrderedSet<JRSDKAirport>? = travelSegmentBounds.stopoverAirports
        var destinationAirports: NSMutableOrderedSet<JRSDKAirport>? = travelSegmentBounds.destinationAirports
        travelSegmentBounds.overnightStopover = (flightSegment.hasOvernightStopover) ? true : travelSegmentBounds.overnightStopover
        travelSegmentBounds.transferToAnotherAirport = (flightSegment.hasTransferToAnotherAirport) ? true : travelSegmentBounds.transferToAnotherAirport
        travelSegmentBounds.minTotalDuration = min(flightSegment.totalDurationInMinutes, travelSegmentBounds.minTotalDuration)
        travelSegmentBounds.maxTotalDuration = max(flightSegment.totalDurationInMinutes, travelSegmentBounds.maxTotalDuration)
        travelSegmentBounds.minDelaysDuration = min(flightSegment.delayDurationInMinutes, travelSegmentBounds.minDelaysDuration)
        travelSegmentBounds.maxDelaysDuration = max(flightSegment.delayDurationInMinutes, travelSegmentBounds.maxDelaysDuration)
        travelSegmentBounds.minDepartureTime = min(CDouble(flightSegment.departureDateTimestamp), travelSegmentBounds.minDepartureTime)
        travelSegmentBounds.maxDepartureTime = max(CDouble(flightSegment.departureDateTimestamp), travelSegmentBounds.maxDepartureTime)
        travelSegmentBounds.minArrivalTime = min(CDouble(flightSegment.arrivalDateTimestamp), travelSegmentBounds.minArrivalTime)
        travelSegmentBounds.maxArrivalTime = max(CDouble(flightSegment.arrivalDateTimestamp), travelSegmentBounds.maxArrivalTime)
        if flightSegment.flights.count > 0 {
            let transferCount = (flightSegment.flights.count - 1)
            let minPriceForTransferCount = transfersCountsWitnMinPrice[transferCount]
            if !minPriceForTransferCount || CFloat(minPriceForTransferCount) > minPrice {
                transfersCountsWitnMinPrice[transferCount] = (minPrice)
            }
        }
        let originAirport: JRSDKAirport? = flightSegment.flights.first?.originAirport
        let destinationAirport: JRSDKAirport? = flightSegment.flights.last?.destinationAirport
        for flight: JRSDKFlight in flightSegment.flights {
            allAlliances?.append(flight.airline.alliance)
            allAirlines?.append(flight.airline)
            for airport: JRSDKAirport in [flight.originAirport, flight.destinationAirport] {
                if airport.isEqual(originAirport) {
                    originAirports?.append(airport)
                }
                else if airport.isEqual(destinationAirport) {
                    destinationAirports?.append(airport)
                }
                else {
                    stopoverAirports?.append(airport)
                }
            }
        }
        travelSegmentBounds.transfersCountsWitnMinPrice = transfersCountsWitnMinPrice
        travelSegmentBounds.airlines = allAirlines?
        travelSegmentBounds.alliances = allAlliances?
        travelSegmentBounds.originAirports = originAirports?
        travelSegmentBounds.stopoverAirports = stopoverAirports?
        travelSegmentBounds.destinationAirports = destinationAirports?
    }

    func sortBoundsContent() {
        var allPaymentMethods: NSMutableOrderedSet<JRSDKPaymentMethod>? = ticketBounds?.paymentMethods?
        var allGates: NSMutableOrderedSet<JRSDKGate>? = ticketBounds?.gates?
        allPaymentMethods?.sort(by: {(_ obj1: JRSDKPaymentMethod, _ obj2: JRSDKPaymentMethod) -> ComparisonResult in
            return obj1.name?.caseInsensitiveCompare(obj2.name)
        })
        allGates?.sort(by: {(_ obj1: JRSDKGate, _ obj2: JRSDKGate) -> ComparisonResult in
            return obj1.label?.caseInsensitiveCompare(obj2.label)
        })
        ticketBounds?.paymentMethods = allPaymentMethods?
        ticketBounds?.gates = allGates?
        ticketBounds?.reset()
        for travelSegmentBounds: JRFilterTravelSegmentBounds in travelSegmentsBounds {
            var transfersCounts: NSMutableOrderedSet<NSNumber>? = NSMutableOrderedSet(array: travelSegmentBounds.transfersCountsWitnMinPrice.keys)
            var allAlliances: NSMutableOrderedSet<JRSDKAlliance>? = travelSegmentBounds.alliances
            var allAirlines: NSMutableOrderedSet<JRSDKAirline>? = travelSegmentBounds.airlines
            var originAirports: NSMutableOrderedSet<JRSDKAirport>? = travelSegmentBounds.originAirports
            var stopoverAirports: NSMutableOrderedSet<JRSDKAirport>? = travelSegmentBounds.stopoverAirports
            var destinationAirports: NSMutableOrderedSet<JRSDKAirport>? = travelSegmentBounds.destinationAirports
            transfersCounts?.sort(by: {(_ obj1: NSNumber, _ obj2: NSNumber) -> ComparisonResult in
                return obj1.compare(obj2)
            }) /* options: .concurrent */
            allAirlines?.sort(by: {(_ obj1: JRSDKAirline, _ obj2: JRSDKAirline) -> ComparisonResult in
                return obj1.name?.caseInsensitiveCompare(obj2.name)
            }) /* options: .concurrent */
            allAlliances?.sort(by: {(_ obj1: JRSDKAlliance, _ obj2: JRSDKAlliance) -> ComparisonResult in
                return obj1.name?.caseInsensitiveCompare(obj2.name)
            }) /* options: .concurrent */
            originAirports?.sort(by: {(_ obj1: JRSDKAirport, _ obj2: JRSDKAirport) -> ComparisonResult in
                return obj1.city.caseInsensitiveCompare(obj2.city)
            }) /* options: .concurrent */
            stopoverAirports?.sort(by: {(_ obj1: JRSDKAirport, _ obj2: JRSDKAirport) -> ComparisonResult in
                return obj1.city.caseInsensitiveCompare(obj2.city)
            }) /* options: .concurrent */
            destinationAirports?.sort(by: {(_ obj1: JRSDKAirport, _ obj2: JRSDKAirport) -> ComparisonResult in
                return obj1.city.caseInsensitiveCompare(obj2.city)
            }) /* options: .concurrent */
            travelSegmentBounds.transfersCounts = transfersCounts?
            travelSegmentBounds.airlines = allAirlines?
            travelSegmentBounds.alliances = allAlliances?
            travelSegmentBounds.originAirports = originAirports?
            travelSegmentBounds.stopoverAirports = stopoverAirports?
            travelSegmentBounds.destinationAirports = destinationAirports?
            travelSegmentBounds.reset()
        }
    }
}