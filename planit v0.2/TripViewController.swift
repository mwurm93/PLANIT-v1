//
//  TripViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/16/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import Firebase
import JTAppleCalendar
import Cartography

class TripViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    //MARK: Class variables
    var scrollContentViewHeight: NSLayoutConstraint?
    var controller: ChatViewController?
    
    var userNameQuestionView: UserNameQuestionView?
    var tripNameQuestionView: TripNameQuestionView?
    var whereTravellingFromQuestionView: WhereTravellingFromQuestionView?
    var datesPickedOutCalendarView: DatesPickedOutCalendarView?
    var decidedOnCityToVisitQuestionView: DecidedOnCityToVisitQuestionView?
    var yesCityDecidedQuestionView: YesCityDecidedQuestionView?
    var noCityDecidedAnyIdeasQuestionView: NoCityDecidedAnyIdeasQuestionView?
    var planTripToIdeaQuestionView: PlanTripToIdeaQuestionView?
    var whatTypeOfTripQuestionView: WhatTypeOfTripQuestionView?
    var howFarAwayQuestionView: HowFarAwayQuestionView?
    var destinationOptionsCardView: DestinationOptionsCardView?
    var addAnotherDestinationQuestionView: AddAnotherDestinationQuestionView?
    var howDoYouWantToGetThereQuestionView: HowDoYouWantToGetThereQuestionView?
    var flightSearchQuestionView: FlightSearchQuestionView?
    var flightResultsQuestionView: FlightResultsQuestionView?

    //CalendarView vars
    let timesOfDayArray = ["Early morning (before 8am)","Morning (8am-11am)","Midday (11am-2pm)","Afternoon (2pm-5pm)","Evening (5pm-9pm)","Night (after 9pm)","Anytime"]
    var leftDates = [Date]()
    var rightDates = [Date]()
    var fullDates = [Date]()
    var lengthOfAvailabilitySegmentsArray = [Int]()
    var leftDateTimeArrays = NSMutableDictionary()
    var rightDateTimeArrays = NSMutableDictionary()
    var mostRecentSelectedCellDate = NSDate()
    var dateEditing = "departureDate"
    var searchMode = "roundtrip"
    
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
    @IBOutlet weak var scrollUpButton: UIButton!
    @IBOutlet weak var scrollDownButton: UIButton!
    @IBOutlet var datePickingSubview: UIView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var datePickingSubviewDoneButton: UIButton!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var itineraryView: UIView!

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
        functionsToLoadSubviewsDictionary[9] = spawnYesCityDecidedQuestionView
        functionsToLoadSubviewsDictionary[10] = spawnHowDoYouWantToGetThereQuestionView
        functionsToLoadSubviewsDictionary[11] = spawnFlightSearchQuestionView
        functionsToLoadSubviewsDictionary[12] = spawnFlightResultsQuestionView

        
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
        scrollView.indicatorStyle = .white
        
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
        
        handleScrollUpAndDownButtons()
        
        //Trip Name
        if NewOrAddedTripFromSegue == 1 {
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
        
        //Calendar subview setup
        //Calendar Setup
        datePickingSubview.layer.cornerRadius = 10
        
        // Calendar header setup
        calendarView.register(UINib(nibName: "monthHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "monthHeaderView")
        
        // Calendar setup delegate and datasource
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        calendarView.register(UINib(nibName: "CellView", bundle: nil), forCellWithReuseIdentifier: "CellView")
        calendarView.allowsMultipleSelection  = true
        calendarView.isRangeSelectionUsed = true
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 2
        calendarView.scrollingMode = .none
        calendarView.scrollDirection = .vertical
        calendarView.indicatorStyle = .white
        
        // Load trip preferences and install
        if let selectedDatesValue = SavedPreferencesForTrip["selected_dates"] as? [Date] {
            if selectedDatesValue.count > 0 {
                self.calendarView.selectDates(selectedDatesValue as [Date],triggerSelectionDelegate: false)
                calendarView.scrollToDate(selectedDatesValue[0], animateScroll: false)
            }
        }
        
        addChatViewController()
        assistant()
        
        // MARK: Register notifications
        NotificationCenter.default.addObserver(self, selector: #selector(spawnDecidedOnCityQuestionView), name: NSNotification.Name(rawValue: "calendarRangeSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(spawnDatesPickedOutCalendarView), name: NSNotification.Name(rawValue: "whereTravellingFromEntered"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(spawnAddAnotherDestinationQuestionViewEvenIfNonNil), name: NSNotification.Name(rawValue: "destinationDecidedEntered"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(spawnPlanIdeaAsDestinationQuestionView), name: NSNotification.Name(rawValue: "destinationIdeaEntered"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(spawnAddAnotherDestinationQuestionViewEvenIfNonNil), name: NSNotification.Name(rawValue: "AddAnotherDestinationQuestionView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(animateInSubview_Departure), name: NSNotification.Name(rawValue: "animateInDatePickingSubview_Departure"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(animateInSubview_Return), name: NSNotification.Name(rawValue: "animateInDatePickingSubview_Return"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(animateOutSubview), name: NSNotification.Name(rawValue: "animateOutDatePickingSubview"), object: nil)
    }
//    
    override func viewDidAppear(_ animated: Bool) {
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
    func animateInSubview_Departure(){
        //Animate In Subview
        dateEditing = "departureDate"
        self.view.endEditing(true)
        self.view.addSubview(datePickingSubview)
        let bounds = UIScreen.main.bounds
        datePickingSubview.center = CGPoint(x: bounds.size.width / 2, y: 405)
        datePickingSubview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        datePickingSubview.alpha = 0
        UIView.animate(withDuration: 0.2) {
            self.datePickingSubview.alpha = 1
            self.datePickingSubview.transform = CGAffineTransform.identity
        }
        
        getLengthOfSelectedAvailabilities()
        if self.leftDates.count == self.rightDates.count && (self.leftDates.count != 0 || self.rightDates.count != 0) {
            self.datePickingSubview.isHidden = false
        }
    }
//    func animateInSubview_Return(){
//        dateEditing = "returnDate"
//        //Animate In Subview
//        self.view.addSubview(datePickingSubview)
//        let bounds = UIScreen.main.bounds
//        datePickingSubview.center = CGPoint(x: bounds.size.width / 2, y: 500)
//        datePickingSubview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
//        datePickingSubview.alpha = 0
//        UIView.animate(withDuration: 0.2) {
//            self.datePickingSubview.alpha = 1
//            self.datePickingSubview.transform = CGAffineTransform.identity
//        }
//        
//        getLengthOfSelectedAvailabilities()
//        if self.leftDates.count == self.rightDates.count && (self.leftDates.count != 0 || self.rightDates.count != 0) {
//            self.datePickingSubview.isHidden = false
//        }
//    }

    func animateOutSubview() {
        UIView.animate(withDuration: 0.3, animations: {
            self.datePickingSubview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.datePickingSubview.alpha = 0
            self.datePickingSubview.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }) { (Success:Bool) in
            self.datePickingSubview.removeFromSuperview()
        }
    }

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
    
    func scrollUpOneSubview(){
        let yPoint = scrollView.contentOffset.y - self.scrollContentView.subviews[self.scrollContentView.subviews.count - 1].frame.height
        if yPoint >= 0 {
            UIView.animate(withDuration: 1) {
                self.scrollView.setContentOffset(CGPoint(x: 0, y: yPoint), animated: false)
            }
        }
    }
    
    func scrollDownOneSubview(){
        let yPoint = scrollView.contentOffset.y + 2 * self.scrollContentView.subviews[self.scrollContentView.subviews.count - 1].frame.height
        if yPoint <= scrollView.contentSize.height {
            UIView.animate(withDuration: 1) {
                self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentOffset.y + self.scrollContentView.subviews[self.scrollContentView.subviews.count - 1].frame.height), animated: false)
            }
        }
    }
    
    func handleScrollUpAndDownButtons(){
        let yPointDown = scrollView.contentOffset.y + 2 * self.scrollContentView.subviews[self.scrollContentView.subviews.count - 1].frame.height
        let yPointUp = scrollView.contentOffset.y - self.scrollContentView.subviews[self.scrollContentView.subviews.count - 1].frame.height
        if yPointDown > scrollView.contentSize.height {
            self.scrollDownButton.isHidden = true
        } else {
            self.scrollDownButton.isHidden = false
        }
        if yPointUp < 0 {
            self.scrollUpButton.isHidden = true
        } else {
            self.scrollUpButton.isHidden = false
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
        let heightConstraint = NSLayoutConstraint(item: userNameQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (userNameQuestionView?.frame.height)!)
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
            let heightConstraint = NSLayoutConstraint(item: tripNameQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (tripNameQuestionView?.frame.height)!)
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
            whereTravellingFromQuestionView?.button1?.addTarget(self, action: #selector(self.spawnDatesPickedOutCalendarView), for: UIControlEvents.touchUpInside)
            self.whereTravellingFromQuestionView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: whereTravellingFromQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (whereTravellingFromQuestionView?.frame.height)!)
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
            let heightConstraint = NSLayoutConstraint(item: datesPickedOutCalendarView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (datesPickedOutCalendarView?.frame.height)!)
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
            let heightConstraint = NSLayoutConstraint(item: decidedOnCityToVisitQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (decidedOnCityToVisitQuestionView?.frame.height)!)
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
            let heightConstraint = NSLayoutConstraint(item: noCityDecidedAnyIdeasQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (noCityDecidedAnyIdeasQuestionView?.frame.height)!)
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
            let heightConstraint = NSLayoutConstraint(item: planTripToIdeaQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (planTripToIdeaQuestionView?.frame.height)!)
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
            let heightConstraint = NSLayoutConstraint(item: whatTypeOfTripQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (whatTypeOfTripQuestionView?.frame.height)!)
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
            let heightConstraint = NSLayoutConstraint(item: howFarAwayQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (howFarAwayQuestionView?.frame.height)!)
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
//            destinationOptionsCardView?.button1?.addTarget(self, action: #selector(self.destinationOptionsCardView_x(sender:)), for: UIControlEvents.touchUpInside)
//            destinationOptionsCardView?.button2?.addTarget(self, action: #selector(self.destinationOptionsCardView_heart(sender:)), for: UIControlEvents.touchUpInside)
            self.destinationOptionsCardView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: destinationOptionsCardView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (destinationOptionsCardView?.frame.height)!)
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
            addAnotherDestinationQuestionView?.button1?.addTarget(self, action: #selector(self.addAnotherDestinationQuestionView_justDestination(sender:)), for: UIControlEvents.touchUpInside)
            self.addAnotherDestinationQuestionView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: addAnotherDestinationQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (addAnotherDestinationQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
        }
        updateHeightOfScrollView()
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])
        if destinationsForTrip.count != 0 {
            addAnotherDestinationQuestionView?.questionLabel?.text = "Woohoo! Let's plan a trip to \(destinationsForTrip[0]).\n\nWill this be your only destination on this trip?"
            addAnotherDestinationQuestionView?.button1?.setTitle("Yep, just \(destinationsForTrip[0])", for: .normal)
            addAnotherDestinationQuestionView?.button1?.setTitle("Yep, just \(destinationsForTrip[0])", for: .highlighted)
            addAnotherDestinationQuestionView?.button1?.setTitle("Yep, just \(destinationsForTrip[0])", for: .selected)
        }
        scrollDownToTopSubview()
        updateProgress()
    }
    func spawnYesCityDecidedQuestionView() {
        if yesCityDecidedQuestionView == nil {
            //Load next question
            yesCityDecidedQuestionView = Bundle.main.loadNibNamed("YesCityDecidedQuestionView", owner: self, options: nil)?.first! as? YesCityDecidedQuestionView
            self.scrollContentView.addSubview(yesCityDecidedQuestionView!)
            yesCityDecidedQuestionView?.tag = 9
            let bounds = UIScreen.main.bounds
            yesCityDecidedQuestionView?.button?.addTarget(self, action: #selector(self.yesCityDecidedQuestionView_actuallyDiscoverMoreOptions(sender:)), for: UIControlEvents.touchUpInside)
            self.yesCityDecidedQuestionView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: yesCityDecidedQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (yesCityDecidedQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
        }
        updateHeightOfScrollView()
        scrollDownToTopSubview()
        updateProgress()
    }
    func spawnHowDoYouWantToGetThereQuestionView() {
        if howDoYouWantToGetThereQuestionView == nil {
            //Load next question
            howDoYouWantToGetThereQuestionView = Bundle.main.loadNibNamed("HowDoYouWantToGetThereQuestionView", owner: self, options: nil)?.first! as? HowDoYouWantToGetThereQuestionView
            self.scrollContentView.addSubview(howDoYouWantToGetThereQuestionView!)
            howDoYouWantToGetThereQuestionView?.tag = 10
            let bounds = UIScreen.main.bounds
            howDoYouWantToGetThereQuestionView?.button1?.addTarget(self, action: #selector(self.howDoYouWantToGetThereQuestionView_fly(sender:)), for: UIControlEvents.touchUpInside)
            howDoYouWantToGetThereQuestionView?.button2?.addTarget(self, action: #selector(self.howDoYouWantToGetThereQuestionView_drive(sender:)), for: UIControlEvents.touchUpInside)
            howDoYouWantToGetThereQuestionView?.button3?.addTarget(self, action: #selector(self.howDoYouWantToGetThereQuestionView_busTrainOther(sender:)), for: UIControlEvents.touchUpInside)
            howDoYouWantToGetThereQuestionView?.button4?.addTarget(self, action: #selector(self.howDoYouWantToGetThereQuestionView_iDontKnowHelpMe(sender:)), for: UIControlEvents.touchUpInside)
            howDoYouWantToGetThereQuestionView?.button5?.addTarget(self, action: #selector(self.howDoYouWantToGetThereQuestionView_illAlreadyBeThere(sender:)), for: UIControlEvents.touchUpInside)
            self.howDoYouWantToGetThereQuestionView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: howDoYouWantToGetThereQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (howDoYouWantToGetThereQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
        }
        updateHeightOfScrollView()
        scrollDownToTopSubview()
        updateProgress()
    }
    func spawnFlightSearchQuestionView(){
        if flightSearchQuestionView == nil {
            //Load next question
            flightSearchQuestionView = Bundle.main.loadNibNamed("FlightSearchQuestionView", owner: self, options: nil)?.first! as? FlightSearchQuestionView
            self.scrollContentView.addSubview(flightSearchQuestionView!)
            flightSearchQuestionView?.tag = 11
            let bounds = UIScreen.main.bounds
            flightSearchQuestionView?.searchButton.addTarget(self, action: #selector(self.searchFlights(sender:)), for: UIControlEvents.touchUpInside)
            self.flightSearchQuestionView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: flightSearchQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (flightSearchQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            if let leftDateTimeArrays = SavedPreferencesForTrip["origin_departure_times"]  as? NSMutableDictionary {
                if let rightDateTimeArrays = SavedPreferencesForTrip["return_departure_times"] as? NSMutableDictionary {
                    let departureDictionary = leftDateTimeArrays as Dictionary
                    let returnDictionary = rightDateTimeArrays as Dictionary
                    let departureKeys = Array(departureDictionary.keys)
                    let returnKeys = Array(returnDictionary.keys)
                    if returnKeys.count != 0 {
                        let returnDateValue = returnKeys[0]
                        flightSearchQuestionView?.returnDate.text =  "\(returnDateValue)"
                    }
                    if departureKeys.count != 0 {
                        let departureDateValue = departureKeys[0]
                        flightSearchQuestionView?.departureDate.text =  "\(departureDateValue)"
                    }
                }
            }
        }
        updateHeightOfScrollView()
        scrollDownToTopSubview()
        updateProgress()
    }
    func spawnFlightResultsQuestionView() {
        let controller:flightResultsViewController = self.storyboard!.instantiateViewController(withIdentifier: "flightResultsViewController") as! flightResultsViewController
        controller.willMove(toParentViewController: self)
        self.addChildViewController(controller)
        controller.searchMode = flightSearchQuestionView?.searchMode
        controller.loadView()
        controller.viewDidLoad()
        controller.view.frame = self.view.bounds
        for subview in (flightSearchQuestionView?.subviews)! {
            subview.isHidden = true
        }
        scrollUpButton.isHidden = true
        scrollDownButton.isHidden = true
        
        self.flightSearchQuestionView?.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
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
            spawnYesCityDecidedQuestionView()
        }
    }
    func yesCityDecidedQuestionView_actuallyDiscoverMoreOptions(sender:UIButton) {
        if sender.isSelected == true {
            spawnNoCityDecidedAnyIdeasQuestionView()
        }
    }
    
    func noCityDecidedAnyIdeasQuestionView_noIdeas(sender:UIButton) {
        if sender.isSelected == true {
            spawnWhatTypeOfTripQuestionView()
        }
    }
    
    func planTripToIdeaQuestionView_Yes(sender:UIButton) {
        if sender.isSelected == true {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])
            if destinationsForTrip.count == 0 {
                destinationsForTrip.append((noCityDecidedAnyIdeasQuestionView?.searchController?.searchBar.text)!)
            } else {
                destinationsForTrip[0] = (noCityDecidedAnyIdeasQuestionView?.searchController?.searchBar.text)!
            }
            SavedPreferencesForTrip["destinationsForTrip"] = destinationsForTrip
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            spawnAddAnotherDestinationQuestionViewEvenIfNonNil()
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
    func addAnotherDestinationQuestionView_justDestination(sender:UIButton) {
        if sender.isSelected == true {
            spawnHowDoYouWantToGetThereQuestionView()
        }
    }
    func howDoYouWantToGetThereQuestionView_fly(sender:UIButton) {
        if sender.isSelected == true {
            spawnFlightSearchQuestionView()
        }
    }
    func howDoYouWantToGetThereQuestionView_drive(sender:UIButton) {
        if sender.isSelected == true {
        }
    }
    func howDoYouWantToGetThereQuestionView_busTrainOther(sender:UIButton) {
        if sender.isSelected == true {
        }
    }
    func howDoYouWantToGetThereQuestionView_iDontKnowHelpMe(sender:UIButton) {
        if sender.isSelected == true {
        }
    }
    func howDoYouWantToGetThereQuestionView_illAlreadyBeThere(sender:UIButton) {
        if sender.isSelected == true {
        }
    }
    func searchFlights(sender:UIButton) {
        spawnFlightResultsQuestionView()
    }

    
    // MARK: create subview even if non nil functions
    func spawnAddAnotherDestinationQuestionViewEvenIfNonNil() {
        if addAnotherDestinationQuestionView != nil {
            addAnotherDestinationQuestionView = nil
        }
        spawnAddAnotherDestinationQuestionView()
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

    //MARK: Scrollview delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleScrollUpAndDownButtons()
        animateOutSubview()
    }
    
    // MARK: SAVE TO SINGLETON
    ////// ADD NEW TRIP VARS (NS ONLY) HERE ///////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    override func fetchSavedPreferencesForTrip() -> NSMutableDictionary {
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
        var contactPhoneNumbers = [NSString]()
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
        
        var destinationsForTrip = [NSString]()
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
            
            destinationsForTrip = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "destinationsForTrip") as? [NSString] ?? [NSString]()

            //Activities VC
            selectedActivities = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_activities") as? [NSString] ?? [NSString]()
            //Ranking VC
            topTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "top_trips") as? [NSString] ?? [NSString]()
            rankedPotentialTripsDictionary = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionary") as? [NSDictionary] ?? [NSDictionary]()
            rankedPotentialTripsDictionaryArrayIndex = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionaryArrayIndex") as? NSNumber ?? NSNumber()
            
        }
        
        //SavedPreferences
        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus,"progress": progress, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips,"numberDestinations":numberDestinations,"nonSpecificDates":nonSpecificDates, "rankedPotentialTripsDictionary": rankedPotentialTripsDictionary, "tripID": tripID,"lastVC": lastVC,"firebaseChannelKey": firebaseChannelKey,"rankedPotentialTripsDictionaryArrayIndex": rankedPotentialTripsDictionaryArrayIndex, "timesViewed": timesViewed, "destinationsForTrip": destinationsForTrip] as NSMutableDictionary
        
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
    
    func addChatViewController() {
        controller = self.storyboard!.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        controller?.willMove(toParentViewController: self)
        self.addChildViewController(controller!)
        controller?.loadView()
        controller?.viewDidLoad()
        controller?.view.frame = self.view.bounds
        self.chatView.addSubview((controller?.view)!)
        constrain((controller?.view)!, chatView) { view1, view2 in
            view1.left == view2.left
            view1.top == view2.top
            view1.width == view2.width
            view1.height == view2.height
        }
        controller?.didMove(toParentViewController: self)
        chatView.isHidden = true
    }
    func assistantViewIsHiddenTrue() {
        scrollView.isHidden = true
        scrollUpButton.isHidden = true
        scrollDownButton.isHidden = true
    }
    func assistantViewIsHiddenFalse() {
        scrollView.isHidden = false
        scrollUpButton.isHidden = false
        scrollDownButton.isHidden = false
    }
    
    func assistant() {
        UIView.animate(withDuration: 0.4) {
            self.underline.layer.frame = CGRect(x: 36, y: 25, width: 90, height: 51)
        }
        assistantViewIsHiddenFalse()
        itineraryView.isHidden = true
        chatView.isHidden = true
        self.view.endEditing(true)
    }
    func itinerary() {
        UIView.animate(withDuration: 0.4) {
            self.underline.layer.frame = CGRect(x: 163, y: 25, width: 85, height: 51)
        }
        assistantViewIsHiddenTrue()
        itineraryView.isHidden = false
        chatView.isHidden = true
        self.view.endEditing(true)
    }
    func chat() {
        UIView.animate(withDuration: 0.4) {
            self.underline.layer.frame = CGRect(x: 288, y: 25, width: 50, height: 51)
        }
        assistantViewIsHiddenTrue()
        itineraryView.isHidden = true
        chatView.isHidden = false
        self.view.endEditing(true)
        controller?.inputToolbar.contentView.textView.becomeFirstResponder()
    }
    
    // MARK: Actions
    @IBAction func assistantButtonTouchedUpInside(_ sender: Any) {
        assistant()
    }
    @IBAction func itineraryButtonTouchedUpInside(_ sender: Any) {
        itinerary()
    }
    @IBAction func chatButtonTouchedUpInside(_ sender: Any) {
        chat()
    }
    @IBAction func scrollUpButtonTouchedUpInside(_ sender: Any) {
        scrollUpOneSubview()
    }
    
    @IBAction func scrollDownButtonTouchedUpInside(_ sender: Any) {
        scrollDownOneSubview()
    }
    @IBAction func datePickingSubviewDoneButtonTouchedUpInside(_ sender: Any) {
        animateOutSubview()
    }

}

// MARK: JTCalendarView Extension
extension TripViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = Date()
        let endDate = formatter.date(from: "2018 12 31")
        let parameters = ConfigurationParameters(
            startDate: startDate,
            endDate: endDate!,
            numberOfRows: 6, // Only 1, 2, 3, & 6 are allowed
            calendar: Calendar.current,
            generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfRow,
            firstDayOfWeek: .sunday)
        return parameters
    }
    
    func handleSelection(cell: JTAppleCell?, cellState: CellState) {
        let myCustomCell = cell as? CellView
        
        switch cellState.selectedPosition() {
        case .full:
            myCustomCell?.selectedView.isHidden = false
            myCustomCell?.dayLabel.textColor = DatesPickedOutCalendarView.blackColor
            myCustomCell?.selectedView.layer.backgroundColor = DatesPickedOutCalendarView.whiteColor.cgColor
            myCustomCell?.selectedView.layer.cornerRadius =  ((myCustomCell?.selectedView.frame.height)!/2)
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
        case .left:
            myCustomCell?.selectedView.isHidden = false
            myCustomCell?.dayLabel.textColor = DatesPickedOutCalendarView.blackColor
            myCustomCell?.selectedView.layer.backgroundColor = DatesPickedOutCalendarView.whiteColor.cgColor
            myCustomCell?.selectedView.layer.cornerRadius =  ((myCustomCell?.selectedView.frame.height)!/2)
            myCustomCell?.rightSideConnector.isHidden = false
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            
        case .right:
            myCustomCell?.selectedView.isHidden = false
            myCustomCell?.dayLabel.textColor = DatesPickedOutCalendarView.blackColor
            myCustomCell?.selectedView.layer.backgroundColor = DatesPickedOutCalendarView.whiteColor.cgColor
            myCustomCell?.selectedView.layer.cornerRadius =  ((myCustomCell?.selectedView.frame.height)!/2)
            myCustomCell?.leftSideConnector.isHidden = false
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            
        case .middle:
            myCustomCell?.selectedView.isHidden = true
            myCustomCell?.middleConnector.isHidden = false
            myCustomCell?.middleConnector.layer.backgroundColor = DatesPickedOutCalendarView.transparentWhiteColor
            myCustomCell?.dayLabel.textColor = DatesPickedOutCalendarView.whiteColor
            myCustomCell?.selectedView.layer.cornerRadius =  0
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.leftSideConnector.isHidden = true
        default:
            myCustomCell?.selectedView.isHidden = true
            myCustomCell?.selectedView.layer.backgroundColor = DatesPickedOutCalendarView.transparentColor
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            myCustomCell?.dayLabel.textColor = DatesPickedOutCalendarView.whiteColor
        }
        if cellState.date < Date() {
            myCustomCell?.dayLabel.textColor = DatesPickedOutCalendarView.darkGrayColor
        }
        
        if cellState.dateBelongsTo != .thisMonth  {
            myCustomCell?.dayLabel.textColor = UIColor(cgColor: DatesPickedOutCalendarView.transparentColor)
            myCustomCell?.selectedView.isHidden = true
            myCustomCell?.selectedView.layer.backgroundColor = DatesPickedOutCalendarView.transparentColor
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            return
        }
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        let myCustomCell = calendarView?.dequeueReusableJTAppleCell(withReuseIdentifier: "CellView", for: indexPath) as! CellView
        myCustomCell.dayLabel.text = cellState.text
        if cellState.dateBelongsTo == .previousMonthWithinBoundary || cellState.dateBelongsTo == .followingMonthWithinBoundary {
            myCustomCell.isSelected = false
        }
        
        handleSelection(cell: myCustomCell, cellState: cellState)
        
        return myCustomCell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        if dateEditing == "departureDate" {
        UIView.animate(withDuration: 0.4) {
            self.datePickingSubview.center.y = 473
        }
            dateEditing = "returnDate"
        }
        
        if leftDateTimeArrays.count >= 1 && rightDateTimeArrays.count >= 1 {
            calendarView?.deselectAllDates(triggerSelectionDelegate: false)
            rightDateTimeArrays.removeAllObjects()
            leftDateTimeArrays.removeAllObjects()
            calendarView?.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
        }
        
        //UNCOMMENT FOR TWO CLICK RANGE SELECTION
        let leftKeys = leftDateTimeArrays.allKeys
        let rightKeys = rightDateTimeArrays.allKeys
        if leftKeys.count == 1 && rightKeys.count == 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let leftDate = dateFormatter.date(from: leftKeys[0] as! String)
            if date > leftDate! {
                calendarView?.selectDates(from: leftDate!, to: date,  triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
                let when = DispatchTime.now() + 0.15
                DispatchQueue.main.asyncAfter(deadline: when) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "calendarRangeSelected"), object: nil)
                }
                
            } else {
                calendarView?.deselectAllDates(triggerSelectionDelegate: false)
                rightDateTimeArrays.removeAllObjects()
                leftDateTimeArrays.removeAllObjects()
                calendarView?.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
            }
        }
        
        handleSelection(cell: cell, cellState: cellState)
        
        // Create array of selected dates
        let selectedDates = calendarView?.selectedDates as! [NSDate]
        getLengthOfSelectedAvailabilities()
        
        //        //Update trip preferences in dictionary
        //        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        //        SavedPreferencesForTrip["selected_dates"] = selectedDates
        //        SavedPreferencesForTrip["Availability_segment_lengths"] = lengthOfAvailabilitySegmentsArray as [NSNumber]
        //        //Save
        //        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
        mostRecentSelectedCellDate = date as NSDate
        
        let availableTimeOfDayInCell = ["Anytime"]
        let timeOfDayToAddToArray = availableTimeOfDayInCell.joined(separator: ", ") as NSString
        
        let cell = calendarView?.cellStatus(for: mostRecentSelectedCellDate as Date)
        if cell?.selectedPosition() == .full || cell?.selectedPosition() == .left {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
            leftDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
            flightSearchQuestionView?.departureDate.text =  "\(mostRecentSelectedCellDateAsNSString)"
        }
        if cell?.selectedPosition() == .right {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
            rightDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
            flightSearchQuestionView?.returnDate.text =  "\(mostRecentSelectedCellDateAsNSString)"
        }
        
                //Update trip preferences in dictionary
                let SavedPreferencesForTrip2 = fetchSavedPreferencesForTrip()
                SavedPreferencesForTrip2["origin_departure_times"] = leftDateTimeArrays as NSDictionary
                SavedPreferencesForTrip2["return_departure_times"] = rightDateTimeArrays as NSDictionary
        
                //Save
                saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip2)
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        handleSelection(cell: cell, cellState: cellState)
        getLengthOfSelectedAvailabilities()
        
        if lengthOfAvailabilitySegmentsArray.count > 1 || (leftDates.count > 0 && rightDates.count > 0 && fullDates.count > 0) || fullDates.count > 1 {
            rightDateTimeArrays.removeAllObjects()
            leftDateTimeArrays.removeAllObjects()
            lengthOfAvailabilitySegmentsArray.removeAll()
            calendarView?.deselectAllDates(triggerSelectionDelegate: false)
            return
        }
        
        // Create array of selected dates
        calendarView?.deselectDates(from: date, to: date, triggerSelectionDelegate: false)
        let selectedDates = calendarView?.selectedDates as! [NSDate]
        
        if selectedDates.count > 0 {
            
            var leftMostDate: Date?
            var rightMostDate: Date?
            
            for selectedDate in selectedDates {
                if leftMostDate == nil {
                    leftMostDate = selectedDate as Date
                } else if leftMostDate! > selectedDate as Date {
                    leftMostDate = selectedDate as Date
                }
                if rightMostDate == nil {
                    rightMostDate = selectedDate as Date
                } else if selectedDate as Date > rightMostDate! {
                    rightMostDate = selectedDate as Date
                }
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let leftMostDateAsString = formatter.string (from: leftMostDate!)
            let rightMostDateAsString = formatter.string (from: rightMostDate!)
            if leftDateTimeArrays[leftMostDateAsString] == nil {
                mostRecentSelectedCellDate = leftMostDate! as NSDate
                leftDateTimeArrays.removeAllObjects()
                
                let availableTimeOfDayInCell = ["Anytime"]
                let timeOfDayToAddToArray = availableTimeOfDayInCell.joined(separator: ", ") as NSString
                
                let cell = calendarView?.cellStatus(for: mostRecentSelectedCellDate as Date)
                if cell?.selectedPosition() == .full || cell?.selectedPosition() == .left {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
                    leftDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
                    flightSearchQuestionView?.departureDate.text =  "\(mostRecentSelectedCellDateAsNSString)"
                }
                if cell?.selectedPosition() == .right {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
                    rightDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
                    flightSearchQuestionView?.returnDate.text =  "\(mostRecentSelectedCellDateAsNSString)"
                }
                
                                //Update trip preferences in dictionary
                                let SavedPreferencesForTrip2 = fetchSavedPreferencesForTrip()
                                SavedPreferencesForTrip2["origin_departure_times"] = leftDateTimeArrays as NSDictionary
                                SavedPreferencesForTrip2["return_departure_times"] = rightDateTimeArrays as NSDictionary
                
                                //Save
                                saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip2)
                
            }
            //
            if rightDateTimeArrays[rightMostDateAsString] == nil {
                mostRecentSelectedCellDate = rightMostDate! as NSDate
                rightDateTimeArrays.removeAllObjects()
                
                let availableTimeOfDayInCell = ["Anytime"]
                let timeOfDayToAddToArray = availableTimeOfDayInCell.joined(separator: ", ") as NSString
                
                let cell = calendarView?.cellStatus(for: mostRecentSelectedCellDate as Date)
                if cell?.selectedPosition() == .full || cell?.selectedPosition() == .left {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
                    leftDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
                    flightSearchQuestionView?.departureDate.text =  "\(mostRecentSelectedCellDateAsNSString)"
                }
                if cell?.selectedPosition() == .right {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
                    rightDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
                    flightSearchQuestionView?.returnDate.text =  "\(mostRecentSelectedCellDateAsNSString)"
                }
                
                                //Update trip preferences in dictionary
                                let SavedPreferencesForTrip2 = fetchSavedPreferencesForTrip()
                                SavedPreferencesForTrip2["origin_departure_times"] = leftDateTimeArrays as NSDictionary
                                SavedPreferencesForTrip2["return_departure_times"] = rightDateTimeArrays as NSDictionary
                
                                //Save
                                saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip2)
            }
            
        }
        
                //Update trip preferences in dictionary
                let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                SavedPreferencesForTrip["selected_dates"] = selectedDates as [NSDate]
                SavedPreferencesForTrip["Availability_segment_lengths"] = lengthOfAvailabilitySegmentsArray as [NSNumber]
                //Save
                saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell, cellState: CellState) -> Bool {
        
        if cellState.dateBelongsTo != .thisMonth || cellState.date < Date() {
            return false
        }
        return true
    }
    
    // MARK custom func to get length of selected availability segments
    func getLengthOfSelectedAvailabilities() {
        let selectedDates = calendarView?.selectedDates as! [NSDate]
        leftDates = []
        rightDates = []
        fullDates = []
        lengthOfAvailabilitySegmentsArray = []
        if selectedDates.count > 0 {
            for date in selectedDates {
                if calendarView?.cellStatus(for: date as Date)?.selectedPosition() == .left {
                    leftDates.append(date as Date)
                }
            }
            for date in selectedDates {
                if calendarView?.cellStatus(for: date as Date)?.selectedPosition() == .right {
                    rightDates.append(date as Date)
                }
            }
            for date in selectedDates {
                if calendarView?.cellStatus(for: date as Date)?.selectedPosition() == .full {
                    fullDates.append(date as Date)
                }
            }
            if rightDates != [] && leftDates != [] {
                for segment in 0...leftDates.count - 1 {
                    let segmentAvailability = rightDates[segment].timeIntervalSince(leftDates[segment]) / 86400 + 1
                    lengthOfAvailabilitySegmentsArray.append(Int(segmentAvailability))
                }
            } else {
                lengthOfAvailabilitySegmentsArray = [1]
            }
        } else {
            lengthOfAvailabilitySegmentsArray = [0]
        }
    }
    
    // MARK: Calendar header functions
    // Sets the height of your header
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return MonthSize(defaultSize: 21)
    }
    
    // This setups the display of your header
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        
        let headerCell = calendarView?.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "monthHeaderView", for: indexPath) as! monthHeaderView
        
        // Create Year String
        let yearDateFormatter = DateFormatter()
        yearDateFormatter.dateFormat = "yyyy"
        let YearHeader = yearDateFormatter.string(from: range.start)
        
        //Create Month String
        let monthDateFormatter = DateFormatter()
        monthDateFormatter.dateFormat = "MM"
        let MonthHeader = monthDateFormatter.string(from: range.start)
        
        // Update header
        
        
        if MonthHeader == "01" {
            headerCell.monthLabel.text = "January " + YearHeader
        } else if MonthHeader == "02" {
            headerCell.monthLabel.text = "February " + YearHeader
        } else if MonthHeader == "03" {
            headerCell.monthLabel.text = "March " + YearHeader
        } else if MonthHeader == "04" {
            headerCell.monthLabel.text = "April " + YearHeader
        } else if MonthHeader == "05" {
            headerCell.monthLabel.text = "May " + YearHeader
        } else if MonthHeader == "06" {
            headerCell.monthLabel.text = "June " + YearHeader
        } else if MonthHeader == "07" {
            headerCell.monthLabel.text = "July " + YearHeader
        } else if MonthHeader == "08" {
            headerCell.monthLabel.text = "August " + YearHeader
        } else if MonthHeader == "09" {
            headerCell.monthLabel.text = "September " + YearHeader
        } else if MonthHeader == "10" {
            headerCell.monthLabel.text = "October " + YearHeader
        } else if MonthHeader == "11" {
            headerCell.monthLabel.text = "November " + YearHeader
        } else if MonthHeader == "12" {
            headerCell.monthLabel.text = "December " + YearHeader
        }
        
        return headerCell
}
}
