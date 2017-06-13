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

class exploreHotelsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GMSMapViewDelegate, SMCalloutViewDelegate, UIGestureRecognizerDelegate {
    
    //Vars passed from segue
    var rankedPotentialTripsDictionaryArrayIndex: Int?
    
    // MARK: Class properties
    var selectedIndex = IndexPath(row: 0, section: 0)
    
    //Times VC viewed
    var timesViewed = [String: Int]()
    
    var sectionTitles = ["Group's top hotel", "Alternatives"]
    var effect:UIVisualEffect!
    var hotelStockPhotos = [#imageLiteral(resourceName: "hotelPoolStockPhoto"),#imageLiteral(resourceName: "hotelRoomStockPhoto")]
    
    var sortFilterHotelsCalloutView = SMCalloutView()
    let sortFilterHotelsCalloutTableView = UITableView(frame: CGRect.zero, style: .plain)
    var calloutTableViewMode = "sort"
    let sortFirstLevelOptions = ["Price","Rating"]
    let filterFirstLevelOptions = ["Vicinity to...","Amenities","Rating","Clear filters"]
    var rankedPotentialTripsDictionary = [Dictionary<String, Any>]()
    var hotelResultsDictionary = [Dictionary<String, Any>]()
    
    //Instructions
    var instructionsView: instructionsView?

    
    // MARK: Outlets
    @IBOutlet weak var recommendationRankingTableView: UITableView!
    @IBOutlet weak var readyToBookButton: UIButton!
    @IBOutlet weak var returnToSwipingButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var popupBackgroundView: UIVisualEffectView!
    @IBOutlet weak var searchSummaryTitle: UILabel!
    @IBOutlet weak var searchSummaryDates: UILabel!
    @IBOutlet weak var instructionsGotItButton: UIButton!
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLastVC()
        
        let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
        rankedPotentialTripsDictionaryArrayIndex = SavedPreferencesForTrip["rankedPotentialTripsDictionaryArrayIndex"] as? Int
        
        //Setup instructions collection view
        instructionsView = Bundle.main.loadNibNamed("instructionsView", owner: self, options: nil)?.first! as? instructionsView
        instructionsView?.frame.origin.y = 200
        self.view.insertSubview(instructionsView!, aboveSubview: popupBackgroundView)
        instructionsView?.isHidden = true
        instructionsGotItButton.isHidden = true
        
        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                rankedPotentialTripsDictionary = rankedPotentialTripsDictionaryFromSingleton as! [Dictionary<String, AnyObject>]
                if let thisTripDict = rankedPotentialTripsDictionaryFromSingleton[rankedPotentialTripsDictionaryArrayIndex!] as? Dictionary<String, AnyObject> {
                    if let thisTripHotelResults = thisTripDict["hotelOptions"] {
                        if thisTripHotelResults.count > 1 {
                            rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex!]["hotelOptions"] = thisTripHotelResults
                        } else {
                            //Load from server
                            let hotelOptionsDictionaryFromServer = [["hotelName":"The W"],["hotelName":"Hilton"],["hotelName":"Marriott"],["hotelName":"Holiday Inn"],["hotelName":"VRBO"]]
                            
                            rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex!]["hotelOptions"] = hotelOptionsDictionaryFromServer
                        }
                    }
                }
            }
        }
        //Create shorter name
        hotelResultsDictionary = rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex!]["hotelOptions"] as! [Dictionary<String, Any>]
        //Save for retrieval from rankings page
        self.rankedPotentialTripsDictionary[self.rankedPotentialTripsDictionaryArrayIndex!]["hotelOptions"] = self.hotelResultsDictionary
        SavedPreferencesForTrip["rankedPotentialTripsDictionary"] = self.rankedPotentialTripsDictionary
        //Save
        self.saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)

        //Update search summary title
        searchSummaryTitle.text = "Accomodation in \(String(describing: rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex!]["destination"] as! String))"

        
        //Set up sort and filter callout views
        self.sortFilterHotelsCalloutView.delegate = self
        self.sortFilterHotelsCalloutView.isHidden = true
        
        sortFilterHotelsCalloutTableView.delegate = self
        sortFilterHotelsCalloutTableView.dataSource = self
        sortFilterHotelsCalloutTableView.frame = CGRect(x: 0, y: 121, width: 100, height: 100)
        sortFilterHotelsCalloutTableView.isEditing = false
        sortFilterHotelsCalloutTableView.allowsMultipleSelection = false
        sortFilterHotelsCalloutTableView.backgroundColor = UIColor.clear
        sortFilterHotelsCalloutTableView.layer.backgroundColor = UIColor.clear.cgColor
        
        //        hideKeyboardWhenTappedAround()
        
        //Set up table
        recommendationRankingTableView.tableFooterView = UIView()
        recommendationRankingTableView.isEditing = true
        recommendationRankingTableView.allowsSelectionDuringEditing = true
        recommendationRankingTableView.separatorColor = UIColor.white
        
        self.readyToBookButton.setTitle("Select hotel", for: .normal)
        self.readyToBookButton.setTitleColor(UIColor.white, for: .normal)
        self.readyToBookButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        self.readyToBookButton.backgroundColor = UIColor.blue
        self.readyToBookButton.layer.cornerRadius = self.readyToBookButton.frame.height / 2
        self.readyToBookButton.titleLabel?.textAlignment = .center
        
        timesViewed = (SavedPreferencesForTrip["timesViewed"] as? [String : Int])!
        if timesViewed["hotelResults"] == 0 {
            var when = DispatchTime.now()
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.animateInstructionsIn()
                let currentTimesViewed = self.timesViewed["hotelResults"]
                self.timesViewed["hotelResults"]! = currentTimesViewed! + 1
                SavedPreferencesForTrip["timesViewed"] = self.timesViewed as NSDictionary
                self.saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
            }
            when = DispatchTime.now() + 0.8
            DispatchQueue.main.asyncAfter(deadline: when) {
                UIView.animate(withDuration: 1.5) {
                    self.instructionsView?.instructionsCollectionView?.scrollToItem(at: IndexPath(item: 5,section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
                    
                }
            }
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
        
    // MARK: UITableviewdelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == recommendationRankingTableView {
            return 2
        }
        // else if tableView == sortFilterHotelsCalloutTableView
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
        // else if tableView == sortFilterHotelsCalloutTableView
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
            
            cell.hotelName.text = hotelsForRow["hotelName"] as! String
            
            return cell
        }
        // else if tableView == sortFilterHotelsCalloutTableView
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
        } else if tableView == sortFilterHotelsCalloutTableView {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.sortFilterHotelsCalloutView.dismissCallout(animated: true)
                self.sortFilterHotelsCalloutView.isHidden = true
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
        // else if tableView == sortFilterHotelsCalloutTableView
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
                
                let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
                self.rankedPotentialTripsDictionary[self.rankedPotentialTripsDictionaryArrayIndex!]["hotelOptions"] = self.hotelResultsDictionary
                SavedPreferencesForTrip["rankedPotentialTripsDictionary"] = self.rankedPotentialTripsDictionary
                //Save
                self.saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)

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
                
                let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
                self.rankedPotentialTripsDictionary[self.rankedPotentialTripsDictionaryArrayIndex!]["hotelOptions"] = self.hotelResultsDictionary
                SavedPreferencesForTrip["rankedPotentialTripsDictionary"] = self.rankedPotentialTripsDictionary
                //Save
                self.saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)

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
            
            let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
            rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex!]["hotelOptions"] = hotelResultsDictionary
            SavedPreferencesForTrip["rankedPotentialTripsDictionary"] = self.rankedPotentialTripsDictionary
            //Save
            self.saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
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
        // else if tableView == sortFilterHotelsCalloutTableView
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
        // else if tableView == sortFilterHotelsCalloutTableView
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        self.instructionsView?.instructionsCollectionView?.scrollToItem(at: IndexPath(item: 5,section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
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
        let lastVC = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "lastVC") as? NSString ?? NSString()
        let timesViewed = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "timesViewed") as? NSDictionary ?? NSDictionary()
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
        let firebaseChannelKey = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "firebaseChannelKey") as? NSString ?? NSString()
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
        let rankedPotentialTripsDictionaryArrayIndex = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionaryArrayIndex") as? NSNumber ?? NSNumber()

        //SavedPreferences
        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus,"finished_entering_preferences_status": finishedEnteringPreferencesStatus, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips,"numberDestinations":numberDestinations,"nonSpecificDates":nonSpecificDates, "rankedPotentialTripsDictionary": rankedPotentialTripsDictionary, "tripID": tripID,"lastVC": lastVC,"firebaseChannelKey": firebaseChannelKey,"rankedPotentialTripsDictionaryArrayIndex": rankedPotentialTripsDictionaryArrayIndex, "timesViewed": timesViewed] as NSMutableDictionary
        
        return fetchedSavedPreferencesForTrip
    }
    func saveUpdatedExistingTrip(SavedPreferencesForTrip: NSMutableDictionary) {
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
    }
    func updateLastVC(){
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["lastVC"] = "hotelResults" as NSString
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    func updateCompletionStatus() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["finished_entering_preferences_status"] = "hotelResults" as NSString
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    func animateInstructionsIn(){
        instructionsView?.isHidden = false
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
    
    // MARK: Actions
    @IBAction func infoButtonTouchedUpInside(_ sender: Any) {
        animateInstructionsIn()
        self.instructionsView?.instructionsCollectionView?.scrollToItem(at: IndexPath(item: 5,section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    }
    @IBAction func instructionsGotItButtonTouchedUpInside(_ sender: Any) {
        animateInstructionsOut()
    }
    @IBAction func nextButtonPressed(_ sender: Any) {
        updateCompletionStatus()
    }

    @IBAction func sortButtonTouchedUpInside(_ sender: Any) {
        if self.sortFilterHotelsCalloutView.isHidden == true || (self.sortFilterHotelsCalloutView.isHidden == false && calloutTableViewMode == "filter"){
            calloutTableViewMode = "sort"
            sortFilterHotelsCalloutTableView.frame = CGRect(x: 0, y: 109, width: 140, height: 22 * sortFirstLevelOptions.count)
            sortFilterHotelsCalloutTableView.reloadData()
            self.sortFilterHotelsCalloutView.contentView = sortFilterHotelsCalloutTableView
            self.sortFilterHotelsCalloutView.isHidden = false
            self.sortFilterHotelsCalloutView.animation(withType: .stretch, presenting: true)
            self.sortFilterHotelsCalloutView.permittedArrowDirection = .up
            var calloutRect: CGRect = CGRect.zero
            calloutRect.origin = CGPoint(x: sortButton.frame.midX, y: CGFloat(109))
            self.sortFilterHotelsCalloutView.presentCallout(from: calloutRect, in: self.view, constrainedTo: self.view, animated: true)
            
        } else {
            self.sortFilterHotelsCalloutView.dismissCallout(animated: true)
            self.sortFilterHotelsCalloutView.isHidden = true
        }
    }
    @IBAction func filterButtonTouchedUpInsider(_ sender: Any) {
        if self.sortFilterHotelsCalloutView.isHidden == true || (self.sortFilterHotelsCalloutView.isHidden == false && calloutTableViewMode == "sort") {
            calloutTableViewMode = "filter"
            sortFilterHotelsCalloutTableView.frame = CGRect(x: 0, y: 109, width: 120, height: 22 * filterFirstLevelOptions.count)
            sortFilterHotelsCalloutTableView.reloadData()
            self.sortFilterHotelsCalloutView.contentView = sortFilterHotelsCalloutTableView
            self.sortFilterHotelsCalloutView.isHidden = false
            self.sortFilterHotelsCalloutView.animation(withType: .stretch, presenting: true)
            self.sortFilterHotelsCalloutView.permittedArrowDirection = .up
            var calloutRect: CGRect = CGRect.zero
            calloutRect.origin = CGPoint(x: filterButton.frame.midX, y: CGFloat(109))
            self.sortFilterHotelsCalloutView.presentCallout(from: calloutRect, in: self.view, constrainedTo: self.view, animated: true)
            
        } else {
            self.sortFilterHotelsCalloutView.dismissCallout(animated: true)
            self.sortFilterHotelsCalloutView.isHidden = true
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
