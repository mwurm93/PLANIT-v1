//
//  FlightResultsQuestionView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/21/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import SMCalloutView

class FlightResultsQuestionView: UIView, UITableViewDelegate, UITableViewDataSource, SMCalloutViewDelegate {
    
    //Vars passed from segue
    var rankedPotentialTripsDictionaryArrayIndex: Int?
    var searchMode: String?
    
    //MARK: Class vars
    var flightResultsTableView: UITableView?
    
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

    // MARK: Outlets
    @IBOutlet weak var searchSummaryTitle: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addViews()
        //        self.layer.borderColor = UIColor.white.cgColor
        //        self.layer.borderWidth = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
        
        flightResultsTableView?.frame = CGRect(x: (bounds.size.width - 300) / 2, y: 100, width: 300, height: 400)

    }
    
    
    func addViews() {
        
        searchMode = "roundtrip"
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                rankedPotentialTripsDictionary = rankedPotentialTripsDictionaryFromSingleton as! [Dictionary<String, AnyObject>]
                for i in 0 ... rankedPotentialTripsDictionary.count - 1 {
                    if rankedPotentialTripsDictionary[i]["destination"] as! String == (SavedPreferencesForTrip["destinationsForTrip"] as! [String])[0] {
                        rankedPotentialTripsDictionaryArrayIndex = i
                    }
                }
            }
        }
        
        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                rankedPotentialTripsDictionary = rankedPotentialTripsDictionaryFromSingleton as! [Dictionary<String, AnyObject>]
                if let thisTripDict = rankedPotentialTripsDictionaryFromSingleton[rankedPotentialTripsDictionaryArrayIndex!] as? Dictionary<String, AnyObject> {
                    if let thisTripFlightResults = thisTripDict["flightOptions"] {
                        if thisTripFlightResults.count > 1 {
                            rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex!]["flightOptions"] = thisTripFlightResults
                        } else {
                            //Load from server
                            var flightOptionsDictionaryFromServer = [["departureDepartureTime":"1:00a","departureOrigin":"JFK","departureArrivalTime":"2:00a","departureDestination":"AAA","returnDepartureTime":"1:00a","returnOrigin":"JFK","returnArrivalTime":"2:00a","returnDestination":"MIA","totalPrice":"$1,000"],["departureDepartureTime":"2:00a","departureOrigin":"JFK","departureArrivalTime":"3:00a","departureDestination":"BBB","returnDepartureTime":"2:00a","returnOrigin":"JFK","returnArrivalTime":"3:00a","returnDestination":"MIA","totalPrice":"$1,100"],["departureDepartureTime":"3:00a","departureOrigin":"JFK","departureArrivalTime":"4:00a","departureDestination":"CCC","returnDepartureTime":"3:00a","returnOrigin":"JFK","returnArrivalTime":"4:00a","returnDestination":"MIA","totalPrice":"$1,200"],["departureDepartureTime":"4:00a","departureOrigin":"JFK","departureArrivalTime":"5:00a","departureDestination":"DDD","returnDepartureTime":"4:00a","returnOrigin":"JFK","returnArrivalTime":"5:00a","returnDestination":"MIA","totalPrice":"$1,300"],["departureDepartureTime":"5:00a","departureOrigin":"JFK","departureArrivalTime":"6:00a","departureDestination":"EEE","returnDepartureTime":"5:00a","returnOrigin":"JFK","returnArrivalTime":"6:00a","returnDestination":"MIA","totalPrice":"$1,400"],["departureDepartureTime":"6:00a","departureOrigin":"JFK","departureArrivalTime":"7:00a","departureDestination":"FFF","returnDepartureTime":"6:00a","returnOrigin":"JFK","returnArrivalTime":"7:00a","returnDestination":"MIA","totalPrice":"$1,500"],["departureDepartureTime":"7:00a","departureOrigin":"JFK","departureArrivalTime":"8:00a","departureDestination":"GGG","returnDepartureTime":"7:00a","returnOrigin":"JFK","returnArrivalTime":"8:00a","returnDestination":"MIA","totalPrice":"$1,600"],["departureDepartureTime":"8:00a","departureOrigin":"JFK","departureArrivalTime":"9:00a","departureDestination":"HHH","returnDepartureTime":"8:00a","returnOrigin":"JFK","returnArrivalTime":"9:00a","returnDestination":"MIA","totalPrice":"$1,700"]]
                            
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
        searchSummaryTitle.text = "\(homeAirportValue) - \(String(describing: rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex!]["destination"] as! String)) \(String(describing: searchMode!))"
        
        self.sortFilterFlightsCalloutView.delegate = self
        self.sortFilterFlightsCalloutView.isHidden = true
        
        sortFilterFlightsCalloutTableView.delegate = self
        sortFilterFlightsCalloutTableView.dataSource = self
        sortFilterFlightsCalloutTableView.frame = CGRect(x: 0, y: 121, width: 100, height: 100)
        sortFilterFlightsCalloutTableView.isEditing = false
        sortFilterFlightsCalloutTableView.allowsMultipleSelection = false
        sortFilterFlightsCalloutTableView.backgroundColor = UIColor.clear
        sortFilterFlightsCalloutTableView.layer.backgroundColor = UIColor.clear.cgColor
        sortButton.addTarget(self, action: #selector(self.sortButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
        filterButton.addTarget(self, action: #selector(self.filterButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
        
        //Set up table
        flightResultsTableView = UITableView(frame: CGRect.zero, style: .grouped)
        flightResultsTableView?.tableFooterView = UIView()
        flightResultsTableView?.separatorColor = UIColor.white
        flightResultsTableView?.register(UINib(nibName: "flightSearchResultTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "flightSearchResultTableViewCell")
        flightResultsTableView?.register(flightSearchResultTableViewCell.self, forCellReuseIdentifier: "flightSearchResultTableViewCell")
//        destinationsSwipedRightTableView?.register(destinationsSwipedRightTableViewCell.self, forCellReuseIdentifier: "destinationsSwipedRightTableViewCell")

        flightResultsTableView?.delegate = self
        flightResultsTableView?.dataSource = self
        flightResultsTableView?.backgroundColor = UIColor.clear
        flightResultsTableView?.layer.backgroundColor = UIColor.clear.cgColor
        flightResultsTableView?.allowsSelection = true
        flightResultsTableView?.backgroundView = nil
        flightResultsTableView?.isOpaque = false
        self.addSubview(flightResultsTableView!)
    }
    
    // MARK: UITableviewdelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == flightResultsTableView {
            return 1
        }
        // else if tableView == sortFilterFlightsCalloutTableView
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == flightResultsTableView {
            if section == 0 {
                return 1
            }
            // if section == 1
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "flightSearchResultTableViewCell", for: indexPath) as! flightSearchResultTableViewCell
            cell.selectionStyle = .none
            
//            if cell == nil {
//                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cellID")
//            }

            
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
            
//            if indexPath == IndexPath(row: 0, section: 0) {
//                cell.backgroundColor = UIColor.blue
//            } else {
//                cell.backgroundColor = UIColor.clear
//            }
            
            var flightsForRow = flightResultsDictionary[0]
            
            
            var addedRow = indexPath.row + 1
            if indexPath.section == 1 {
                flightsForRow = flightResultsDictionary[addedRow]
                addedRow += 1
            }
            
//            cell.departureOrigin.text = flightsForRow["departureOrigin"] as? String
//            cell.departureDestination.text = flightsForRow["departureDestination"] as? String
//            cell.departureDepartureTime.text = flightsForRow["departureDepartureTime"] as? String
//            cell.departureArrivalTime.text = flightsForRow["departureArrivalTime"] as? String
//            cell.returnDepartureTime.text = flightsForRow["returnDepartureTime"] as? String
//            cell.returnOrigin.text = flightsForRow["returnOrigin"] as? String
//            cell.returnArrivalTime.text = flightsForRow["returnArrivalTime"] as? String
//            cell.returnDestination.text = flightsForRow["returnDestination"] as? String
//            cell.totalPrice.text = flightsForRow["totalPrice"] as? String
            
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
        if tableView == flightResultsTableView {
            if selectedIndex == indexPath {
                selectedIndex = IndexPath(row: 0, section: 0)
            } else {
                selectedIndex = indexPath
            }
            self.flightResultsTableView?.beginUpdates()
            self.flightResultsTableView?.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            self.flightResultsTableView?.endUpdates()
        } else if tableView == sortFilterFlightsCalloutTableView {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.sortFilterFlightsCalloutView.dismissCallout(animated: true)
                self.sortFilterFlightsCalloutView.isHidden = true
                //HANDLE SORT / FILTER SELECTION
            })
        }
    }
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//    }
    
//    // MARK: moving rows
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .none
//    }
//    
//    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
    
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
    
    // MARK: Table Section Headers
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
//            let header = UIView(frame: CGRect(x: 0, y: 0, width: (flightResultsTableView?.bounds.size.width)!, height: 30))
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
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if tableView == flightResultsTableView {
//            return 30
//        }
//        return CGFloat.leastNormalMagnitude
//    }
//    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return CGFloat.leastNormalMagnitude
//    }
    
    // MARK: Actions
    func filterButtonClicked(sender:UIButton) {
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
            self.sortFilterFlightsCalloutView.presentCallout(from: calloutRect, in: self, constrainedTo: self, animated: true)
            
        } else {
            self.sortFilterFlightsCalloutView.dismissCallout(animated: true)
            self.sortFilterFlightsCalloutView.isHidden = true
        }
    }
    func sortButtonClicked(sender:UIButton) {
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
            self.sortFilterFlightsCalloutView.presentCallout(from: calloutRect, in: self, constrainedTo: self, animated: true)
            
        } else {
            self.sortFilterFlightsCalloutView.dismissCallout(animated: true)
            self.sortFilterFlightsCalloutView.isHidden = true
        }
    }

}
