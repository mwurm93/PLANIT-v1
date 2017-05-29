//
//  exploreHotelsViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/4/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import GoogleMaps
import SMCalloutView

class exploreHotelsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, GMSMapViewDelegate, SMCalloutViewDelegate {
    
    // MARK: Class properties
    //Load flight results from server
    var selectedIndex = IndexPath()
    var hotelResultsDictionary = [["hotelName":"The W"],["hotelName":"Hilton"],["hotelName":"Marriott"],["hotelName":"Holiday Inn"],["hotelName":"VRBO"]]
    
    var sectionTitles = ["Group's top hotel", "Alternatives"]
    var effect:UIVisualEffect!
    var hotelStockPhotos = [#imageLiteral(resourceName: "hotelPoolStockPhoto"),#imageLiteral(resourceName: "hotelRoomStockPhoto")]
    
    var sortFilterFlightsCalloutView = SMCalloutView()
    let sortFilterFlightsCalloutTableView = UITableView(frame: CGRect.zero, style: .plain)
    var calloutTableViewMode = "sort"
    let sortFirstLevelOptions = ["Price","Rating"]
    let filterFirstLevelOptions = ["Amenities","Rating","Clear filters"]
    
    // MARK: Outlets
    @IBOutlet weak var recommendationRankingTableView: UITableView!
    @IBOutlet weak var readyToBookButton: UIButton!
    @IBOutlet weak var returnToSwipingButton: UIButton!
    @IBOutlet weak var tripNameLabel: UITextField!
    @IBOutlet weak var popupBlurView: UIVisualEffectView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up sort and filter callout views
        self.sortFilterFlightsCalloutView.delegate = self
        self.sortFilterFlightsCalloutView.isHidden = true
        
        sortFilterFlightsCalloutTableView.delegate = self
        sortFilterFlightsCalloutTableView.dataSource = self
        sortFilterFlightsCalloutTableView.frame = CGRect(x: 0, y: 121, width: 100, height: 100)
        sortFilterFlightsCalloutTableView.isEditing = false
        sortFilterFlightsCalloutTableView.allowsMultipleSelection = false
        sortFilterFlightsCalloutTableView.backgroundColor = UIColor.clear
        sortFilterFlightsCalloutTableView.layer.backgroundColor = UIColor.clear.cgColor
        
        //Set up popupblurview
        effect = popupBlurView.effect
        popupBlurView.effect = nil
        
        //        hideKeyboardWhenTappedAround()
        self.tripNameLabel.delegate = self
        
        //Set up table
        recommendationRankingTableView.tableFooterView = UIView()
        recommendationRankingTableView.isEditing = true
        recommendationRankingTableView.allowsSelectionDuringEditing = true
        recommendationRankingTableView.separatorColor = UIColor.white
        
        //Load the values from our shared data container singleton
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        //Install the value into the label.
        if tripNameValue != nil {
            self.tripNameLabel.text =  "\(tripNameValue!)"
        }
        
        let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
        
        self.readyToBookButton.setTitle("Confirm details and book", for: .normal)
        self.readyToBookButton.setTitleColor(UIColor.white, for: .normal)
        self.readyToBookButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        self.readyToBookButton.backgroundColor = UIColor.blue
        self.readyToBookButton.layer.cornerRadius = self.readyToBookButton.frame.height / 2
        self.readyToBookButton.titleLabel?.textAlignment = .center
        
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
        if tableView == recommendationRankingTableView {
            return 2
        }
        // else if tableView == sortFilterFlightsCalloutTableView
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == recommendationRankingTableView {
            if section == 0 {
                return 1
            }
            // if section == 1
            let numberOfRows = hotelResultsDictionary.count
            return numberOfRows - 1
        }
        // else if tableView == sortFilterFlightsCalloutTableView
        else if calloutTableViewMode == "sort" {
            return sortFirstLevelOptions.count
        }
        return filterFirstLevelOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == recommendationRankingTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "hotelResultPrototypeCell", for: indexPath) as! hotelTableViewCell
            cell.selectionStyle = .none
            cell.showHotelOnMap()
            
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
            
