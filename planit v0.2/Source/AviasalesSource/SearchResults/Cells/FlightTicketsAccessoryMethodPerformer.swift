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
}
