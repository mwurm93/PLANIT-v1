//
//  JRResultsTicketCell.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 7/18/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

//import Foundation
//import UIKit
//import AviasalesSDK
//
//@objc class FlightTicketsAccessoryMethodPerformer: NSObject {
//    func saveFlightTickets(ticket: JRSDKTicket) {
//        let flightTicketToSave  = NSKeyedArchiver.archivedData(withRootObject: ticket)
//        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//        var savedFlightTickets = SavedPreferencesForTrip["savedFlightTickets"] as! [Data]
//        savedFlightTickets.append(flightTicketToSave)
//        SavedPreferencesForTrip["savedFlightTickets"] = savedFlightTickets
//        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
//    }
//
//    func removeSavedFlightTickets(ticket: JRSDKTicket) {
//        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//        var savedFlightTicketsAsData = SavedPreferencesForTrip["savedFlightTickets"] as! [Data]
//        var savedFlightTickets = [JRSDKTicket]()
//        for savedFlightTicketAsData in savedFlightTicketsAsData {
//            let savedFlightTicket = NSKeyedUnarchiver.unarchiveObject(with: savedFlightTicketAsData) as? JRSDKTicket
//            savedFlightTickets.append(savedFlightTicket!)
//        }
//        for i in 0 ... savedFlightTickets.count - 1 {
//            if ticket == savedFlightTickets[i] {
//                savedFlightTicketsAsData.remove(at: i)
//            }
//        }
//        SavedPreferencesForTrip["savedFlightTickets"] = savedFlightTicketsAsData
//        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
//    }
//    
//    func fetchSavedFlightTickets() -> [JRSDKTicket] {
//        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//        var savedFlightTicketsAsData = SavedPreferencesForTrip["savedFlightTickets"] as! [Data]
//        var savedFlightTickets = [JRSDKTicket]()
//        for savedFlightTicketAsData in savedFlightTicketsAsData {
//            let savedFlightTicket = NSKeyedUnarchiver.unarchiveObject(with: savedFlightTicketAsData) as? JRSDKTicket
//            savedFlightTickets.append(savedFlightTicket!)
//        }
//        return savedFlightTickets
//    }
//    func checkIfSavedFlightTicketsContains(ticket:JRSDKTicket, savedFlightTickets: [JRSDKTicket]) -> Int {
//        for savedFlightTicket in savedFlightTickets {
//            if ticket == savedFlightTicket {
//                return 1
//            }
//        }
//        return 0
//    }

