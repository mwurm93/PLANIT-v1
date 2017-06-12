//
//  SwipingViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/9/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import ContactsUI
import Contacts
import UIColor_FlatColors
import Cartography
import SMCalloutView

class SwipingViewController: UIViewController, UITextFieldDelegate, CNContactPickerDelegate, CNContactViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout, SMCalloutViewDelegate {
    
        //City dict
        var rankedPotentialTripsDictionary = [Dictionary<String, Any>]()
        
        //SMCallout
        var sortFilterFlightsCalloutView = SMCalloutView()
        let sortFilterFlightsCalloutTableView = UITableView(frame: CGRect.zero, style: .plain)
        let filterFirstLevelOptions = ["Activities","Int'l vs. Domestic","Temperature", "Clear fliters"]
        
        //Messaging var
        let messageComposer = MessageComposer()
        
        //Slider vars
        let sliderStep: Float = 1
        
        //Cache color vars
        static let transparentColor = UIColor(colorWithHexValue: 0xFFFFFF, alpha: 0).cgColor
        static let whiteColor = UIColor(colorWithHexValue: 0xFFFFFF, alpha: 1)
        static let transparentWhiteColor = UIColor(colorWithHexValue: 0xFFFFFF, alpha: 0.33).cgColor
        static let darkGrayColor = UIColor(colorWithHexValue: 0x656565, alpha: 1)
        static let blackColor = UIColor(colorWithHexValue: 0x000000, alpha: 1)
        
        //ZLSwipeableView vars
        var colors = ["Turquoise", "Green Sea", "Emerald", "Nephritis", "Peter River", "Belize Hole", "Amethyst", "Wisteria", "Wet Asphalt", "Midnight Blue", "Sun Flower", "Orange", "Carrot", "Pumpkin", "Alizarin", "Pomegranate", "Silver", "Concrete", "Asbestos"]
        var colorIndex = 0
        var cardToLoadIndex = 0
        var loadCardsFromXib = true
        var isTrackingPanLocation = false
        var panGestureRecognizer = UIPanGestureRecognizer()
        var countSwipes = 0
        var totalDailySwipeAllotment = 6
        
        //Contacts vars COPY
        fileprivate var addressBookStore: CNContactStore!
        let picker = CNContactPickerViewController()
        var contacts: [CNContact]?
        var contactIDs: [NSString]?
        var contactPhoneNumbers = [NSString]()
        var editModeEnabled = false
    
        //Instructions
        var instructionsView: instructionsView?
        
        // MARK: Outlets
        @IBOutlet weak var rejectIcon: UIButton!
        @IBOutlet weak var heartIcon: UIButton!
        @IBOutlet weak var nextButton: UIButton!
        @IBOutlet weak var ranOutOfSwipesLabel: UILabel!
        @IBOutlet weak var contactsCollectionView: UICollectionView!
        @IBOutlet weak var popupBlurView: UIVisualEffectView!
        @IBOutlet weak var addContactPlusIconMainVC: UIButton!
        @IBOutlet weak var popupBackgroundViewMainVC: UIVisualEffectView!
        @IBOutlet weak var addFriendsInstructionsView: UIView!
        @IBOutlet weak var detailedCardView: UIScrollView!
        @IBOutlet weak var tripNameLabel: UITextField!
        @IBOutlet weak var popupBackgroundViewDeleteContacts: UIVisualEffectView!
        @IBOutlet weak var popupBackgroundViewDeleteContactsWithinCollectionView: UIVisualEffectView!
        @IBOutlet weak var instructionsGotItButton: UIButton!
        @IBOutlet weak var filterButton: UIButton!
        @IBOutlet weak var inviteFriendsGotItButton: UIButton!
    @IBOutlet weak var swipeableView: ZLSwipeableView!
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            swipeableView.nextView = {
                return self.nextCardView()
            }
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            updateLastVC()
            
            //Setup instructions collection view
            instructionsView = Bundle.main.loadNibNamed("instructionsView", owner: self, options: nil)?.first! as? instructionsView
            instructionsView?.frame.origin.y = 200
            self.view.insertSubview(instructionsView!, aboveSubview: popupBackgroundViewMainVC)
            instructionsView?.isHidden = true
            instructionsGotItButton.isHidden = true
            
//            //City data
            let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
            if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
                if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                    rankedPotentialTripsDictionary = rankedPotentialTripsDictionaryFromSingleton as! [Dictionary<String, AnyObject>]
                }
            }
