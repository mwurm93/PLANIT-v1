//
//  rankingViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 12/17/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit

class RankingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    // MARK: Class properties
    //Load potential destinations from server
    var rankedPotentialTripsDictionary = [Dictionary<String, Any>]()
    var sectionTitles = ["Group's top trip", "Alternatives"]
    var effect:UIVisualEffect!
    var rankedPotentialTripsDictionaryArrayIndexForSegue: Int?
    
    //Instructions
    var instructionsView: instructionsView?
    
    // MARK: Outlets
    @IBOutlet weak var recommendationRankingTableView: UITableView!
    @IBOutlet weak var readyToBookButton: UIButton!
    @IBOutlet weak var returnToSwipingButton: UIButton!
    @IBOutlet weak var tripNameLabel: UITextField!
    @IBOutlet weak var popupBackgroundView: UIVisualEffectView!
    @IBOutlet weak var instructionsGotItButton: UIButton!
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup instructions collection view
        instructionsView = Bundle.main.loadNibNamed("instructionsView", owner: self, options: nil)?.first! as? instructionsView
        instructionsView?.frame.origin.y = 200
        self.view.insertSubview(instructionsView!, aboveSubview: popupBackgroundView)
        instructionsView?.isHidden = true
        instructionsGotItButton.isHidden = true
        
