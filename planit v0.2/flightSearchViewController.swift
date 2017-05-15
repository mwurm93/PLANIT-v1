//
//  flightSearchViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/15/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class flightSearchViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var underline: UIImageView!
    @IBOutlet weak var departureOrigin: UITextField!
    @IBOutlet weak var departureDestination: UITextField!
    @IBOutlet weak var departureDate: UITextField!
    @IBOutlet weak var returnOrigin: UITextField!
    @IBOutlet weak var returnDestination: UITextField!
    @IBOutlet weak var returnDate: UITextField!
    @IBOutlet weak var returnOriginLabel: UILabel!
    @IBOutlet weak var returnDestinationLabel: UILabel!
    @IBOutlet weak var returnDateLabel: UILabel!
    
    var searchMode = "roundtrip"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        underline.layer.frame = CGRect(x: 139, y: 20, width: 98, height: 51)
        returnOrigin.isHidden = true
        returnOriginLabel.isHidden = true
        returnDestination.isHidden = true
        returnDestinationLabel.isHidden = true
        returnDate.isHidden = false
        returnDateLabel.isHidden = false
        
        //Textfield setup
        self.departureDate.delegate = self
        departureDate.layer.borderWidth = 1
        departureDate.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        departureDate.layer.masksToBounds = true
        departureDate.layer.cornerRadius = 5
        let departureDateValue = "DATA MODEL PENDING"
        departureDate.text =  "\(departureDateValue)"
        let departureDateLabelPlaceholder = departureDate!.value(forKey: "placeholderLabel") as? UILabel
        departureDateLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)

        self.departureOrigin.delegate = self
        departureOrigin.layer.borderWidth = 1
        departureOrigin.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        departureOrigin.layer.masksToBounds = true
        departureOrigin.layer.cornerRadius = 5
        let departureOriginValue = "DATA MODEL PENDING"
        departureOrigin.text =  "\(departureOriginValue)"
        let departureOriginLabelPlaceholder = departureOrigin!.value(forKey: "placeholderLabel") as? UILabel
        departureOriginLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)

        self.departureDestination.delegate = self
        departureDestination.layer.borderWidth = 1
        departureDestination.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        departureDestination.layer.masksToBounds = true
        departureDestination.layer.cornerRadius = 5
        let departureDestinationValue = "DATA MODEL PENDING"
        departureDestination.text =  "\(departureDestinationValue)"
        let departureDestinationLabelPlaceholder = departureDestination!.value(forKey: "placeholderLabel") as? UILabel
        departureDestinationLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)

        self.returnDate.delegate = self
        returnDate.layer.borderWidth = 1
        returnDate.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        returnDate.layer.masksToBounds = true
        returnDate.layer.cornerRadius = 5
        let returnDateValue = "DATA MODEL PENDING"
        returnDate.text =  "\(returnDateValue)"
        let returnDateLabelPlaceholder = returnDate!.value(forKey: "placeholderLabel") as? UILabel
        returnDateLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        self.returnOrigin.delegate = self
        returnOrigin.layer.borderWidth = 1
        returnOrigin.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        returnOrigin.layer.masksToBounds = true
        returnOrigin.layer.cornerRadius = 5
        let returnOriginValue = "DATA MODEL PENDING"
        returnOrigin.text =  "\(returnOriginValue)"
        let returnOriginLabelPlaceholder = returnOrigin!.value(forKey: "placeholderLabel") as? UILabel
        returnOriginLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        self.returnDestination.delegate = self
        returnDestination.layer.borderWidth = 1
        returnDestination.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        returnDestination.layer.masksToBounds = true
        returnDestination.layer.cornerRadius = 5
        let returnDestinationValue = "DATA MODEL PENDING"
        returnDestination.text =  "\(returnDestinationValue)"
        let returnDestinationLabelPlaceholder = returnDestination!.value(forKey: "placeholderLabel") as? UILabel
        returnDestinationLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)        
        
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        departureDestination.resignFirstResponder()
        departureOrigin.resignFirstResponder()
        departureDate.resignFirstResponder()

        returnDestination.resignFirstResponder()
        returnOrigin.resignFirstResponder()
        returnDate.resignFirstResponder()
        
        //SAVE TO DATA MODEL
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        
        
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    //MARK: Custom functions
    func fetchSavedPreferencesForTrip() -> NSMutableDictionary {
        //Update preference vars if an existing trip
        //Trip status
        let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? 0 as NSNumber
        let finishedEnteringPreferencesStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "finished_entering_preferences_status") as? NSString ?? NSString()
        //New Trip VC
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? NSString ?? NSString()
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString] ?? [NSString]()
        let contactPhoneNumbers = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contact_phone_numbers") as? [NSString] ?? [NSString]()
        let hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? [NSNumber] ?? [NSNumber]()
        //Calendar VC
        let segmentLengthValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "Availability_segment_lengths") as? [NSNumber] ?? [NSNumber]()
        let selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [NSDate] ?? [NSDate]()
        let leftDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "origin_departure_times") as? NSDictionary ?? NSDictionary()
        let rightDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "return_departure_times") as? NSDictionary ?? NSDictionary()
        //Budget VC
        let budgetValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "budget") as? NSString ?? NSString()
        let expectedRoundtripFare = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_roundtrip_fare") as? NSString ?? NSString()
        let expectedNightlyRate = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_nightly_rate") as? NSString ?? NSString()
        //Suggested Destination VC
        let decidedOnDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_control") as? NSString ?? NSString()
        let decidedOnDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_value") as? NSString ?? NSString()
        let suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? NSString ?? NSString()
        let suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? NSString ?? NSString()
        //Activities VC
        let selectedActivities = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_activities") as? [NSString] ?? [NSString]()
        //Ranking VC
        let topTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "top_trips") as? [NSString] ?? [NSString]()
        
        //SavedPreferences
        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus,"finished_entering_preferences_status": finishedEnteringPreferencesStatus, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips] as NSMutableDictionary
        
        return fetchedSavedPreferencesForTrip
    }
    func saveUpdatedExistingTrip(SavedPreferencesForTrip: NSMutableDictionary) {
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
    }

    
    //MARK: Actions
    @IBAction func multiCityButtonTouchedUpInside(_ sender: Any) {
        UIView.animate(withDuration: 0.4) {
            self.underline.layer.frame = CGRect(x: 247, y: 20, width: 98, height: 51)
            self.returnOrigin.isHidden = false
            self.returnOriginLabel.isHidden = false
            self.returnDestination.isHidden = false
            self.returnDestinationLabel.isHidden = false
            self.returnDate.isHidden = false
            self.returnDateLabel.isHidden = false
        }
        searchMode = "multiCity"
    }
    @IBAction func roundtripButtonTouchedUpInside(_ sender: Any) {
        UIView.animate(withDuration: 0.4) {
            self.underline.layer.frame = CGRect(x: 139, y: 20, width: 98, height: 51)
            self.returnOrigin.isHidden = true
            self.returnOriginLabel.isHidden = true
            self.returnDestination.isHidden = true
            self.returnDestinationLabel.isHidden = true
            self.returnDate.isHidden = false
            self.returnDateLabel.isHidden = false        }
        searchMode = "roundtrip"
    }
    @IBAction func oneWayButtonTouchedUpInside(_ sender: Any) {
        UIView.animate(withDuration: 0.4) {
            self.underline.layer.frame = CGRect(x: 30, y: 20, width: 98, height: 51)
            self.returnOrigin.isHidden = true
            self.returnOriginLabel.isHidden = true
            self.returnDestination.isHidden = true
            self.returnDestinationLabel.isHidden = true
            self.returnDate.isHidden = true
            self.returnDateLabel.isHidden = true
        }
        searchMode = "oneWay"
    }
}
