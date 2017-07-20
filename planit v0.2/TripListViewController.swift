//
//  TripList.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/11/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import GooglePlaces
import Firebase

class TripListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
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
    
    //Firebase channels
    private var channelRefHandle: DatabaseHandle?
    private var channels: [Channel] = []
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
    
    //Times VC viewed
    var timesViewedNonTrip = [String: Int]()
    
    let sectionTitles = ["Still in the works...", "Booked"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timesViewedNonTrip = DataContainerSingleton.sharedDataContainer.timesViewedNonTrip as? [String : Int] ?? ["settings":0, "bucketList":0, "tripList":0]
        
        observeChannels()
        
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
        
        if timesViewedNonTrip["tripList"] == 0 {
            
                let currentTimesViewed = self.timesViewedNonTrip["tripList"]
                self.timesViewedNonTrip["tripList"]! = currentTimesViewed! + 1
                DataContainerSingleton.sharedDataContainer.timesViewedNonTrip = self.timesViewedNonTrip as NSDictionary
        }
    }
    
    func setUpCreateTripButton() {
        let bounds = UIScreen.main.bounds
        createTripButton.setTitleColor(UIColor.white, for: .normal)
        createTripButton.setBackgroundColor(color: UIColor.clear, forState: .normal)
        createTripButton.setTitleColor(UIColor.white, for: .selected)
        createTripButton.setBackgroundColor(color: UIColor.blue, forState: .selected)
        createTripButton.layer.borderWidth = 1
        createTripButton.layer.borderColor = UIColor.white.cgColor
        createTripButton.setTitle("Plan a trip", for: .normal)
        createTripButton.setTitle("Plan a trip", for: .selected)
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
        addAnotherTripButton.setTitle("Plan a trip", for: .normal)
        
        addAnotherTripButton.setTitle("Plan a trip", for: .selected)
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
        }
        else {
        return 2
        }
    }
    
    // Section Header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var bookingStatuses: [Int] = []
        
        if (DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! > 0 {
            for index in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
                let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[index].object(forKey: "booking_status") as? Int
                if bookingStatus != nil {
                    bookingStatuses.append(bookingStatus!)
                }
            }
            
            var countTripsBooked = 0
            var countTripsUnbooked = 0
            var countTripsTotal = 0
            
            if bookingStatuses != [] {
                for index in 0...(bookingStatuses.count - 1) {
                    countTripsBooked += bookingStatuses[index]
                }
            }
            
            if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && section == 1 && countTripsBooked > 0 {
                if countTripsBooked > 0 {
                    return sectionTitles[section]
                }
            }
            if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && section == 0 && bookingStatuses != [] {

                countTripsTotal = (DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)!
                
                countTripsUnbooked = countTripsTotal - countTripsBooked
                
                if countTripsUnbooked > 0 {
                    return sectionTitles[section]
                }
            }
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: existingTripsTable.bounds.size.width, height: 30))
        header.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        header.layer.cornerRadius = 5

        let title = UILabel()
        title.frame = header.frame
        title.textAlignment = .left
        title.font = UIFont.boldSystemFont(ofSize: 20)
        title.textColor = UIColor.white
        title.text = sectionTitles[section]
        header.addSubview(title)

        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! > 0 {

            var bookingStatuses: [Int] = []
            for index in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
                let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[index].object(forKey: "booking_status") as? Int
                if bookingStatus != nil {
                    bookingStatuses.append(bookingStatus!)
                }
            }
            
            var countTripsBooked = 0
            var countTripsUnbooked = 0
            var countTripsTotal = 0
            
            if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && section == 1 && bookingStatuses != [] {
                for index in 0...(bookingStatuses.count - 1) {
                    countTripsBooked += bookingStatuses[index]
                }
                return countTripsBooked
            }
            // else if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && section == 0 {
            if bookingStatuses != [] {
                for index in 0...(bookingStatuses.count - 1) {
                    countTripsBooked += bookingStatuses[index]
                }
            }
            countTripsTotal = (DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)!
            countTripsUnbooked = countTripsTotal - countTripsBooked
            
            return countTripsUnbooked
        
        }
        
        return 0
    }
    
    var lastUnbookedStatusIndexAddedToTable: Int?
    var lastBookedStatusIndexAddedToTable: Int?
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if lastUnbookedStatusIndexAddedToTable == nil {
            lastUnbookedStatusIndexAddedToTable = -1
        }
        if lastBookedStatusIndexAddedToTable == nil {
            lastBookedStatusIndexAddedToTable = -1
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "existingTripViewPrototypeCell", for: indexPath) as! ExistingTripTableViewCell
        
        var bookingStatuses: [Int] = []
        for index in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
            
            let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[index].object(forKey: "booking_status") as? Int
            if bookingStatus != nil {
            bookingStatuses.append(bookingStatus!)
            }
        }
        
        if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && indexPath.section == 0 && bookingStatuses != [] {
            for unbookedIndex in 0...(bookingStatuses.count - 1)  {
                if bookingStatuses[unbookedIndex] == 0 && unbookedIndex > lastUnbookedStatusIndexAddedToTable! {
                    let addedRowInUnbookedSection = unbookedIndex
                    cell.layer.cornerRadius = 10
                    cell.layer.borderWidth = 2
                    cell.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:1).cgColor
                    cell.layer.masksToBounds = true

                    cell.existingTripTableViewLabel.text = DataContainerSingleton.sharedDataContainer.usertrippreferences?[addedRowInUnbookedSection].object(forKey: "trip_name") as? String
                    existingTripsTable.isHidden = false
                    lastUnbookedStatusIndexAddedToTable = unbookedIndex
                    
                    return cell
                }
            }
        }
        else if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && indexPath.section == 1 && bookingStatuses != [] {
            for bookedIndex in 0...(bookingStatuses.count - 1)  {
                if bookingStatuses[bookedIndex] == 1 && bookedIndex > lastBookedStatusIndexAddedToTable!{
                    let addedRowInBookedSection = bookedIndex
                    cell.layer.cornerRadius = 5
                    cell.layer.borderWidth = 2
                    cell.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:1).cgColor
                    cell.layer.masksToBounds = true
                    cell.existingTripTableViewLabel.text = DataContainerSingleton.sharedDataContainer.usertrippreferences?[addedRowInBookedSection].object(forKey: "trip_name") as? String
                    existingTripsTable.isHidden = false
                    lastBookedStatusIndexAddedToTable = bookedIndex
                    
                    return cell
                }
            }
        }
        // if  == nil {
            existingTripsTable.isHidden = true
        
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > channels.count - 1 {
            return
        } else {
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as! ExistingTripTableViewCell
            let searchForTitle = cell.existingTripTableViewLabel.text
            
            let channel = channels[(indexPath as NSIndexPath).row]
            channelRef = channelRef.child(channel.id)
            
            for trip in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
                
                if DataContainerSingleton.sharedDataContainer.usertrippreferences?[trip].object(forKey: "trip_name") as? String == searchForTitle {
                    DataContainerSingleton.sharedDataContainer.currenttrip = trip
                }
            }
            super.performSegue(withIdentifier: "tripListToTripViewController", sender: channel)
        }
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
            destination?.newChannelRef = channelRef
        }
        if segue.identifier == "tripListToTripViewController" {
            let navVC = segue.destination as? UINavigationController
            
            let destination = navVC?.viewControllers.first as? TripViewController

            
//            let destination = segue.destination as? TripViewController
            
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
            destination?.newChannelRef = channelRef
        }

        
    }

    private func observeChannels() {
        // We can use the observe method to listen for new
        // channels being written to the Firebase DB
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in
            let channelData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            if let name = channelData["name"] as! String!, name.characters.count > 0 {
                self.channels.append(Channel(id: id, name: name))
            } else {
                print("Error! Could not decode channel data")
            }
        })
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
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
            
                    if existingTripsTable.numberOfRows(inSection: 0) == 0 && existingTripsTable.numberOfRows(inSection: 1) != 0{
                    //delete header
                    }
                    if existingTripsTable.numberOfRows(inSection: 0) != 0 && existingTripsTable.numberOfRows(inSection: 1) == 0{
                    //delete header
                    }
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
}
