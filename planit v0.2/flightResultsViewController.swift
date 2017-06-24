//
//  flightResultsViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/15/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import SMCalloutView
import Cartography

class flightResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SMCalloutViewDelegate, UIGestureRecognizerDelegate {
    
    //Vars passed from segue
    var rankedPotentialTripsDictionaryArrayIndex: Int?
    var searchMode: String?
    
    //MARK: Class vars
    
    //Times VC viewed
    var timesViewed = [String: Int]()

    //Load flight results from server
    var selectedIndex = IndexPath(row: 0, section: 0)
    var sectionTitles = ["Selected flight", "Alternatives"]
    var sortFilterFlightsCalloutView = SMCalloutView()
    let sortFilterFlightsCalloutTableView = UITableView(frame: CGRect.zero, style: .plain)
    var calloutTableViewMode = "sort"
    let sortFirstLevelOptions = ["Price","Duration","Landing Time", "Departure Time"]
    let filterFirstLevelOptions = ["Stops","Airlines","Clear filters"]
    var rankedPotentialTripsDictionary = [Dictionary<String, Any>]()
    var flightResultsDictionary = [Dictionary<String, Any>]()

    //Instructions
    var instructionsView: instructionsView?

    
    //MARK: Outlets
    @IBOutlet weak var flightResultsTableView: UITableView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var popupBackgroundView: UIVisualEffectView!
    @IBOutlet weak var selectFlightButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchSummaryTitle: UILabel!
    @IBOutlet weak var searchSummaryDates: UILabel!
    @IBOutlet weak var instructionsGotItButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
        rankedPotentialTripsDictionaryArrayIndex = SavedPreferencesForTrip["rankedPotentialTripsDictionaryArrayIndex"] as? Int
                
        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                rankedPotentialTripsDictionary = rankedPotentialTripsDictionaryFromSingleton as! [Dictionary<String, AnyObject>]
                if let thisTripDict = rankedPotentialTripsDictionaryFromSingleton[rankedPotentialTripsDictionaryArrayIndex!] as? Dictionary<String, AnyObject> {
                    if let thisTripFlightResults = thisTripDict["flightOptions"] {
                        if thisTripFlightResults.count > 1 {
                            rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex!]["flightOptions"] = thisTripFlightResults
                        } else {
                            //Load from server
                            var flightOptionsDictionaryFromServer = [["departureDepartureTime":"1:00a","departureOrigin":"JFK","departureArrivalTime":"2:00a","departureDestination":"AAA","returnDepartureTime":"1:00a","returnOrigin":"JFK","returnArrivalTime":"2:00a","returnDestination":"MIA","totalPrice":"$1,000","selectedStatus":0],["departureDepartureTime":"2:00a","departureOrigin":"JFK","departureArrivalTime":"3:00a","departureDestination":"BBB","returnDepartureTime":"2:00a","returnOrigin":"JFK","returnArrivalTime":"3:00a","returnDestination":"MIA","totalPrice":"$1,100","selectedStatus":0],["departureDepartureTime":"3:00a","departureOrigin":"JFK","departureArrivalTime":"4:00a","departureDestination":"CCC","returnDepartureTime":"3:00a","returnOrigin":"JFK","returnArrivalTime":"4:00a","returnDestination":"MIA","totalPrice":"$1,200","selectedStatus":0],["departureDepartureTime":"4:00a","departureOrigin":"JFK","departureArrivalTime":"5:00a","departureDestination":"DDD","returnDepartureTime":"4:00a","returnOrigin":"JFK","returnArrivalTime":"5:00a","returnDestination":"MIA","totalPrice":"$1,300","selectedStatus":0],["departureDepartureTime":"5:00a","departureOrigin":"JFK","departureArrivalTime":"6:00a","departureDestination":"EEE","returnDepartureTime":"5:00a","returnOrigin":"JFK","returnArrivalTime":"6:00a","returnDestination":"MIA","totalPrice":"$1,400","selectedStatus":0],["departureDepartureTime":"6:00a","departureOrigin":"JFK","departureArrivalTime":"7:00a","departureDestination":"FFF","returnDepartureTime":"6:00a","returnOrigin":"JFK","returnArrivalTime":"7:00a","returnDestination":"MIA","totalPrice":"$1,500","selectedStatus":0],["departureDepartureTime":"7:00a","departureOrigin":"JFK","departureArrivalTime":"8:00a","departureDestination":"GGG","returnDepartureTime":"7:00a","returnOrigin":"JFK","returnArrivalTime":"8:00a","returnDestination":"MIA","totalPrice":"$1,600","selectedStatus":0],["departureDepartureTime":"8:00a","departureOrigin":"JFK","departureArrivalTime":"9:00a","departureDestination":"HHH","returnDepartureTime":"8:00a","returnOrigin":"JFK","returnArrivalTime":"9:00a","returnDestination":"MIA","totalPrice":"$1,700","selectedStatus":0]]
                            
                            for index in 0 ... flightOptionsDictionaryFromServer.count - 1 {
                                var homeAirportValue = String()
                                if  DataContainerSingleton.sharedDataContainer.homeAirport != nil && DataContainerSingleton.sharedDataContainer.homeAirport != "" {
                                    homeAirportValue = DataContainerSingleton.sharedDataContainer.homeAirport!
                                } else {
                                    homeAirportValue = ""
                                }
                                
                                flightOptionsDictionaryFromServer[index]["returnDestination"] = homeAirportValue
                                flightOptionsDictionaryFromServer[index]["departureOrigin"] = homeAirportValue
                                flightOptionsDictionaryFromServer[index]["departureDestination"] = rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex!]["destination"] as? String
                                flightOptionsDictionaryFromServer[index]["returnOrigin"] = rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex!]["destination"] as? String
                            }
                            