//        hideKeyboardWhenTappedAround()
        
        //Set up table
        recommendationRankingTableView.tableFooterView = UIView()
        recommendationRankingTableView.isEditing = true
        recommendationRankingTableView.allowsSelectionDuringEditing = true
        recommendationRankingTableView.separatorColor = UIColor.white

        //Load the values from our shared data container singleton
        self.tripNameLabel.delegate = self
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        //Install the value into the label.
        if tripNameValue != nil {
            self.tripNameLabel.text =  "\(tripNameValue!)"
        }
        tripNameLabel.adjustsFontSizeToFitWidth = true
        tripNameLabel.minimumFontSize = 10
        
        let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                rankedPotentialTripsDictionary = rankedPotentialTripsDictionaryFromSingleton as! [Dictionary<String, AnyObject>]
            } else {
                //Load from server
                let rankedPotentialTripsDictionaryFromServer = [["price":"$1,000","percentSwipedRight":"100","destination":"Miami","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()]],["price":"$???","percentSwipedRight":"75","destination":"San Diego","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()]],["price":"$???","percentSwipedRight":"75","destination":"Cabo","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()]],["price":"$???","percentSwipedRight":"50","destination":"Denver","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()]],["price":"$???","percentSwipedRight":"50","destination":"New York","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()]]]
                rankedPotentialTripsDictionary = rankedPotentialTripsDictionaryFromServer
            }
        }
        SavedPreferencesForTrip["rankedPotentialTripsDictionary"] = self.rankedPotentialTripsDictionary
        //Save
        self.saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)

        
        self.readyToBookButton.setTitle("Book trip to \(String(describing: rankedPotentialTripsDictionary[0]["destination"]!))", for: .normal)
        self.readyToBookButton.setTitleColor(UIColor.white, for: .normal)
        self.readyToBookButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        self.readyToBookButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.readyToBookButton.backgroundColor = UIColor.blue
        self.readyToBookButton.layer.cornerRadius = self.readyToBookButton.frame.height / 2
        self.readyToBookButton.titleLabel?.textAlignment = .center
        
        let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        if existing_trips?.count == 1 && SavedPreferencesForTrip["finished_entering_preferences_status"]  as! String == "swiping"{
            let when = DispatchTime.now() + 0.4
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.animateInstructionsIn()
            }
        } else {
            recommendationRankingTableView.frame = CGRect(x: 0, y: 75, width: 375, height: 500)
        }
        
        let atap = UITapGestureRecognizer(target: self, action: #selector(self.dismissInstructions(touch:)))
        atap.numberOfTapsRequired = 1
        atap.delegate = self
        self.popupBackgroundView.addGestureRecognizer(atap)
        popupBackgroundView.isHidden = true
        popupBackgroundView.isUserInteractionEnabled = true
    }
    
    // didReceiveMemoryWarning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        tripNameLabel.resignFirstResponder()
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

    // MARK: UITableviewdelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        // if section == 1
        let numberOfRows = rankedPotentialTripsDictionary.count
        return numberOfRows - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "rankedRecommendationsPrototypeCell", for: indexPath) as! rankedRecommendationsTableViewCell
        cell.selectionStyle = .none
        
        //Change hamburger icon
        for view in cell.subviews as [UIView] {
            if type(of: view).description().range(of: "Reorder") != nil {
                for subview in view.subviews as! [UIImageView] {
                    if subview.isKind(of: UIImageView.self) {
                        subview.image = UIImage(named: "hamburger")
                        subview.bounds = CGRect(x: 0, y: 0, width: 20, height: 13)
                    }
                }
            }
        }
        
        if indexPath == IndexPath(row: 0, section: 0) {
            cell.backgroundColor = UIColor.blue
            cell.changeFlightsButton.tag = 0
        } else {
            cell.backgroundColor = UIColor.clear
            cell.changeFlightsButton.tag = indexPath.row + 1
        }
        
        var nextRowToAdd = Int()
        if indexPath.section == 0 {
            nextRowToAdd = 0
        } else if indexPath.section == 1 {
            nextRowToAdd = indexPath.row + 1
        }
        let destinationsForRow = rankedPotentialTripsDictionary[nextRowToAdd]

        cell.destinationLabel.text = destinationsForRow["destination"] as! String
        cell.tripPrice.text = destinationsForRow["price"] as! String
        cell.percentSwipedRight.text = "\(String(describing: destinationsForRow["percentSwipedRight"]!))% swiped right"
        cell.accomodationFrom.text = "Accommodation from $??? per night"
        
        let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                if let thisTripDict = rankedPotentialTripsDictionaryFromSingleton[nextRowToAdd] as? Dictionary<String, AnyObject> {
                    if let thisTripFlightResults = thisTripDict["flightOptions"] as? [Dictionary<String, AnyObject>] {
                        if thisTripFlightResults.count > 1 {
                            if let topFlightOption = thisTripFlightResults[0] as? Dictionary<String,Any> {
                                cell.DepartureOrigin.text = topFlightOption["departureOrigin"] as? String
                                cell.departureDestination.text = topFlightOption["departureDestination"] as? String
                                cell.departureDepartureTime.text = topFlightOption["departureDepartureTime"] as? String
                                cell.departureArrivalTime.text = topFlightOption["departureArrivalTime"] as? String
                                cell.returnDepartureTime.text = topFlightOption["returnDepartureTime"] as? String
                                cell.returnOrigin.text = topFlightOption["returnOrigin"] as? String
                                cell.returnArrivalTime.text = topFlightOption["returnArrivalTime"] as? String
                                cell.returnDestination.text = topFlightOption["returnDestination"] as? String
                                cell.tripPrice.text = topFlightOption["totalPrice"] as? String
                            }
                        } else {
                            cell.DepartureOrigin.text = "???"
                            cell.departureDestination.text = "???"
                            cell.departureDepartureTime.text = "??:??"
                            cell.departureArrivalTime.text = "??:??"
                            cell.returnDepartureTime.text = "??:??"
                            cell.returnOrigin.text = "???"
                            cell.returnArrivalTime.text = "??:??"
                            cell.returnDestination.text = "???"
                            cell.tripPrice.text = "$???"
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    }
    
    // MARK: moving rows
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath == IndexPath(row: 1, section: 0) {
            return IndexPath(row: 0, section: 1)
        }
        
        return proposedDestinationIndexPath
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if destinationIndexPath == IndexPath(row: 0, section: 0) {
            let alertController = UIAlertController(title: "You are changing your group's destination to \(String(describing: self.rankedPotentialTripsDictionary[sourceIndexPath.row + 1]["destination"]!))", message: "Make sure everyone in your group is okay with this!", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                tableView.reloadData()
            }
            let continueAction = UIAlertAction(title: "Continue", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in

                let movedRowDictionary = self.rankedPotentialTripsDictionary[sourceIndexPath.row + 1]
                self.rankedPotentialTripsDictionary.remove(at: sourceIndexPath.row + 1)
                self.rankedPotentialTripsDictionary.insert(movedRowDictionary, at: 0)
                
                let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
                SavedPreferencesForTrip["rankedPotentialTripsDictionary"] = self.rankedPotentialTripsDictionary
                //Save
                self.saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
                
                tableView.reloadData()
                
                self.readyToBookButton.setTitle("Review flights to \(String(describing: self.rankedPotentialTripsDictionary[0]["destination"]!))", for: .normal)
            }
            alertController.addAction(cancelAction)
            alertController.addAction(continueAction)
            self.present(alertController, animated: true, completion: nil)
        } else if sourceIndexPath == IndexPath(row: 0, section: 0) {
            let alertController = UIAlertController(title: "You are changing your group's destination to \(String(describing: self.rankedPotentialTripsDictionary[1]["destination"]!))", message: "Make sure everyone in your group is okay with this!", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                tableView.reloadData()
            }
            let continueAction = UIAlertAction(title: "Continue", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                
                let movedRowDictionary = self.rankedPotentialTripsDictionary[sourceIndexPath.row]
                self.rankedPotentialTripsDictionary.remove(at: sourceIndexPath.row)
                self.rankedPotentialTripsDictionary.insert(movedRowDictionary, at: destinationIndexPath.row)
                
                let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
                SavedPreferencesForTrip["rankedPotentialTripsDictionary"] = self.rankedPotentialTripsDictionary
                //Save
                self.saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
                
                tableView.reloadData()
                
                self.readyToBookButton.setTitle("Review flights to \(String(describing: self.rankedPotentialTripsDictionary[0]["destination"]!))", for: .normal)
            }
            alertController.addAction(cancelAction)
            alertController.addAction(continueAction)
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            let movedRowDictionary = rankedPotentialTripsDictionary[sourceIndexPath.row + 1]
            rankedPotentialTripsDictionary.remove(at: sourceIndexPath.row + 1)
            rankedPotentialTripsDictionary.insert(movedRowDictionary, at: destinationIndexPath.row + 1)
        
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["rankedPotentialTripsDictionary"] = rankedPotentialTripsDictionary
            //Save
            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        }
        
        tableView.reloadData()
    }
    
    // MARK: Table Section Headers
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: recommendationRankingTableView.bounds.size.width, height: 30))
        header.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        header.layer.cornerRadius = 5
        
        let title = UILabel()
        title.frame = CGRect(x: 10, y: header.frame.minY, width: header.frame.width, height: header.frame.height)
        title.textAlignment = .left
        title.font = UIFont.boldSystemFont(ofSize: 20)
        title.textColor = UIColor.white
        title.text = sectionTitles[section]
        header.addSubview(title)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeFlightsButtonToFlightSearch" {
            let destination = segue.destination as? flightSearchViewController
            destination?.rankedPotentialTripsDictionaryArrayIndex = rankedPotentialTripsDictionaryArrayIndexForSegue
        }
        if segue.identifier == "changeHotelButtonToExploreHotels" {
            let destination = segue.destination as? exploreHotelsViewController
            destination?.rankedPotentialTripsDictionaryArrayIndex = rankedPotentialTripsDictionaryArrayIndexForSegue
        }
    }
    
    ////// ADD NEW TRIP VARS (NS ONLY) HERE ///////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func fetchSavedPreferencesForTrip() -> NSMutableDictionary {
        //Update preference vars if an existing trip
        //Trip status
        let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? 0 as NSNumber
        let finishedEnteringPreferencesStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "finished_entering_preferences_status") as? NSString ?? NSString()
        //New Trip VC
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? NSString ?? NSString()
        let tripID = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "tripID") as? NSString ?? NSString()
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString] ?? [NSString]()
        let contactPhoneNumbers = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contact_phone_numbers") as? [NSString] ?? [NSString]()
        let hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? [NSNumber] ?? [NSNumber]()
        let segmentLengthValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "Availability_segment_lengths") as? [NSNumber] ?? [NSNumber]()
        let selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [NSDate] ?? [NSDate]()
        let leftDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "origin_departure_times") as? NSDictionary ?? NSDictionary()
        let rightDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "return_departure_times") as? NSDictionary ?? NSDictionary()
        let numberDestinations = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "numberDestinations") as? NSNumber ?? NSNumber()
        let nonSpecificDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "nonSpecificDates") as? NSDictionary ?? NSDictionary()
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
        let rankedPotentialTripsDictionary = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionary") as? [NSDictionary] ?? [NSDictionary]()

        //SavedPreferences
        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus,"finished_entering_preferences_status": finishedEnteringPreferencesStatus, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips,"numberDestinations":numberDestinations,"nonSpecificDates":nonSpecificDates, "rankedPotentialTripsDictionary": rankedPotentialTripsDictionary, "tripID": tripID] as NSMutableDictionary
        
        return fetchedSavedPreferencesForTrip
    }
    func saveUpdatedExistingTrip(SavedPreferencesForTrip: NSMutableDictionary) {
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
    }
    
    func animateInstructionsIn(){
        instructionsView?.isHidden = false
        instructionsView?.instructionsCollectionView?.scrollToItem(at: IndexPath(item: 1,section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        
        instructionsView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        instructionsView?.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.popupBackgroundView.isHidden = false
            self.instructionsView?.alpha = 1
            self.instructionsView?.transform = CGAffineTransform.identity
            self.instructionsGotItButton.isHidden = false
        }
    }
    
    func animateInstructionsOut(){
        UIView.animate(withDuration: 0.3, animations: {
            self.instructionsView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.instructionsView?.alpha = 0
            self.instructionsGotItButton.isHidden = true
            self.popupBackgroundView.isHidden = true
            
        }) { (Success:Bool) in
            self.instructionsView?.layer.isHidden = true
        }        
    }
    
    func dismissInstructions(touch: UITapGestureRecognizer) {
        animateInstructionsOut()
    }
    func updateCompletionStatus(){
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["finished_entering_preferences_status"] = "ranking" as NSString
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    // MARK: Actions
    @IBAction func infoButtonTouchedUpInside(_ sender: Any) {
        animateInstructionsIn()
    }
    @IBAction func instructionsGotItButtonTouchedUpInside(_ sender: Any) {
        animateInstructionsOut()
    }
    @IBAction func chooseFlightsButtonTouchedUpInside(_ sender: Any) {
        updateCompletionStatus()
        let UIButtonPressed = sender as! UIButton
        rankedPotentialTripsDictionaryArrayIndexForSegue = UIButtonPressed.tag
        super.performSegue(withIdentifier: "changeFlightsButtonToFlightSearch", sender: self)
        
    }
    @IBAction func chooseHotelButtonTouchedUpInside(_ sender: Any) {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["finished_entering_preferences_status"] = "flightResults" as NSString
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        let UIButtonPressed = sender as! UIButton
        rankedPotentialTripsDictionaryArrayIndexForSegue = UIButtonPressed.tag
        super.performSegue(withIdentifier: "changeHotelButtonToExploreHotels", sender: self)
    }
    
    
    @IBAction func moveForwardButtonTouchedUpInside(_ sender: Any) {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["finished_entering_preferences_status"] = "hotelResults" as NSString
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)

        rankedPotentialTripsDictionaryArrayIndexForSegue = 0
        super.performSegue(withIdentifier: "rankingToBooking", sender: self)
    }
    @IBAction func tripNameEditingChanged(_ sender: Any) {
        let tripNameValue = tripNameLabel.text as! NSString
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["trip_name"] = tripNameValue
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
}
