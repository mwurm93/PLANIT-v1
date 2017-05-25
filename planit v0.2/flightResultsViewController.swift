//
//  flightResultsViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/15/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class flightResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Class vars
    //Load flight results from server
    var flightResultsDictionary = [["departureDepartureTime":"12:00a","departureOrigin":"JFK","departureArrivalTime":"12:00","departureDestination":"AAA","returnDepartureTime":"12:00a","returnOrigin":"JFK","returnArrivalTime":"12:00","returnDestination":"MIA","totalPrice":"8,888"],["departureDepartureTime":"12:00a","departureOrigin":"JFK","departureArrivalTime":"12:00","departureDestination":"BBB","returnDepartureTime":"12:00a","returnOrigin":"JFK","returnArrivalTime":"12:00","returnDestination":"MIA","totalPrice":"8,888"],["departureDepartureTime":"12:00a","departureOrigin":"JFK","departureArrivalTime":"12:00","departureDestination":"CCC","returnDepartureTime":"12:00a","returnOrigin":"JFK","returnArrivalTime":"12:00","returnDestination":"MIA","totalPrice":"8,888"],["departureDepartureTime":"12:00a","departureOrigin":"JFK","departureArrivalTime":"12:00","departureDestination":"DDD","returnDepartureTime":"12:00a","returnOrigin":"JFK","returnArrivalTime":"12:00","returnDestination":"MIA","totalPrice":"8,888"],["departureDepartureTime":"12:00a","departureOrigin":"JFK","departureArrivalTime":"12:00","departureDestination":"EEE","returnDepartureTime":"12:00a","returnOrigin":"JFK","returnArrivalTime":"12:00","returnDestination":"MIA","totalPrice":"8,888"],["departureDepartureTime":"12:00a","departureOrigin":"JFK","departureArrivalTime":"12:00","departureDestination":"FFF","returnDepartureTime":"12:00a","returnOrigin":"JFK","returnArrivalTime":"12:00","returnDestination":"MIA","totalPrice":"8,888"],["departureDepartureTime":"12:00a","departureOrigin":"JFK","departureArrivalTime":"12:00","departureDestination":"GGG","returnDepartureTime":"12:00a","returnOrigin":"JFK","returnArrivalTime":"12:00","returnDestination":"MIA","totalPrice":"8,888"],["departureDepartureTime":"12:00a","departureOrigin":"JFK","departureArrivalTime":"12:00","departureDestination":"HHH","returnDepartureTime":"12:00a","returnOrigin":"JFK","returnArrivalTime":"12:00","returnDestination":"MIA","totalPrice":"8,888"]]
    var selectedIndex = IndexPath(row: 0, section: 0)
    var sectionTitles = ["Selected flight", "Alternatives"]
    
    //MARK: Outlets
    @IBOutlet weak var flightResultsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up table
        flightResultsTableView.tableFooterView = UIView()
        flightResultsTableView.isEditing = true
        flightResultsTableView.allowsSelectionDuringEditing = true
        flightResultsTableView.separatorColor = UIColor.white

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
        let numberOfRows = flightResultsDictionary.count
        return numberOfRows - 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (selectedIndex == indexPath) {
            return 104
        } else {
            return 52
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if selectedIndex == indexPath {
            selectedIndex = IndexPath(row: 0, section: 0)
        } else {
            selectedIndex = indexPath
        }
        
//        if indexPath != IndexPath(row: 0, section: 0) {
            self.flightResultsTableView.beginUpdates()
            self.flightResultsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            self.flightResultsTableView.endUpdates()
//        }
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
        return sectionTitles[section]
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
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

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