                            rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex!]["flightOptions"] = flightOptionsDictionaryFromServer
                        }
                    }
                }
            }
        }
        //Create shorter name
        flightResultsDictionary = rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex!]["flightOptions"] as! [Dictionary<String, Any>]
        
        //Save for retrieval from rankings page
        rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex!]["flightOptions"] = flightResultsDictionary
        SavedPreferencesForTrip["rankedPotentialTripsDictionary"] = rankedPotentialTripsDictionary
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
        //Update search summary title
        var homeAirportValue = String()
        if  DataContainerSingleton.sharedDataContainer.homeAirport != nil && DataContainerSingleton.sharedDataContainer.homeAirport != "" {
            homeAirportValue = DataContainerSingleton.sharedDataContainer.homeAirport!
        } else {
            homeAirportValue = ""
        }        
        searchSummaryTitle.text = "\(homeAirportValue) - \(String(describing: (SavedPreferencesForTrip["destinationsForTrip"] as! [String])[0])) \(String(describing: searchMode!))"
        
        self.sortFilterFlightsCalloutView.delegate = self
        self.sortFilterFlightsCalloutView.isHidden = true
        
        sortFilterFlightsCalloutTableView.delegate = self
        sortFilterFlightsCalloutTableView.dataSource = self
        sortFilterFlightsCalloutTableView.frame = CGRect(x: 0, y: 121, width: 100, height: 100)
        sortFilterFlightsCalloutTableView.isEditing = false
        sortFilterFlightsCalloutTableView.allowsMultipleSelection = false
        sortFilterFlightsCalloutTableView.backgroundColor = UIColor.clear
        sortFilterFlightsCalloutTableView.layer.backgroundColor = UIColor.clear.cgColor
        
        //Set up table
        flightResultsTableView.tableFooterView = UIView()
//        flightResultsTableView.isEditing = true
//        flightResultsTableView.allowsSelectionDuringEditing = true
        flightResultsTableView.separatorColor = UIColor.white
//        constrain(flightResultsTableView, scrollView.) { view1, view2 in
//            view1.bottom == view2.bottom
//        }
        
