//
//  ActivitiesViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/17/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit

class ActivitiesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var activitiesSearchBar: UISearchBar!
    @IBOutlet weak var tripRecommendationsLabel: UILabel!
    @IBOutlet weak var rightArrowButton: UIButton!
    @IBOutlet weak var buttonBeneathLabel: UIButton!
    @IBOutlet weak var activitiesCollectionView: UICollectionView!
    @IBOutlet weak var tripNameLabel: UITextField!
    @IBOutlet weak var instructionsView: UIView!
    @IBOutlet weak var popupBackgroundView: UIVisualEffectView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var gotItButton: UIButton!
    
    var activityItems: [ActivityItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load the values from our shared data container singleton
        self.tripNameLabel.delegate = self
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        //Install the value into the label.
        if tripNameValue != nil {
            self.tripNameLabel.text =  "\(tripNameValue!)"
        }
        
        hideKeyboardWhenTappedAround()
        
        tripRecommendationsLabel.text = "Skip to hotels"
        
        // Call collection initializer
        initActivityItems()
        activitiesCollectionView.reloadData()
        activitiesCollectionView.allowsMultipleSelection = true

        //update aesthetics
        activitiesCollectionView.layer.cornerRadius = 5
        activitiesCollectionView.layer.backgroundColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 0).cgColor
        
        // Set appearance of search bar
        activitiesSearchBar.layer.cornerRadius = 5
        let textFieldInsideSearchBar = activitiesSearchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        clearButton.tintColor = UIColor.white
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = UIColor.white
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        if existing_trips?.count == 1 && SavedPreferencesForTrip["finished_entering_preferences_status"] as! String == "flightResults" {
            let when = DispatchTime.now() + 0.4
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.animateInstructionsIn()
            }
        }
        
        let atap = UITapGestureRecognizer(target: self, action: #selector(self.dismissInstructions(touch:)))
        atap.numberOfTapsRequired = 1
        atap.delegate = self
        self.popupBackgroundView.addGestureRecognizer(atap)
        popupBackgroundView.isHidden = true
        popupBackgroundView.isUserInteractionEnabled = true
        instructionsView.isHidden = true
        instructionsView.layer.cornerRadius = 10
    }

    override func viewDidAppear(_ animated: Bool) {
        // Update cell border color to blue if saved as a selected activity
        let selectedActivities = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_activities") as? [String]
        
        let visibleCellIndices = self.activitiesCollectionView.indexPathsForVisibleItems
        for visibleCellIndex in visibleCellIndices {
            let visibleCell = activitiesCollectionView.cellForItem(at: visibleCellIndex) as! ActivitiesCollectionViewCell
            if selectedActivities != nil {
            if (selectedActivities?.contains(visibleCell.activityLabel.text!))! {
                visibleCell.tintColor = UIColor.blue
                activitiesCollectionView.selectItem(at: visibleCellIndex, animated: true, scrollPosition: .top)
            }
            else {
                visibleCell.tintColor = UIColor.white
                activitiesCollectionView.deselectItem(at: visibleCellIndex, animated: true)
            }
            }
            else {
                visibleCell.tintColor = UIColor.white
                activitiesCollectionView.deselectItem(at: visibleCellIndex, animated: true)
            }
        }
        
        // Change label for continuing
        if selectedActivities != nil {
            if (selectedActivities?.count)! > 0 {
            tripRecommendationsLabel.text = "Explore hotels"
            }
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard
        tripNameLabel.resignFirstResponder()

        //Save trip name
        if textField == tripNameLabel {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["trip_name"] = tripNameLabel.text
            //Save
            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        }
        
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    // MARK: Activities collection View item init
    fileprivate func initActivityItems() {
//        
//        var items = [ActivityItem]()
//        let inputFile = Bundle.main.path(forResource: "items", ofType: "plist")
//        
//        let inputDataArray = NSArray(contentsOfFile: inputFile!)
//        
//        for inputItem in inputDataArray as! [Dictionary<String, String>] {
//            let activityItem = ActivityItem(dataDictionary: inputItem)
//            items.append(activityItem)
//        }
//        activityItems = items
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if collectionView == activitiesCollectionView {
            return activityItems.count
//        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if collectionView == activitiesCollectionView {
            activitiesCollectionView.allowsMultipleSelection = true
            let cell = activitiesCollectionView.dequeueReusableCell(withReuseIdentifier: "activitiesViewPrototypeCell", for: indexPath) as! ActivitiesCollectionViewCell
//            cell.setActivityItem(activityItems[indexPath.row])
            cell.activityImage.image = cell.activityImage.image?.withRenderingMode(.alwaysTemplate)

            return cell
//        }
    }
    
    // MARK: - UICollectionViewDelegate
    // Item DEselected: update border color and save data when
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == activitiesCollectionView {

        // Change border color to grey
        let deSelectedCell = collectionView.cellForItem(at: indexPath)
        deSelectedCell?.tintColor = UIColor.white
            
        // Create array of selected activities
        var selectedActivities = [String]()
        let indexPaths = self.activitiesCollectionView!.indexPathsForSelectedItems
        for indexItem in indexPaths! {
            let currentCell = activitiesCollectionView.cellForItem(at: indexItem)! as! ActivitiesCollectionViewCell
            let selectedActivity = currentCell.activityLabel.text
            selectedActivities.append(selectedActivity!)
        }
        
        var selectedActivitiesForUpdate = [NSString]()
        for activity in selectedActivities {
            selectedActivitiesForUpdate.append(activity as NSString)
        }
            
            
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["selected_activities"] = selectedActivitiesForUpdate as [NSString]
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
        // Change label for continuing
        if selectedActivities.count > 0 {
            tripRecommendationsLabel.text = "Explore hotels"
        }
        if selectedActivities.count == 0 {
            tripRecommendationsLabel.text = "Skip to hotels"
        }
    }
       
    }
    
    // Item SELECTED: update border color and save data when
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == activitiesCollectionView {
            
        // Change border color to grey
        let SelectedCell = activitiesCollectionView.cellForItem(at: indexPath)
            SelectedCell?.tintColor = UIColor.blue
        
        // Create array of selected activities
        var selectedActivities = [String]()
        let indexPaths = self.activitiesCollectionView!.indexPathsForSelectedItems
        for indexItem in indexPaths! {
            let currentCell = collectionView.cellForItem(at: indexItem)! as! ActivitiesCollectionViewCell
            let selectedActivity = currentCell.activityLabel.text
            selectedActivities.append(selectedActivity!)
        }
        var selectedActivitiesForUpdate = [NSString]()
        for activity in selectedActivities {
            selectedActivitiesForUpdate.append(activity as NSString)
        }
        
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["selected_activities"] = selectedActivitiesForUpdate as [NSString]
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
        // Change label for continuing
        if selectedActivities.count > 0 {
            tripRecommendationsLabel.text = "Explore hotels"
        }
        if selectedActivities.count == 0 {
            tripRecommendationsLabel.text = "Skip to hotels"
        }
    }
    }
    
    // MARK: - UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if collectionView == activitiesCollectionView {
            let picDimension = self.view.frame.size.width / 4.2
            return CGSize(width: picDimension, height: picDimension)
//        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        if collectionView == activitiesCollectionView {
            let leftRightInset = self.view.frame.size.width / 18.0
            return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset)
