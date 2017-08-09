//
//  FlightTicketsAccessoryMethodPerformer.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 7/24/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import Foundation
import UIKit
import AviasalesSDK

@objc class FlightTicketsAccessoryMethodPerformer: NSObject {
    func saveFlightTickets(ticket: JRSDKTicket) {
        let flightTicketToSave  = NSKeyedArchiver.archivedData(withRootObject: ticket)
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var savedFlightTickets = SavedPreferencesForTrip["savedFlightTickets"] as! [Data]
        savedFlightTickets.append(flightTicketToSave)
        
        //travelDictArray
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
        travelDictionaryArray[indexOfDestinationBeingPlanned]["flightsSavedOnPlanit"] = savedFlightTickets
        SavedPreferencesForTrip["travelDictionaryArray"] = travelDictionaryArray
        
        
        SavedPreferencesForTrip["savedFlightTickets"] = savedFlightTickets
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    func saveLastOpenFlightTicket(ticket: JRSDKTicket) {
        let flightTicketToSave  = NSKeyedArchiver.archivedData(withRootObject: ticket)
        var lastFlightOpenInBrowserDict = Dictionary<String, Any>()
        lastFlightOpenInBrowserDict["unbooked"] = flightTicketToSave
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["lastFlightOpenInBrowser"] = lastFlightOpenInBrowserDict
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
    }
    func removeSavedFlightTickets(ticket: JRSDKTicket) {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var savedFlightTicketsAsData = SavedPreferencesForTrip["savedFlightTickets"] as! [Data]
        var savedFlightTickets = [JRSDKTicket]()
        for savedFlightTicketAsData in savedFlightTicketsAsData {
            let savedFlightTicket = NSKeyedUnarchiver.unarchiveObject(with: savedFlightTicketAsData) as? JRSDKTicket
            savedFlightTickets.append(savedFlightTicket!)
        }
        for i in 0 ... savedFlightTickets.count - 1 {
            if ticket == savedFlightTickets[i] {
                savedFlightTicketsAsData.remove(at: i)
            }
        }
        
        //travelDictArray
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
        travelDictionaryArray[indexOfDestinationBeingPlanned]["flightsSavedOnPlanit"] = savedFlightTickets
        SavedPreferencesForTrip["travelDictionaryArray"] = travelDictionaryArray

        SavedPreferencesForTrip["savedFlightTickets"] = savedFlightTicketsAsData
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    func fetchSavedFlightTickets() -> [JRSDKTicket] {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var savedFlightTicketsAsData = SavedPreferencesForTrip["savedFlightTickets"] as! [Data]
        var savedFlightTickets = [JRSDKTicket]()
        for savedFlightTicketAsData in savedFlightTicketsAsData {
            let savedFlightTicket = NSKeyedUnarchiver.unarchiveObject(with: savedFlightTicketAsData) as? JRSDKTicket
            savedFlightTickets.append(savedFlightTicket!)
        }
        return savedFlightTickets
    }
    func checkIfSavedFlightTicketsContains(ticket:JRSDKTicket, savedFlightTickets: [JRSDKTicket]) -> Int {
        for savedFlightTicket in savedFlightTickets {
            if ticket == savedFlightTicket {
                return 1
            }
        }
        return 0
    }
    
    
    //Roundtrip functions
    func saveIsRoundTrip(isRoundtrip:Bool)  {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        
        var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
        travelDictionaryArray[indexOfDestinationBeingPlanned]["isRoundtrip"] = isRoundtrip
        SavedPreferencesForTrip["travelDictionaryArray"] = travelDictionaryArray
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
    }
    func fetchIsRoundtrip() -> Bool {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
        let isRoundtrip = travelDictionaryArray[indexOfDestinationBeingPlanned]["isRoundtrip"] as? Bool
        return isRoundtrip!
    }
    
    
    
    //MARK: airport loading
    
    //Starting point
    func checkIfStartingPointAirportFound() -> Bool {
        var startingPointDict = DataContainerSingleton.sharedDataContainer.startingPointDict as! [String:Any]
        if let startingPointAirportAsString = startingPointDict["JRSDKAirport"] as? String {
            if startingPointAirportAsString == "noAirportFound" {
                return false
            }
        }
        return true
    }
    func fetchStartingPointAirport() -> JRSDKAirport {
        var startingPointDict = DataContainerSingleton.sharedDataContainer.startingPointDict as! [String:Any]
        let startingPointAirportAsData = startingPointDict["JRSDKAirport"] as! Data
        let startingPointAirport = NSKeyedUnarchiver.unarchiveObject(with: startingPointAirportAsData) as? JRSDKAirport
        
        return startingPointAirport!
    }
    //Ending point
    func checkIfDifferentEndingPoint() -> Bool {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let endingPoint = SavedPreferencesForTrip["endingPoint"] as! String
        if endingPoint != "" {
            return true
        }
        return false
    }
    func checkIfEndingPointAirportFound() -> Bool {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var endingPointDict = SavedPreferencesForTrip["endingPointDict"] as! [String:Any]
        if let endingPointAirportAsString = endingPointDict["JRSDKAirport"] as? String {
            if endingPointAirportAsString == "noAirportFound" {
                return false
            }
        }
        return true
    }
    func fetchEndingPointAirport() -> JRSDKAirport {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var endingPointDict = SavedPreferencesForTrip["endingPointDict"] as! [String:Any]
        let endingPointAirportAsData = endingPointDict["JRSDKAirport"] as! Data
        let endingPointAirport = NSKeyedUnarchiver.unarchiveObject(with: endingPointAirportAsData) as? JRSDKAirport
        
        return endingPointAirport!
    }
    //Destinations
    func checkIfDestinationAirportFound(indexOfDestinationBeingPlanned:Int) -> Bool {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var destinationsForTripDictArray = SavedPreferencesForTrip["destinationsForTripDictArray"] as! [[String:Any]]
        if let destinationAirportAsString = destinationsForTripDictArray[indexOfDestinationBeingPlanned]["JRSDKAirport"] as? String {
            if destinationAirportAsString == "noAirportFound" {
                return false
            }
        }
        return true
    }
    func fetchDestinationAirport(indexOfDestinationBeingPlanned:Int) -> JRSDKAirport {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var destinationsForTripDictArray = SavedPreferencesForTrip["destinationsForTripDictArray"] as! [[String:Any]]
        let destinationAirportAsData = destinationsForTripDictArray[indexOfDestinationBeingPlanned]["JRSDKAirport"] as! Data
        let destinationAirport = NSKeyedUnarchiver.unarchiveObject(with: destinationAirportAsData) as? JRSDKAirport
        
        return destinationAirport!
    }
    //index and count destinations
    func fetchIndexOfDestinationBeingPlanned() -> Int {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        return indexOfDestinationBeingPlanned
    }
    func fetchNumberDestinationsForTrip() -> Int {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
        return destinationsForTrip.count
    }
    
    func fetchDepartureDate() -> Date {
        let dateFormatter = DateFormatter()

        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var datesDestinationsDictionary = SavedPreferencesForTrip["datesDestinationsDictionary"] as! [String:[Date]]
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])
        
        var leftDatesDestinations = [String:Date]()
        var rightDatesDestinations = [String:Date]()
        
        if indexOfDestinationBeingPlanned < destinationsForTrip.count {
            if datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned]] != nil {
                leftDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned]] = datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned]]?[0]
                rightDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned]] = datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned]]?[(datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned]]?.count)! - 1]
                dateFormatter.dateFormat = "MM/dd/YYYY"
                return leftDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned]]!
                //let rightDateAsString = formatter.string(from: rightDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned]]!
            }
        } else if indexOfDestinationBeingPlanned == destinationsForTrip.count {
            leftDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned - 1]] = datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned - 1]]?[0]
            rightDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned - 1]] = datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned - 1]]?[(datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned - 1]]?.count)! - 1]
            dateFormatter.dateFormat = "MM/dd/YYYY"
            return rightDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned - 1]]!
        }
        return Date()
    }
    func fetchReturnDate() -> Date {
        let dateFormatter = DateFormatter()

        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var datesDestinationsDictionary = SavedPreferencesForTrip["datesDestinationsDictionary"] as! [String:[Date]]
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])
        
        var leftDatesDestinations = [String:Date]()
        var rightDatesDestinations = [String:Date]()
        
        if indexOfDestinationBeingPlanned < destinationsForTrip.count {
            if datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned]] != nil {
                leftDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned]] = datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned]]?[0]
                rightDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned]] = datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned]]?[(datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned]]?.count)! - 1]
                dateFormatter.dateFormat = "MM/dd/YYYY"
                //return leftDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned]]!
                return rightDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned]]!
            }
        } else if indexOfDestinationBeingPlanned == destinationsForTrip.count {
            leftDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned - 1]] = datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned - 1]]?[0]
            rightDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned - 1]] = datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned - 1]]?[(datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned - 1]]?.count)! - 1]
            dateFormatter.dateFormat = "MM/dd/YYYY"
            return rightDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned - 1]]!
        }
        return Date()
    }

}