//        timesViewed = (SavedPreferencesForTrip["timesViewed"] as? [String : Int])!
//        if timesViewed["flightResults"] == 0 {
//            var when = DispatchTime.now()
//            DispatchQueue.main.asyncAfter(deadline: when) {
//                self.animateInstructionsIn()
//                let currentTimesViewed = self.timesViewed["flightResults"]
//                self.timesViewed["flightResults"]! = currentTimesViewed! + 1
//                SavedPreferencesForTrip["timesViewed"] = self.timesViewed as NSDictionary
//                self.saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
//            }
//            when = DispatchTime.now() + 0.8
//            DispatchQueue.main.asyncAfter(deadline: when) {
//                UIView.animate(withDuration: 1.5) {
//                    self.instructionsView?.instructionsCollectionView?.scrollToItem(at: IndexPath(item: 4,section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
//                    
//                }
//            }
//        }
//        
//        let atap = UITapGestureRecognizer(target: self, action: #selector(self.dismissInstructions(touch:)))
//        atap.numberOfTapsRequired = 1
//        atap.delegate = self
//        self.popupBackgroundView.addGestureRecognizer(atap)
//        popupBackgroundView.isHidden = true
//        popupBackgroundView.isUserInteractionEnabled = true
    
        NotificationCenter.default.addObserver(self, selector: #selector(bookSelectedFlightToFlightResults), name: NSNotification.Name(rawValue: "bookSelectedFlightToFlightResults"), object: nil)
    }
    
    // MARK: UITableviewdelegate
    func numberOfSections(in tableView: UITableView) -> Int {
//        if tableView == flightResultsTableView {
//            return 2
//        }
//        // else if tableView == sortFilterFlightsCalloutTableView
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == flightResultsTableView {
            let numberOfRows = flightResultsDictionary.count
            return numberOfRows - 1
        }
        // else if tableView == sortFilterFlightsCalloutTableView
        else if calloutTableViewMode == "sort" {
            return sortFirstLevelOptions.count
        }
        return filterFirstLevelOptions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == flightResultsTableView {
            if (selectedIndex == indexPath) {
                return 104
            } else {
                return 52
            }
        }
        // else if tableView == sortFilterFlightsCalloutTableView
        return 22
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == flightResultsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "flightSearchResultTableViewPrototypeCell", for: indexPath) as! flightSearchResultTableViewCell
            cell.selectionStyle = .none
            
