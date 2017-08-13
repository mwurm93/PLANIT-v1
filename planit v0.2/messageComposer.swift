//
//  messageComposer.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 1/23/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import Foundation
import MessageUI
import Contacts
import UIKit


class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {
    
    var formatter = DateFormatter()
    
    // A wrapper function to indicate whether or not a text message can be sent from the user's device
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    // Configures and returns a MFMessageComposeViewController instance
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let contactPhoneNumbers = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contact_phone_numbers") as? [NSString]
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        messageComposeVC.recipients = contactPhoneNumbers as [String]?
        
        //Create text
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
        let tripDates = SavedPreferencesForTrip["selected_dates"] as! [Date]
        
        let destinationsForMessage = destinationsForTrip.joined(separator: ", ")
        
        if tripDates.count > 1 {
            let checkInDate = tripDates[0]
            formatter.dateFormat = "MM/dd"
            let checkInDateAsString = formatter.string(from: checkInDate)
            let checkOutDate = tripDates[tripDates.count - 1]
            let checkOutDateAsString = formatter.string(from: checkOutDate)
            let numberNights = DateUtil.hl_daysBetweenDate(checkInDate, andOtherDate:checkOutDate)
            
            messageComposeVC.body =  "Hey, I just started planning a \(numberNights) night trip to \(destinationsForMessage) from \(checkInDate) to \(checkOutDate) on Planit. Check out the itinerary I've put together and we can finish planning it!"
            
        } else {
            messageComposeVC.body =  "Hey, I just started planning a trip to \(destinationsForMessage) on Planit. Check out the itinerary I've put together and we can finish planning it!"
        }
        
        return messageComposeVC
    }
    
    // MFMessageComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)        
    }
}
