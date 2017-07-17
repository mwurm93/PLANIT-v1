//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFilterTask.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

protocol JRFilterTaskDelegate: NSObjectProtocol {
    func filterTaskDidFinish(withTickets filteredTickets: NSOrderedSet<JRSDKTicket>)
}

class JRFilterTask: NSObject {
    weak var ticketBounds: JRFilterTicketBounds?
    weak var travelSegmentBounds: [Any]?
    weak var delegate: JRFilterTaskDelegate?
    weak var ticketsToFilter: NSOrderedSet<JRSDKTicket>?

    convenience init(for ticketsToFilter: NSOrderedSet<JRSDKTicket>, ticketBounds: JRFilterTicketBounds, travelSegmentBounds: [Any], taskDelegate delegate: JRFilterTaskDelegate?) {
        return JRFilterTask.initFilterTask(forTickets: ticketsToFilter, ticketBounds: ticketBounds, travelSegmentBounds: travelSegmentBounds, taskDelegate: delegate)
    }

    func performFiltering() {
        var filteredTickets: NSMutableOrderedSet<JRSDKTicket>? = NSMutableOrderedSet()
        for ticket: JRSDKTicket in ticketsToFilter {
            var filteredProposals: NSMutableOrderedSet<JRSDKProposal>? = ticket.proposals
            let filteredTicket: JRSDKTicket? = ticket
            for proposal: JRSDKProposal in ticket.proposals {
                let priceValue: CGFloat = CFloat(proposal.price.priceInUSD())
                if priceValue > ticketBounds.filterPrice {
                    filteredProposals?.remove(at: filteredProposals?.index(of: proposal)!)
                }
                else if !ticketBounds.filterGates.hasMainGate(proposal.gate) {
                    filteredProposals?.remove(at: filteredProposals?.index(of: proposal)!)
                }
                else if !proposal.gate.paymentMethods?.intersect(Set<AnyHashable>()) {
                    filteredProposals?.remove(at: filteredProposals?.index(of: proposal)!)
                }
            }
            if filteredProposals?.count > 0 {
                if !needRemoveTicket(afterTravelSegmentBoundsWereApplied: ticket) {
                    filteredTicket?.proposals = filteredProposals
                    filteredTickets?.append(filteredTicket)
                }
            }
        }
        delegate?.filterTaskDidFinish(withTickets: filteredTickets)
    }

    func initFilterTask(forTickets ticketsToFilter: NSOrderedSet<JRSDKTicket>, ticketBounds: JRFilterTicketBounds, travelSegmentBounds: [Any], taskDelegate delegate: JRFilterTaskDelegate?) -> JRFilterTask {
        super.init()
        
        self.ticketBounds = ticketBounds
        self.ticketsToFilter = ticketsToFilter
        self.travelSegmentBounds = travelSegmentBounds
        self.delegate = delegate
    
    }

    func needRemoveTicket(afterTravelSegmentBoundsWereApplied ticket: JRSDKTicket) -> Bool {
        var needRemove: Bool = false
        for travelSegmentBounds: JRFilterTravelSegmentBounds in travelSegmentBounds {
            let indexOfTravelSegment: Int = (travelSegmentBounds as NSArray).index(of: travelSegmentBounds)
            let flightSegment = ticket.flightSegments[indexOfTravelSegment] as? JRSDKFlightSegment ?? JRSDKFlightSegment()
            if travelSegmentBounds.filterTotalDuration < flightSegment.totalDurationInMinutes {
                needRemove = true
                break
            }
            if travelSegmentBounds.minFilterDelaysDuration > flightSegment.delayDurationInMinutes || travelSegmentBounds.maxFilterDelaysDuration < flightSegment.delayDurationInMinutes {
                needRemove = true
                break
            }
            if travelSegmentBounds.minFilterDepartureTime > CDouble(flightSegment.departureDateTimestamp) || travelSegmentBounds.maxFilterDepartureTime < CDouble(flightSegment.departureDateTimestamp) {
                needRemove = true
                break
            }
            if travelSegmentBounds.minFilterArrivalTime > CDouble(flightSegment.arrivalDateTimestamp) || travelSegmentBounds.maxFilterArrivalTime < CDouble(flightSegment.arrivalDateTimestamp) {
                needRemove = true
                break
            }
            if flightSegment.flights.count > 0 {
                if !travelSegmentBounds.filterTransfersCounts.contains((flightSegment.flights.count - 1)) {
                    needRemove = true
                    break
                }
            }
            let flightSegmentAirlines: Set<JRSDKAirline> = flightSegment.flights.value(forKeyPath: "airline")
            if !flightSegmentAirlines.isSubsetOf(Set<AnyHashable>()) {
                needRemove = true
                break
            }
            let flightSegmentAlliances: Set<JRSDKAlliance> = flightSegment.flights.value(forKeyPath: "airline.alliance")
            if !flightSegmentAlliances.isSubsetOf(Set<AnyHashable>()) {
                needRemove = true
                break
            }
            let originAirport: JRSDKAirport? = flightSegment.flights.first?.originAirport
            if !travelSegmentBounds.filterOriginAirports.contains(originAirport) {
                needRemove = true
                break
            }
            let destinationAirport: JRSDKAirport? = flightSegment.flights.last?.destinationAirport
            if !travelSegmentBounds.filterDestinationAirports.contains(destinationAirport) {
                needRemove = true
                break
            }
            if flightSegment.flights.count > 1 {
                var stopoverAirports: Set<JRSDKAirport> = Set<AnyHashable>()
                for flight: JRSDKFlight in flightSegment.flights {
                    for airport: JRSDKAirport in [flight.originAirport, flight.destinationAirport] {
                        if !airport.isEqual(originAirport) && !airport.isEqual(destinationAirport) {
                            stopoverAirports.insert(airport)
                        }
                    }
                }
                if !stopoverAirports.isSubsetOf(Set<AnyHashable>()) {
                    needRemove = true
                    break
                }
            }
        }
        return needRemove
    }
}

extension NSOrderedSet {
    func hasMainGate(_ gate: JRSDKGate) -> Bool {
        return index(ofObjectPassingTest: {(_ obj: JRSDKGate, _ idx: Int, _ stop: Bool) -> Bool in
            return (obj.mainGateID == gate.mainGateID)
        }) != NSNotFound
    }
}