//    func convertTicketForSave(ticket:JRSDKTicket) -> NSDictionary {
//        var flightResultDictionary = [AnyHashable: Any]()
//        flightResultDictionary["sign"] = ticket.sign
//        flightResultDictionary["simpleRating"] = ticket.simpleRating
//        flightResultDictionary["isFromTrustedGate"] = ticket.isFromTrustedGate
//        flightResultDictionary["isCharter"] = ticket.isCharter
//        //Convert NSOrderedSet to NSArray for saving to NSUserDefaults
//        //Flight Segments
//        var flightSegmentsDictArray = [[AnyHashable: Any]]()
//        for i in 0 ... ticket.flightSegments.count - 1 {
//            var flightSegmentDict = [AnyHashable: Any]()
//            flightSegmentDict["hasOvernightStopover"] = (ticket.flightSegments.array[i] as! JRSDKFlightSegment).hasOvernightStopover
//            flightSegmentDict["hasTransferToAnotherAirport"] = (ticket.flightSegments.array[i] as! JRSDKFlightSegment).hasTransferToAnotherAirport
//            flightSegmentDict["departureDateTimestamp"] = (ticket.flightSegments.array[i] as! JRSDKFlightSegment).departureDateTimestamp
//            flightSegmentDict["arrivalDateTimestamp"] = (ticket.flightSegments.array[i] as! JRSDKFlightSegment).arrivalDateTimestamp
//            flightSegmentDict["delayDurationInMinutes"] = (ticket.flightSegments.array[i] as! JRSDKFlightSegment).delayDurationInMinutes as NSNumber
//            flightSegmentDict["totalDurationInMinutes"] = (ticket.flightSegments.array[i] as! JRSDKFlightSegment).totalDurationInMinutes as NSNumber
//            
//            var segmentAirlineDict = [AnyHashable: Any]()
//            segmentAirlineDict["averageRate"] = (ticket.flightSegments.array[i] as! JRSDKFlightSegment).segmentAirline.averageRate
//            segmentAirlineDict["name"] = (ticket.flightSegments.array[i] as! JRSDKFlightSegment).segmentAirline.name
//            segmentAirlineDict["iata"] = (ticket.flightSegments.array[i] as! JRSDKFlightSegment).segmentAirline.iata
//            segmentAirlineDict["isLowcost"] = (ticket.flightSegments.array[i] as! JRSDKFlightSegment).segmentAirline.isLowcost
//            segmentAirlineDict["alliance"] = (ticket.flightSegments.array[i] as! JRSDKFlightSegment).segmentAirline.alliance.name
//            var commonBaggageRuleDict = [AnyHashable: Any]()
//            commonBaggageRuleDict["baggagePackagesCount"] = (ticket.flightSegments.array[i] as! JRSDKFlightSegment).segmentAirline.commonBaggageRule?.baggagePackagesCount.hashValue
//            commonBaggageRuleDict["baggageTotalWeight"] = (ticket.flightSegments.array[i] as! JRSDKFlightSegment).segmentAirline.commonBaggageRule?.baggageTotalWeight.hashValue
//            commonBaggageRuleDict["baggageRuleType"] = (ticket.flightSegments.array[i] as! JRSDKFlightSegment).segmentAirline.commonBaggageRule?.baggageRuleType.hashValue
//            commonBaggageRuleDict["handbagPackagesCount"] = (ticket.flightSegments.array[i] as! JRSDKFlightSegment).segmentAirline.commonBaggageRule?.handbagPackagesCount.hashValue
//            commonBaggageRuleDict["handbagTotalWeight"] = (ticket.flightSegments.array[i] as! JRSDKFlightSegment).segmentAirline.commonBaggageRule?.handbagTotalWeight.hashValue
//            commonBaggageRuleDict["handbagRuleType"] = (ticket.flightSegments.array[i] as! JRSDKFlightSegment).segmentAirline.commonBaggageRule?.handbagRuleType.hashValue
//            commonBaggageRuleDict["relative"] = (ticket.flightSegments.array[i] as! JRSDKFlightSegment).segmentAirline.commonBaggageRule?.relative
//            segmentAirlineDict["commonBaggageRule"] = commonBaggageRuleDict
//            flightSegmentDict["segmentAirline"] = segmentAirlineDict
//            
//            
//            var flightsDictArray = [[AnyHashable: Any]]()
//            for j in 0 ... (ticket.flightSegments.array[i] as! JRSDKFlightSegment).flights.count - 1 {
//                let flight = ((ticket.flightSegments.array[i] as! JRSDKFlightSegment).flights[j] as! JRSDKFlight)
//                var flightDict = [AnyHashable: Any]()
//                flightDict["aircraft"] = flight.aircraft
//                flightDict["delay"] = flight.delay
//                flightDict["departureDate"] = flight.departureDate
//                flightDict["arrivalDate"] = flight.arrivalDate
//                flightDict["duration"] = flight.duration
//                flightDict["number"] = flight.number
//                //Origin Airport
//                var flightOriginAirportDict = [AnyHashable: Any]()
//                flightOriginAirportDict["averageRate"] = flight.originAirport.averageRate
//                flightOriginAirportDict["city"] = flight.originAirport.city
//                flightOriginAirportDict["cityNameCasePr"] = flight.originAirport.cityNameCasePr
//                flightOriginAirportDict["cityNameCaseRo"] = flight.originAirport.cityNameCaseRo
//                flightOriginAirportDict["cityNameCaseVi"] = flight.originAirport.cityNameCaseVi
//                flightOriginAirportDict["countryName"] = flight.originAirport.countryName
//                flightOriginAirportDict["countryCode"] = flight.originAirport.countryCode
//                flightOriginAirportDict["iata"] = flight.originAirport.iata
//                flightOriginAirportDict["parentIata"] = flight.originAirport.parentIata
//                flightOriginAirportDict["latitude"] = flight.originAirport.latitude
//                flightOriginAirportDict["longitude"] = flight.originAirport.longitude
//                flightOriginAirportDict["timeZone"] = flight.originAirport.timeZone?.abbreviation()
//                flightOriginAirportDict["airportName"] = flight.originAirport.airportName
//                flightOriginAirportDict["indexStrings"] = flight.originAirport.indexStrings
//                flightOriginAirportDict["airportType"] = flight.originAirport.airportType.hashValue as! NSNumber
//                flightOriginAirportDict["weight"] = flight.originAirport.weight
//                flightOriginAirportDict["searchable"] = flight.originAirport.searchable
//                flightOriginAirportDict["flightable"] = flight.originAirport.flightable
//                flightOriginAirportDict["isCity"] = flight.originAirport.isCity
//                flightOriginAirportDict["fromServer"] = flight.originAirport.fromServer
//                
//                flightDict["originAirport"] = flightOriginAirportDict
//                //destinationAirport
//                var flightdestinationAirportDict = [AnyHashable: Any]()
//                flightdestinationAirportDict["averageRate"] = flight.destinationAirport.averageRate
//                flightdestinationAirportDict["city"] = flight.destinationAirport.city
//                flightdestinationAirportDict["cityNameCasePr"] = flight.destinationAirport.cityNameCasePr
//                flightdestinationAirportDict["cityNameCaseRo"] = flight.destinationAirport.cityNameCaseRo
//                flightdestinationAirportDict["cityNameCaseVi"] = flight.destinationAirport.cityNameCaseVi
//                flightdestinationAirportDict["countryName"] = flight.destinationAirport.countryName
//                flightdestinationAirportDict["countryCode"] = flight.destinationAirport.countryCode
//                flightdestinationAirportDict["iata"] = flight.destinationAirport.iata
//                flightdestinationAirportDict["parentIata"] = flight.destinationAirport.parentIata
//                flightdestinationAirportDict["latitude"] = flight.destinationAirport.latitude
//                flightdestinationAirportDict["longitude"] = flight.destinationAirport.longitude
//                flightdestinationAirportDict["timeZone"] = flight.destinationAirport.timeZone?.abbreviation()
//                flightdestinationAirportDict["airportName"] = flight.destinationAirport.airportName
//                flightdestinationAirportDict["indexStrings"] = flight.destinationAirport.indexStrings
//                flightdestinationAirportDict["airportType"] = flight.destinationAirport.airportType.hashValue as! NSNumber
//                flightdestinationAirportDict["weight"] = flight.destinationAirport.weight
//                flightdestinationAirportDict["searchable"] = flight.destinationAirport.searchable
//                flightdestinationAirportDict["flightable"] = flight.destinationAirport.flightable
//                flightdestinationAirportDict["isCity"] = flight.destinationAirport.isCity
//                flightdestinationAirportDict["fromServer"] = flight.destinationAirport.fromServer
//                
//                flightDict["destinationAirport"] = flightdestinationAirportDict
//                
//                //Technical stops
//                var technicalStopsDictArray = [[AnyHashable: Any]]()
//                if flight.technicalStops.count > 0 {
//                    for k in 0 ... flight.technicalStops.count - 1 {
//                        let technicalStop = (flight.technicalStops.array[k] as! JRSDKAirport)
//                        var technicalStopDict = [AnyHashable: Any]()
//                        technicalStopDict["averageRate"] = technicalStop.averageRate
//                        technicalStopDict["city"] = technicalStop.city
//                        technicalStopDict["cityNameCasePr"] = technicalStop.cityNameCasePr
//                        technicalStopDict["cityNameCaseRo"] = technicalStop.cityNameCaseRo
//                        technicalStopDict["cityNameCaseVi"] = technicalStop.cityNameCaseVi
//                        technicalStopDict["countryName"] = technicalStop.countryName
//                        technicalStopDict["countryCode"] = technicalStop.countryCode
//                        technicalStopDict["iata"] = technicalStop.iata
//                        technicalStopDict["parentIata"] = technicalStop.parentIata
//                        technicalStopDict["latitude"] = technicalStop.latitude
//                        technicalStopDict["longitude"] = technicalStop.longitude
//                        technicalStopDict["timeZone"] = technicalStop.timeZone?.abbreviation()
//                        technicalStopDict["airportName"] = technicalStop.airportName
//                        technicalStopDict["indexStrings"] = technicalStop.indexStrings
//                        technicalStopDict["airportType"] = technicalStop.airportType.hashValue as! NSNumber
//                        technicalStopDict["weight"] = technicalStop.weight
//                        technicalStopDict["searchable"] = technicalStop.searchable
//                        technicalStopDict["flightable"] = technicalStop.flightable
//                        technicalStopDict["isCity"] = technicalStop.isCity
//                        technicalStopDict["fromServer"] = technicalStop.fromServer
//                        technicalStopsDictArray.append(technicalStopDict)
//                    }
//                }
//                flightDict["technicalStops"] = technicalStopsDictArray
//                
//                //Airline
//                var flightAirlineDict = [AnyHashable: Any]()
//                flightAirlineDict["averageRate"] = flight.airline.averageRate
//                flightAirlineDict["name"] = flight.airline.name
//                flightAirlineDict["iata"] = flight.airline.iata
//                flightAirlineDict["isLowcost"] = flight.airline.isLowcost
//                flightAirlineDict["alliance"] = flight.airline.alliance.name
//                var commonBaggageRuleDict = [AnyHashable: Any]()
//                commonBaggageRuleDict["baggagePackagesCount"] = flight.airline.commonBaggageRule?.baggagePackagesCount.hashValue
//                commonBaggageRuleDict["baggageTotalWeight"] = flight.airline.commonBaggageRule?.baggageTotalWeight.hashValue
//                commonBaggageRuleDict["baggageRuleType"] = flight.airline.commonBaggageRule?.baggageRuleType.hashValue
//                commonBaggageRuleDict["handbagPackagesCount"] = flight.airline.commonBaggageRule?.handbagPackagesCount.hashValue
//                commonBaggageRuleDict["handbagTotalWeight"] = flight.airline.commonBaggageRule?.handbagTotalWeight.hashValue
//                commonBaggageRuleDict["handbagRuleType"] = flight.airline.commonBaggageRule?.handbagRuleType.hashValue
//                commonBaggageRuleDict["relative"] = flight.airline.commonBaggageRule?.relative
//                flightAirlineDict["commonBaggageRule"] = commonBaggageRuleDict
//                flightDict["airline"] = flightAirlineDict
//                //Operating airline
//                var operatingFlightAirlineDict = [AnyHashable: Any]()
//                flightAirlineDict["averageRate"] = flight.operatingAirline.averageRate
//                flightAirlineDict["name"] = flight.operatingAirline.name
//                flightAirlineDict["iata"] = flight.operatingAirline.iata
//                flightAirlineDict["isLowcost"] = flight.operatingAirline.isLowcost
//                flightAirlineDict["alliance"] = flight.operatingAirline.alliance.name
//                var operatingFlightCommonBaggageRuleDict = [AnyHashable: Any]()
//                operatingFlightCommonBaggageRuleDict["baggagePackagesCount"] = flight.operatingAirline.commonBaggageRule?.baggagePackagesCount.hashValue
//                operatingFlightCommonBaggageRuleDict["baggageTotalWeight"] = flight.operatingAirline.commonBaggageRule?.baggageTotalWeight.hashValue
//                operatingFlightCommonBaggageRuleDict["baggageRuleType"] = flight.operatingAirline.commonBaggageRule?.baggageRuleType.hashValue
//                operatingFlightCommonBaggageRuleDict["handbagPackagesCount"] = flight.operatingAirline.commonBaggageRule?.handbagPackagesCount.hashValue
//                operatingFlightCommonBaggageRuleDict["handbagTotalWeight"] = flight.operatingAirline.commonBaggageRule?.handbagTotalWeight.hashValue
//                operatingFlightCommonBaggageRuleDict["handbagRuleType"] = flight.operatingAirline.commonBaggageRule?.handbagRuleType.hashValue
//                operatingFlightCommonBaggageRuleDict["relative"] = flight.operatingAirline.commonBaggageRule?.relative
//                operatingFlightAirlineDict["commonBaggageRule"] = operatingFlightCommonBaggageRuleDict
//                flightDict["operatingAirline"] = operatingFlightAirlineDict
//                flightsDictArray.append(flightDict)
//            }
//            flightSegmentDict["flights"] = flightsDictArray
//            flightSegmentDict["arrivalDateTimestamp"] = (ticket.flightSegments.array[i] as! JRSDKFlightSegment).arrivalDateTimestamp
//            flightSegmentsDictArray.append(flightSegmentDict)
//        }
//        flightResultDictionary["flightSegments"] = NSOrderedSet(array: flightSegmentsDictArray)
//        
//        //search result info
//        var searchResultInfo = [AnyHashable: Any]()
//        searchResultInfo["searchID"] = ticket.searchResultInfo.searchID
//        searchResultInfo["receivingDate"] = ticket.searchResultInfo.receivingDate
//        searchResultInfo["type"] = ticket.searchResultInfo.type.hashValue
//        var searchInfo = [AnyHashable: Any]()
//        searchInfo["adults"] = ticket.searchResultInfo.searchInfo.adults
//        searchInfo["children"] = ticket.searchResultInfo.searchInfo.children
//        searchInfo["infants"] = ticket.searchResultInfo.searchInfo.infants
//        searchInfo["travelClass"] = ticket.searchResultInfo.searchInfo.travelClass.hashValue
//        searchInfo["ticketSignToSearch"] = ticket.searchResultInfo.searchInfo.ticketSignToSearch
//        var travelSegments = [[AnyHashable: Any]]()
//        for m in 0 ... ticket.searchResultInfo.searchInfo.travelSegments.count - 1 {
//            let segment = ticket.searchResultInfo.searchInfo.travelSegments.array[m] as! JRSDKTravelSegment
//            var travelSegmentDict =  [AnyHashable: Any]()
//            //Date
//            
//            travelSegmentDict["departureDate"] = segment.departureDate
//            //Origin Airport
//            var travelSegmentOriginAirportDict = [AnyHashable: Any]()
//            travelSegmentOriginAirportDict["averageRate"] = segment.originAirport.averageRate
//            travelSegmentOriginAirportDict["city"] = segment.originAirport.city
//            travelSegmentOriginAirportDict["cityNameCasePr"] = segment.originAirport.cityNameCasePr
//            travelSegmentOriginAirportDict["cityNameCaseRo"] = segment.originAirport.cityNameCaseRo
//            travelSegmentOriginAirportDict["cityNameCaseVi"] = segment.originAirport.cityNameCaseVi
//            travelSegmentOriginAirportDict["countryName"] = segment.originAirport.countryName
//            travelSegmentOriginAirportDict["countryCode"] = segment.originAirport.countryCode
//            travelSegmentOriginAirportDict["iata"] = segment.originAirport.iata
//            travelSegmentOriginAirportDict["parentIata"] = segment.originAirport.parentIata
//            travelSegmentOriginAirportDict["latitude"] = segment.originAirport.latitude
//            travelSegmentOriginAirportDict["longitude"] = segment.originAirport.longitude
//            travelSegmentOriginAirportDict["timeZone"] = segment.originAirport.timeZone?.abbreviation()
//            travelSegmentOriginAirportDict["airportName"] = segment.originAirport.airportName
//            travelSegmentOriginAirportDict["indexStrings"] = segment.originAirport.indexStrings
//            travelSegmentOriginAirportDict["airportType"] = segment.originAirport.airportType.hashValue
//            travelSegmentOriginAirportDict["weight"] = segment.originAirport.weight
//            travelSegmentOriginAirportDict["searchable"] = segment.originAirport.searchable
//            travelSegmentOriginAirportDict["flightable"] = segment.originAirport.flightable
//            travelSegmentOriginAirportDict["isCity"] = segment.originAirport.isCity
//            travelSegmentOriginAirportDict["fromServer"] = segment.originAirport.fromServer
//            
//            travelSegmentDict["originAirport"] = travelSegmentOriginAirportDict
//            //destinationAirport
//            var travelSegmentDestinationAirportDict = [AnyHashable: Any]()
//            travelSegmentDestinationAirportDict["averageRate"] = segment.originAirport.averageRate
//            travelSegmentDestinationAirportDict["city"] = segment.originAirport.city
//            travelSegmentDestinationAirportDict["cityNameCasePr"] = segment.originAirport.cityNameCasePr
//            travelSegmentDestinationAirportDict["cityNameCaseRo"] = segment.originAirport.cityNameCaseRo
//            travelSegmentDestinationAirportDict["cityNameCaseVi"] = segment.originAirport.cityNameCaseVi
//            travelSegmentDestinationAirportDict["countryName"] = segment.originAirport.countryName
//            travelSegmentDestinationAirportDict["countryCode"] = segment.originAirport.countryCode
//            travelSegmentDestinationAirportDict["iata"] = segment.originAirport.iata
//            travelSegmentDestinationAirportDict["parentIata"] = segment.originAirport.parentIata
//            travelSegmentDestinationAirportDict["latitude"] = segment.originAirport.latitude
//            travelSegmentDestinationAirportDict["longitude"] = segment.originAirport.longitude
//            travelSegmentDestinationAirportDict["timeZone"] = segment.originAirport.timeZone?.abbreviation()
//            travelSegmentDestinationAirportDict["airportName"] = segment.originAirport.airportName
//            travelSegmentDestinationAirportDict["indexStrings"] = segment.originAirport.indexStrings
//            travelSegmentDestinationAirportDict["airportType"] = segment.originAirport.airportType.hashValue
//            travelSegmentDestinationAirportDict["weight"] = segment.originAirport.weight
//            travelSegmentDestinationAirportDict["searchable"] = segment.originAirport.searchable
//            travelSegmentDestinationAirportDict["flightable"] = segment.originAirport.flightable
//            travelSegmentDestinationAirportDict["isCity"] = segment.originAirport.isCity
//            travelSegmentDestinationAirportDict["fromServer"] = segment.originAirport.fromServer
//            
//            travelSegmentDict["departureAirport"] = travelSegmentDestinationAirportDict
//            travelSegments.append(travelSegmentDict)
//        }
//        searchInfo["travelSegments"] = travelSegments
//        searchResultInfo["searchInfo"] = searchInfo
//        flightResultDictionary["searchResultInfo"] = searchResultInfo
//
//        var proposalDictArray = [[AnyHashable: Any]]()
//        for n in 0 ... ticket.proposals.count - 1 {
//            var proposalDict = [AnyHashable: Any]()
//            let proposal = (ticket.proposals[n] as! JRSDKProposal)
//            proposalDict["orderID"] = proposal.orderID
//            proposalDict["creditGracePeriod"] = proposal.creditGracePeriod
//            proposalDict["creditPaymentsCount"] = proposal.creditPaymentsCount
//            proposalDict["creditLastPaymentDate"] = proposal.creditLastPaymentDate
//            proposalDict["creditOverpaymentPercent"] = proposal.creditOverpaymentPercent
//            //Credit Payment Price
//            var proposalCreditPriceDict = [AnyHashable: Any]()
//            proposalCreditPriceDict["currency"] = proposal.creditPayment?.currency
//            proposalCreditPriceDict["value"] = proposal.creditPayment?.value
//            proposalDict["creditPayment"] = proposalCreditPriceDict
//            //Price
//            var proposalPriceDict = [AnyHashable: Any]()
//            proposalPriceDict["currency"] = proposal.price.currency
//            proposalPriceDict["value"] = proposal.price.value
//            proposalDict["price"] = proposalPriceDict
//            
//            
//            //        @property (strong, nonatomic, nullable) JRSDKGate *gate;
//            //        @property (strong, nonatomic, nullable) JRSDKTicket *ticket;
//            //        @property (strong, nonatomic, nullable) JRSDKProposalRate *rate;
//            
//            
//            
//            proposalDictArray.append(proposalDict)
//        }
//            
//        return flightResultDictionary as NSDictionary
//    }
////    func rebuildTicketFrom(flightResultDictionary: [AnyHashable: Any]) {
////        var ticketBuilder = JRSDKTicketBuilder()
////        ticketBuilder.sign = flightResultDictionary["sign"] as? String
////        ticketBuilder.simpleRating = flightResultDictionary["simpleRating"] as? NSNumber
////        ticketBuilder.isCharter = flightResultDictionary["isCharter"] as! Bool
////        ticketBuilder.isFromTrustedGate = flightResultDictionary["isCharter"] as! Bool
////        
////        let searchResultInfoDict = flightResultDictionary["searchResultInfo"] as! [AnyHashable: Any]
////        
////        var searchResultInfoBuilder = JRSDKSearchResultInfoBuilder()
////        searchResultInfoBuilder.searchID = searchResultInfoDict["searchID"] as? String
////        searchResultInfoBuilder.type = JRSDKSearchResultType(rawValue: searchResultInfoDict["type"] as! Int)!
////        searchResultInfoBuilder.receivingDate = searchResultInfoDict["receivingDate"] as? Date
////        var searchInfoBuilder = JRSDKSearchInfoBuilder()
////        let searchInfo = searchResultInfoDict["searchInfo"] as! [AnyHashable: Any]
////        searchInfoBuilder.adults = searchInfo["adults"] as! UInt
////        searchInfoBuilder.infants = searchInfo["infants"] as! UInt
////        searchInfoBuilder.children = searchInfo["children"] as! UInt
////        searchInfoBuilder.travelClass = JRSDKTravelClass(rawValue: searchInfo["travelClass"] as! Int)!
////        searchInfoBuilder.ticketSignToSearch = searchInfo["ticketSignToSearch"] as? String
////        var travelSegments = [JRSDKTravelSegment]()
////        for m in 0 ... (searchInfo["travelSegments"] as! [[AnyHashable: Any]]).count - 1 {
////            let segment = (searchInfo["travelSegments"] as! [[AnyHashable: Any]])[m]
////            var travelSegmentBuilder = JRSDKTravelSegmentBuilder()
////            //Date
////            travelSegmentBuilder.departureDate = segment["departureDate"] as? Date
////            //Origin Airport
////            var originAirportBuilder = JRSDKAirportBuilder()
////            var travelSegmentOriginAirportDict = segment["originAirport"] as! [AnyHashable: Any]
////            originAirportBuilder.averageRate = travelSegmentOriginAirportDict["averageRate"] as? NSNumber
////            originAirportBuilder.city = travelSegmentOriginAirportDict["city"] as? String
////            originAirportBuilder.cityNameCasePr = travelSegmentOriginAirportDict["cityNameCasePr"] as? String
////            originAirportBuilder.cityNameCaseRo = travelSegmentOriginAirportDict["cityNameCaseRo"] as? String
////            originAirportBuilder.cityNameCaseVi = travelSegmentOriginAirportDict["cityNameCaseVi"] as? String
////            originAirportBuilder.countryName = travelSegmentOriginAirportDict["countryName"] as? String
////            originAirportBuilder.countryCode = travelSegmentOriginAirportDict["countryCode"] as? String
////            originAirportBuilder.iata = travelSegmentOriginAirportDict["iata"] as? String
////            originAirportBuilder.parentIata = travelSegmentOriginAirportDict["parentIata"] as? String
////            originAirportBuilder.latitude = travelSegmentOriginAirportDict["latitude"] as? NSNumber
////            originAirportBuilder.longitude = travelSegmentOriginAirportDict["longitude"] as? NSNumber
////            originAirportBuilder.timeZone = TimeZone(abbreviation: travelSegmentOriginAirportDict["timeZone"] as? String)
////            originAirportBuilder.airportName = travelSegmentOriginAirportDict["airportName"] as? String
////            originAirportBuilder.indexStrings = travelSegmentOriginAirportDict["indexStrings"] as? [String]
////            originAirportBuilder.airportType = JRSDKAirportType(rawValue: travelSegmentOriginAirportDict["airportType"] as? UInt)!
////            originAirportBuilder.weight = travelSegmentOriginAirportDict["weight"] as? Int
////            originAirportBuilder.searchable = travelSegmentOriginAirportDict["searchable"] as? Bool
////            originAirportBuilder.flightable = travelSegmentOriginAirportDict["flightable"] as? Bool
////            originAirportBuilder.isCity = travelSegmentOriginAirportDict["isCity"] as? Bool
////            originAirportBuilder.fromServer = travelSegmentOriginAirportDict["fromServer"] as? Bool
////            let rebuiltOriginAirport = originAirportBuilder.build()
////            travelSegmentBuilder.originAirport = rebuiltOriginAirport
////            
////            //destinationAirport
////            var destinationAirportBuilder = JRSDKAirportBuilder()
////            var travelSegmentdestinationAirportDict = segment["destinationAirport"] as! [AnyHashable: Any]
////            destinationAirportBuilder.averageRate = travelSegmentdestinationAirportDict["averageRate"] as? NSNumber
////            destinationAirportBuilder.city = travelSegmentdestinationAirportDict["city"] as? String
////            destinationAirportBuilder.cityNameCasePr = travelSegmentdestinationAirportDict["cityNameCasePr"] as? String
////            destinationAirportBuilder.cityNameCaseRo = travelSegmentdestinationAirportDict["cityNameCaseRo"] as? String
////            destinationAirportBuilder.cityNameCaseVi = travelSegmentdestinationAirportDict["cityNameCaseVi"] as? String
////            destinationAirportBuilder.countryName = travelSegmentdestinationAirportDict["countryName"] as? String
////            destinationAirportBuilder.countryCode = travelSegmentdestinationAirportDict["countryCode"] as? String
////            destinationAirportBuilder.iata = travelSegmentdestinationAirportDict["iata"] as? String
////            destinationAirportBuilder.parentIata = travelSegmentdestinationAirportDict["parentIata"] as? String
////            destinationAirportBuilder.latitude = travelSegmentdestinationAirportDict["latitude"] as? NSNumber
////            destinationAirportBuilder.longitude = travelSegmentdestinationAirportDict["longitude"] as? NSNumber
////            destinationAirportBuilder.timeZone = TimeZone(abbreviation: travelSegmentdestinationAirportDict["timeZone"] as! String)
////            destinationAirportBuilder.airportName = travelSegmentdestinationAirportDict["airportName"] as? String
////            destinationAirportBuilder.indexStrings = travelSegmentdestinationAirportDict["indexStrings"] as? [String]
////            destinationAirportBuilder.airportType = JRSDKAirportType(rawValue: travelSegmentdestinationAirportDict["airportType"] as! UInt)!
////            destinationAirportBuilder.weight = travelSegmentdestinationAirportDict["weight"] as! Int
////            destinationAirportBuilder.searchable = travelSegmentdestinationAirportDict["searchable"] as! Bool
////            destinationAirportBuilder.flightable = travelSegmentdestinationAirportDict["flightable"] as! Bool
////            destinationAirportBuilder.isCity = travelSegmentdestinationAirportDict["isCity"] as! Bool
////            destinationAirportBuilder.fromServer = travelSegmentdestinationAirportDict["fromServer"] as! Bool
////            let rebuiltDestinationAirport = destinationAirportBuilder.build()
////            travelSegmentBuilder.destinationAirport = rebuiltDestinationAirport
////            
////            let rebuiltTravelSegment = travelSegmentBuilder.build()
////            travelSegments.append(rebuiltTravelSegment!)
////        }
////        searchInfoBuilder.travelSegments = NSOrderedSet(array: travelSegments)
////        let rebuiltSearchInfo = searchInfoBuilder.build()
////        searchResultInfoBuilder.searchInfo = rebuiltSearchInfo
////        let rebuiltSearchResultInfo = searchResultInfoBuilder.build()
////
////        
////    
//////    ticketBuilder.searchResultInfo = ticket.searchResultInfo;
//////    ticketBuilder.flightSegments = ticket.flightSegments;
//////    ticketBuilder.proposals = ticket.proposals;
//////    var proposalBuilders = NSOrderedSet()
//////    for proposal in ticket.proposals
//////        let proposalBuilder = JRSDKProposalBuilder()
//////        proposalBuilders.
//////        append(proposalBuilder)
//////    }
//////    ticketBuilder.proposalBuilders = proposalBuilders
//////    ticketBuilder.build()
//////    
//////    JRSDKTicket *ticket = self.ticket;
//////    
//////    JRTicketVC *const ticketVC = [[JRTicketVC alloc] initWithSearchInfo:self.ticket.searchResultInfo.searchInfo searchID:self.ticket.searchResultInfo.searchID];
//////    [ticketVC setTicket:ticket];
//////
////    }
//}