//                else {
//                    //Load from server
//                    var rankedPotentialTripsDictionaryFromServer = [["price":"$1,000","percentSwipedRight":"100","destination":"Miami","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()],"destinationPhotos":["miami_1","miami_2"],"topThingsToDo":["Vizcaya Museum and Gardens", "American Airlines Arena", "Wynwood Walls", "Boat tours","Zoological Wildlife Foundation"],"averageMonthlyHighs":[String()],"averageMonthlyLows":[String()]]]
//                    
//                    rankedPotentialTripsDictionaryFromServer.append(["price":"$???","percentSwipedRight":"75","destination":"Washington DC","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()],"destinationPhotos":["washingtonDC_1","washingtonDC_2","washingtonDC_3","washingtonDC_4"],"topThingsToDo":["National Mall", "Smithsonian Air and Space Museum" ,"Logan Circle"],"averageMonthlyHighs":[String()],"averageMonthlyLows":[String()]])
//                    
//                    rankedPotentialTripsDictionaryFromServer.append(["price":"$???","percentSwipedRight":"75","destination":"San Diego","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()],"destinationPhotos":["sanDiego_1","sanDiego_2","sanDiego_3","sanDiego_4"],"topThingsToDo":["Sunset Cliffs", "San Diego Zoo" ,"Petco Park"],"averageMonthlyHighs":[String()],"averageMonthlyLows":[String()]])
//                    
//                    rankedPotentialTripsDictionaryFromServer.append(["price":"$???","percentSwipedRight":"75","destination":"Nashville","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()],"destinationPhotos":["nashville_1","nashville_2","nashville_3","nashville_4"],"topThingsToDo":["Grand Ole Opry", "Broadway" ,"Country Music Hall of Fame"],"averageMonthlyHighs":[String()],"averageMonthlyLows":[String()]])
//                    
//                    rankedPotentialTripsDictionaryFromServer.append(["price":"$???","percentSwipedRight":"50","destination":"New Orleans","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()],"destinationPhotos":["newOrleans_1","newOrleans_2","newOrleans_3","newOrleans_4"],"topThingsToDo":["Bourbon Street", "National WWII Museum" ,"Jackson Square"],"averageMonthlyHighs":[String()],"averageMonthlyLows":[String()]])
//                    
//                    rankedPotentialTripsDictionaryFromServer.append(["price":"$???","percentSwipedRight":"50","destination":"Austin","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()],"destinationPhotos":["austin_1","austin_2","austin_3","austin_4"],"topThingsToDo":["Zilker Park", "6th Street" ,"University of Texas"],"averageMonthlyHighs":[String()],"averageMonthlyLows":[String()]])
//                    
//                    rankedPotentialTripsDictionary = rankedPotentialTripsDictionaryFromServer
//                    
//                }
//            }
            
            totalDailySwipeAllotment = rankedPotentialTripsDictionary.count
            
            SavedPreferencesForTrip["rankedPotentialTripsDictionary"] = self.rankedPotentialTripsDictionary
            //Save
            self.saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            
            //SMCalloutView
            self.sortFilterFlightsCalloutView.delegate = self
            self.sortFilterFlightsCalloutView.isHidden = true
            
            sortFilterFlightsCalloutTableView.delegate = self
            sortFilterFlightsCalloutTableView.dataSource = self
            sortFilterFlightsCalloutTableView.frame = CGRect(x: 0, y: 121, width: 100, height: 100)
            sortFilterFlightsCalloutTableView.isEditing = false
            sortFilterFlightsCalloutTableView.allowsMultipleSelection = false
            sortFilterFlightsCalloutTableView.backgroundColor = UIColor.clear
            sortFilterFlightsCalloutTableView.layer.backgroundColor = UIColor.clear.cgColor
            
            self.hideKeyboardWhenTappedAround()
            
            popupBlurView.isUserInteractionEnabled = true
            
            //Load the values from our shared data container singleton
            let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
            //Install the value into the label.
            if tripNameValue != nil {
                self.tripNameLabel.text =  "\(tripNameValue!)"
            }
            tripNameLabel.adjustsFontSizeToFitWidth = true
            tripNameLabel.minimumFontSize = 10
            
            detailedCardView.isHidden = true
            panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panRecognized(recognizer:)))
            panGestureRecognizer.delegate = self
            detailedCardView.addGestureRecognizer(panGestureRecognizer)
            detailedCardView.layer.cornerRadius = 15
            
            
            if self.contacts?.count == 0 || self.contacts == nil {
                self.addContactPlusIconMainVC.setTitle("Invite friends", for: .normal)
                self.addContactPlusIconMainVC.titleLabel?.font = UIFont.systemFont(ofSize: 21)
                self.addContactPlusIconMainVC.frame = CGRect(x: 87, y: 611, width: 201, height: 47)
                self.view.bringSubview(toFront: self.addContactPlusIconMainVC)
            }
            
            //Trip Name textField
            self.tripNameLabel.delegate = self
            
            //COPY FOR CONTACTS
            addressBookStore = CNContactStore()
            
            let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gestureReconizer:)))
            lpgr.minimumPressDuration = 0.5
            lpgr.delaysTouchesBegan = true
            lpgr.delegate = self
            self.contactsCollectionView.addGestureRecognizer(lpgr)
            //
            let atap = UITapGestureRecognizer(target: self, action: #selector(self.dismissInstructions(touch:)))
            atap.numberOfTapsRequired = 1
            atap.delegate = self
            self.popupBackgroundViewMainVC.addGestureRecognizer(atap)
            popupBackgroundViewMainVC.isHidden = true
            popupBackgroundViewMainVC.isUserInteractionEnabled = true
            addFriendsInstructionsView.isHidden = true
            addFriendsInstructionsView.layer.cornerRadius = 10
            //
            let tapOutsideContacts = UITapGestureRecognizer(target: self, action: #selector(self.leaveDeleteContactsMode(touch:)))
            tapOutsideContacts.numberOfTapsRequired = 1
            tapOutsideContacts.delegate = self
            self.popupBackgroundViewDeleteContacts.addGestureRecognizer(tapOutsideContacts)
            popupBackgroundViewDeleteContacts.isHidden = true
            popupBackgroundViewDeleteContacts.isUserInteractionEnabled = true
            //
            let tapOutsideContact = UITapGestureRecognizer(target: self, action: #selector(self.leaveDeleteContactsMode2(touch:)))
            tapOutsideContact.numberOfTapsRequired = 1
            tapOutsideContact.delegate = self
            self.popupBackgroundViewDeleteContactsWithinCollectionView.addGestureRecognizer(tapOutsideContact)
            popupBackgroundViewDeleteContactsWithinCollectionView.isHidden = true
            popupBackgroundViewDeleteContactsWithinCollectionView.isUserInteractionEnabled = true
            
            popupBlurView.alpha = 0
            
            self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
            
            heartIcon.setImage(#imageLiteral(resourceName: "fullHeart"), for: .highlighted)
            rejectIcon.setImage(#imageLiteral(resourceName: "fullX"), for: .highlighted)
            ranOutOfSwipesLabel.isHidden = true
            
            view.autoresizingMask = .flexibleTopMargin
            view.sizeToFit()
            
//            if NewOrAddedTripFromSegue == 1 {
//                nextButton.alpha =  0
//                contactsCollectionView.alpha = 0
//                addContactPlusIconMainVC.alpha = 0
//                
//                let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
//                
//                //Create trip and trip data model
//                if tripNameLabel.text == "New Trip" {
//                    var tripNameValue = "Trip started \(Date().description.substring(to: 10).substring(from: 5))"
//                    //Check if trip name used already
//                    if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && DataContainerSingleton.sharedDataContainer.usertrippreferences?.count != 0 {
//                        var countTripsMadeToday = 0
//                        for trip in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
//                            if (DataContainerSingleton.sharedDataContainer.usertrippreferences?[trip].object(forKey: "trip_name") as? String)!.contains("\(Date().description.substring(to: 10).substring(from: 5))") {
//                                countTripsMadeToday += 1
//                            }
//                        }
//                        if countTripsMadeToday != 0 {
//                            tripNameValue = "Trip " + ("#\(countTripsMadeToday + 1) ") + tripNameValue.substring(from: 5)
//                        }
//                    }
//                    
//                    tripNameLabel.text = tripNameValue
//                    
//                    //Update trip preferences in dictionary
//                    let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//                    SavedPreferencesForTrip["trip_name"] = tripNameValue as NSString
//                    //Save
//                    saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
//                    
//                    //Create trip on server
//                    apollo.perform(mutation: CreateTripMutation(trip: CreateTripInput(tripName: tripNameValue)), resultHandler: { (result, error) in
//                        guard let data = result?.data else { return }
//                        let tripID = data.createTrip?.changedTrip?.id
//                        
//                        let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
//                        SavedPreferencesForTrip["tripID"] = tripID as! NSString
//                        //Save
//                        self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
//                        
//                        print(error ?? "no error message")
//                    })
//                    
//                    //Create new firebase channel
//                    if let name = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String {
//                        newChannelRef = channelsRef.childByAutoId()
//                        let channelItem = [
//                            "name": name
//                        ]
//                        newChannelRef?.setValue(channelItem)
//                        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//                        SavedPreferencesForTrip["firebaseChannelKey"] = newChannelRef?.key as! NSString
//                        //Save
//                        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
//                        
//                    }
//                }
//                
            
                let when = DispatchTime.now() + 0.6
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.animateInstructionsIn()
                }
//            }
//            else {
                retrieveContactsWithStore(store: addressBookStore)
//            }
            
            //ZLSwipeableview
            swipeableView.allowedDirection = .Horizontal
            
            swipeableView.didStart = {view, location in
//                print("Did start swiping view at location: \(location)")
            }
            swipeableView.swiping = {view, location, translation in
//                print("Swiping at view location: \(location) translation: \(translation)")
            }
            swipeableView.didEnd = {view, location in
//                print("Did end swiping view at location: \(location)")
            }
            swipeableView.didSwipe = {view, direction, vector in
                self.countSwipes += 1
                
                if self.totalDailySwipeAllotment - self.countSwipes > 8 {
                    self.swipeableView.numberOfActiveView = 8
                } else {
                    self.swipeableView.numberOfActiveView = UInt(self.totalDailySwipeAllotment - self.countSwipes)
                }
                if self.swipeableView.numberOfActiveView == 0 {
                    self.performSegue(withIdentifier: "destinationSwipingToDestinationRanking", sender: self)
                }
                
                if self.contactPhoneNumbers.count == 0 && self.countSwipes % 3 == 0 {
                    self.addFriendsInstructionsView.sizeToFit()
                    self.contactsCollectionView.isHidden = true
                    let newFrame = CGRect(x: self.addFriendsInstructionsView.frame.minX, y: 500, width: self.addFriendsInstructionsView.frame.width, height: self.addFriendsInstructionsView.frame.height)
                    self.addFriendsInstructionsView.frame = newFrame
                    self.view.bringSubview(toFront: self.addFriendsInstructionsView)
                    self.addFriendsInstructionsView.frame.size.height = 77
                    self.addFriendsInstructionsView.frame.origin.y = 530
                    self.addFriendsInstructionsView.isHidden = false
                    self.addFriendsInstructionsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                    self.addFriendsInstructionsView.alpha = 0
                    self.swipeableView.isUserInteractionEnabled = false
                    UIView.animate(withDuration: 0.4) {
                        self.popupBackgroundViewMainVC.isHidden = false
                        self.addFriendsInstructionsView.alpha = 1
                        self.addFriendsInstructionsView.transform = CGAffineTransform.identity
                    }
                }
                
//                if self.countSwipes == 1 {
//                    self.swipeableView.rewind()
//                    self.countSwipes -= 1
//                }
                
                let when = DispatchTime.now() + 0.8
                
                if direction == .Right {
                    self.heartIcon.isHighlighted = true
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.heartIcon.isHighlighted = false
                    }
                }
                if direction == .Left {
                    self.rejectIcon.isHighlighted = true
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.rejectIcon.isHighlighted = false
                    }
                }
            }
            swipeableView.didCancel = {view in
//                print("Did cancel swiping view")
            }
            swipeableView.didTap = {view, location in
                self.detailedCardView.isHidden = false
                self.view.bringSubview(toFront: self.detailedCardView)
                self.detailedCardView.alpha = 1
                self.detailedCardView.backgroundColor = self.swipeableView.topView()?.backgroundColor
                
                let bounds = UIScreen.main.bounds
                let width = bounds.size.width
                let height = bounds.size.height
                self.detailedCardView.frame = CGRect(x: 0, y: 0, width: width, height: height)
                
                let contentView = Bundle.main.loadNibNamed("CardContentView", owner: self, options: nil)?.first! as! CardView
                contentView.translatesAutoresizingMaskIntoConstraints = false
                contentView.backgroundColor = self.swipeableView.topView()?.backgroundColor
                contentView.layer.cornerRadius = 0
                contentView.layer.shadowOpacity = 0
                contentView.cardToLoad = self.countSwipes
                contentView.cardMode = "detailed"
                
                self.detailedCardView.addSubview(contentView)
                constrain(contentView, self.detailedCardView) { view1, view2 in
                    view1.left == view2.left
                    view1.top == view2.top + 70
                    view1.width == self.detailedCardView.bounds.width
                    view1.height == self.detailedCardView.bounds.height
                }
                self.swipeableView.isUserInteractionEnabled = false
                for subview in contentView.subviews {
                    subview.frame.size.width = width
                }
            }
            swipeableView.didDisappear = { view in
//                print("Did disappear swiping view")
            }
            
            constrain(swipeableView, view) { view1, view2 in
                view1.left == view2.left+30
                view1.right == view2.right-30
                view1.top == view2.top + 105
                view1.bottom == view2.bottom - 150
            }
            
            //Custom animation
            func toRadian(_ degree: CGFloat) -> CGFloat {
                return degree * CGFloat(Double.pi/180)
            }
            func rotateAndTranslateView(_ view: UIView, forDegree degree: CGFloat, translation: CGPoint, duration: TimeInterval, offsetFromCenter offset: CGPoint, swipeableView: ZLSwipeableView) {
                UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
                    view.center = swipeableView.convert(swipeableView.center, from: swipeableView.superview)
                    var transform = CGAffineTransform(translationX: offset.x, y: offset.y)
                    transform = transform.rotated(by: toRadian(degree))
                    transform = transform.translatedBy(x: -offset.x, y: -offset.y)
                    transform = transform.translatedBy(x: translation.x, y: translation.y)
                    view.transform = transform
                }, completion: nil)
            }
            swipeableView.numberOfActiveView = UInt(totalDailySwipeAllotment)
            swipeableView.animateView = {(view: UIView, index: Int, views: [UIView], swipeableView: ZLSwipeableView) in
                let degree = CGFloat(sin(0.5*Double(index)))
                let offset = CGPoint(x: 0, y: swipeableView.bounds.height*0.3)
                let translation = CGPoint(x: degree*10, y: CGFloat(-index*5))
                let duration = 0.4
                rotateAndTranslateView(view, forDegree: degree, translation: translation, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
            }
            
            self.loadCardsFromXib = true
            self.colorIndex = 0
            self.swipeableView.discardViews()
            self.swipeableView.loadViews()
            
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            super.prepare(for: segue, sender: sender)
        }
        
    
        //Dismissing detailed card view
        public func panRecognized(recognizer:UIPanGestureRecognizer) {
            let bounds = UIScreen.main.bounds
            let width = bounds.size.width
            let height = bounds.size.height
            let dismissTriggerOffset = height/5
            
            if recognizer.state == .began && detailedCardView.contentOffset.y == 0 {
                recognizer.setTranslation(CGPoint.zero, in: detailedCardView)
                isTrackingPanLocation = true
            } else if recognizer.state == .cancelled || recognizer.state == .ended && isTrackingPanLocation {
                let panOffset = recognizer.translation(in: detailedCardView)
                if panOffset.y < dismissTriggerOffset {
                    UIView.animate(withDuration: 0.4) {
                        self.detailedCardView.frame = CGRect(x: 0, y: 0, width: width, height: height)
                    }
                }
                isTrackingPanLocation = false
            } else if recognizer.state != .ended && recognizer.state != .cancelled &&
                recognizer.state != .failed && isTrackingPanLocation {
                let panOffset = recognizer.translation(in: detailedCardView)
                if panOffset.y < 0 {
                    isTrackingPanLocation = false
                } else if panOffset.y < dismissTriggerOffset {
                    let panOffset = recognizer.translation(in: detailedCardView)
                    self.detailedCardView.frame = CGRect(x: 0, y: panOffset.y, width: width, height: height)
                } else {
                    recognizer.isEnabled = false
                    recognizer.isEnabled = true
                    swipeableView.isUserInteractionEnabled = true
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        self.detailedCardView.frame = self.swipeableView.frame
                        self.detailedCardView.alpha = 0.6}, completion: { (finished: Bool) in
                            self.detailedCardView.alpha = 0.0}
                    )
                }
            } else {
                isTrackingPanLocation = false
            }
        }
        
        public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith
            otherGestureRecognizer : UIGestureRecognizer)->Bool {
            return true
        }
        
        //ZLFunctions
        func leftButtonAction() {
            self.swipeableView.swipeTopView(inDirection: .Left)
        }
        
        func upButtonAction() {
            self.swipeableView.swipeTopView(inDirection: .Up)
        }
        
        func rightButtonAction() {
            self.swipeableView.swipeTopView(inDirection: .Right)
        }
        
        func downButtonAction() {
            self.swipeableView.swipeTopView(inDirection: .Down)
        }
        
        // MARK: ()
        func nextCardView() -> UIView? {
            if colorIndex >= colors.count {
                colorIndex = 0
            }
            
            if cardToLoadIndex > rankedPotentialTripsDictionary.count - 1 {
                cardToLoadIndex = 0
            }
            
            
            let cardView = CardView(frame: swipeableView.bounds)
            cardView.backgroundColor = colorForName(colors[colorIndex])
            colorIndex += 1
            
            if loadCardsFromXib {
                let contentView = Bundle.main.loadNibNamed("CardContentView", owner: self, options: nil)?.first! as! CardView
                contentView.translatesAutoresizingMaskIntoConstraints = false
                contentView.backgroundColor = cardView.backgroundColor
                contentView.cardToLoad = cardToLoadIndex
                contentView.cardMode = "card"
                cardView.addSubview(contentView)
                
                // This is important:
                // https://github.com/zhxnlai/ZLSwipeableView/issues/9
                /*// Alternative:
                 let metrics = ["width":cardView.bounds.width, "height": cardView.bounds.height]
                 let views = ["contentView": contentView, "cardView": cardView]
                 cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView(width)]", options: .AlignAllLeft, metrics: metrics, views: views))
                 cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView(height)]", options: .AlignAllLeft, metrics: metrics, views: views))
                 */
                constrain(contentView, cardView) { view1, view2 in
                    view1.left == view2.left
                    view1.top == view2.top
                    view1.width == cardView.bounds.width
                    view1.height == cardView.bounds.height
                }
            }
            cardToLoadIndex += 1
            return cardView
        }
        
        func colorForName(_ name: String) -> UIColor {
            let sanitizedName = name.replacingOccurrences(of: " ", with: "")
            let selector = "flat\(sanitizedName)Color"
            return UIColor.perform(Selector(selector)).takeUnretainedValue() as! UIColor
        }
        
        override func viewWillAppear(_ animated: Bool) {
            if self.contacts?.count != 0 && self.contacts != nil {
                self.addContactPlusIconMainVC.setTitle("+", for: .normal)
                self.addContactPlusIconMainVC.titleLabel?.font = UIFont.systemFont(ofSize: 39)
                self.addContactPlusIconMainVC.frame = CGRect(x: 271, y: 611, width: 43, height: 47)
                self.view.bringSubview(toFront: self.addContactPlusIconMainVC)
            } else {
                self.addContactPlusIconMainVC.setTitle("Invite friends", for: .normal)
                self.addContactPlusIconMainVC.titleLabel?.font = UIFont.systemFont(ofSize: 21)
                self.addContactPlusIconMainVC.frame = CGRect(x: 87, y: 611, width: 201, height: 47)
                self.view.bringSubview(toFront: self.addContactPlusIconMainVC)
            }
        }
        
        func animateInstructionsIn(){
            instructionsView?.isHidden = false
            instructionsView?.instructionsCollectionView?.scrollToItem(at: IndexPath(item: 1,section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
            
            instructionsView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            instructionsView?.alpha = 0
            swipeableView.isUserInteractionEnabled = false
            addContactPlusIconMainVC.isHidden = true
            contactsCollectionView.isHidden = true
            UIView.animate(withDuration: 0.4) {
                self.popupBackgroundViewMainVC.isHidden = false
                self.instructionsView?.alpha = 1
                self.instructionsView?.transform = CGAffineTransform.identity
                self.instructionsGotItButton.isHidden = false
            }
        }
        
        func animateInstructionsOut(){
            contactsCollectionView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.instructionsView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.instructionsView?.alpha = 0
                self.popupBackgroundViewMainVC.isHidden = true
                self.swipeableView.isUserInteractionEnabled = true
                if self.countSwipes > 1 {
                    self.contactsCollectionView.isHidden = false
                }
                self.instructionsGotItButton.isHidden = true
                self.addContactPlusIconMainVC.isHidden = false
            }) { (Success:Bool) in
                self.instructionsView?.layer.isHidden = true
            }
            
        }
    
        func dismissInstructions(touch: UITapGestureRecognizer) {
            animateInstructionsOut()
        }
        
        // COPY for Contacts
        func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
            if gestureReconizer.state == UIGestureRecognizerState.began {
                editModeEnabled = true
                popupBackgroundViewDeleteContacts.isHidden = false
                popupBackgroundViewDeleteContactsWithinCollectionView.isHidden = false
                
                for item in self.contactsCollectionView!.visibleCells as! [contactsCollectionViewCell] {
                    let indexPath: IndexPath = self.contactsCollectionView!.indexPath(for: item as contactsCollectionViewCell)!
                    let cell: contactsCollectionViewCell = self.contactsCollectionView!.cellForItem(at: indexPath) as! contactsCollectionViewCell!
                    cell.deleteButton.isHidden = false
                    cell.shakeIcons()
                }
            }
        }
        
        func leaveDeleteContactsMode(touch: UITapGestureRecognizer) {
            dismissDeleteContactsMode()
        }
        
        func leaveDeleteContactsMode2(touch: UITapGestureRecognizer) {
            dismissDeleteContactsMode()
        }
        
        func dismissDeleteContactsMode(){
            self.popupBackgroundViewDeleteContactsWithinCollectionView.isHidden = true
            self.popupBackgroundViewDeleteContacts.isHidden = true
            for item in self.contactsCollectionView!.visibleCells as! [contactsCollectionViewCell] {
                let indexPath: IndexPath = self.contactsCollectionView!.indexPath(for: item as contactsCollectionViewCell)!
                let cell: contactsCollectionViewCell = self.contactsCollectionView!.cellForItem(at: indexPath) as! contactsCollectionViewCell!
                cell.deleteButton.isHidden = true
                cell.stopShakingIcons()
            }
            editModeEnabled = false
        }
        
        // MARK: - UICollectionViewDataSource
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            var numberOfContacts = 0
            if contacts != nil {
                numberOfContacts += contacts!.count
            }
            
            return numberOfContacts
        }
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let contactsCell = contactsCollectionView.dequeueReusableCell(withReuseIdentifier: "contactsCollectionPrototypeCell", for: indexPath) as! contactsCollectionViewCell
            
            let contact = contacts?[indexPath.row]
            
            if (contact?.imageDataAvailable)! {
                contactsCell.thumbnailImage.image = UIImage(data: (contact?.thumbnailImageData!)!)
                contactsCell.thumbnailImage.contentMode = .scaleToFill
                let reCenter = contactsCell.thumbnailImage.center
                contactsCell.thumbnailImage.layer.frame = CGRect(x: contactsCell.thumbnailImage.layer.frame.minX
                    , y: contactsCell.thumbnailImage.layer.frame.minY, width: contactsCell.thumbnailImage.layer.frame.width * 0.91, height: contactsCell.thumbnailImage.layer.frame.height * 0.91)
                contactsCell.thumbnailImage.center = reCenter
                contactsCell.thumbnailImage.layer.cornerRadius = contactsCell.thumbnailImage.frame.height / 2
                contactsCell.thumbnailImage.layer.masksToBounds = true
                contactsCell.initialsLabel.isHidden = true
                contactsCell.thumbnailImageFilter.isHidden = false
                contactsCell.thumbnailImageFilter.image = UIImage(named: "no_contact_image_selected")!
                contactsCell.thumbnailImageFilter.alpha = 0.5
            } else {
                contactsCell.thumbnailImage.image = UIImage(named: "no_contact_image")!
                contactsCell.thumbnailImageFilter.isHidden = true
                contactsCell.initialsLabel.isHidden = false
                let firstInitial = contact?.givenName[0]
                let secondInitial = contact?.familyName[0]
                contactsCell.initialsLabel.text = firstInitial! + secondInitial!
            }
            
            //Delete button
            contactsCell.deleteButton.isHidden = true
            // Give the delete button an index number
            contactsCell.deleteButton.layer.setValue(indexPath.row, forKey: "index")
            // Add an action function to the delete button
            contactsCell.deleteButton.addTarget(self, action: #selector(self.deleteContactButtonTouchedUpInside(sender:)), for: UIControlEvents.touchUpInside)
            
            return contactsCell
        }
        func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            if collectionView == contactsCollectionView {
                
                let visibleCells = self.contactsCollectionView.visibleCells
                
                if editModeEnabled == true {
                    for cell in visibleCells {
                        let visibleCellIndexPath = contactsCollectionView.indexPath(for: cell)
                        let visibleCell = contactsCollectionView.cellForItem(at: visibleCellIndexPath!) as! contactsCollectionViewCell
                        // Shake all of the collection view cells
                        visibleCell.shakeIcons()
                    }
                }
            }
        }
        
        // This function is fired when the collection view stop scrolling
        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            if collectionView == contactsCollectionView {
                
                let visibleCells = self.contactsCollectionView.visibleCells
                
                if editModeEnabled == true {
                    for cell in visibleCells {
                        let visibleCellIndexPath = contactsCollectionView.indexPath(for: cell)
                        let visibleCell = contactsCollectionView.cellForItem(at: visibleCellIndexPath!) as! contactsCollectionViewCell
                        // Shake all of the collection view cells
                        visibleCell.shakeIcons()
                    }
                }
            }
        }
        
        // MARK: - UICollectionViewFlowLayout
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
            if collectionView == contactsCollectionView {
                let picDimension = 55
                return CGSize(width: picDimension, height: picDimension)
            }
            return CGSize(width: 50, height: 50)
        }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            
            
            return UIEdgeInsetsMake(0, 0, 0, 0)
        }
        
        fileprivate func checkContactsAccess() {
            switch CNContactStore.authorizationStatus(for: .contacts) {
            // Update our UI if the user has granted access to their Contacts
            case .authorized:
                self.showContactsPicker()
            // Prompt the user for access to Contacts if there is no definitive answer
            case .notDetermined :
                self.requestContactsAccess()
            // Display a message if the user has denied or restricted access to Contacts
            case .denied,
                 .restricted:
                let alert = UIAlertController(title: "Privacy Warning!",
                                              message: "Please Enable permission! in settings!.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        fileprivate func requestContactsAccess() {
            addressBookStore.requestAccess(for: .contacts) {granted, error in
                if granted {
                    DispatchQueue.main.async {
                        self.showContactsPicker()
                        return
                    }
                }
            }
        }
        
        //Show Contact Picker
        fileprivate  func showContactsPicker() {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            contactIDs = SavedPreferencesForTrip["contacts_in_group"] as? [NSString]
            
            picker.delegate = self
            picker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
            
            if (contactIDs?.count)! > 0 {
                picker.predicateForEnablingContact = NSPredicate(format:"(phoneNumbers.@count > 0) AND NOT (identifier in %@)", contactIDs!)
            } else {
                picker.predicateForEnablingContact = NSPredicate(format:"(phoneNumbers.@count > 0)")
            }
            picker.predicateForSelectionOfContact = NSPredicate(format:"phoneNumbers.@count == 1")
            self.present(picker , animated: true, completion: nil)
        }
        
        func retrieveContactsWithStore(store: CNContactStore) {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            contactIDs = SavedPreferencesForTrip["contacts_in_group"] as? [NSString]
            contactPhoneNumbers = (SavedPreferencesForTrip["contact_phone_numbers"] as? [NSString])!
            
            do {
                if (contactIDs?.count)! > 0 {
                    let predicate = CNContact.predicateForContacts(withIdentifiers: contactIDs! as [String])
                    let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey, CNContactImageDataAvailableKey] as [Any]
                    let updatedContacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                    
                    var reorderedUpdatedContacts = [CNContact]()
                    for contactID in contactIDs! {
                        for updatedContact in updatedContacts {
                            if updatedContact.identifier as NSString == contactID {
                                reorderedUpdatedContacts.append(updatedContact)
                            }
                        }
                    }
                    self.contacts = reorderedUpdatedContacts
                    
                    //Update trip preferences dictionary
                    let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                    SavedPreferencesForTrip["contacts_in_group"] = contactIDs
                    SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
                    
                } else {
                    self.contacts = nil
                }
            } catch {
                print(error)
            }
        }
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
            
            if (contactIDs?.count)! > 0 {
                contacts?.append(contactProperty.contact)
                contactIDs?.append(contactProperty.contact.identifier as NSString)
                let allPhoneNumbersForContact = contactProperty.contact.phoneNumbers
                var indexForCorrectPhoneNumber: Int?
                for indexOfPhoneNumber in 0...(allPhoneNumbersForContact.count - 1) {
                    if allPhoneNumbersForContact[indexOfPhoneNumber].value == contactProperty.value as! CNPhoneNumber {
                        indexForCorrectPhoneNumber = indexOfPhoneNumber
                    }
                }
                let phoneNumberToAdd = contactProperty.contact.phoneNumbers[indexForCorrectPhoneNumber!].value.value(forKey: "digits") as! NSString
                contactPhoneNumbers.append(phoneNumberToAdd)
                
                let numberContactsInTable = (contacts?.count)! - 1
                
                //Update trip preferences dictionary
                let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                SavedPreferencesForTrip["contacts_in_group"] = contactIDs
                SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
                
                //Save updated trip preferences dictionary
                saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
                
                let addedRowIndexPath = [IndexPath(row: numberContactsInTable, section: 0)]
                
                contactsCollectionView.insertItems(at: addedRowIndexPath as [IndexPath])
            }
            else {
                contacts = [contactProperty.contact]
                contactIDs = [contactProperty.contact.identifier as NSString]
                let allPhoneNumbersForContact = contactProperty.contact.phoneNumbers
                var indexForCorrectPhoneNumber: Int?
                for indexOfPhoneNumber in 0...(allPhoneNumbersForContact.count - 1) {
                    if allPhoneNumbersForContact[indexOfPhoneNumber].value == contactProperty.value as! CNPhoneNumber {
                        indexForCorrectPhoneNumber = indexOfPhoneNumber
                    }
                }
                let phoneNumberToAdd = contactProperty.contact.phoneNumbers[indexForCorrectPhoneNumber!].value.value(forKey: "digits") as! NSString
                contactPhoneNumbers = [phoneNumberToAdd]
                
                //Update trip preferences dictionary
                let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                SavedPreferencesForTrip["contacts_in_group"] = contactIDs
                SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
                
                //Save updated trip preferences dictionary
                saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
                
                let addedRowIndexPath = [IndexPath(row: 0, section: 0)]
                contactsCollectionView.insertItems(at: addedRowIndexPath)
            }
            if popupBlurView.alpha == 0 {
                let when = DispatchTime.now() + 0.6
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.spawnMessages()
                }
            }
        }
        
        func spawnMessages() {
            // Make sure the device can send text messages
            if (messageComposer.canSendText()) {
                // Obtain a configured MFMessageComposeViewController
                let messageComposeVC = messageComposer.configuredMessageComposeViewController()
                
                // Present the configured MFMessageComposeViewController instance
                present(messageComposeVC, animated: true, completion: nil)
            } else {
                // Let the user know if his/her device isn't able to send text messages
                let errorAlert = UIAlertController(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.destructive) {
                    (result : UIAlertAction) -> Void in
                }
                
                errorAlert.addAction(cancelAction)
                self.present(errorAlert, animated: true, completion: nil)
            }
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            
            //Update changed preferences as variables
            if (contactIDs?.count)! > 0 {
                contacts?.append(contact)
                contactIDs?.append(contact.identifier as NSString)
                let phoneNumberToAdd = contact.phoneNumbers[0].value.value(forKey: "digits") as! NSString
                contactPhoneNumbers.append(phoneNumberToAdd)
                
                let numberContactsInTable = (contacts?.count)! - 1
                
                //Update trip preferences dictionary
                let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                SavedPreferencesForTrip["contacts_in_group"] = contactIDs
                SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
                
                //Save updated trip preferences dictionary
                saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
                
                let addedRowIndexPath = [IndexPath(row: numberContactsInTable, section: 0)]
                contactsCollectionView.insertItems(at: addedRowIndexPath)
            }
            else {
                contacts = [contact]
                contactIDs = [contact.identifier as NSString]
                let phoneNumberToAdd = contact.phoneNumbers[0].value.value(forKey: "digits") as! NSString
                contactPhoneNumbers = [phoneNumberToAdd]
                
                //Update trip preferences dictionary
                let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                SavedPreferencesForTrip["contacts_in_group"] = contactIDs
                SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
                
                //Save updated trip preferences dictionary
                saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
                
                let addedRowIndexPath = [IndexPath(row: 0, section: 0)]
                contactsCollectionView.insertItems(at: addedRowIndexPath)
            }
            
            if popupBlurView.alpha == 0 {
                let when = DispatchTime.now() + 0.6
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.spawnMessages()
                }
            }
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
        
        // MARK: UITextFieldDelegate
        func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
            // Hide the keyboard.
            tripNameLabel.resignFirstResponder()
            
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            
            if textField == tripNameLabel {
                SavedPreferencesForTrip["trip_name"] = tripNameLabel.text
                //Save
                saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
            }
            
            return true
        }
        func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            return true
        }
        
        // MARK: UITableviewdelegate
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            var numberOfRows = 0
            
            if tableView == sortFilterFlightsCalloutTableView {
                numberOfRows = filterFirstLevelOptions.count
            }
            return numberOfRows
        }
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            //  if tableView == sortFilterFlightsCalloutTableView
            return 22
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            // if tableView == sortFilterFlightsCalloutTableView
            var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellID")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cellID")
            }
            
            cell?.textLabel?.text = filterFirstLevelOptions[indexPath.row]
            cell?.textLabel?.textColor = UIColor.black
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell?.textLabel?.numberOfLines = 0
            cell?.backgroundColor = UIColor.clear
            
            return cell!
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if tableView == sortFilterFlightsCalloutTableView {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                    self.sortFilterFlightsCalloutView.dismissCallout(animated: true)
                    self.sortFilterFlightsCalloutView.isHidden = true
                    //HANDLE SORT / FILTER SELECTION
                })
            }
        }
        
        
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return false
        }
        
    
    
        func deleteContact(indexPath: IndexPath) {
            contacts?.remove(at: indexPath.row)
            contactIDs?.remove(at: indexPath.row)
            contactPhoneNumbers.remove(at: indexPath.row)
            contactsCollectionView.deleteItems(at: [indexPath])
            
            let visibleContactsCells = contactsCollectionView.visibleCells as! [contactsCollectionViewCell]
            for visibleContactCell in visibleContactsCells {
                let newIndexPathForItem = contactsCollectionView.indexPath(for: visibleContactCell)
                visibleContactCell.deleteButton.layer.setValue(newIndexPathForItem?.row, forKey: "index")
            }
            
            if contacts?.count == 0 || contacts == nil {
                addContactPlusIconMainVC.setTitle("Invite friends", for: .normal)
                addContactPlusIconMainVC.titleLabel?.font = UIFont.systemFont(ofSize: 21)
                addContactPlusIconMainVC.frame = CGRect(x: 87, y: 611, width: 201, height: 47)
                self.view.bringSubview(toFront: self.addContactPlusIconMainVC)
                
                dismissDeleteContactsMode()
            }
            
            //Update trip preferences dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["contacts_in_group"] = contactIDs
            SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
            //Save updated trip preferences dictionary
            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        }
        
        //MARK: Actions
        @IBAction func infoButtonTouchedUpInside(_ sender: Any) {
            animateInstructionsIn()
        }
        @IBAction func filterButtonTouchedUpInside(_ sender: Any) {
            if self.sortFilterFlightsCalloutView.isHidden == true {
                sortFilterFlightsCalloutTableView.frame = CGRect(x: 0, y: 539, width: 170, height: 22 * filterFirstLevelOptions.count)
                sortFilterFlightsCalloutTableView.reloadData()
                self.sortFilterFlightsCalloutView.contentView = sortFilterFlightsCalloutTableView
                self.sortFilterFlightsCalloutView.isHidden = false
                self.sortFilterFlightsCalloutView.animation(withType: .stretch, presenting: true)
                self.sortFilterFlightsCalloutView.permittedArrowDirection = .down
                var calloutRect: CGRect = CGRect.zero
                calloutRect.origin = CGPoint(x: filterButton.frame.midX, y: CGFloat(539))
                self.sortFilterFlightsCalloutView.presentCallout(from: calloutRect, in: self.view, constrainedTo: self.view, animated: true)
                
            } else {
                self.sortFilterFlightsCalloutView.dismissCallout(animated: true)
                self.sortFilterFlightsCalloutView.isHidden = true
            }
        }
        func deleteContactButtonTouchedUpInside(sender:UIButton) {
            let i: Int = (sender.layer.value(forKey: "index")) as! Int
            deleteContact(indexPath: IndexPath(row:i, section: 0))
        }
        @IBAction func instructionsGotItTouchedUpInside(_ sender: Any) {
            animateInstructionsOut()
        }
        @IBAction func inviteFriendsGotItButtonTouchedUpInside(_ sender: Any) {
            UIView.animate(withDuration: 0.3, animations: {
                self.addFriendsInstructionsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.addFriendsInstructionsView.alpha = 0
                self.popupBackgroundViewMainVC.isHidden = true
                self.swipeableView.isUserInteractionEnabled = true
                if self.countSwipes > 1 {
                    self.contactsCollectionView.isHidden = false
                }
                
            }) { (Success:Bool) in
                self.addFriendsInstructionsView.layer.isHidden = true
            }
        }
        
        
        @IBAction func tripNameLabelEditingChanged(_ sender: Any) {
            let tripNameValue = tripNameLabel.text! as NSString
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["trip_name"] = tripNameValue
            //Save
            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        }
        @IBAction func nextButtonTouchedUpInside(_ sender: Any) {
            updateCompletionStatus()
        }
        
        @IBAction func addContact(_ sender: Any) {
            checkContactsAccess()
        }
        @IBAction func rejectSelected(_ sender: Any) {
            leftButtonAction()
        }
        
        @IBAction func heartSelected(_ sender: Any) {
            rightButtonAction()
        }
        
    