            var hotelsForRow = hotelResultsDictionary[0]
            
            
            var addedRow = indexPath.row + 1
            if indexPath.section == 1 {
                hotelsForRow = hotelResultsDictionary[addedRow]
                addedRow += 1
            }
            
            cell.hotelName.text = hotelsForRow["hotelName"]
            
            return cell
        }
        // else if tableView == sortFilterFlightsCalloutTableView
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellID")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cellID")
        }
        
        if calloutTableViewMode == "filter" {
            cell?.textLabel?.text = filterFirstLevelOptions[indexPath.row]
        } else if calloutTableViewMode == "sort" {
            cell?.textLabel?.text = sortFirstLevelOptions[indexPath.row]
        }
        
        cell?.textLabel?.textColor = UIColor.black
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell?.textLabel?.numberOfLines = 0
        cell?.backgroundColor = UIColor.clear
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == recommendationRankingTableView {
        if selectedIndex == indexPath {
            selectedIndex = IndexPath()
        } else {
            selectedIndex = indexPath
        }
        self.recommendationRankingTableView.beginUpdates()
        self.recommendationRankingTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        self.recommendationRankingTableView.endUpdates()
        } else if tableView == sortFilterFlightsCalloutTableView {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.sortFilterFlightsCalloutView.dismissCallout(animated: true)
                self.sortFilterFlightsCalloutView.isHidden = true
                //HANDLE SORT / FILTER SELECTION
            })
        }
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
        if tableView == recommendationRankingTableView {
            return true
        }
        // else if tableView == sortFilterFlightsCalloutTableView
        return false
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath == IndexPath(row: 1, section: 0) {
            return IndexPath(row: 0, section: 1)
        }
        
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if destinationIndexPath == IndexPath(row: 0, section: 0) {
            let alertController = UIAlertController(title: "You are changing your group's hotel to \(String(describing: self.hotelResultsDictionary[sourceIndexPath.row + 1]["hotelName"]!))", message: "Make sure everyone in your group is okay with this!", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                tableView.reloadData()
            }
            let continueAction = UIAlertAction(title: "Continue", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                
                let movedRowDictionary = self.hotelResultsDictionary[sourceIndexPath.row + 1]
                self.hotelResultsDictionary.remove(at: sourceIndexPath.row + 1)
                self.hotelResultsDictionary.insert(movedRowDictionary, at: 0)
                tableView.reloadData()
                
                self.readyToBookButton.setTitle("Confirm details and book", for: .normal)
            }
            alertController.addAction(cancelAction)
            alertController.addAction(continueAction)
            self.present(alertController, animated: true, completion: nil)
        } else if sourceIndexPath == IndexPath(row: 0, section: 0) {
            let alertController = UIAlertController(title: "You are changing your group's hotel to \(String(describing: self.hotelResultsDictionary[1]["hotelName"]!))", message: "Make sure everyone in your group is okay with this!", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                tableView.reloadData()
            }
            let continueAction = UIAlertAction(title: "Continue", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                
                let movedRowDictionary = self.hotelResultsDictionary[sourceIndexPath.row]
                self.hotelResultsDictionary.remove(at: sourceIndexPath.row)
                self.hotelResultsDictionary.insert(movedRowDictionary, at: destinationIndexPath.row)
                tableView.reloadData()
                
                self.readyToBookButton.setTitle("Confirm details and book", for: .normal)
            }
            alertController.addAction(cancelAction)
            alertController.addAction(continueAction)
            self.present(alertController, animated: true, completion: nil)
            
            
        } else {
            let movedRowDictionary = hotelResultsDictionary[sourceIndexPath.row + 1]
            hotelResultsDictionary.remove(at: sourceIndexPath.row + 1)
            hotelResultsDictionary.insert(movedRowDictionary, at: destinationIndexPath.row + 1)
        }
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == recommendationRankingTableView {
            if (selectedIndex == indexPath) {
                return 287.5
            } else {
                return 46
            }
        }
        // else if tableView == sortFilterFlightsCalloutTableView
        return 22
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? hotelTableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        tableViewCell.expandedViewPhotos()
    }
    
    // MARK: Table Section Headers
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == recommendationRankingTableView {
            return sectionTitles[section]
        }
        // else if tableView == sortFilterFlightsCalloutTableView
        return nil
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == recommendationRankingTableView {
            let header = UIView(frame: CGRect(x: 0, y: 0, width: recommendationRankingTableView.bounds.size.width, height: 30))
            header.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
            header.layer.cornerRadius = 5
            
            let title = UILabel()
            title.frame = CGRect(x: 5, y: header.frame.minY, width: header.frame.width, height: header.frame.height)
            title.textAlignment = .left
            title.font = UIFont.boldSystemFont(ofSize: 20)
            title.textColor = UIColor.white
            title.text = sectionTitles[section]
            header.addSubview(title)
            
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == recommendationRankingTableView {
            return 30
        }
        return CGFloat.leastNormalMagnitude
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
    
    
    // MARK: Actions
    @IBAction func tripNameEditingChanged(_ sender: Any) {
        let tripNameValue = tripNameLabel.text as! NSString
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["trip_name"] = tripNameValue
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["finished_entering_preferences_status"] = "Ranking" as NSString
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }

    @IBAction func sortButtonTouchedUpInside(_ sender: Any) {
        if self.sortFilterFlightsCalloutView.isHidden == true || (self.sortFilterFlightsCalloutView.isHidden == false && calloutTableViewMode == "filter"){
            calloutTableViewMode = "sort"
            sortFilterFlightsCalloutTableView.frame = CGRect(x: 0, y: 121, width: 140, height: 22 * sortFirstLevelOptions.count)
            sortFilterFlightsCalloutTableView.reloadData()
            self.sortFilterFlightsCalloutView.contentView = sortFilterFlightsCalloutTableView
            self.sortFilterFlightsCalloutView.isHidden = false
            self.sortFilterFlightsCalloutView.animation(withType: .stretch, presenting: true)
            self.sortFilterFlightsCalloutView.permittedArrowDirection = .up
            var calloutRect: CGRect = CGRect.zero
            calloutRect.origin = CGPoint(x: sortButton.frame.midX, y: CGFloat(125))
            self.sortFilterFlightsCalloutView.presentCallout(from: calloutRect, in: self.view, constrainedTo: self.view, animated: true)
            
        } else {
            self.sortFilterFlightsCalloutView.dismissCallout(animated: true)
            self.sortFilterFlightsCalloutView.isHidden = true
        }
    }
    @IBAction func filterButtonTouchedUpInsider(_ sender: Any) {
        if self.sortFilterFlightsCalloutView.isHidden == true || (self.sortFilterFlightsCalloutView.isHidden == false && calloutTableViewMode == "sort") {
            calloutTableViewMode = "filter"
            sortFilterFlightsCalloutTableView.frame = CGRect(x: 0, y: 121, width: 120, height: 22 * filterFirstLevelOptions.count)
            sortFilterFlightsCalloutTableView.reloadData()
            self.sortFilterFlightsCalloutView.contentView = sortFilterFlightsCalloutTableView
            self.sortFilterFlightsCalloutView.isHidden = false
            self.sortFilterFlightsCalloutView.animation(withType: .stretch, presenting: true)
            self.sortFilterFlightsCalloutView.permittedArrowDirection = .up
            var calloutRect: CGRect = CGRect.zero
            calloutRect.origin = CGPoint(x: filterButton.frame.midX, y: CGFloat(125))
            self.sortFilterFlightsCalloutView.presentCallout(from: calloutRect, in: self.view, constrainedTo: self.view, animated: true)
            
        } else {
            self.sortFilterFlightsCalloutView.dismissCallout(animated: true)
            self.sortFilterFlightsCalloutView.isHidden = true
        }
    }
}

extension exploreHotelsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hotelStockPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hotelPhotosCollectionViewCell", for: indexPath) as! hotelPhotosCollectionViewCell
        
        cell.hotelStockPhotoVIew.image = hotelStockPhotos[indexPath.item]
        
        return cell
    }
}
