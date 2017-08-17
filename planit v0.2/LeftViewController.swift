//
//  LeftViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 8/17/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class LeftViewController: UIViewController {
    
    //FIREBASEDISABLED
    //    //Firebase channels
    //    private var channelRefHandle: DatabaseHandle?
    //    private var channels: [Channel] = []
    //    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
    
    //Class vars
    var formatter = DateFormatter()
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var userNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.darkGray
        
        
    }

    
//, UITableViewDataSource, UITableViewDelegate {

//    var menuItems:[String] = ["Main","About"];
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(true)
//        self.navigationController?.view.layoutSubviews()
//    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//    }
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    func tableView func numberOfSections(in tableView: UITableView) -> Int {
//    }
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return menuItems.count;
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
            existingTripsTable.reloadData()
            
        }
        
    }

}
