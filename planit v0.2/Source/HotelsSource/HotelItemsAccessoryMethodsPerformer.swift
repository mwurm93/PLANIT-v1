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
        SavedPreferencesForTrip["savedHotelItems"] = savedHotelItems
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
}
