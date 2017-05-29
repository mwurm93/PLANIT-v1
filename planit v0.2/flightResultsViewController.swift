//
//  flightResultsViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/15/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import SMCalloutView

class flightResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SMCalloutViewDelegate {
    
    //MARK: Class vars
    //Load flight results from server
    var flightResultsDictionary = [["departureDepartureTime":"12:00a","departureOrigin":"JFK","departureArrivalTime":"12:00","departureDestination":"AAA","returnDepartureTime":"12:00a","returnOrigin":"JFK","returnArrivalTime":"12:00","returnDestination":"MIA","totalPrice":"8,888"],["departureDepartureTime":"12:00a","departureOrigin":"JFK","departureArrivalTime":"12:00","departureDestination":"BBB","returnDepartureTime":"12:00a","returnOrigin":"JFK","returnArrivalTime":"12:00","returnDestination":"MIA","totalPrice":"8,888"],["departureDepartureTime":"12:00a","departureOrigin":"JFK","departureArrivalTime":"12:00","departureDestination":"CCC","returnDepartureTime":"12:00a","returnOrigin":"JFK","returnArrivalTime":"12:00","returnDestination":"MIA","totalPrice":"8,888"],["departureDepartureTime":"12:00a","departureOrigin":"JFK","departureArrivalTime":"12:00","departureDestination":"DDD","returnDepartureTime":"12:00a","returnOrigin":"JFK","returnArrivalTime":"12:00","returnDestination":"MIA","totalPrice":"8,888"],["departureDepartureTime":"12:00a","departureOrigin":"JFK","departureArrivalTime":"12:00","departureDestination":"EEE","returnDepartureTime":"12:00a","returnOrigin":"JFK","returnArrivalTime":"12:00","returnDestination":"MIA","totalPrice":"8,888"],["departureDepartureTime":"12:00a","departureOrigin":"JFK","departureArrivalTime":"12:00","departureDestination":"FFF","returnDepartureTime":"12:00a","returnOrigin":"JFK","returnArrivalTime":"12:00","returnDestination":"MIA","totalPrice":"8,888"],["departureDepartureTime":"12:00a","departureOrigin":"JFK","departureArrivalTime":"12:00","departureDestination":"GGG","returnDepartureTime":"12:00a","returnOrigin":"JFK","returnArrivalTime":"12:00","returnDestination":"MIA","totalPrice":"8,888"],["departureDepartureTime":"12:00a","departureOrigin":"JFK","departureArrivalTime":"12:00","departureDestination":"HHH","returnDepartureTime":"12:00a","returnOrigin":"JFK","returnArrivalTime":"12:00","returnDestination":"MIA","totalPrice":"8,888"]]
    var selectedIndex = IndexPath(row: 0, section: 0)
    var sectionTitles = ["Selected flight", "Alternatives"]
    var sortFilterFlightsCalloutView = SMCalloutView()
    let sortFilterFlightsCalloutTableView = UITableView(frame: CGRect.zero, style: .plain)

    var calloutTableViewMode = "sort"
    let sortFirstLevelOptions = ["Price","Duration","Landing Time", "Departure Time"]
    let filterFirstLevelOptions = ["Stops","Airlines"]
    
