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
    var flightResultsDictionary = [[String:String]()]
    
    //MARK: Outlets
    @IBOutlet weak var flightResultsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.flightResultsTableView.layer.cornerRadius = 5
        let FirstRow = IndexPath(row: 0, section: 0)
        flightResultsTableView.selectRow(at: FirstRow, animated: false, scrollPosition: UITableViewScrollPosition.none)
        flightResultsTableView.cellForRow(at: FirstRow)?.contentView.backgroundColor = UIColor.blue
        
        //Load flight results from server
        flightResultsDictionary = [["departureDepartureTime":"12:00a","departureOrigin":"JFK","departureArrivalTime":"12:00","departureDestination":"MIA","returnDepartureTime":"12:00a","returnOrigin":"JFK","returnArrivalTime":"12:00","returnDestination":"MIA","totalPrice":"8,888"]]
    }
    
    // MARK: UITableviewdelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = flightResultsDictionary.count
        return numberOfRows
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "flightSearchResultTableViewCell", for: indexPath) as! flightSearchResultTableViewCell
        
        var addedRow = indexPath.row
        if indexPath.section == 1 {
            addedRow += 1
        }
        
        let flightsForRow = flightResultsDictionary[addedRow]
        
        ///NEXT WORK HEREEEE
        cell.departureOrigin.text = flightsForRow["departureOrigin"]
        cell.layer.cornerRadius = 10
        cell.contentView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.contentView.backgroundColor = UIColor.blue
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deSelectedCell = tableView.cellForRow(at: indexPath)
        deSelectedCell?.contentView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
    }

}