//        }
    }
    
//    ////// ADD NEW TRIP VARS (NS ONLY) HERE ///////////////////////////////////////////////////////////////////////////
//    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    func fetchSavedPreferencesForTrip() -> NSMutableDictionary {
//        //Update preference vars if an existing trip
//        //Trip status
//        let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? 0 as NSNumber
//        let finishedEnteringPreferencesStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "finished_entering_preferences_status") as? NSString ?? NSString()
//        //New Trip VC
//        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? NSString ?? NSString()
//        let tripID = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "tripID") as? NSString ?? NSString()
//        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString] ?? [NSString]()
//        let contactPhoneNumbers = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contact_phone_numbers") as? [NSString] ?? [NSString]()
//        let hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? [NSNumber] ?? [NSNumber]()
//        let segmentLengthValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "Availability_segment_lengths") as? [NSNumber] ?? [NSNumber]()
//        let selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [NSDate] ?? [NSDate]()
//        let leftDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "origin_departure_times") as? NSDictionary ?? NSDictionary()
//        let rightDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "return_departure_times") as? NSDictionary ?? NSDictionary()
//        let numberDestinations = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "numberDestinations") as? NSNumber ?? NSNumber()
//        let nonSpecificDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "nonSpecificDates") as? NSDictionary ?? NSDictionary()
//        //Budget VC
//        let budgetValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "budget") as? NSString ?? NSString()
//        let expectedRoundtripFare = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_roundtrip_fare") as? NSString ?? NSString()
//        let expectedNightlyRate = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_nightly_rate") as? NSString ?? NSString()
//        //Suggested Destination VC
//        let decidedOnDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_control") as? NSString ?? NSString()
//        let decidedOnDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_value") as? NSString ?? NSString()
//        let suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? NSString ?? NSString()
//        let suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? NSString ?? NSString()
//        //Activities VC
//        let selectedActivities = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_activities") as? [NSString] ?? [NSString]()
//        //Ranking VC
//        let topTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "top_trips") as? [NSString] ?? [NSString]()
//        let rankedPotentialTripsDictionary = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionary") as? [NSDictionary] ?? [NSDictionary]()
//
//        //SavedPreferences
//        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus,"finished_entering_preferences_status": finishedEnteringPreferencesStatus, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips, "numberDestinations":numberDestinations,"nonSpecificDates":nonSpecificDates, "rankedPotentialTripsDictionary": rankedPotentialTripsDictionary, "tripID": tripID] as NSMutableDictionary
//        
//        return fetchedSavedPreferencesForTrip
//    }
//    func saveUpdatedExistingTrip(SavedPreferencesForTrip: NSMutableDictionary) {
//        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
//        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
//        existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
//        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
//    }
    
    override func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func animateInstructionsIn(){
        instructionsView.layer.isHidden = false
        instructionsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        instructionsView.alpha = 0
        activitiesCollectionView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.4) {
            self.popupBackgroundView.isHidden = false
            self.instructionsView.alpha = 1
            self.instructionsView.transform = CGAffineTransform.identity
        }
    }
    
    func dismissInstructions(touch: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.instructionsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.instructionsView.alpha = 0
            self.popupBackgroundView.isHidden = true
            self.activitiesCollectionView.isUserInteractionEnabled = true
            self.activitiesCollectionView.frame = CGRect(x: 17, y: 196, width: 340, height: 403)
        }) { (Success:Bool) in
            self.instructionsView.layer.isHidden = true
        }
    }
    
    func updateCompletionStatus() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["finished_entering_preferences_status"] = "activities" as NSString
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    //MARK: Actions
    @IBAction func gotItButtonTouchedUpInside(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.instructionsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.instructionsView.alpha = 0
            self.popupBackgroundView.isHidden = true
            self.activitiesCollectionView.isUserInteractionEnabled = true
            self.activitiesCollectionView.frame = CGRect(x: 17, y: 196, width: 340, height: 403)
        }) { (Success:Bool) in
            self.instructionsView.layer.isHidden = true
        }
    }
    @IBAction func nextButtonPressed(_ sender: Any) {
        updateCompletionStatus()
    }
}
