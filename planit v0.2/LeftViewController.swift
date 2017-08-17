//
//  LeftViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 8/17/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class LeftViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    //FIREBASEDISABLED
    //    //Firebase channels
    //    private var channelRefHandle: DatabaseHandle?
    //    private var channels: [Channel] = []
    //    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
    
    //MARK: Class vars
    var formatter = DateFormatter()
    
    //MARK: Outlets
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.endEditing(true)


        self.navigationController?.isNavigationBarHidden = true
        let firstNameValue = DataContainerSingleton.sharedDataContainer.firstName ?? ""
        if firstNameValue == "" {
            self.userNameLabel.text =  "New user"
        }
        else {
            self.userNameLabel.text =  "\(firstNameValue)"
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        reorderTripsChronologically()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "leftViewControllerViewWillAppear"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "leftViewControllerViewWillDisappear"), object: nil)
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
        if indexPath.section == 0 {
            var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellID")
            
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cellID")
            }
            
            cell?.textLabel?.text = "New Trip"
            cell?.textLabel?.textColor = UIColor.white
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell?.textLabel?.numberOfLines = 0
            cell?.backgroundColor = UIColor.clear
            
            return cell!

        } else if indexPath.section == 1 {
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
            
            return cell
        } else if indexPath.section == 2 {
            var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellID")
            
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cellID")
            }
            
            cell?.textLabel?.text = "Bucket list"
            cell?.textLabel?.textColor = UIColor.white
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell?.textLabel?.numberOfLines = 0
            cell?.backgroundColor = UIColor.clear
            
            return cell!
        }
        // else if indexPath.section == 3 {
            var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellID")
            
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cellID")
            }
            
            cell?.textLabel?.text = "Login"
            cell?.textLabel?.textColor = UIColor.white
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell?.textLabel?.numberOfLines = 0
            cell?.backgroundColor = UIColor.clear
            
            return cell!
    }
    
    //MARK: TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: break
        case 1:
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
        case 2: break
        case 3: break
        default:
            break
        }
        
    }
    

//    var menuItems:[String] = ["Main","About"];
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(true)
//        self.navigationController?.view.layoutSubviews()
//    }

//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
//        var mycell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as MyCustomTableViewCell
//        mycell.menuItemLabel.text = menuItems[indexPath.row]
//        return mycell;
//    }
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        switch(indexPath.row)
//        {
//        case 0:
//            var centerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ViewController") as ViewController
//            var centerNavController = UINavigationController(rootViewController: centerViewController)
//            var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
//            appDelegate.centerContainer!.centerViewController = centerNavController
//            appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
//            break;
//        case 1:
//            var aboutViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AboutViewController") as AboutViewController
//            var aboutNavController = UINavigationController(rootViewController: aboutViewController)
//            var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
//            appDelegate.centerContainer!.centerViewController = aboutNavController
//            appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
//            break;
//        default:
//            println("\(menuItems[indexPath.row]) is selected");
//        }
//    }
    
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

}
