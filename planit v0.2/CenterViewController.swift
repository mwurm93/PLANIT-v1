//
//  CenterViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 8/17/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import Cartography

class CenterViewController: UIViewController {
    
    var tripViewController: TripViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        if DataContainerSingleton.sharedDataContainer.usertrippreferences == nil || DataContainerSingleton.sharedDataContainer.usertrippreferences?.count == 0 {
            DataContainerSingleton.sharedDataContainer.currenttrip = 0
        }
        
        setUpTripController()
    }
    
    
    func setUpTripController() {
        
        var centerViewController = self.storyboard?.instantiateViewController(withIdentifier: "TripViewController") as! TripViewController
        
        centerViewController.NewOrAddedTripFromSegue = 1
        //FIREBASEDISABLED
        //            centerViewController?.newChannelRef = channelRef
        centerViewController.isTripSpawnedFromBucketList = 0
        
        var centerNavController = UINavigationController(rootViewController: centerViewController)
        centerViewController.navigationController?.isNavigationBarHidden = true
        var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer!.centerViewController = centerNavController
//        appDelegate.centerContainer!.toggleDrawerSide(DrawerSide.left, animated: true, completion: nil)

        
        
        
//        tripViewController = self.storyboard!.instantiateViewController(withIdentifier: "TripViewController") as? TripViewController
//        tripViewController?.willMove(toParentViewController: self)
//        self.addChildViewController(tripViewController!)
//        tripViewController?.loadView()
//        setUpTripControllerForNewTrip()
//        tripViewController?.viewDidLoad()
//        tripViewController?.view.frame = self.view.bounds
//        self.view.addSubview((tripViewController?.view)!)
//        constrain((tripViewController?.view)!, self.view) { view1, view2 in
//            view1.left == view2.left
//            view1.top == view2.top
//            view1.width == view2.width
//            view1.height == view2.height
//        }
//        tripViewController?.didMove(toParentViewController: self)
    }
    
    func setUpTripControllerForNewTrip() {        
//        var NewOrAddedTripForSegue = Int()
        
//        let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
//        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
//        var numberSavedTrips: Int?
//        if existing_trips == nil {
//            numberSavedTrips = 0
//            NewOrAddedTripForSegue = 1
//        } else {
//            numberSavedTrips = (existing_trips?.count)! - 1
//            if currentTripIndex <= numberSavedTrips! {
//                NewOrAddedTripForSegue = 0
//            } else {
//                NewOrAddedTripForSegue = 1
//            }
//        }
        tripViewController?.NewOrAddedTripFromSegue = 1
        //FIREBASEDISABLED
        //            tripViewController?.newChannelRef = channelRef
        tripViewController?.isTripSpawnedFromBucketList = 0
    }
}
