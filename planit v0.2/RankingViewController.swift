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
    //Load flight results from server
    var destinationsResultsDictionary = [["price":"$1,000","percentSwipedRight":"100","destination":"Miami"],["price":"$???","percentSwipedRight":"75","destination":"San Diego"],["price":"$???","percentSwipedRight":"75","destination":"Cabo"],["price":"$???","percentSwipedRight":"50","destination":"Denver"],["price":"$???","percentSwipedRight":"50","destination":"New York"]]
    var sectionTitles = ["Group's top trip", "Alternatives"]
    var effect:UIVisualEffect!
    
    // MARK: Outlets
    @IBOutlet weak var recommendationRankingTableView: UITableView!
    @IBOutlet weak var readyToBookButton: UIButton!
    @IBOutlet weak var returnToSwipingButton: UIButton!
    @IBOutlet weak var tripNameLabel: UITextField!
    @IBOutlet weak var popupBlurView: UIVisualEffectView!
    @IBOutlet weak var rankingInstructionsView: UIView!
    @IBOutlet weak var popupBackgroundView: UIVisualEffectView!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up popupblurview
        effect = popupBlurView.effect
        popupBlurView.effect = nil
        
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
        
        let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
        
        self.readyToBookButton.setTitle("Review flights to \(String(describing: destinationsResultsDictionary[0]["destination"]!))", for: .normal)
        self.readyToBookButton.setTitleColor(UIColor.white, for: .normal)
        self.readyToBookButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        self.readyToBookButton.backgroundColor = UIColor.blue
        self.readyToBookButton.layer.cornerRadius = self.readyToBookButton.frame.height / 2
        self.readyToBookButton.titleLabel?.textAlignment = .center
        
        let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        if existing_trips?.count == 1 {
            let when = DispatchTime.now() + 0.4
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.animateInstructionsIn()
                self.readyToBookButton.alpha =  0
                self.returnToSwipingButton.alpha =  0
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
        rankingInstructionsView.isHidden = true
        rankingInstructionsView.layer.cornerRadius = 10
        let hamburgerAttachment = NSTextAttachment()
        hamburgerAttachment.image = #imageLiteral(resourceName: "hamburger_black")
        hamburgerAttachment.bounds = CGRect(x: 0, y: 0, width: 20, height: 13)
        let changeAttachment = NSTextAttachment()
        changeAttachment.image = #imageLiteral(resourceName: "change_black")
        changeAttachment.bounds = CGRect(x: 0, y: 0, width: 20, height: 15)
        let stringForLabel = NSMutableAttributedString(string: "See your group's favorite trips above! Tap ")
        let attachment1 = NSAttributedString(attachment: changeAttachment)
        let attachment2 = NSAttributedString(attachment: hamburgerAttachment)
        stringForLabel.append(attachment1)
        stringForLabel.append(NSAttributedString(string:" to look at flights, and drag the "))
        stringForLabel.append(attachment2)
        stringForLabel.append(NSAttributedString(string: " to change your trip"))
        instructionsLabel.attributedText = stringForLabel
    }
    
    // didReceiveMemoryWarning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        tripNameLabel.resignFirstResponder()
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
        let numberOfRows = destinationsResultsDictionary.count
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
        } else {
            cell.backgroundColor = UIColor.clear
        }
        
        var destinationsForRow = destinationsResultsDictionary[0]
        
        
        var addedRow = indexPath.row + 1
        if indexPath.section == 1 {
            destinationsForRow = destinationsResultsDictionary[addedRow]
            addedRow += 1
        }
        
        cell.destinationLabel.text = destinationsForRow["destination"]
        cell.tripPrice.text = destinationsForRow["price"]
        cell.percentSwipedRight.text = "\(String(describing: destinationsForRow["percentSwipedRight"]!))% swiped right"
        
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
            let alertController = UIAlertController(title: "You are changing your group's destination to \(String(describing: self.destinationsResultsDictionary[sourceIndexPath.row + 1]["destination"]!))", message: "Make sure everyone in your group is okay with this!", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                tableView.reloadData()
            }
            let continueAction = UIAlertAction(title: "Continue", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in

                let movedRowDictionary = self.destinationsResultsDictionary[sourceIndexPath.row + 1]
                self.destinationsResultsDictionary.remove(at: sourceIndexPath.row + 1)
                self.destinationsResultsDictionary.insert(movedRowDictionary, at: 0)
                tableView.reloadData()
                
                self.readyToBookButton.setTitle("Review flights to \(String(describing: self.destinationsResultsDictionary[0]["destination"]!))", for: .normal)
            }
            alertController.addAction(cancelAction)
            alertController.addAction(continueAction)
            self.present(alertController, animated: true, completion: nil)
        } else if sourceIndexPath == IndexPath(row: 0, section: 0) {
            let alertController = UIAlertController(title: "You are changing your group's destination to \(String(describing: self.destinationsResultsDictionary[1]["destination"]!))", message: "Make sure everyone in your group is okay with this!", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                tableView.reloadData()
            }
            let continueAction = UIAlertAction(title: "Continue", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                
                let movedRowDictionary = self.destinationsResultsDictionary[sourceIndexPath.row]
                self.destinationsResultsDictionary.remove(at: sourceIndexPath.row)
                self.destinationsResultsDictionary.insert(movedRowDictionary, at: destinationIndexPath.row)
                tableView.reloadData()
                
                self.readyToBookButton.setTitle("Review flights to \(String(describing: self.destinationsResultsDictionary[0]["destination"]!))", for: .normal)
            }
            alertController.addAction(cancelAction)
            alertController.addAction(continueAction)
            self.present(alertController, animated: true, completion: nil)

            
        } else {
            let movedRowDictionary = destinationsResultsDictionary[sourceIndexPath.row + 1]
            destinationsResultsDictionary.remove(at: sourceIndexPath.row + 1)
            destinationsResultsDictionary.insert(movedRowDictionary, at: destinationIndexPath.row + 1)
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

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if segue.identifier == "destinationChosenSegue" {
//            let destination = segue.destination as? ReviewAndBookViewController
//            
//            let path = recommendationRankingTableView.indexPathForSelectedRow! as IndexPath
//            let cell = recommendationRankingTableView.cellForRow(at: path) as! rankedRecommendationsTableViewCell
//            destination?.destinationLabelViaSegue = cell.destinationLabel.text!
//            destination?.tripPriceViaSegue = cell.tripPrice.text!
//        }
//    }
    
    ////// ADD NEW TRIP VARS (NS ONLY) HERE ///////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
    
    func animateInstructionsIn(){
        rankingInstructionsView.layer.isHidden = false
        rankingInstructionsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        rankingInstructionsView.alpha = 0
        recommendationRankingTableView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.4) {
            self.popupBackgroundView.isHidden = false
            self.rankingInstructionsView.alpha = 1
            self.rankingInstructionsView.transform = CGAffineTransform.identity
        }
    }
    
    func dismissInstructions(touch: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.rankingInstructionsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.rankingInstructionsView.alpha = 0
            self.popupBackgroundView.isHidden = true
            self.returnToSwipingButton.alpha = 1
            self.readyToBookButton.alpha = 1
            self.recommendationRankingTableView.isUserInteractionEnabled = true
            self.recommendationRankingTableView.frame = CGRect(x: 0, y: 75, width: 375, height: 500)
        }) { (Success:Bool) in
            self.rankingInstructionsView.layer.isHidden = true
        }
    }
    
    // MARK: Actions
    @IBAction func instructionsGotItButtonTouchedUpInsider(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.rankingInstructionsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.rankingInstructionsView.alpha = 0
            self.popupBackgroundView.isHidden = true
            self.returnToSwipingButton.alpha = 1
            self.readyToBookButton.alpha = 1
            self.recommendationRankingTableView.isUserInteractionEnabled = true
            self.recommendationRankingTableView.frame = CGRect(x: 0, y: 75, width: 375, height: 500)
        }) { (Success:Bool) in
            self.rankingInstructionsView.layer.isHidden = true
        }
    }
    @IBAction func chooseFlightsButtonTouchedUpInside(_ sender: Any) {
        
    }
    @IBAction func tripNameEditingChanged(_ sender: Any) {
        let tripNameValue = tripNameLabel.text as! NSString
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["trip_name"] = tripNameValue
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    @IBAction func readyToBookButtonPressed(_ sender: Any) {

//        self.performSegue(withIdentifier: "destinationChosenSegue", sender: self)
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["finished_entering_preferences_status"] = "Ranking" as NSString
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }

}
