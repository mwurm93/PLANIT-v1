//
//  LeftViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 8/17/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import DrawerController
import Firebase

class LeftViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    //FIREBASEDISABLED
    //Firebase channels
    private var channelRefHandle: DatabaseHandle?
    private var channels: [Channel] = []
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
    
    //MARK: Class vars
    var formatter = DateFormatter()
    
    //MARK: Outlets
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //FIREBASEDISABLED
        observeChannels()

        
        menuTableView.dataSource = self
        menuTableView.delegate = self
        var tableHeight = CGFloat()
        let userTripPreferences = DataContainerSingleton.sharedDataContainer.usertrippreferences
        updateMenuTableHeight()

        self.view.endEditing(true)


        self.navigationController?.isNavigationBarHidden = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        reorderTripsChronologically()
        menuTableView.reloadData()
        
        let firstNameValue = DataContainerSingleton.sharedDataContainer.firstName ?? ""
        if firstNameValue == "" {
            self.userNameLabel.text =  "New user"
        }
        else {
            self.userNameLabel.text =  "\(firstNameValue)"
        }        
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "leftViewControllerViewWillAppear"), object: nil)
        let when = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline: when) {
            UIApplication.shared.sendAction("resignFirstResponder", to:nil, from:nil, for:nil)
            self.view.endEditing(true)

        }
        
        var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer!.openDrawerGestureModeMask = OpenDrawerGestureMode.panningCenterView
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "leftViewControllerViewWillDisappear"), object: nil)
        UIApplication.shared.sendAction("resignFirstResponder", to:nil, from:nil, for:nil)
    }

    
    //MARK: TableView Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            let userTripPreferences = DataContainerSingleton.sharedDataContainer.usertrippreferences
            if userTripPreferences != nil {
                let countTripsTotal = userTripPreferences?.count
                return countTripsTotal!
            }
            return 0
        case 2:
            return 1
        case 3:
            return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        updateMenuTableHeight()
        let cell = tableView.dequeueReusableCell(withIdentifier: "existingTripViewPrototypeCell", for: indexPath) as! ExistingTripTableViewCell
        
        if indexPath.section == 0 {
            cell.tripStartDateLabel.isHidden = true
            cell.tripEndDateLabel.isHidden = true
            cell.toLabel.isHidden = true
            cell.destinationsLabel.isHidden = true
            cell.tripNameLabel.isHidden = true
            
            cell.menuItemLabel.isHidden = false
            cell.menuItemImageView.isHidden = false
            
            cell.menuItemImageView.image = #imageLiteral(resourceName: "addTripIcon")
            cell.menuItemLabel.text = "New Trip"

            return cell

        } else if indexPath.section == 1 {
            cell.menuItemLabel.isHidden = true
            cell.menuItemImageView.isHidden = true

            if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil {
                
                //Cell styling
//                cell.tripBackgroundView.layer.cornerRadius = 5
//                cell.tripBackgroundView.layer.masksToBounds = true
                let tripName = DataContainerSingleton.sharedDataContainer.usertrippreferences?[indexPath.row].object(forKey: "trip_name") as? String
                cell.tripNameLabel.adjustsFontSizeToFitWidth = true
                cell.destinationsLabel.adjustsFontSizeToFitWidth = true
                
                //Trip name
                cell.existingTripTableViewLabel.text = tripName
                cell.existingTripTableViewLabel.numberOfLines = 0
                cell.existingTripTableViewLabel.adjustsFontSizeToFitWidth = true
                cell.existingTripTableViewLabel.isHidden = true
                
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
                        cell.tripNameLabel.isHidden = false
                        cell.tripNameLabel.text = tripName
                        
                    }
                } else {
                    cell.destinationsLabel.isHidden = false
                    cell.destinationsLabel.text = "Destination TBD"
                    cell.tripNameLabel.isHidden = false
                    cell.tripNameLabel.text = tripName
                }
                
                
                return cell
            }
            
            return cell
        } else if indexPath.section == 2 {
            cell.tripStartDateLabel.isHidden = true
            cell.tripEndDateLabel.isHidden = true
            cell.toLabel.isHidden = true
            cell.destinationsLabel.isHidden = true
            cell.tripNameLabel.isHidden = true
            
            cell.menuItemLabel.isHidden = false
            cell.menuItemImageView.isHidden = false
            
            cell.menuItemImageView.image = #imageLiteral(resourceName: "earth")
            cell.menuItemLabel.text = "Bucket List"
            
            return cell
        }
        // else if indexPath.section == 3 {
        cell.tripStartDateLabel.isHidden = true
        cell.tripEndDateLabel.isHidden = true
        cell.toLabel.isHidden = true
        cell.destinationsLabel.isHidden = true
        cell.tripNameLabel.isHidden = true
        
        cell.menuItemLabel.isHidden = false
        cell.menuItemImageView.isHidden = false
        
        cell.menuItemImageView.image = #imageLiteral(resourceName: "userIcon")
        if DataContainerSingleton.sharedDataContainer.token == nil {
            cell.menuItemLabel.text = "Login or Sign Up"
        } else {
            cell.menuItemLabel.text = "Settings"
        }
        
        return cell
    }
    
    //MARK: TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        switch indexPath.section {
        case 0:
            //Increment current trip
            DataContainerSingleton.sharedDataContainer.currenttrip = DataContainerSingleton.sharedDataContainer.currenttrip! + 1

            var centerViewController = self.storyboard?.instantiateViewController(withIdentifier: "TripViewController") as! TripViewController
            centerViewController.NewOrAddedTripFromSegue = 1
            //FIREBASEDISABLED
            //            centerViewController?.newChannelRef = channelRef
            centerViewController.isTripSpawnedFromBucketList = 0

            var centerNavController = UINavigationController(rootViewController: centerViewController)
            centerNavController.navigationController?.isNavigationBarHidden = true
            centerViewController.navigationController?.isNavigationBarHidden = true
            appDelegate.centerContainer!.centerViewController = centerNavController
            appDelegate.centerContainer!.toggleDrawerSide(DrawerSide.left, animated: true, completion: nil)
            return
        case 1:
            
            //FIREBASEDISABLED
            
            if DataContainerSingleton.sharedDataContainer.token != nil && indexPath.row > channels.count - 1 {
                //PLANNED: Activity indicator
                return
            } else {
                let cell = tableView.cellForRow(at: indexPath as IndexPath) as! ExistingTripTableViewCell
                let searchForTitle = cell.existingTripTableViewLabel.text
                
                //FIREBASEDISABLED
                let channel = channels[(indexPath as NSIndexPath).row]
                channelRef = channelRef.child(channel.id)
                
                let startingCurrentTrip = DataContainerSingleton.sharedDataContainer.currenttrip
                for trip in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
                    if DataContainerSingleton.sharedDataContainer.usertrippreferences?[trip].object(forKey: "trip_name") as? String == searchForTitle {
                        DataContainerSingleton.sharedDataContainer.currenttrip = trip
                    }
                }
                
                if ((appDelegate.centerContainer!.centerViewController as! UINavigationController).topViewController!.isKind(of: TripViewController.self)) && startingCurrentTrip == DataContainerSingleton.sharedDataContainer.currenttrip {
                    appDelegate.centerContainer!.toggleDrawerSide(DrawerSide.left, animated: true, completion: nil)
                    return
                }
                
                
                //FIREBASEDISABLED
                //            super.performSegue(withIdentifier: "tripListToTripViewController", sender: channel)
                var centerViewController = self.storyboard?.instantiateViewController(withIdentifier: "TripViewController") as! TripViewController
                
                centerViewController.NewOrAddedTripFromSegue = 0
                //FIREBASEDISABLED
                centerViewController.newChannelRef = channelRef
                centerViewController.isTripSpawnedFromBucketList = 0
                
                var centerNavController = UINavigationController(rootViewController: centerViewController)
                centerViewController.navigationController?.isNavigationBarHidden = true
                appDelegate.centerContainer!.centerViewController = centerNavController
                appDelegate.centerContainer!.toggleDrawerSide(DrawerSide.left, animated: true, completion: nil)
                
            }
        case 2:
            if ((appDelegate.centerContainer!.centerViewController as! UINavigationController).topViewController!.isKind(of: bucketListViewController.self)) {
                appDelegate.centerContainer!.toggleDrawerSide(DrawerSide.left, animated: true, completion: nil)
                return
            }
            var centerViewController = self.storyboard?.instantiateViewController(withIdentifier: "bucketListViewController") as! bucketListViewController
            var centerNavController = UINavigationController(rootViewController: centerViewController)
            centerViewController.navigationController?.isNavigationBarHidden = true
            appDelegate.centerContainer!.centerViewController = centerNavController
            appDelegate.centerContainer!.toggleDrawerSide(DrawerSide.left, animated: true, completion: nil)
        case 3:
            if DataContainerSingleton.sharedDataContainer.token == nil {
                if ((appDelegate.centerContainer!.centerViewController as! UINavigationController).topViewController!.isKind(of: EmailViewController.self)) {
                    appDelegate.centerContainer!.toggleDrawerSide(DrawerSide.left, animated: true, completion: nil)
                    return
                }
                var centerViewController = self.storyboard?.instantiateViewController(withIdentifier: "EmailViewController") as! EmailViewController
                var centerNavController = UINavigationController(rootViewController: centerViewController)
                centerViewController.navigationController?.isNavigationBarHidden = true
                appDelegate.centerContainer!.centerViewController = centerNavController
                appDelegate.centerContainer!.toggleDrawerSide(DrawerSide.left, animated: true, completion: nil)
            } else {
                if ((appDelegate.centerContainer!.centerViewController as! UINavigationController).topViewController!.isKind(of: SettingsViewController.self)) {
                    appDelegate.centerContainer!.toggleDrawerSide(DrawerSide.left, animated: true, completion: nil)
                    return
                }
                var centerViewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
                var centerNavController = UINavigationController(rootViewController: centerViewController)
                centerViewController.navigationController?.isNavigationBarHidden = true
                appDelegate.centerContainer!.centerViewController = centerNavController
                appDelegate.centerContainer!.toggleDrawerSide(DrawerSide.left, animated: true, completion: nil)
            }
        default:
            break
        }
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        }
        return false
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as! ExistingTripTableViewCell
            let searchForTitle = cell.existingTripTableViewLabel.text
            
            for trip in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
                if DataContainerSingleton.sharedDataContainer.usertrippreferences?[trip].object(forKey: "trip_name") as? String == searchForTitle {
                    
                    //Remove from data model
                    DataContainerSingleton.sharedDataContainer.usertrippreferences?.remove(at: trip)
                    
                    //Remove from table
                    menuTableView.beginUpdates()
                    menuTableView.deleteRows(at: [indexPath], with: .left)
                    
                    menuTableView.endUpdates()
                    
                    if (DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! == 0 {
                        var centerViewController = self.storyboard?.instantiateViewController(withIdentifier: "bucketListViewController") as! bucketListViewController
                        var centerNavController = UINavigationController(rootViewController: centerViewController)
                        centerNavController.navigationController?.isNavigationBarHidden = true
                        centerViewController.navigationController?.isNavigationBarHidden = true
                        var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.centerContainer!.centerViewController = centerNavController
                    }
                    //Return if delete cell trip name found
                    
                    updateMenuTableHeight()
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
            menuTableView.reloadData()
            
        }
        
    }
    
    func updateMenuTableHeight() {
        var tableHeight = CGFloat()
        let userTripPreferences = DataContainerSingleton.sharedDataContainer.usertrippreferences
        if userTripPreferences != nil {
            let countTripsTotal = userTripPreferences?.count
            tableHeight = CGFloat(220 + 70 * countTripsTotal!)
        } else {
            tableHeight = 220
        }
        
        if (tableHeight + menuTableView.frame.origin.y) > UIScreen.main.bounds.height {
            tableHeight = UIScreen.main.bounds.height - menuTableView.frame.origin.y
        }
        menuTableView.frame.size.height = tableHeight
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


}
