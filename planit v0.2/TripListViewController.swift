//
//  TripList.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/11/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import GooglePlaces

//FIREBASEDISABLED
//import Firebase

class TripListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var existingTripsTable: UITableView!
    @IBOutlet weak var createTripButton: UIButton!
    @IBOutlet weak var addAnotherTripButton: UIButton!
    @IBOutlet weak var myTripsTitleLabel: UILabel!
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var backgroundBlurFilterView: UIVisualEffectView!
    @IBOutlet weak var goToBucketListButton: UIButton!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var welcomeToPlanitLabel: UILabel!
    
    //FIREBASEDISABLED
//    //Firebase channels
//    private var channelRefHandle: DatabaseHandle?
//    private var channels: [Channel] = []
//    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
    
    //Class vars
    var formatter = DateFormatter()

    
    //Times VC viewed
//    var timesViewedNonTrip = [String: Int]()
    
//    let sectionTitles = ["Still in the works...", "Booked"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        timesViewedNonTrip = DataContainerSingleton.sharedDataContainer.timesViewedNonTrip as? [String : Int] ?? ["settings":0, "bucketList":0, "tripList":0]
        
        //FIREBASEDISABLED
//        observeChannels()
        
        view.autoresizingMask = .flexibleTopMargin
        view.sizeToFit()
        
        if DataContainerSingleton.sharedDataContainer.usertrippreferences == nil || DataContainerSingleton.sharedDataContainer.usertrippreferences?.count == 0 {
            
            DataContainerSingleton.sharedDataContainer.currenttrip = 0
            
            myTripsTitleLabel.isHidden = true
            existingTripsTable.isHidden = true
            addAnotherTripButton.isHidden = true
            goToBucketListButton.isHidden = true
            
            setUpCreateTripButton()
            
        }
        else {
            existingTripsTable.isHidden = false
            existingTripsTable.tableFooterView = UIView()
            existingTripsTable.layer.cornerRadius = 5
            
            setUpAddAnotherTripButton()
            addAnotherTripButton.isHidden = false
            goToBucketListButton.isHidden = false
            
            createTripButton.isHidden = true
        }
        
        self.existingTripsTable.tableHeaderView = nil
        self.existingTripsTable.tableFooterView = nil

        