    //MARK: Outlets
    @IBOutlet weak var flightResultsTableView: UITableView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        flightResultsTableView.isEditing = true
        flightResultsTableView.allowsSelectionDuringEditing = true
        flightResultsTableView.separatorColor = UIColor.white

    }
    
    // MARK: UITableviewdelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == flightResultsTableView {
            return 2
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "flightSearchResultTableViewPrototypeCell", for: indexPath) as! flightSearchResultTableViewCell
            cell.selectionStyle = .none
            
            //Change hamburger icon
            for view in cell.subviews as [UIView] {
                if type(of: view).description().range(of: "Reorder") != nil {
                    for subview in view.subviews as! [UIImageView] {
                        if subview.isKind(of: UIImageView.self) {
                            subview.image = UIImage(named: "hamburger")
                        }
                    }
                }
            }
            
            if indexPath == IndexPath(row: 0, section: 0) {
                cell.backgroundColor = UIColor.blue
            } else {
                cell.backgroundColor = UIColor.clear
            }
            
            var flightsForRow = flightResultsDictionary[0]
            
            
            var addedRow = indexPath.row + 1
            if indexPath.section == 1 {
                flightsForRow = flightResultsDictionary[addedRow]
                addedRow += 1
            }
            
            cell.departureOrigin.text = flightsForRow["departureOrigin"]
            cell.departureDestination.text = flightsForRow["departureDestination"]
            cell.departureDepartureTime.text = flightsForRow["departureDepartureTime"]
            cell.departureArrivalTime.text = flightsForRow["departureArrivalTime"]
            cell.returnDepartureTime.text = flightsForRow["returnDepartureTime"]
            cell.returnOrigin.text = flightsForRow["returnOrigin"]
            cell.returnArrivalTime.text = flightsForRow["returnArrivalTime"]
            cell.returnDestination.text = flightsForRow["returnDestination"]
            cell.totalPrice.text = flightsForRow["totalPrice"]
            
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
        if tableView == flightResultsTableView {
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
            let movedRowDictionary = flightResultsDictionary[sourceIndexPath.row + 1]
            flightResultsDictionary.remove(at: sourceIndexPath.row + 1)
            flightResultsDictionary.insert(movedRowDictionary, at: 0)
        } else if sourceIndexPath == IndexPath(row: 0, section: 0) {
            let movedRowDictionary = flightResultsDictionary[sourceIndexPath.row]
            flightResultsDictionary.remove(at: sourceIndexPath.row)
            flightResultsDictionary.insert(movedRowDictionary, at: destinationIndexPath.row)
        } else {
            let movedRowDictionary = flightResultsDictionary[sourceIndexPath.row + 1]
            flightResultsDictionary.remove(at: sourceIndexPath.row + 1)
            flightResultsDictionary.insert(movedRowDictionary, at: destinationIndexPath.row + 1)
        }
        tableView.reloadData()
    }
    
    // MARK: Table Section Headers
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == flightResultsTableView {
            return sectionTitles[section]
        }
        // else if tableView == sortFilterFlightsCalloutTableView
        return nil
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if tableView == flightResultsTableView {
            let header = UIView(frame: CGRect(x: 0, y: 0, width: flightResultsTableView.bounds.size.width, height: 30))
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
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == flightResultsTableView {
            return 30
        }
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    //MARK: Actions
    @IBAction func filterFlightsButtonTouchedUpInside(_ sender: Any) {
        if self.sortFilterFlightsCalloutView.isHidden == true || (self.sortFilterFlightsCalloutView.isHidden == false && calloutTableViewMode == "sort") {
            calloutTableViewMode = "filter"
            sortFilterFlightsCalloutTableView.frame = CGRect(x: 0, y: 121, width: 100, height: 22 * filterFirstLevelOptions.count)
            sortFilterFlightsCalloutTableView.reloadData()
            self.sortFilterFlightsCalloutView.contentView = sortFilterFlightsCalloutTableView
            self.sortFilterFlightsCalloutView.isHidden = false
            self.sortFilterFlightsCalloutView.animation(withType: .stretch, presenting: true)
            self.sortFilterFlightsCalloutView.permittedArrowDirection = .up
            var calloutRect: CGRect = CGRect.zero
            calloutRect.origin = CGPoint(x: filterButton.frame.midX, y: CGFloat(59))
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
            calloutRect.origin = CGPoint(x: sortButton.frame.midX, y: CGFloat(59))
            self.sortFilterFlightsCalloutView.presentCallout(from: calloutRect, in: self.view, constrainedTo: self.view, animated: true)
            
        } else {
            self.sortFilterFlightsCalloutView.dismissCallout(animated: true)
            self.sortFilterFlightsCalloutView.isHidden = true
        }
    }
}