//        @IBAction func chatButtonIsTouchedUpInside(_ sender: Any) {
//            // Make sure the device can send text messages
//            if (messageComposer.canSendText()) {
//                // Obtain a configured MFMessageComposeViewController
//                let messageComposeVC = messageComposer.configuredMessageComposeViewController()
//                
//                // Present the configured MFMessageComposeViewController instance
//                present(messageComposeVC, animated: true, completion: nil)
//                
//                chatButton.isHidden = true
//                subviewDoneButton.isHidden = false
//                
//            } else {
//                // Let the user know if his/her device isn't able to send text messages
//                let errorAlert = UIAlertController(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", preferredStyle: UIAlertControllerStyle.alert)
//                let cancelAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.destructive) {
//                    (result : UIAlertAction) -> Void in
//                }
//                
//                errorAlert.addAction(cancelAction)
//                self.present(errorAlert, animated: true, completion: nil)
//                
//                chatButton.isHidden = false
//                subviewDoneButton.isHidden = true
//            }
//        }        
    
        //Custom functions
        func updateLastVC(){
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["lastVC"] = "swiping" as NSString
            //Save
            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        }
        
        func updateCompletionStatus(){
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["finished_entering_preferences_status"] = "swiping" as NSString
            //Save
            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        }
        
    ////// ADD NEW TRIP VARS (NS ONLY) HERE ///////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func fetchSavedPreferencesForTrip() -> NSMutableDictionary {
        //Update preference vars if an existing trip
        //Trip status
        let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? 0 as NSNumber
        let finishedEnteringPreferencesStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "finished_entering_preferences_status") as? NSString ?? NSString()
        let lastVC = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "lastVC") as? NSString ?? NSString()
        //New Trip VC
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? NSString ?? NSString()
        let tripID = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "tripID") as? NSString ?? NSString()
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString] ?? [NSString]()
        let contactPhoneNumbers = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contact_phone_numbers") as? [NSString] ?? [NSString]()
        let hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? [NSNumber] ?? [NSNumber]()
        let segmentLengthValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "Availability_segment_lengths") as? [NSNumber] ?? [NSNumber]()
        let selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [NSDate] ?? [NSDate]()
        let leftDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "origin_departure_times") as? NSDictionary ?? NSDictionary()
        let rightDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "return_departure_times") as? NSDictionary ?? NSDictionary()
        let numberDestinations = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "numberDestinations") as? NSNumber ?? NSNumber()
        let nonSpecificDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "nonSpecificDates") as? NSDictionary ?? NSDictionary()
        let firebaseChannelKey = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "firebaseChannelKey") as? NSString ?? NSString()
        //Budget VC
        let budgetValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "budget") as? NSString ?? NSString()
        let expectedRoundtripFare = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_roundtrip_fare") as? NSString ?? NSString()
        let expectedNightlyRate = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_nightly_rate") as? NSString ?? NSString()
        //Suggested Destination VC
        let decidedOnDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_control") as? NSString ?? NSString()
        let decidedOnDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_value") as? NSString ?? NSString()
        let suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? NSString ?? NSString()
        let suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? NSString ?? NSString()
        //Activities VC
        let selectedActivities = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_activities") as? [NSString] ?? [NSString]()
        //Ranking VC
        let topTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "top_trips") as? [NSString] ?? [NSString]()
        let rankedPotentialTripsDictionary = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionary") as? [NSDictionary] ?? [NSDictionary]()
        let rankedPotentialTripsDictionaryArrayIndex = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionaryArrayIndex") as? NSNumber ?? NSNumber()
        
        //SavedPreferences
        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus,"finished_entering_preferences_status": finishedEnteringPreferencesStatus, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips,"numberDestinations":numberDestinations,"nonSpecificDates":nonSpecificDates, "rankedPotentialTripsDictionary": rankedPotentialTripsDictionary, "tripID": tripID,"lastVC": lastVC,"firebaseChannelKey": firebaseChannelKey,"rankedPotentialTripsDictionaryArrayIndex": rankedPotentialTripsDictionaryArrayIndex] as NSMutableDictionary
        
        return fetchedSavedPreferencesForTrip
    }
    func saveUpdatedExistingTrip(SavedPreferencesForTrip: NSMutableDictionary) {
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
    }
}
