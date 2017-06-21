//
//  TripViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/16/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import Firebase

class TripViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    //MARK: Class variables
    var scrollContentViewHeight: NSLayoutConstraint?
    
    var userNameQuestionView: UserNameQuestionView?
    var tripNameQuestionView: TripNameQuestionView?
    var whereTravellingFromQuestionView: WhereTravellingFromQuestionView?
    var datesPickedOutCalendarView: DatesPickedOutCalendarView?
    var decidedOnCityToVisitQuestionView: DecidedOnCityToVisitQuestionView?
    var noCityDecidedAnyIdeasQuestionView: NoCityDecidedAnyIdeasQuestionView?
    var planTripToIdeaQuestionView: PlanTripToIdeaQuestionView?
    var whatTypeOfTripQuestionView: WhatTypeOfTripQuestionView?
    var howFarAwayQuestionView: HowFarAwayQuestionView?
    var destinationOptionsCardView: DestinationOptionsCardView?
    var addAnotherDestinationQuestionView: AddAnotherDestinationQuestionView?
    
    //Firebase channel
    var channelsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("channels")
    var newChannelRef: FIRDatabaseReference?

    //Singleton
    var NewOrAddedTripFromSegue: Int?

    //City dict
    var rankedPotentialTripsDictionary = [Dictionary<String, Any>]()
    
    //Loading subviews based on progress
    var functionsToLoadSubviewsDictionary = Dictionary<Int,() -> ()>()
    
    // MARK: Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var underline: UIImageView!
    @IBOutlet weak var assistantButton: UIButton!
    @IBOutlet weak var itineraryButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        functionsToLoadSubviewsDictionary[0] = spawnWhereTravellingFromQuestionView
        functionsToLoadSubviewsDictionary[1] = spawnDatesPickedOutCalendarView
        functionsToLoadSubviewsDictionary[2] = spawnDecidedOnCityQuestionView
        functionsToLoadSubviewsDictionary[3] = spawnNoCityDecidedAnyIdeasQuestionView
        functionsToLoadSubviewsDictionary[4] = spawnPlanIdeaAsDestinationQuestionView
        functionsToLoadSubviewsDictionary[5] = spawnWhatTypeOfTripQuestionView
        functionsToLoadSubviewsDictionary[6] = spawnHowFarAwayQuestion
        functionsToLoadSubviewsDictionary[7] = spawnDestinationOptionsCardView
        functionsToLoadSubviewsDictionary[8] = spawnAddAnotherDestinationQuestionView
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                rankedPotentialTripsDictionary = rankedPotentialTripsDictionaryFromSingleton as! [Dictionary<String, AnyObject>]
            } else {
                //Load from server
                var rankedPotentialTripsDictionaryFromServer = [["price":"$1,000","percentSwipedRight":"100","destination":"Miami","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()],"destinationPhotos":["miami_1","miami_2"],"topThingsToDo":["Vizcaya Museum and Gardens", "American Airlines Arena", "Wynwood Walls", "Boat tours","Zoological Wildlife Foundation"],"averageMonthlyHighs":[String()],"averageMonthlyLows":[String()],"swipedStatus":"unswiped"]]
                
                rankedPotentialTripsDictionaryFromServer.append(["price":"$???","percentSwipedRight":"75","destination":"Washington DC","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()],"destinationPhotos":["washingtonDC_1","washingtonDC_2","washingtonDC_3","washingtonDC_4"],"topThingsToDo":["National Mall", "Smithsonian Air and Space Museum" ,"Logan Circle"],"averageMonthlyHighs":[String()],"averageMonthlyLows":[String()],"swipedStatus":"unswiped"])
                
                rankedPotentialTripsDictionaryFromServer.append(["price":"$???","percentSwipedRight":"75","destination":"San Diego","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()],"destinationPhotos":["sanDiego_1","sanDiego_2","sanDiego_3","sanDiego_4"],"topThingsToDo":["Sunset Cliffs", "San Diego Zoo" ,"Petco Park"],"averageMonthlyHighs":[String()],"averageMonthlyLows":[String()],"swipedStatus":"unswiped"])
                
                rankedPotentialTripsDictionaryFromServer.append(["price":"$???","percentSwipedRight":"75","destination":"Nashville","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()],"destinationPhotos":["nashville_1","nashville_2","nashville_3","nashville_4"],"topThingsToDo":["Grand Ole Opry", "Broadway" ,"Country Music Hall of Fame"],"averageMonthlyHighs":[String()],"averageMonthlyLows":[String()],"swipedStatus":"unswiped"])
                
                rankedPotentialTripsDictionaryFromServer.append(["price":"$???","percentSwipedRight":"50","destination":"New Orleans","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()],"destinationPhotos":["newOrleans_1","newOrleans_2","newOrleans_3","newOrleans_4"],"topThingsToDo":["Bourbon Street", "National WWII Museum" ,"Jackson Square"],"averageMonthlyHighs":[String()],"averageMonthlyLows":[String()],"swipedStatus":"unswiped"])
                
                rankedPotentialTripsDictionaryFromServer.append(["price":"$???","percentSwipedRight":"50","destination":"Austin","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()],"destinationPhotos":["austin_1","austin_2","austin_3","austin_4"],"topThingsToDo":["Zilker Park", "6th Street" ,"University of Texas"],"averageMonthlyHighs":[String()],"averageMonthlyLows":[String()],"swipedStatus":"unswiped"])
                
                rankedPotentialTripsDictionary = rankedPotentialTripsDictionaryFromServer
            }
        }
        
        
        SavedPreferencesForTrip["rankedPotentialTripsDictionary"] = self.rankedPotentialTripsDictionary
        //Save
        self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)

        scrollView.delegate = self
        
            if DataContainerSingleton.sharedDataContainer.firstName == nil {
                spawnUserNameQuestionView()
            } else {
                spawnTripNameQuestionView()
            }
        if NewOrAddedTripFromSegue == 0 {
            addSubviewsBasedOnProgress()
        }
        
        scrollContentViewHeight = NSLayoutConstraint(item: scrollContentView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: scrollContentView.subviews[scrollContentView.subviews.count - 1].frame.maxY)
        view.addConstraints([scrollContentViewHeight!])
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        //Trip Name
        if NewOrAddedTripFromSegue == 1 {
            let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
            
            //Create trip and trip data model
            if tripNameQuestionView == nil || tripNameQuestionView?.tripNameQuestionTextfield?.text == "" || tripNameQuestionView?.tripNameQuestionTextfield?.text == nil {
                    var tripNameValue = "Trip started \(Date().description.substring(to: 10).substring(from: 5))"
                    //Check if trip name used already
                    if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && DataContainerSingleton.sharedDataContainer.usertrippreferences?.count != 0 {
                        var countTripsMadeToday = 0
                        for trip in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
                            if (DataContainerSingleton.sharedDataContainer.usertrippreferences?[trip].object(forKey: "trip_name") as? String)!.contains("\(Date().description.substring(to: 10).substring(from: 5))") {
                                countTripsMadeToday += 1
                            }
                        }
                        if countTripsMadeToday != 0 {
                            tripNameValue = "Trip " + ("#\(countTripsMadeToday + 1) ") + tripNameValue.substring(from: 5)
                        }
                    }
                    
                    //                tripNameQuestionView?.tripNameQuestionTextfield?.text = tripNameValue
                    
                    //Update trip preferences in dictionary
                    let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                    SavedPreferencesForTrip["trip_name"] = tripNameValue as NSString
                    //Save
                    saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                    
                    //Create trip on server
                    apollo.perform(mutation: CreateTripMutation(trip: CreateTripInput(tripName: tripNameValue)), resultHandler: { (result, error) in
                        guard let data = result?.data else { return }
                        let tripID = data.createTrip?.changedTrip?.id
                        
                        let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
                        SavedPreferencesForTrip["tripID"] = tripID as! NSString
                        //Save
                        self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                        
                        print(error ?? "no error message")
                    })
                    
                    //Create new firebase channel
                    if let name = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String {
                        newChannelRef = channelsRef.childByAutoId()
                        let channelItem = [
                            "name": name
                        ]
                        newChannelRef?.setValue(channelItem)
                        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                        SavedPreferencesForTrip["firebaseChannelKey"] = newChannelRef?.key as! NSString
                        //Save
                        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                        
                    }
            }
            
                //            let SavedPreferencesForTrip_2 = fetchSavedPreferencesForTrip()
                //            timesViewed = (SavedPreferencesForTrip_2["timesViewed"] as? [String : Int])!
                //
                //            if timesViewed["newTrip"] == 0 {
                //                let when = DispatchTime.now()
                //                DispatchQueue.main.asyncAfter(deadline: when) {
                //                    self.animateInstructionsIn()
                //                    let currentTimesViewed = self.timesViewed["newTrip"]
                //                    self.timesViewed["newTrip"]! = currentTimesViewed! + 1
                //                    SavedPreferencesForTrip_2["timesViewed"] = self.timesViewed as NSDictionary
                //                    self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip_2)
                //                }
                //            }
            
        } else {
                //            retrieveContactsWithStore(store: addressBookStore)
        }
        
        // MARK: Register notifications
        NotificationCenter.default.addObserver(self, selector: #selector(spawnDecidedOnCityQuestionView), name: NSNotification.Name(rawValue: "calendarRangeSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(spawnDatesPickedOutCalendarView), name: NSNotification.Name(rawValue: "whereTravellingFromEntered"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(spawnPlanIdeaAsDestinationQuestionView), name: NSNotification.Name(rawValue: "destinationIdeaEntered"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(spawnAddAnotherDestinationQuestionView), name: NSNotification.Name(rawValue: "AddAnotherDestinationQuestionView"), object: nil)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        if NewOrAddedTripFromSegue == 0 {
            updateHeightOfScrollView()
            scrollDownToTopSubview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Custom functions
    func updateHeightOfScrollView(){
        let heightOfScrollView = scrollContentView.subviews[scrollContentView.subviews.count - 1].frame.maxY
        scrollContentViewHeight?.constant = heightOfScrollView
        scrollContentView.frame.size.height = heightOfScrollView
        scrollView.contentSize.height = heightOfScrollView
    }
    func scrollDownToTopSubview(){
        //Scroll to next question
        UIView.animate(withDuration: 1) {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollContentView.subviews[self.scrollContentView.subviews.count - 1].frame.minY), animated: false)
        }
        
    }
    
    func addSubviewsBasedOnProgress() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let subviewTags = SavedPreferencesForTrip["progress"] as! [Int]
        for subviewTag in subviewTags {
            self.functionsToLoadSubviewsDictionary[subviewTag]!()
        }
    }
    
    func updateProgress() {
        var currentSubviewsInScrollContentView = [Int]()
        for subview in scrollContentView.subviews {
            if subview != userNameQuestionView && subview != tripNameQuestionView {
                currentSubviewsInScrollContentView.append(subview.tag)
            }
        }
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["progress"] = currentSubviewsInScrollContentView as [NSNumber]
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    func spawnUserNameQuestionView() {
        userNameQuestionView = Bundle.main.loadNibNamed("UserNameQuestionView", owner: self, options: nil)?.first! as? UserNameQuestionView
        self.scrollContentView.addSubview(userNameQuestionView!)
        userNameQuestionView?.userNameQuestionTextfield?.delegate = self
        userNameQuestionView?.userNameQuestionTextfield?.becomeFirstResponder()
        let bounds = UIScreen.main.bounds
        self.userNameQuestionView!.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
        let heightConstraint = NSLayoutConstraint(item: userNameQuestionView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (userNameQuestionView?.frame.height)!)
        view.addConstraints([heightConstraint])
        updateHeightOfScrollView()
    }
    
    func spawnTripNameQuestionView() {
        if userNameQuestionView != nil {
            userNameQuestionView?.userNameQuestionTextfield?.resignFirstResponder()
            if userNameQuestionView?.userNameQuestionTextfield?.text != nil {
                tripNameQuestionView?.questionLabel?.text = "Hi \((userNameQuestionView?.userNameQuestionTextfield?.text!)!)! \nDo you want to name your trip?"
            }
        } else {
            tripNameQuestionView?.questionLabel?.text = "Hi \(String(describing: DataContainerSingleton.sharedDataContainer.firstName!))! \nDo you want to name your trip?"
        }
        if tripNameQuestionView == nil {
            //Load next question
            tripNameQuestionView = Bundle.main.loadNibNamed("TripNameQuestionView", owner: self, options: nil)?.first! as? TripNameQuestionView
            tripNameQuestionView?.tripNameQuestionButton?.addTarget(self, action: #selector(self.tripNameQuestionButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
            self.scrollContentView.addSubview(tripNameQuestionView!)
            tripNameQuestionView?.tripNameQuestionTextfield?.delegate = self
            let bounds = UIScreen.main.bounds
            
            if userNameQuestionView != nil {
                self.tripNameQuestionView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else {
                self.tripNameQuestionView!.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            }
            let heightConstraint = NSLayoutConstraint(item: tripNameQuestionView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (tripNameQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            if userNameQuestionView != nil {
                if userNameQuestionView?.userNameQuestionTextfield?.text != nil {
                    tripNameQuestionView?.questionLabel?.text = "Hi \((userNameQuestionView?.userNameQuestionTextfield?.text!)!)! \nDo you want to name your trip?"
                }
            } else {
                tripNameQuestionView?.questionLabel?.text = "Hi \(String(describing: DataContainerSingleton.sharedDataContainer.firstName!))! \nDo you want to name your trip?"
            }
            tripNameQuestionView?.tripNameQuestionTextfield?.becomeFirstResponder()
        }
        
        updateHeightOfScrollView()
        if userNameQuestionView != nil {
            scrollDownToTopSubview()
        }
    }
    func spawnWhereTravellingFromQuestionView(){
        tripNameQuestionView?.tripNameQuestionTextfield?.resignFirstResponder()
        if whereTravellingFromQuestionView == nil {
            //Load next question
            whereTravellingFromQuestionView = Bundle.main.loadNibNamed("WhereTravellingFromQuestionView", owner: self, options: nil)?.first! as? WhereTravellingFromQuestionView
            whereTravellingFromQuestionView?.tag = 0
            self.scrollContentView.addSubview(whereTravellingFromQuestionView!)
            let bounds = UIScreen.main.bounds
            
            self.whereTravellingFromQuestionView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: whereTravellingFromQuestionView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (whereTravellingFromQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
        }
        updateHeightOfScrollView()
        scrollDownToTopSubview()
//        whereTravellingFromQuestionView?.searchController?.searchBar.becomeFirstResponder()
        updateProgress()
    }
    func spawnDatesPickedOutCalendarView() {
        if datesPickedOutCalendarView == nil {
            //Load next question
            datesPickedOutCalendarView = Bundle.main.loadNibNamed("DatesPickedOutCalendarView", owner: self, options: nil)?.first! as? DatesPickedOutCalendarView
            datesPickedOutCalendarView?.tag = 1
            self.scrollContentView.addSubview(datesPickedOutCalendarView!)
            let bounds = UIScreen.main.bounds
            self.datesPickedOutCalendarView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: datesPickedOutCalendarView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (datesPickedOutCalendarView?.frame.height)!)
            view.addConstraints([heightConstraint])
        }
        updateHeightOfScrollView()
        scrollDownToTopSubview()
        updateProgress()
        
        let when = DispatchTime.now() + 1.4
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.datesPickedOutCalendarView?.calendarView.flashScrollIndicators()
        }
    }
    func spawnDecidedOnCityQuestionView() {
        if decidedOnCityToVisitQuestionView == nil {
            //Load next question
            decidedOnCityToVisitQuestionView = Bundle.main.loadNibNamed("DecidedOnCityToVisitQuestionView", owner: self, options: nil)?.first! as? DecidedOnCityToVisitQuestionView
            decidedOnCityToVisitQuestionView?.tag = 2
            self.scrollContentView.addSubview(decidedOnCityToVisitQuestionView!)
            let bounds = UIScreen.main.bounds
            decidedOnCityToVisitQuestionView?.button1?.addTarget(self, action: #selector(self.decidedOnCityToVisitQuestion_Yes(sender:)), for: UIControlEvents.touchUpInside)
            decidedOnCityToVisitQuestionView?.button2?.addTarget(self, action: #selector(self.decidedOnCityToVisitQuestion_No(sender:)), for: UIControlEvents.touchUpInside)
            self.decidedOnCityToVisitQuestionView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: decidedOnCityToVisitQuestionView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (decidedOnCityToVisitQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
        }
        updateHeightOfScrollView()
        scrollDownToTopSubview()
        updateProgress()
    }
    
    func spawnNoCityDecidedAnyIdeasQuestionView() {
        if noCityDecidedAnyIdeasQuestionView == nil {
            //Load next question
            noCityDecidedAnyIdeasQuestionView = Bundle.main.loadNibNamed("NoCityDecidedAnyIdeasQuestionView", owner: self, options: nil)?.first! as? NoCityDecidedAnyIdeasQuestionView
            self.scrollContentView.addSubview(noCityDecidedAnyIdeasQuestionView!)
            noCityDecidedAnyIdeasQuestionView?.tag = 3
            let bounds = UIScreen.main.bounds
            noCityDecidedAnyIdeasQuestionView?.button?.addTarget(self, action: #selector(self.noCityDecidedAnyIdeasQuestionView_noIdeas(sender:)), for: UIControlEvents.touchUpInside)
            self.noCityDecidedAnyIdeasQuestionView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: noCityDecidedAnyIdeasQuestionView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (noCityDecidedAnyIdeasQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
        }
        updateHeightOfScrollView()
        scrollDownToTopSubview()
        updateProgress()
    }
    func spawnPlanIdeaAsDestinationQuestionView() {
        if planTripToIdeaQuestionView == nil {
            //Load next question
            planTripToIdeaQuestionView = Bundle.main.loadNibNamed("PlanTripToIdeaQuestionView", owner: self, options: nil)?.first! as? PlanTripToIdeaQuestionView
            planTripToIdeaQuestionView?.tag = 4
            if noCityDecidedAnyIdeasQuestionView?.searchController?.searchBar.text != nil && noCityDecidedAnyIdeasQuestionView?.searchController?.searchBar.text != "" {
                planTripToIdeaQuestionView?.questionLabel?.text = "Do you want to plan\nyour trip to \((noCityDecidedAnyIdeasQuestionView?.searchController?.searchBar.text!)!)?"
            }
            self.scrollContentView.addSubview(planTripToIdeaQuestionView!)
            let bounds = UIScreen.main.bounds
            planTripToIdeaQuestionView?.button1?.addTarget(self, action: #selector(self.planTripToIdeaQuestionView_Yes(sender:)), for: UIControlEvents.touchUpInside)
            planTripToIdeaQuestionView?.button2?.addTarget(self, action: #selector(self.planTripToIdeaQuestionView_No(sender:)), for: UIControlEvents.touchUpInside)
            self.planTripToIdeaQuestionView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: planTripToIdeaQuestionView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (planTripToIdeaQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
        }
        updateHeightOfScrollView()
        scrollDownToTopSubview()
        updateProgress()
    }
    func spawnWhatTypeOfTripQuestionView() {
        if whatTypeOfTripQuestionView == nil {
            //Load next question
            whatTypeOfTripQuestionView = Bundle.main.loadNibNamed("WhatTypeOfTripQuestionView", owner: self, options: nil)?.first! as? WhatTypeOfTripQuestionView
            whatTypeOfTripQuestionView?.tag = 5
            self.scrollContentView.addSubview(whatTypeOfTripQuestionView!)
            let bounds = UIScreen.main.bounds
            whatTypeOfTripQuestionView?.button1?.addTarget(self, action: #selector(self.whatTypeOfTripQuestionView_beaches(sender:)), for: UIControlEvents.touchUpInside)
            whatTypeOfTripQuestionView?.button2?.addTarget(self, action: #selector(self.whatTypeOfTripQuestionView_natureAdventuring(sender:)), for: UIControlEvents.touchUpInside)
            whatTypeOfTripQuestionView?.button3?.addTarget(self, action: #selector(self.whatTypeOfTripQuestionView_winterSports(sender:)), for: UIControlEvents.touchUpInside)
            whatTypeOfTripQuestionView?.button4?.addTarget(self, action: #selector(self.whatTypeOfTripQuestionView_partying(sender:)), for: UIControlEvents.touchUpInside)
            whatTypeOfTripQuestionView?.button5?.addTarget(self, action: #selector(self.whatTypeOfTripQuestionView_foodieHavens(sender:)), for: UIControlEvents.touchUpInside)
            self.whatTypeOfTripQuestionView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: whatTypeOfTripQuestionView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (whatTypeOfTripQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
        }
        updateHeightOfScrollView()
        scrollDownToTopSubview()
        updateProgress()
    }
    func spawnHowFarAwayQuestion() {
        if howFarAwayQuestionView == nil {
            //Load next question
            howFarAwayQuestionView = Bundle.main.loadNibNamed("HowFarAwayQuestionView", owner: self, options: nil)?.first! as? HowFarAwayQuestionView
            howFarAwayQuestionView?.tag = 6
            self.scrollContentView.addSubview(howFarAwayQuestionView!)
            let bounds = UIScreen.main.bounds
            howFarAwayQuestionView?.button1?.addTarget(self, action: #selector(self.howFarAwayQuestionView_shortDrive(sender:)), for: UIControlEvents.touchUpInside)
            howFarAwayQuestionView?.button2?.addTarget(self, action: #selector(self.howFarAwayQuestionView_shortFlight(sender:)), for: UIControlEvents.touchUpInside)
            howFarAwayQuestionView?.button3?.addTarget(self, action: #selector(self.howFarAwayQuestionView_domestic(sender:)), for: UIControlEvents.touchUpInside)
            howFarAwayQuestionView?.button4?.addTarget(self, action: #selector(self.howFarAwayQuestionView_international(sender:)), for: UIControlEvents.touchUpInside)
            self.howFarAwayQuestionView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: howFarAwayQuestionView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (howFarAwayQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
        }
        updateHeightOfScrollView()
        scrollDownToTopSubview()
        updateProgress()
    }

    func spawnDestinationOptionsCardView() {
        if destinationOptionsCardView == nil {
            //Load next question
            destinationOptionsCardView = Bundle.main.loadNibNamed("DestinationOptionsCardView", owner: self, options: nil)?.first! as? DestinationOptionsCardView
            destinationOptionsCardView?.tag = 7
            self.scrollContentView.addSubview(destinationOptionsCardView!)
            let bounds = UIScreen.main.bounds
            destinationOptionsCardView?.button1?.addTarget(self, action: #selector(self.destinationOptionsCardView_x(sender:)), for: UIControlEvents.touchUpInside)
            destinationOptionsCardView?.button2?.addTarget(self, action: #selector(self.destinationOptionsCardView_heart(sender:)), for: UIControlEvents.touchUpInside)
            self.destinationOptionsCardView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: destinationOptionsCardView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (destinationOptionsCardView?.frame.height)!)
            view.addConstraints([heightConstraint])
        }
        updateHeightOfScrollView()
        scrollDownToTopSubview()
        updateProgress()
    }
    func spawnAddAnotherDestinationQuestionView() {
        if addAnotherDestinationQuestionView == nil {
            //Load next question
            addAnotherDestinationQuestionView = Bundle.main.loadNibNamed("AddAnotherDestinationQuestionView", owner: self, options: nil)?.first! as? AddAnotherDestinationQuestionView
            addAnotherDestinationQuestionView?.tag = 8
            self.scrollContentView.addSubview(addAnotherDestinationQuestionView!)
            let bounds = UIScreen.main.bounds
//            chooseDestinationTableView?.button1?.addTarget(self, action: #selector(self.destinationOptionsCardView_x(sender:)), for: UIControlEvents.touchUpInside)
//            destinationOptionsCardView?.button2?.addTarget(self, action: #selector(self.destinationOptionsCardView_heart(sender:)), for: UIControlEvents.touchUpInside)
            self.addAnotherDestinationQuestionView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: addAnotherDestinationQuestionView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (addAnotherDestinationQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
        }
        updateHeightOfScrollView()
        scrollDownToTopSubview()
        updateProgress()
    }
    
    // MARK: Sent events
    func tripNameQuestionButtonClicked(sender:UIButton) {
        if sender.isSelected == true {
            spawnWhereTravellingFromQuestionView()
        }
    }
    func decidedOnCityToVisitQuestion_No(sender:UIButton) {
        if sender.isSelected == true {
            spawnNoCityDecidedAnyIdeasQuestionView()
        }
    }
    func decidedOnCityToVisitQuestion_Yes(sender:UIButton) {
        if sender.isSelected == true {
        
        }
    }
    
    func noCityDecidedAnyIdeasQuestionView_noIdeas(sender:UIButton) {
        if sender.isSelected == true {
            spawnWhatTypeOfTripQuestionView()
        }
    }
    
    func planTripToIdeaQuestionView_Yes(sender:UIButton) {
        if sender.isSelected == true {
            
        }
    }
    func planTripToIdeaQuestionView_No(sender:UIButton) {
        if sender.isSelected == true {
            spawnWhatTypeOfTripQuestionView()
        }
    }
    func whatTypeOfTripQuestionView_beaches(sender:UIButton) {
        if sender.isSelected == true {
            spawnHowFarAwayQuestion()
        }
    }
    func whatTypeOfTripQuestionView_natureAdventuring(sender:UIButton) {
        if sender.isSelected == true {
            spawnHowFarAwayQuestion()
        }
    }
    func whatTypeOfTripQuestionView_winterSports(sender:UIButton) {
        if sender.isSelected == true {
            spawnHowFarAwayQuestion()
        }
    }
    func whatTypeOfTripQuestionView_partying(sender:UIButton) {
        if sender.isSelected == true {
            spawnHowFarAwayQuestion()
        }
    }
    func whatTypeOfTripQuestionView_foodieHavens(sender:UIButton) {
        if sender.isSelected == true {
            spawnHowFarAwayQuestion()
        }
    }
    func howFarAwayQuestionView_shortDrive(sender:UIButton) {
        if sender.isSelected == true {
            spawnDestinationOptionsCardView()
        }
    }
    func howFarAwayQuestionView_shortFlight(sender:UIButton) {
        if sender.isSelected == true {
            spawnDestinationOptionsCardView()
        }
    }
    func howFarAwayQuestionView_domestic(sender:UIButton) {
        if sender.isSelected == true {
            spawnDestinationOptionsCardView()
        }
    }
    func howFarAwayQuestionView_international(sender:UIButton) {
        if sender.isSelected == true {
            spawnDestinationOptionsCardView()
        }
    }
    func destinationOptionsCardView_x(sender:UIButton) {
        if sender.isSelected == true {
        }
    }
    func destinationOptionsCardView_heart(sender:UIButton) {
        if sender.isSelected == true {
        }
    }

    


    // MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        
        if textField == userNameQuestionView?.userNameQuestionTextfield {
            if userNameQuestionView?.userNameQuestionTextfield?.text == nil || userNameQuestionView?.userNameQuestionTextfield?.text == "" {
                return false
            } else {
                DataContainerSingleton.sharedDataContainer.firstName = textField.text
                spawnTripNameQuestionView()
            }
        }
        
        if textField == tripNameQuestionView?.tripNameQuestionTextfield {
            if tripNameQuestionView?.tripNameQuestionTextfield?.text == nil || tripNameQuestionView?.tripNameQuestionTextfield?.text == "" {
                return false
            } else {
                let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                SavedPreferencesForTrip["trip_name"] = textField.text
                saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                spawnWhereTravellingFromQuestionView()
            }
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        return true
    }

    
    // MARK: SAVE TO SINGLETON
    ////// ADD NEW TRIP VARS (NS ONLY) HERE ///////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func fetchSavedPreferencesForTrip() -> NSMutableDictionary {
        //Determine if new or added trip
        let isNewOrAddedTrip = determineIfNewOrAddedTrip()
        
        //Init preference vars for if new or added trip
        //Trip status
        var bookingStatus = NSNumber(value: 0)
        var progress = [NSNumber]()
        var lastVC = NSString()
        var timesViewed = NSDictionary()
        //New Trip VC
        var tripNameValue = NSString()
        var tripID = NSString()
        var contacts = [NSString]()
        var contactPhoneNumbers =  [NSString]()
        var hotelRoomsValue =  [NSNumber]()
        var segmentLengthValue = [NSNumber]()
        var selectedDates = [NSDate]()
        var leftDateTimeArrays = NSDictionary()
        var rightDateTimeArrays = NSDictionary()
        var numberDestinations = NSNumber(value: 1)
        var nonSpecificDates = NSDictionary()
        var firebaseChannelKey = NSString()
        //Budget VC DEPRICATED
        var budgetValue = NSString()
        var expectedRoundtripFare = NSString()
        var expectedNightlyRate = NSString()
        //Suggested Destination VC DEPRICATED
        var decidedOnDestinationControlValue = NSString()
        var decidedOnDestinationValue = NSString()
        var suggestDestinationControlValue = NSString()
        var suggestedDestinationValue = NSString()
        //Activities VC
        var selectedActivities = [NSString]()
        //Ranking VC
        var topTrips = [NSString]()
        var rankedPotentialTripsDictionary = [NSDictionary]()
        var rankedPotentialTripsDictionaryArrayIndex = NSNumber(value: 0)
        
        //Update preference vars if an existing trip
        if isNewOrAddedTrip == 0 {
            //Trip status
            bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? 0 as NSNumber
            progress = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "progress") as? [NSNumber] ?? [NSNumber]()
            lastVC = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "lastVC") as? NSString ?? NSString()
            timesViewed = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "timesViewed") as? NSDictionary ?? NSDictionary()
            //New Trip VC
            tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? NSString ?? NSString()
            tripID = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "tripID") as? NSString ?? NSString()
            
            contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString] ?? [NSString]()
            contactPhoneNumbers = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contact_phone_numbers") as? [NSString] ?? [NSString]()
            hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? [NSNumber] ?? [NSNumber]()
            segmentLengthValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "Availability_segment_lengths") as? [NSNumber] ?? [NSNumber]()
            selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [NSDate] ?? [NSDate]()
            leftDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "origin_departure_times") as? NSDictionary ?? NSDictionary()
            rightDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "return_departure_times") as? NSDictionary ?? NSDictionary()
            numberDestinations = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "numberDestinations") as? NSNumber ?? NSNumber()
            nonSpecificDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "nonSpecificDates") as? NSDictionary ?? NSDictionary()
            firebaseChannelKey = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "firebaseChannelKey") as? NSString ?? NSString()
            //Budget VC
            budgetValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "budget") as? NSString ?? NSString()
            expectedRoundtripFare = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_roundtrip_fare") as? NSString ?? NSString()
            expectedNightlyRate = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_nightly_rate") as? NSString ?? NSString()
            //Suggested Destination VC
            decidedOnDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_control") as? NSString ?? NSString()
            decidedOnDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_value") as? NSString ?? NSString()
            suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? NSString ?? NSString()
            suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? NSString ?? NSString()
            //Activities VC
            selectedActivities = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_activities") as? [NSString] ?? [NSString]()
            //Ranking VC
            topTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "top_trips") as? [NSString] ?? [NSString]()
            rankedPotentialTripsDictionary = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionary") as? [NSDictionary] ?? [NSDictionary]()
            rankedPotentialTripsDictionaryArrayIndex = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionaryArrayIndex") as? NSNumber ?? NSNumber()
            
        }
        
        //SavedPreferences
        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus,"progress": progress, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips,"numberDestinations":numberDestinations,"nonSpecificDates":nonSpecificDates, "rankedPotentialTripsDictionary": rankedPotentialTripsDictionary, "tripID": tripID,"lastVC": lastVC,"firebaseChannelKey": firebaseChannelKey,"rankedPotentialTripsDictionaryArrayIndex": rankedPotentialTripsDictionaryArrayIndex, "timesViewed": timesViewed] as NSMutableDictionary
        
        return fetchedSavedPreferencesForTrip
        
    }
    
    func determineIfNewOrAddedTrip() -> Int {
        let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        var numberSavedTrips: Int?
        var isNewOrAddedTrip: Int?
        if existing_trips == nil {
            numberSavedTrips = 0
            isNewOrAddedTrip = 1
        }
        else {
            numberSavedTrips = (existing_trips?.count)! - 1
            if currentTripIndex <= numberSavedTrips! {
                isNewOrAddedTrip = 0
            } else {
                isNewOrAddedTrip = 1
            }
        }
        return isNewOrAddedTrip!
    }
    
    func saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: NSMutableDictionary) {
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        
        var numberSavedTrips: Int?
        if DataContainerSingleton.sharedDataContainer.usertrippreferences == nil {
            numberSavedTrips = 0
        }
        else {
            numberSavedTrips = (existing_trips?.count)! - 1
            
        }
        
        //Case: first trip
        if existing_trips == nil {
            let firstTrip = [SavedPreferencesForTrip as NSDictionary]
            DataContainerSingleton.sharedDataContainer.usertrippreferences = firstTrip
        }
            //Case: existing trip
        else if currentTripIndex <= numberSavedTrips!   {
            existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
            DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        }
            //Case: added trip, but not first trip
        else {
            existing_trips?.append(SavedPreferencesForTrip as NSDictionary)
            DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        }
    }

}