//        if timesViewedNonTrip["tripList"] == 0 {
//            
//                let currentTimesViewed = self.timesViewedNonTrip["tripList"]
//                self.timesViewedNonTrip["tripList"]! = currentTimesViewed! + 1
//                DataContainerSingleton.sharedDataContainer.timesViewedNonTrip = self.timesViewedNonTrip as NSDictionary
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reorderTripsChronologically()
    }
    
    func setUpCreateTripButton() {
        let bounds = UIScreen.main.bounds
        createTripButton.setTitleColor(UIColor.white, for: .normal)
        createTripButton.setBackgroundColor(color: UIColor.clear, forState: .normal)
        createTripButton.setTitleColor(UIColor.white, for: .selected)
        createTripButton.setBackgroundColor(color: UIColor.blue, forState: .selected)
        createTripButton.layer.borderWidth = 1
        createTripButton.layer.borderColor = UIColor.white.cgColor
        createTripButton.setTitle("Plan a trip!", for: .normal)
        createTripButton.setTitle("Plan a trip!", for: .selected)
        createTripButton?.sizeToFit()
        createTripButton?.frame.size.height = 50
        createTripButton?.frame.size.width += 30
        createTripButton?.frame.origin.x = (bounds.size.width - (createTripButton?.frame.width)!) / 2
        createTripButton?.frame.origin.y = (bounds.size.height - (createTripButton?.frame.height)!) / 2
        createTripButton?.layer.cornerRadius = (createTripButton?.frame.height)! / 2
        createTripButton.isHidden = false
    }
    
    func setUpAddAnotherTripButton() {
        let bounds = UIScreen.main.bounds
        addAnotherTripButton.setTitleColor(UIColor.white, for: .normal)
        addAnotherTripButton.setBackgroundColor(color: UIColor.clear, forState: .normal)
        addAnotherTripButton.setTitleColor(UIColor.white, for: .selected)
        addAnotherTripButton.setBackgroundColor(color: UIColor.blue, forState: .selected)
        addAnotherTripButton.layer.borderWidth = 1
        addAnotherTripButton.layer.borderColor = UIColor.white.cgColor
        addAnotherTripButton.setTitle("Plan a trip!", for: .normal)
        addAnotherTripButton.setTitle("Plan a trip!", for: .selected)
        addAnotherTripButton?.sizeToFit()
        addAnotherTripButton?.frame.size.height = 30
        addAnotherTripButton?.frame.size.width += 30
        addAnotherTripButton?.frame.origin.x = bounds.size.width - (addAnotherTripButton?.frame.width)! - 18
        addAnotherTripButton?.frame.origin.y = 30
        addAnotherTripButton?.layer.cornerRadius = (addAnotherTripButton?.frame.height)! / 2
        addAnotherTripButton.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Actions
    @IBAction func addTrip(_ sender: Any) {
        DataContainerSingleton.sharedDataContainer.currenttrip = DataContainerSingleton.sharedDataContainer.currenttrip! + 1
        self.performSegue(withIdentifier: "tripListToTripViewController", sender: self)
    }
    
    @IBAction func createFirstTripButtonTouchedUpInside(_ sender: Any) {
        DataContainerSingleton.sharedDataContainer.currenttrip = 0
    }
    
    // # sections in table
    func numberOfSections(in tableView: UITableView) -> Int {
        let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        if existing_trips == nil {
            return 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let userTripPreferences = DataContainerSingleton.sharedDataContainer.usertrippreferences
        if userTripPreferences != nil {                        
            let countTripsTotal = userTripPreferences?.count
            return countTripsTotal!
        }
        return 0
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "existingTripViewPrototypeCell", for: indexPath) as! ExistingTripTableViewCell
        
        if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil {
            
            //Cell styling
            cell.tripBackgroundView.layer.cornerRadius = 5
//            cell.tripBackgroundView.layer.borderWidth = 2
//            cell.tripBackgroundView.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:1).cgColor
            cell.tripBackgroundView.layer.masksToBounds = true
            let tripName = DataContainerSingleton.sharedDataContainer.usertrippreferences?[indexPath.row].object(forKey: "trip_name") as? String
            cell.tripNameLabel.adjustsFontSizeToFitWidth = true
            cell.destinationsLabel.adjustsFontSizeToFitWidth = true
            
            //Trip name
            cell.existingTripTableViewLabel.text = tripName
            cell.existingTripTableViewLabel.numberOfLines = 0
            cell.existingTripTableViewLabel.adjustsFontSizeToFitWidth = true
            cell.existingTripTableViewLabel.isHidden = true
            existingTripsTable.isHidden = false
            
            //Dates
            let tripDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[indexPath.row].object(forKey: "selected_dates") as? [Date]
            if tripDates != nil {
                if (tripDates?.count)! > 2 {
                    cell.tripStartDateLabel.isHidden = false
                    cell.tripEndDateLabel.isHidden = false
                    cell.toLabel.isHidden = false
                    
                    formatter.dateFormat = "MMM d"
                    cell.tripStartDateLabel.text = formatter.string(from: (tripDates?[0])!)
                    cell.tripEndDateLabel.text = formatter.string(from: (tripDates?[(tripDates?.count)! - 1])!)
                } else if (tripDates?.count)! == 1 {
                    cell.tripStartDateLabel.isHidden = false
                    cell.tripEndDateLabel.isHidden = false
                    cell.toLabel.isHidden = false
                    formatter.dateFormat = "MMM d"
                    cell.tripStartDateLabel.text = formatter.string(from: (tripDates?[0])!)
                    cell.tripEndDateLabel.text = "TBD"
                } else {
                    cell.tripStartDateLabel.isHidden = false
                    cell.tripEndDateLabel.isHidden = false
                    cell.toLabel.isHidden = false
                    cell.tripStartDateLabel.text = "TBD"
                    cell.tripEndDateLabel.text = "TBD"
                }
            } else {
                cell.tripStartDateLabel.isHidden = false
                cell.tripEndDateLabel.isHidden = false
                cell.toLabel.isHidden = false
                cell.tripStartDateLabel.text = "TBD"
                cell.tripEndDateLabel.text = "TBD"
            }
            
            //Destinations and trip name
            let destinationsForTrip = DataContainerSingleton.sharedDataContainer.usertrippreferences?[indexPath.row].object(forKey: "destinationsForTrip") as? [String]
            var destinationsString = String()
            
            if destinationsForTrip != nil {
                if (destinationsForTrip?.count)! > 0 {
                    cell.destinationsLabel.isHidden = false
                    if destinationsForTrip?.count == 1 {
                        cell.destinationsLabel.text = destinationsForTrip?[0]
                    } else if (destinationsForTrip?.count)! > 1 {
                        for i in 0 ... (destinationsForTrip?.count)! - 2 {
                            destinationsString.append((destinationsForTrip?[i])!)
                            if i + 1 == (destinationsForTrip?.count)! - 1 {
                                destinationsString.append(" and ")
                            } else {
                                destinationsString.append(", ")
                            }
                        }
                        destinationsString.append((destinationsForTrip?[(destinationsForTrip?.count)! - 1])!)
                        if destinationsForTrip?.count == 2 {
                            destinationsString = "\((destinationsForTrip?[0])!) and \((destinationsForTrip?[1])!)"
                        }
                        cell.destinationsLabel.text = destinationsString
                    }
                    
                    cell.tripNameLabel.isHidden = false
                    if (tripName?.contains(" started "))! {
                        //trip name is not custom...
                        cell.tripNameLabel.text = "Trip to"
                    } else {
                        cell.tripNameLabel.text = tripName
                    }
                } else {
                    cell.destinationsLabel.isHidden = false
                    cell.destinationsLabel.text = "Destination TBD"
                    cell.tripNameLabel.text = tripName
                }
            } else {
                cell.destinationsLabel.isHidden = false
                cell.destinationsLabel.text = "Destination TBD"
                cell.tripNameLabel.text = tripName
            }

            
            return cell
        }
        existingTripsTable.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //FIREBASEDISABLED
//        if indexPath.row > channels.count - 1 {
//            return
//        } else {
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as! ExistingTripTableViewCell
            let searchForTitle = cell.existingTripTableViewLabel.text

        //FIREBASEDISABLED
//            let channel = channels[(indexPath as NSIndexPath).row]
//            channelRef = channelRef.child(channel.id)
        
            for trip in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
                
                if DataContainerSingleton.sharedDataContainer.usertrippreferences?[trip].object(forKey: "trip_name") as? String == searchForTitle {
                    DataContainerSingleton.sharedDataContainer.currenttrip = trip
                }
            }
            
        //FIREBASEDISABLED
//            super.performSegue(withIdentifier: "tripListToTripViewController", sender: channel)
        super.performSegue(withIdentifier: "tripListToTripViewController", sender: self)
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addTripDestinationUndecided" {
            let destination = segue.destination as? NewTripNameViewController
            
            var NewOrAddedTripForSegue = Int()
            
            let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
            let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
            var numberSavedTrips: Int?
            if existing_trips == nil {
                numberSavedTrips = 0
                NewOrAddedTripForSegue = 1
            } else {
                numberSavedTrips = (existing_trips?.count)! - 1
                if currentTripIndex <= numberSavedTrips! {
                    NewOrAddedTripForSegue = 0
                } else {
                    NewOrAddedTripForSegue = 1
                }
            }
            destination?.NewOrAddedTripFromSegue = NewOrAddedTripForSegue
            //FIREBASEDISABLED
//            destination?.newChannelRef = channelRef
        }
        if segue.identifier == "tripListToTripViewController" {
//            let navVC = segue.destination as? UINavigationController
//            
//            let destination = navVC?.viewControllers.first as? TripViewController
//
            
            let destination = segue.destination as? TripViewController
            
            var NewOrAddedTripForSegue = Int()
            
            let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
            let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
            var numberSavedTrips: Int?
            if existing_trips == nil {
                numberSavedTrips = 0
                NewOrAddedTripForSegue = 1
            } else {
                numberSavedTrips = (existing_trips?.count)! - 1
                if currentTripIndex <= numberSavedTrips! {
                    NewOrAddedTripForSegue = 0
                } else {
                    NewOrAddedTripForSegue = 1
                }
            }
            destination?.NewOrAddedTripFromSegue = NewOrAddedTripForSegue
            //FIREBASEDISABLED
//            destination?.newChannelRef = channelRef
            destination?.isTripSpawnedFromBucketList = 0
        }

        
    }

    //FIREBASEDISABLED

