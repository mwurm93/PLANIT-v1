//
//  HotelItemsAccessoryMethodsPerformer.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 7/24/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import Foundation
import UIKit
import AviasalesSDK

@objc class HotelItemsAccessoryMethodsPerformer: NSObject {
    func saveHotelItems(hotelItem: HLResultVariant) {
        let hotelItemToSave  = NSKeyedArchiver.archivedData(withRootObject: hotelItem)
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var savedHotelItems = SavedPreferencesForTrip["savedHotelItems"] as! [Data]
        savedHotelItems.append(hotelItemToSave)

        //placeToStayDictArray
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        var placeToStayDictionaryArray = SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]]
        placeToStayDictionaryArray[indexOfDestinationBeingPlanned]["hotelsSavedOnPlanit"] = savedHotelItems
        SavedPreferencesForTrip["placeToStayDictionaryArray"] = placeToStayDictionaryArray
        
        SavedPreferencesForTrip["savedHotelItems"] = savedHotelItems
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
    }
    func saveLastOpenHotelItem(hotelItem: HLResultVariant) {
        let hotelItemToSave  = NSKeyedArchiver.archivedData(withRootObject: hotelItem)
        var lastHotelOpenInDetailsDict = Dictionary<String, Any>()
        lastHotelOpenInDetailsDict["unbooked"] = hotelItemToSave
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["lastHotelOpenInBrowser"] = lastHotelOpenInDetailsDict
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }

    func removeSavedHotelItems(hotelItem: HLResultVariant) {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var savedHotelItemsAsData = SavedPreferencesForTrip["savedHotelItems"] as! [Data]
        var savedHotelItems = [HLResultVariant]()
        for savedHotelItemAsData in savedHotelItemsAsData {
            let savedHotelItem = NSKeyedUnarchiver.unarchiveObject(with: savedHotelItemAsData) as? HLResultVariant
            savedHotelItems.append(savedHotelItem!)
        }
        for i in 0 ... savedHotelItems.count - 1 {
            if hotelItem == savedHotelItems[i] {
                savedHotelItemsAsData.remove(at: i)
            }
        }
        
        //placeToStayDictArray
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        var placeToStayDictionaryArray = SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]]
        placeToStayDictionaryArray[indexOfDestinationBeingPlanned]["hotelsSavedOnPlanit"] = savedHotelItems
        SavedPreferencesForTrip["placeToStayDictionaryArray"] = placeToStayDictionaryArray
        
        SavedPreferencesForTrip["savedHotelItems"] = savedHotelItemsAsData
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    func fetchSavedHotelItems() -> [HLResultVariant] {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var savedHotelItemsAsData = SavedPreferencesForTrip["savedHotelItems"] as! [Data]
        var savedHotelItems = [HLResultVariant]()
        for savedHotelItemAsData in savedHotelItemsAsData {
            let savedHotelItem = NSKeyedUnarchiver.unarchiveObject(with: savedHotelItemAsData) as? HLResultVariant
            savedHotelItems.append(savedHotelItem!)
        }
        return savedHotelItems
    }
    func checkIfSavedHotelItemsContains(hotelItem:HLResultVariant, savedHotelItems: [HLResultVariant]) -> Int {
        for savedHotelItem in savedHotelItems {
            if hotelItem == savedHotelItem {
                return 1
            }
        }
        return 0
    }
    func fetchCheckInDate() -> Date {
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
    func fetchCheckOutDate() -> Date {
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
    //Destinations
    func checkIfCityFound(indexOfDestinationBeingPlanned:Int) -> Bool {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var destinationsForTripDictArray = SavedPreferencesForTrip["destinationsForTripDictArray"] as! [[String:Any]]
        if destinationsForTripDictArray.count > indexOfDestinationBeingPlanned {
            if let destinationAirportAsString = destinationsForTripDictArray[indexOfDestinationBeingPlanned]["JRSDKAirport"] as? String {
                if destinationAirportAsString == "noAirportFound" {
                    return false
                }
            } else {
                return true
            }
        }
        return false
    }
    func fetchDestinationAirport(indexOfDestinationBeingPlanned:Int) -> JRSDKAirport {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var destinationsForTripDictArray = SavedPreferencesForTrip["destinationsForTripDictArray"] as! [[String:Any]]
        let destinationAirportAsData = destinationsForTripDictArray[indexOfDestinationBeingPlanned]["JRSDKAirport"] as! Data
        let destinationAirport = NSKeyedUnarchiver.unarchiveObject(with: destinationAirportAsData) as? JRSDKAirport
        
        return destinationAirport!
    }

   
    func fetchCity(indexOfDestinationBeingPlanned:Int) -> HDKCity {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var destinationsForTripDictArray = SavedPreferencesForTrip["destinationsForTripDictArray"] as! [[String:Any]]
        let destinationCityAsData = destinationsForTripDictArray[indexOfDestinationBeingPlanned]["HDKCity"] as! Data
        let destinationCity = NSKeyedUnarchiver.unarchiveObject(with: destinationCityAsData) as? HDKCity
        return destinationCity!
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

    
    func saveSearchInfo(searchInfo: HDKSearchInfo) {
        let HDKSearchInfoToSave  = NSKeyedArchiver.archivedData(withRootObject: searchInfo)
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["HDKSearchInfo"] = HDKSearchInfoToSave
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
}