//            //Change hamburger icon
//            for view in cell.subviews as [UIView] {
//                if type(of: view).description().range(of: "Reorder") != nil {
//                    for subview in view.subviews as! [UIImageView] {
//                        if subview.isKind(of: UIImageView.self) {
//                            subview.image = UIImage(named: "hamburger")
//                            subview.bounds = CGRect(x: 0, y: 0, width: 20, height: 13)
//                        }
//                    }
//                }
//            }
//            
//            if indexPath == IndexPath(row: 0, section: 0) {
//                cell.backgroundColor = UIColor.blue
//            } else {
//                cell.backgroundColor = UIColor.clear
//            }
            
            var flightsForRow = flightResultsDictionary[0]
            var addedRow = indexPath.row
            flightsForRow = flightResultsDictionary[addedRow]
            addedRow += 1
            
            cell.departureOrigin.text = flightsForRow["departureOrigin"] as? String
            cell.departureDestination.text = flightsForRow["departureDestination"] as? String
            cell.departureDepartureTime.text = flightsForRow["departureDepartureTime"] as? String
            cell.departureArrivalTime.text = flightsForRow["departureArrivalTime"] as? String
            cell.returnDepartureTime.text = flightsForRow["returnDepartureTime"] as? String
            cell.returnOrigin.text = flightsForRow["returnOrigin"] as? String
            cell.returnArrivalTime.text = flightsForRow["returnArrivalTime"] as? String
            cell.returnDestination.text = flightsForRow["returnDestination"] as? String
            cell.totalPrice.text = flightsForRow["totalPrice"] as? String
            
            cell.selectFlightButton.setTitleColor(UIColor.white, for: .normal)
            cell.selectFlightButton.setBackgroundColor(color: UIColor.clear, forState: .normal)
            cell.selectFlightButton.setTitleColor(UIColor.white, for: .selected)
            cell.selectFlightButton.setBackgroundColor(color: UIColor.blue, forState: .selected)
            cell.selectFlightButton.layer.borderWidth = 1
            cell.selectFlightButton.layer.borderColor = UIColor.white.cgColor
            cell.selectFlightButton.layer.masksToBounds = true
            cell.selectFlightButton.titleLabel?.numberOfLines = 0
            cell.selectFlightButton.titleLabel?.textAlignment = .center
            cell.selectFlightButton.setTitle("Select flight", for: .normal)
            cell.selectFlightButton.setTitle("Select flight", for: .selected)
            cell.selectFlightButton.translatesAutoresizingMaskIntoConstraints = false
            cell.selectFlightButton.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
            cell.selectFlightButton.sizeToFit()
            cell.selectFlightButton.frame.size.height = 25
            cell.selectFlightButton.frame.size.width += 10
            cell.selectFlightButton.layer.cornerRadius = cell.selectFlightButton.frame.height / 2
            cell.selectFlightButton.tag = addedRow
            
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
    
    func buttonClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true {
            sender.layer.borderWidth = 0
            // Set selected status to 1 (YES)
            flightResultsDictionary[sender.tag]["selectedStatus"] = 1
            // Set selected status of all other flights to 0 (NO)
            for index in 0 ... flightResultsDictionary.count - 1 {
                if index != sender.tag {
                    flightResultsDictionary[index]["selectedStatus"] = 0
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "flightSelectButtonTouchedUpInside"), object: nil)
        } else {
            sender.layer.borderWidth = 1
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == flightResultsTableView {
            if selectedIndex == indexPath {
                selectedIndex = IndexPath(row: 0, section: 0)
            } else {
                selectedIndex = indexPath
            }
            self.flightResultsTableView.beginUpdates()
            self.flightResultsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            self.flightResultsTableView.endUpdates()
        } else if tableView == sortFilterFlightsCalloutTableView {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.sortFilterFlightsCalloutView.dismissCallout(animated: true)
                self.sortFilterFlightsCalloutView.isHidden = true
                //HANDLE SORT / FILTER SELECTION
            })
        }
    }
    
    func bookSelectedFlightToFlightResults() {
        for row in 0 ... flightResultsTableView.numberOfRows(inSection: 0) - 1 {
            let cell = flightResultsTableView.cellForRow(at: IndexPath(row: row, section: 0)) as! flightSearchResultTableViewCell
            cell.selectFlightButton.isSelected = false
            cell.selectFlightButton.layer.borderWidth = 1
            flightResultsDictionary[row]["selectedStatus"] = 0
        }
    }
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//    }
//    
//    // MARK: moving rows
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .none
//    }
//    
//    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//    
//    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        if tableView == flightResultsTableView {
//            return true
//        }
//        // else if tableView == sortFilterFlightsCalloutTableView
//        return false
//    }
//    
//    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
//        if proposedDestinationIndexPath == IndexPath(row: 1, section: 0) {
//            return IndexPath(row: 0, section: 1)
//        }
//        
//        return proposedDestinationIndexPath
//    }
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        
//        if destinationIndexPath == IndexPath(row: 0, section: 0) {
//            let movedRowDictionary = flightResultsDictionary[sourceIndexPath.row + 1]
//            flightResultsDictionary.remove(at: sourceIndexPath.row + 1)
//            flightResultsDictionary.insert(movedRowDictionary, at: 0)
//            
//            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//            rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex!]["flightOptions"] = flightResultsDictionary
//            SavedPreferencesForTrip["rankedPotentialTripsDictionary"] = rankedPotentialTripsDictionary
//            //Save
//            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
//            tableView.reloadData()
//        } else if sourceIndexPath == IndexPath(row: 0, section: 0) {
//            let movedRowDictionary = flightResultsDictionary[sourceIndexPath.row]
//            flightResultsDictionary.remove(at: sourceIndexPath.row)
//            flightResultsDictionary.insert(movedRowDictionary, at: destinationIndexPath.row)
//            
//            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//            rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex!]["flightOptions"] = flightResultsDictionary
//            SavedPreferencesForTrip["rankedPotentialTripsDictionary"] = rankedPotentialTripsDictionary
//            //Save
//            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
//            tableView.reloadData()
//        } else {
//            let movedRowDictionary = flightResultsDictionary[sourceIndexPath.row + 1]
//            flightResultsDictionary.remove(at: sourceIndexPath.row + 1)
//            flightResultsDictionary.insert(movedRowDictionary, at: destinationIndexPath.row + 1)
//            
//            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//            rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex!]["flightOptions"] = flightResultsDictionary
//            SavedPreferencesForTrip["rankedPotentialTripsDictionary"] = rankedPotentialTripsDictionary
//            //Save
//            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
//            tableView.reloadData()
//        }
//        tableView.reloadData()
//    }
//    
//    // MARK: Table Section Headers
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if tableView == flightResultsTableView {
//            return sectionTitles[section]
//        }
//        // else if tableView == sortFilterFlightsCalloutTableView
//        return nil
//    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
//    {
//        if tableView == flightResultsTableView {
//            let header = UIView(frame: CGRect(x: 0, y: 0, width: flightResultsTableView.bounds.size.width, height: 30))
//            header.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
//            header.layer.cornerRadius = 5
//            
//            let title = UILabel()
//            title.frame = CGRect(x: 10, y: header.frame.minY, width: header.frame.width, height: header.frame.height)
//            title.textAlignment = .left
//            title.font = UIFont.boldSystemFont(ofSize: 20)
//            title.textColor = UIColor.white
//            title.text = sectionTitles[section]
//            header.addSubview(title)
//            
//            return header
//        }
//        return nil
//    }
//
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
//    func fetchSavedPreferencesForTrip() -> NSMutableDictionary {
//        //Update preference vars if an existing trip
//        //Trip status
//        let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? 0 as NSNumber
//        let finishedEnteringPreferencesStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "finished_entering_preferences_status") as? NSString ?? NSString()
//        let lastVC = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "lastVC") as? NSString ?? NSString()
//        let timesViewed = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "timesViewed") as? NSDictionary ?? NSDictionary()
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
//        let firebaseChannelKey = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "firebaseChannelKey") as? NSString ?? NSString()
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
//        let rankedPotentialTripsDictionaryArrayIndex = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionaryArrayIndex") as? NSNumber ?? NSNumber()
//
//        //SavedPreferences
//        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus,"finished_entering_preferences_status": finishedEnteringPreferencesStatus, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips,"numberDestinations":numberDestinations,"nonSpecificDates":nonSpecificDates, "rankedPotentialTripsDictionary": rankedPotentialTripsDictionary, "tripID": tripID,"lastVC": lastVC,"firebaseChannelKey": firebaseChannelKey,"rankedPotentialTripsDictionaryArrayIndex": rankedPotentialTripsDictionaryArrayIndex, "timesViewed": timesViewed] as NSMutableDictionary
//        
//        return fetchedSavedPreferencesForTrip
//    }
//    func saveUpdatedExistingTrip(SavedPreferencesForTrip: NSMutableDictionary) {
//        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
//        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
//        existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
//        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
//    }
    
//    func updateLastVC(){
//        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//        SavedPreferencesForTrip["lastVC"] = "flightResults" as NSString
//        //Save
//        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        self.instructionsView?.instructionsCollectionView?.scrollToItem(at: IndexPath(item: 4,section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
//        
//        if segue.identifier == "flightResultsToFlightSearch" {
//            let destination = segue.destination as? flightSearchViewController
//            destination?.rankedPotentialTripsDictionaryArrayIndex = rankedPotentialTripsDictionaryArrayIndex
//        }
//        if segue.identifier == "flightResultsToChat" {
//            let destination = segue.destination as? UINavigationController
//            let chatVC = destination?.topViewController as! ChatViewController
//            chatVC.searchMode = self.searchMode
//        }
//
//    }
//    
//    func updateCompletionStatus() {
//        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//        SavedPreferencesForTrip["finished_entering_preferences_status"] = "flightResults" as NSString
//        //Save
//        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
//    }
//
//    func animateInstructionsIn(){
//        instructionsView?.isHidden = false
//        instructionsView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
//        instructionsView?.alpha = 0
//        UIView.animate(withDuration: 0.4) {
//            self.popupBackgroundView.isHidden = false
//            self.instructionsView?.alpha = 1
//            self.instructionsView?.transform = CGAffineTransform.identity
//            self.instructionsGotItButton.isHidden = false
//        }
//    }
//    
//    func animateInstructionsOut(){
//        UIView.animate(withDuration: 0.3, animations: {
//            self.instructionsView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
//            self.instructionsView?.alpha = 0
//            self.instructionsGotItButton.isHidden = true
//            self.popupBackgroundView.isHidden = true
//        }) { (Success:Bool) in
//            self.instructionsView?.layer.isHidden = true
//            self.instructionsView?.instructionsCollectionView?.scrollToItem(at: IndexPath(item: 4,section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
//        }
//    }
//    
//    func dismissInstructions(touch: UITapGestureRecognizer) {
//        animateInstructionsOut()
//    }
//    
//    //MARK: Actions
//    @IBAction func infoButtonTouchedUpInside(_ sender: Any) {
//        animateInstructionsIn()
//        self.instructionsView?.instructionsCollectionView?.scrollToItem(at: IndexPath(item: 4,section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
//    }
//    @IBAction func instructionsGotItButtonTouchedUpInside(_ sender: Any) {
//        animateInstructionsOut()
//    }
//    
//    @IBAction func backButtonTouchedUpInside(_ sender: Any) {
//        super.performSegue(withIdentifier: "flightResultsToFlightSearch", sender: self)
//    }
//    @IBAction func selectFlightButtonTouchedUpInside(_ sender: Any) {
//        updateCompletionStatus()
//        if rankedPotentialTripsDictionaryArrayIndex == 0 {
//            super.performSegue(withIdentifier: "flightResultsToRanking", sender: self)
//        } else {
//            super.performSegue(withIdentifier: "flightResultsToRanking", sender: self)
//        }
//    }
    
    @IBAction func editFlightSearchButtonTouchedUpInside(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "editFlightSearchButtonTouchedUpInside"), object: nil)
    }
    @IBAction func filterFlightsButtonTouchedUpInside(_ sender: Any) {
        if self.sortFilterFlightsCalloutView.isHidden == true || (self.sortFilterFlightsCalloutView.isHidden == false && calloutTableViewMode == "sort") {
            calloutTableViewMode = "filter"
            sortFilterFlightsCalloutTableView.frame = CGRect(x: 0, y: 121, width: 120, height: 22 * filterFirstLevelOptions.count)
            sortFilterFlightsCalloutTableView.reloadData()
            self.sortFilterFlightsCalloutView.contentView = sortFilterFlightsCalloutTableView
            self.sortFilterFlightsCalloutView.isHidden = false
            self.sortFilterFlightsCalloutView.animation(withType: .stretch, presenting: true)
            self.sortFilterFlightsCalloutView.permittedArrowDirection = .up
            var calloutRect: CGRect = CGRect.zero
            calloutRect.origin = CGPoint(x: filterButton.frame.midX, y: CGFloat(109))
            self.sortFilterFlightsCalloutView.presentCallout(from: calloutRect, in: self.view, constrainedTo: self.view, animated: true)

        } else {
            self.sortFilterFlightsCalloutView.dismissCallout(animated: true)
            self.sortFilterFlightsCalloutView.isHidden = true
        }
    }
    @IBAction func sortFlightsButtonTouchedUpInside(_ sender: Any) {
        if self.sortFilterFlightsCalloutView.isHidden == true || (self.sortFilterFlightsCalloutView.isHidden == false && calloutTableViewMode == "filter"){
            calloutTableViewMode = "sort"
            sortFilterFlightsCalloutTableView.frame = CGRect(x: 0, y: 121, width: 140, height: 22 * sortFirstLevelOptions.count)
            sortFilterFlightsCalloutTableView.reloadData()
            self.sortFilterFlightsCalloutView.contentView = sortFilterFlightsCalloutTableView
            self.sortFilterFlightsCalloutView.isHidden = false
            self.sortFilterFlightsCalloutView.animation(withType: .stretch, presenting: true)
            self.sortFilterFlightsCalloutView.permittedArrowDirection = .up
            var calloutRect: CGRect = CGRect.zero
            calloutRect.origin = CGPoint(x: sortButton.frame.midX, y: CGFloat(109))
            self.sortFilterFlightsCalloutView.presentCallout(from: calloutRect, in: self.view, constrainedTo: self.view, animated: true)
            
        } else {
            self.sortFilterFlightsCalloutView.dismissCallout(animated: true)
            self.sortFilterFlightsCalloutView.isHidden = true
        }
    }
}