//    private func observeChannels() {
//        // We can use the observe method to listen for new
//        // channels being written to the Firebase DB
//        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in
//            let channelData = snapshot.value as! Dictionary<String, AnyObject>
//            let id = snapshot.key
//            if let name = channelData["name"] as! String!, name.characters.count > 0 {
//                self.channels.append(Channel(id: id, name: name))
//            } else {
//                print("Error! Could not decode channel data")
//            }
//        })
//    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            self.existingTripsTable.rowHeight = 90


            let cell = tableView.cellForRow(at: indexPath as IndexPath) as! ExistingTripTableViewCell
            let searchForTitle = cell.existingTripTableViewLabel.text
            
            for trip in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
                if DataContainerSingleton.sharedDataContainer.usertrippreferences?[trip].object(forKey: "trip_name") as? String == searchForTitle {
                    
                    //Remove from data model
                    DataContainerSingleton.sharedDataContainer.usertrippreferences?.remove(at: trip)
                    
                    //Remove from table
                    existingTripsTable.beginUpdates()
                    existingTripsTable.deleteRows(at: [indexPath], with: .left)
            
                    existingTripsTable.endUpdates()

                    if (DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! == 0 {
                        myTripsTitleLabel.isHidden = true
                        existingTripsTable.isHidden = true
                        addAnotherTripButton.isHidden = true
                        goToBucketListButton.isHidden = true
                        
                        
                        setUpCreateTripButton()
                        createTripButton.isHidden = false
                    }
                    //Return if delete cell trip name found
                    return
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Leave trip"
    }
    
    //MARK: Custom functions
    func reorderTripsChronologically() {
        var unsortedTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        var sortedTrips = [Dictionary<String, Any>]()
        var tripsWithoutDates = [Dictionary<String, Any>]()
        if unsortedTrips != nil {
            //Take out trips without dates planned
            if (unsortedTrips?.count)! > 1 {
                for i in (0 ... (unsortedTrips?.count)! - 1).reversed() {
                    let tripDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[i].object(forKey: "selected_dates") as? [Date]
                    if tripDates == nil {
                        tripsWithoutDates.append(unsortedTrips?[i] as! [String : Any])
                        unsortedTrips?.remove(at: i)
                    } else {
                        if (tripDates?.count)! == 0 {
                            tripsWithoutDates.append(unsortedTrips?[i] as! [String : Any])
                            unsortedTrips?.remove(at: i)
                        }
                    }
                }
            } else {
                return
            }
            //Reorder trips with dates planned
            if (unsortedTrips?.count)! > 1 {
                sortedTrips = unsortedTrips?.sorted(by: { ($0["selected_dates"] as? [Date])?[0].compare((($1["selected_dates"] as? [Date])?[0])!) == .orderedAscending }) as! [Dictionary<String, Any>]
            } else if (unsortedTrips?.count)! == 1{
                sortedTrips.append((unsortedTrips?[0]) as! Dictionary<String, Any>)
            }
            //Add back trips without dates planned at top
            if tripsWithoutDates.count > 0 {
                for i in 0 ... tripsWithoutDates.count - 1 {
                    sortedTrips.insert(tripsWithoutDates[i], at: 0)
                }
            }
            //Update datasource //Save to singleton
            DataContainerSingleton.sharedDataContainer.usertrippreferences = sortedTrips as [NSDictionary]
            //Reload table
            existingTripsTable.reloadData()
            
        }

    }
}
