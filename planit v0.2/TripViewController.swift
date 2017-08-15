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
import SMCalloutView
import ContactsUI
import Contacts
import Floaty
import SafariServices
import CSVImporter
import UICircularProgressRing
import TwicketSegmentedControl
import ZKPulseView
import MIBadgeButton_Swift

class TripViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, CNContactPickerDelegate, CNContactViewControllerDelegate, UIGestureRecognizerDelegate, FloatyDelegate, TwicketSegmentedControlDelegate, UITextViewDelegate, SMCalloutViewDelegate {

    //MARK: Class variables
    var scrollContentViewHeight: NSLayoutConstraint?
        //View controllers
    var chatController: ChatViewController?
    var flightResultsController: UIViewController?
    var reviewAndBookFlightsController: ReviewAndBookViewController?
    var carRentalResultsController: carRentalResultsViewController?
    var reviewAndBookCarRentalController: ReviewAndBookViewController?
    var hotelResultsController: UIViewController?
    var reviewAndBookHotelController: ReviewAndBookViewController?
        //Itinerary View Controllers
    var hotelBookedOnPlanitController: JRNavigationController?
    var flightBookedOnPlanitController: JRNavigationController?
        //Views
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
    var doYouNeedARentalCarQuestionView: DoYouNeedARentalCarQuestionView?
    var carRentalSearchQuestionView: CarRentalSearchQuestionView?
    var doYouKnowWhereYouWillBeStayingQuestionView: DoYouKnowWhereYouWillBeStayingQuestionView?
    var aboutWhatTimeWillYouStartDrivingQuestionView: AboutWhatTimeWillYouStartDrivingQuestionView?
    var busTrainOtherQuestionView: BusTrainOtherQuestionView?
    var idkHowToGetThereQuestionView: idkHowToGetThereQuestionView?
    var whatTypeOfPlaceToStayQuestionView: WhatTypeOfPlaceToStayQuestionView?
    var hotelSearchQuestionView: HotelSearchQuestionView?
    var shortTermRentalSearchQuestionView: ShortTermRentalSearchQuestionView?
    var stayWithSomeoneIKnowQuestionView: StayWithSomeoneIKnowQuestionView?
    var placeForGroupOrJustYouQuestionView: PlaceForGroupOrJustYouQuestionView?
    var sendProposalQuestionView: SendProposalQuestionView?
    var yesIKnowWhereImStayingQuestionView: YesIKnowWhereImStayingQuestionView?
    var doYouNeedHelpBookingAHotelQuestionView: DoYouNeedHelpBookingAHotelQuestionView?
    var parseDatesForMultipleDestinationsCalendarView: ParseDatesForMultipleDestinationsCalendarView?
    var instructionsQuestionView: InstructionsQuestionView?
    var alreadyHaveFlightsQuestionView: AlreadyHaveFlightsQuestionView?
        //Popover Views
    var didYouBuyTheFlightQuestionPopover: DidYouBuyTheFlightQuestionPopover?
    var didYouBuyTheHotelQuestionView: DidYouBuyTheHotelQuestionView?

        //CalendarView vars
    var leftDates = [Date]()
    var rightDates = [Date]()
    var fullDates = [Date]()
    var lengthOfAvailabilitySegmentsArray = [Int]()
    var leftDateTimeArrays = NSMutableDictionary()
    var rightDateTimeArrays = NSMutableDictionary()
    var mostRecentSelectedCellDate = NSDate()
    var dateEditing = "departureDate"
    var searchMode = "roundtrip"
    
        //Contacts vars COPY
    fileprivate var addressBookStore: CNContactStore!
    let picker = CNContactPickerViewController()
    var contacts: [CNContact]?
    var contactIDs: [NSString]?
    var contactPhoneNumbers = [NSString]()
    var editModeEnabled = false
    var editItineraryModeEnabled = false
    //Messaging var
    let messageComposer = MessageComposer()
        //Firebase channel
    var channelsRef: DatabaseReference = Database.database().reference().child("channels")
    var newChannelRef: DatabaseReference?
        //Singleton
    var NewOrAddedTripFromSegue: Int?
    var isTripSpawnedFromBucketList: Int?
        //City dict
    var rankedPotentialTripsDictionary = [Dictionary<String, Any>]()
        //Loading subviews based on progress
    var functionsToLoadSubviewsDictionary = Dictionary<Int,() -> ()>()
    var subviewFramesDictionary = Dictionary<Int,CGPoint>()
        //FAB
//    var floaty: Floaty?
//    var datesItem: FloatyItem?
//    var destinationItem: FloatyItem?
//    var travelItem: FloatyItem?
//    var placeToStayItem: FloatyItem?
    var progressRing: UICircularProgressRingView?
    var standardProgressIncrement: CGFloat = 10
    var isLoadingSubviews = true
    var totalProgress: CGFloat = 0
        //BookingMode
    var bookingMode = "flight"
        //Date formatting
    var formatter = DateFormatter()
    var backButton: UIButton?
    var segmentedControl: TwicketSegmentedControl?
        //Itinerary Detailed information subview
    var button1: UIButton?
    var textView: UITextView?
    var incompleteColor = UIColor(red: 250/255, green: 190/255, blue: 190/255, alpha: 1)
    var completeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    var detailedInformationSubviewMode = ""
    var isAssistantEnabled = true
    var doneButton: UIButton?
    var itineraryButton2: UIButton?
        //Itinerary info view
    var timesViewed = [String : Int]()
    var infoKeyButton_3_badgeButton: MIBadgeButton?
    var infoKeyButton_4_badgeButton: MIBadgeButton?
    var infoKeyButton_5_badgeButton: MIBadgeButton?
        //SMCalloutView
    var smCalloutView = SMCalloutView()
    var smCalloutViewMode = "itineraryTutorial1"


    //PPN Cities
    var ppnCarRentalCities = [Dictionary<String, String>]()
    var ppnHotelCities = [Dictionary<String, String>]()
    var ppnAirportCities = [Dictionary<String, String>]()
    var stateAbbreviationsDict = [Dictionary<String, String>]()
    var countryAbbreviationsDict = [Dictionary<String, String>]()
    
    // MARK: Outlets
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
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
    @IBOutlet var popupBackgroundFilterView: UIView!
    //Itinerary View Outlets
    @IBOutlet weak var tripNameTextField: UITextField!
    @IBOutlet weak var contactsCollectionView: UICollectionView!
    @IBOutlet weak var addInviteeButton: UIButton!
    @IBOutlet weak var popupBackgroundViewDeleteContactsWithinCollectionView: UIVisualEffectView!
    @IBOutlet weak var popupBackgroundViewDeleteContacts: UIVisualEffectView!
    @IBOutlet weak var itineraryButton1: UIButton!
//    @IBOutlet weak var itineraryButton2: UIButton!
    @IBOutlet weak var itineraryButton3: UIButton!
    @IBOutlet weak var destinationsDatesCollectionView: UICollectionView!
    @IBOutlet var detailedInformationSubview: UIView!
    @IBOutlet weak var popupBackgroundViewEditItineraryWithinCollectionView: UIVisualEffectView!
    @IBOutlet weak var travelSummaryView: UIView!
    @IBOutlet weak var placeToStaySummaryView: UIView!
    @IBOutlet weak var travelSummaryDescriptionButton: UIButton!
    @IBOutlet weak var placetoStaySummaryDescriptionButton: UIButton!
    @IBOutlet weak var infoKeyButton_1: UIButton!
    @IBOutlet weak var infoKeyButton_1_text: UIButton!
    @IBOutlet weak var infoKeyLabel_1: UIButton!
    @IBOutlet weak var infoKeyButton_6: UIButton!
    @IBOutlet weak var infoKeyButton_6_text: UIButton!
    @IBOutlet weak var infoKeyButton_7: UIButton!
    @IBOutlet weak var infoKeyButton_7_text: UIButton!
    @IBOutlet weak var infoKeyLabel_2: UIButton!
    @IBOutlet weak var infoKeyButton_2: UIButton!
    @IBOutlet weak var infoKeyButton_3: UIButton!
    @IBOutlet weak var infoKeyButton_4: UIButton!
    @IBOutlet weak var infoKeyButton_5: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var popupBackgroundFilterViewVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var popupBackgroundFilterViewCloseButton: UIButton!
    @IBOutlet weak var editSwitch: UISwitch!
    @IBOutlet weak var editSwitchLabel: UILabel!
    @IBOutlet weak var searchSummaryLabelTopView: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var hotelMapButton: UIButton!
    @IBOutlet weak var focusBackgroundViewWithinTopView: UIView!
    @IBOutlet weak var focusBackgroundViewWithinItineraryView: UIView!
    @IBOutlet var itineraryTutorialView1: UIView!
    @IBOutlet weak var itineraryTutorialView1_requiresActionByYou: UIButton!
    @IBOutlet weak var itineraryTutorialView1_requiresActionByGroup: UIButton!
    @IBOutlet weak var itineraryTutorialView1_plannedAndConfirmed: UIButton!
    @IBOutlet var itineraryTutorialView2: UIView!
    @IBOutlet var itineraryTutorialView3: UIView!
    @IBOutlet var itineraryTutorialView4: UIView!
    @IBOutlet weak var addInviteeButton_badge: MIBadgeButton!
    
    func handleItineraryTutorial() {
        if smCalloutViewMode == "itineraryTutorial1" {
            itineraryView.isUserInteractionEnabled = false
            
            smCalloutViewMode = "itineraryTutorial2"

            //setup buttons
            //item requires action by you
            itineraryTutorialView1_requiresActionByYou.layer.cornerRadius = (itineraryTutorialView1_requiresActionByYou.frame.height) / 2
            itineraryTutorialView1_requiresActionByYou.layer.borderWidth = 2
            itineraryTutorialView1_requiresActionByYou.layer.borderColor = UIColor.darkGray.cgColor
            itineraryTutorialView1_requiresActionByYou.setTitleColor(UIColor.darkGray, for: .normal)
            //badge button
            let itineraryTutorialView1_requiresActionByYou_badgeButton = MIBadgeButton()
            itineraryTutorialView1_requiresActionByYou_badgeButton.layer.frame.origin = CGPoint(x: itineraryTutorialView1_requiresActionByYou.layer.frame.maxX - 5, y: itineraryTutorialView1_requiresActionByYou.layer.frame.minY + 1)
            itineraryTutorialView1_requiresActionByYou_badgeButton.badgeString = "!"
            itineraryTutorialView1_requiresActionByYou_badgeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            itineraryTutorialView1_requiresActionByYou_badgeButton.badgeTextColor = UIColor.white
            itineraryTutorialView1_requiresActionByYou_badgeButton.badgeBackgroundColor = UIColor.red
            self.itineraryTutorialView1.insertSubview(itineraryTutorialView1_requiresActionByYou_badgeButton, aboveSubview: itineraryTutorialView1_requiresActionByYou)
            
            
            //item requires action by group
            itineraryTutorialView1_requiresActionByGroup.layer.cornerRadius = (itineraryTutorialView1_requiresActionByGroup.frame.height) / 2
            itineraryTutorialView1_requiresActionByGroup.layer.borderWidth = 2
            itineraryTutorialView1_requiresActionByGroup.layer.borderColor = UIColor.darkGray.cgColor
            itineraryTutorialView1_requiresActionByGroup.setTitleColor(UIColor.darkGray, for: .normal)
            //badge button
            let itineraryTutorialView1_requiresActionByGroup_badgeButton = MIBadgeButton()
            itineraryTutorialView1_requiresActionByGroup_badgeButton.layer.frame.origin = CGPoint(x: itineraryTutorialView1_requiresActionByGroup.layer.frame.maxX - 5, y: itineraryTutorialView1_requiresActionByGroup.layer.frame.minY + 1)
            itineraryTutorialView1_requiresActionByGroup_badgeButton.badgeString = "!"
            itineraryTutorialView1_requiresActionByGroup_badgeButton.badgeTextColor = UIColor.white
            itineraryTutorialView1_requiresActionByGroup_badgeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            itineraryTutorialView1_requiresActionByGroup_badgeButton.badgeBackgroundColor = UIColor.orange
            self.itineraryTutorialView1.insertSubview(itineraryTutorialView1_requiresActionByGroup_badgeButton, aboveSubview: itineraryTutorialView1_requiresActionByGroup)
            
            //item complete
            itineraryTutorialView1_plannedAndConfirmed.layer.cornerRadius = (itineraryTutorialView1_plannedAndConfirmed.frame.height) / 2
            itineraryTutorialView1_plannedAndConfirmed.layer.borderWidth = 2
            itineraryTutorialView1_plannedAndConfirmed.layer.borderColor = UIColor.darkGray.cgColor
            itineraryTutorialView1_plannedAndConfirmed.setTitleColor(UIColor.darkGray, for: .normal)
            //badge button
            let itineraryTutorialView1_plannedAndConfirmed_badgeButton = MIBadgeButton()
            itineraryTutorialView1_plannedAndConfirmed_badgeButton.layer.frame.origin = CGPoint(x: itineraryTutorialView1_plannedAndConfirmed.layer.frame.maxX - 5, y: itineraryTutorialView1_plannedAndConfirmed.layer.frame.minY + 1)
            itineraryTutorialView1_plannedAndConfirmed_badgeButton.badgeString = "✓"
            itineraryTutorialView1_plannedAndConfirmed_badgeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            itineraryTutorialView1_plannedAndConfirmed_badgeButton.badgeTextColor = UIColor.white
            itineraryTutorialView1_plannedAndConfirmed_badgeButton.badgeBackgroundColor = UIColor(red: 0, green: 149/255, blue: 0, alpha: 1)
            self.itineraryTutorialView1.insertSubview(itineraryTutorialView1_plannedAndConfirmed_badgeButton, aboveSubview: itineraryTutorialView1_plannedAndConfirmed)
            
            self.focusBackgroundViewWithinTopView.isHidden = false
            self.topView.bringSubview(toFront: focusBackgroundViewWithinTopView)
            self.focusBackgroundViewWithinItineraryView.isHidden = false
            self.itineraryView.bringSubview(toFront: focusBackgroundViewWithinItineraryView)
            self.itineraryView.bringSubview(toFront: destinationsDatesCollectionView)
            
            self.smCalloutView.contentView = itineraryTutorialView1
            self.smCalloutView.isHidden = false
            self.smCalloutView.animation(withType: .stretch, presenting: true)
            self.smCalloutView.permittedArrowDirection = .down
            var calloutRect: CGRect = CGRect.zero
            calloutRect.origin = CGPoint(x: destinationsDatesCollectionView.frame.midX, y: topView.frame.height + destinationsDatesCollectionView.frame.minY)
            self.smCalloutView.presentCallout(from: calloutRect, in: self.view, constrainedTo: self.view, animated: true)

            return
        } else if smCalloutViewMode == "itineraryTutorial2" {
            self.smCalloutView.dismissCallout(animated: true)
            
            self.smCalloutView.contentView = itineraryTutorialView2
            self.smCalloutView.isHidden = false
            self.smCalloutView.animation(withType: .stretch, presenting: true)
            self.smCalloutView.permittedArrowDirection = .down
            var calloutRect: CGRect = CGRect.zero
            calloutRect.origin = CGPoint(x: UIScreen.main.bounds.width / 2, y: CGFloat(295))
            self.smCalloutView.presentCallout(from: calloutRect, in: self.view, constrainedTo: self.view, animated: true)

            smCalloutViewMode = "itineraryTutorial3"
            return
        } else if smCalloutViewMode == "itineraryTutorial3" {
            self.smCalloutView.dismissCallout(animated: true)
            
            self.topView.bringSubview(toFront: focusBackgroundViewWithinTopView)
            self.itineraryView.bringSubview(toFront: focusBackgroundViewWithinItineraryView)
            self.itineraryView.bringSubview(toFront: editSwitch)
            self.itineraryView.bringSubview(toFront: editSwitchLabel)
            
            self.smCalloutView.contentView = itineraryTutorialView3
            self.smCalloutView.isHidden = false
            self.smCalloutView.animation(withType: .stretch, presenting: true)
            self.smCalloutView.permittedArrowDirection = .up
            var calloutRect: CGRect = CGRect.zero
            calloutRect.origin = CGPoint(x: editSwitch.frame.midX, y: topView.frame.height + editSwitch.frame.maxY)
            self.smCalloutView.presentCallout(from: calloutRect, in: self.view, constrainedTo: self.view, animated: true)
 
            smCalloutViewMode = "itineraryTutorial4"
            return
        } else if smCalloutViewMode == "itineraryTutorial4" {
            self.topView.bringSubview(toFront: focusBackgroundViewWithinTopView)
            self.itineraryView.bringSubview(toFront: focusBackgroundViewWithinItineraryView)
            self.itineraryView.bringSubview(toFront: contactsCollectionView)
            self.itineraryView.bringSubview(toFront: addInviteeButton)
            self.itineraryView.bringSubview(toFront: addInviteeButton_badge)
            
            self.smCalloutView.contentView = itineraryTutorialView4
            self.smCalloutView.isHidden = false
            self.smCalloutView.animation(withType: .stretch, presenting: true)
            self.smCalloutView.permittedArrowDirection = .up
            var calloutRect: CGRect = CGRect.zero
            calloutRect.origin = CGPoint(x: addInviteeButton.frame.midX, y: topView.frame.height + addInviteeButton.frame.maxY)
            self.smCalloutView.presentCallout(from: calloutRect, in: self.view, constrainedTo: self.view, animated: true)

            smCalloutViewMode = "itineraryTutorial5"

        } else if smCalloutViewMode == "itineraryTutorial5" {
            self.smCalloutView.dismissCallout(animated: true)
            
            self.focusBackgroundViewWithinTopView.isHidden = true
            self.focusBackgroundViewWithinItineraryView.isHidden = true
            
            itineraryView.isUserInteractionEnabled = true

        }
            //        sortFilterFlightsCalloutTableView.frame = CGRect(x: 0, y: 121, width: 120, height: 22 * filterFirstLevelOptions.count)
//        sortFilterFlightsCalloutTableView.reloadData()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollUpButton.alpha = 0
        self.scrollDownButton.alpha = 0

        
        //SMCalloutView
        self.smCalloutView.delegate = self
        self.smCalloutView.isHidden = true
        //Focus views
        self.focusBackgroundViewWithinTopView.isHidden = true
        self.focusBackgroundViewWithinItineraryView.isHidden = true
        
        self.searchSummaryLabelTopView.isHidden = true
        self.searchSummaryLabelTopView.textAlignment = .center
        self.filterButton.isHidden = true
        self.sortButton.isHidden = true
        self.hotelMapButton.isHidden = true
        self.popupBackgroundFilterView.isHidden = true
        self.addTwicketSegmentedControl()
        self.addBackButtonPointedAtTripList()
        self.setupItineraryInfoView()
        
        //import PPN cities csv
        getCarRentalCities()
        getHotelCities()
        getAirportCities()
        getStateAbbreviations()
        getCountryAbbreviations()
        
        //UPDATE WHEN ADDING SUBVIEWS TO SCROLLVIEW
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
        functionsToLoadSubviewsDictionary[13] = spawnFlightBookingQuestionView
        functionsToLoadSubviewsDictionary[14] = spawnDoYouNeedARentalCarQuestionView
        functionsToLoadSubviewsDictionary[15] = spawnCarRentalSearchQuestionView
        functionsToLoadSubviewsDictionary[16] = spawnRentalCarResultsQuestionView
        functionsToLoadSubviewsDictionary[17] = spawnCarRentalBookingQuestionView
        functionsToLoadSubviewsDictionary[18] = spawnDoYouKnowWhereYouWillBeStayingQuestionView
        functionsToLoadSubviewsDictionary[19] = spawnAboutWhatTimeWillYouStartDrivingQuestionView
        functionsToLoadSubviewsDictionary[20] = spawnBusTrainOtherQuestionView
        functionsToLoadSubviewsDictionary[21] = spawnidkHowToGetThereQuestionView
        functionsToLoadSubviewsDictionary[22] = spawnWhatTypeOfPlaceToStayQuestionView
        functionsToLoadSubviewsDictionary[23] = spawnHotelSearchQuestionView
        functionsToLoadSubviewsDictionary[24] = spawnShortTermRentalSearchQuestionView
        functionsToLoadSubviewsDictionary[25] = spawnStayWithSomeoneIKnowQuestionView
        functionsToLoadSubviewsDictionary[26] = spawnHotelResultsQuestionView
        functionsToLoadSubviewsDictionary[27] = spawnHotelBookingQuestionView
        functionsToLoadSubviewsDictionary[28] = spawnPlaceForGroupOrJustYouQuestionView
        functionsToLoadSubviewsDictionary[29] = spawnSendProposalQuestionView
        functionsToLoadSubviewsDictionary[30] = spawnYesIKnowWhereImStayingQuestionView
        functionsToLoadSubviewsDictionary[31] = spawnDoYouNeedHelpBookingAHotelQuestionView
        functionsToLoadSubviewsDictionary[32] = spawnParseDatesForMultipleDestinationsCalendarView
        functionsToLoadSubviewsDictionary[33] = spawnInstructionsQuestionView
        functionsToLoadSubviewsDictionary[34] = spawnTripNameQuestionView
        functionsToLoadSubviewsDictionary[35] = spawnAlreadyHaveFlightsQuestionView
        
//        hideKeyboardWhenTappedAround()
        
        setUpProgressRing()
        
        //Add shadow to topview
        let borderLine = UIView()
        borderLine.frame = CGRect(x: 0, y: Double(topView.frame.height)-0.5, width: Double(topView.frame.width), height: 0.5)
        borderLine.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        borderLine.layer.shadowColor = UIColor.black.cgColor
        borderLine.layer.shadowRadius = 2.5
        borderLine.layer.masksToBounds = false
        borderLine.layer.shadowOpacity = 1
        borderLine.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.view.addSubview(borderLine)
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()

        let subviewTags = SavedPreferencesForTrip["progress"] as! [Int]

        
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
                spawnInstructionsQuestionView()
            }
        
        if NewOrAddedTripFromSegue == 0 {
            addSubviewsBasedOnProgress()
//            progressRing?.isHidden = false
            self.progressRing?.setProgress(value: totalProgress, animationDuration: 1.0)
            isLoadingSubviews = false
        } else {
  //          progressRing?.isHidden = true
            isLoadingSubviews = false
        }
        
        scrollContentViewHeight = NSLayoutConstraint(item: scrollContentView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: scrollContentView.subviews[scrollContentView.subviews.count - 1].frame.maxY)
        view.addConstraints([scrollContentViewHeight!])
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        
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
                            tripNameValue = "Trip #\(countTripsMadeToday + 1) \(tripNameValue.substring(from: 5))"
                        }
                    }
                    
                    //                tripNameQuestionView?.tripNameQuestionTextfield?.text = tripNameValue
                    
                    //Update trip preferences in dictionary
                    let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                
                    //
                    SavedPreferencesForTrip["assistantMode"] = "initialItineraryBuilding" as! NSString

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
        //Link outs
        NotificationCenter.default.addObserver(self, selector: #selector(openRome2RioSFSafariViewer), name: NSNotification.Name(rawValue: "openRome2RioSFSafariViewer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openGoogleMapsSFSafariViewer), name: NSNotification.Name(rawValue: "openGoogleMapsSFSafariViewer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openAirbnbSFSafariViewer), name: NSNotification.Name(rawValue: "openAirbnbSFSafariViewer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openWanderuSFSafariViewer), name: NSNotification.Name(rawValue: "openWanderuSFSafariViewer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openAmtrakSFSafariViewer), name: NSNotification.Name(rawValue: "openAmtrakSFSafariViewer"), object: nil)

        //Dates
        NotificationCenter.default.addObserver(self, selector: #selector(handleCalendarRangeSelected), name: NSNotification.Name(rawValue: "tripCalendarRangeSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tripCalendarRangeSelectedDoneButtonTouchedUpInside), name: NSNotification.Name(rawValue: "tripCalendarRangeSelectedDoneButtonTouchedUpInside"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tripCalendarRangeSelected_backToItinerary), name: NSNotification.Name(rawValue: "tripCalendarRangeSelected_backToItinerary"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(spawnHowDoYouWantToGetThereQuestionView), name: NSNotification.Name(rawValue: "parseDatesForMultipleDestinationsComplete"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(parseDatesForMultipleDestinationsDateSelected), name: NSNotification.Name(rawValue: "parseDatesForMultipleDestinationsDateSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableAndResetAssistant_moveToItinerary), name: NSNotification.Name(rawValue: "parseDatesForMultipleDestinationsComplete_backToItinerary"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(animateInSubview_Departure), name: NSNotification.Name(rawValue: "animateInDatePickingSubview_Departure"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(animateOutSubview), name: NSNotification.Name(rawValue: "animateOutDatePickingSubview"), object: nil)
        
        //Destination
        NotificationCenter.default.addObserver(self, selector: #selector(whereTravellingFromEntered), name: NSNotification.Name(rawValue: "whereTravellingFromEntered"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(destinationDecidedDestinationChosen), name: NSNotification.Name(rawValue: "destinationDecidedEntered"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(noCityDecidedAnyIdeasQuestionView_ideaEntered), name: NSNotification.Name(rawValue: "destinationIdeaEntered"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(destinationNotDecidedDestinationChosen), name: NSNotification.Name(rawValue: "AddAnotherDestinationQuestionView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(destinationOptionsCardViewSwiped), name: NSNotification.Name(rawValue: "destinationOptionsCardViewSwiped"), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(removeFlightResultsViewController), name: NSNotification.Name(rawValue: "editFlightSearchButtonTouchedUpInside"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(spawnFlightBookingQuestionView), name: NSNotification.Name(rawValue: "flightSelectButtonTouchedUpInside"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(flightSelectedSavedForLater), name: NSNotification.Name(rawValue: "saveFlightForLaterButtonTouchedUpInside"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(bookSelectedFlightToFlightResults), name: NSNotification.Name(rawValue: "bookSelectedFlightToFlightResults"), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(removeCarRentalResultsViewController), name: NSNotification.Name(rawValue: "editCarRentalSearchButtonTouchedUpInside"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(spawnCarRentalBookingQuestionView), name: NSNotification.Name(rawValue: "carRentalSelectButtonTouchedUpInside"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(carRentalSelectedBooked), name: NSNotification.Name(rawValue: "bookCarRentalButtonTouchedUpInside"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(carRentalSelectedSavedForLater), name: NSNotification.Name(rawValue: "saveCarRentalForLaterButtonTouchedUpInside"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(bookSelectedCarRentalToCarRentalResults), name: NSNotification.Name(rawValue: "bookSelectedCarRentalToCarRentalResults"), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(spawnDoYouNeedARentalCarQuestionView), name: NSNotification.Name(rawValue: "busTrainOtherTextViewNextPressed"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(spawnPlaceForGroupOrJustYouQuestionView), name: NSNotification.Name(rawValue: "shortTermRentalTextViewNextPressed"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(spawnPlaceForGroupOrJustYouQuestionView), name: NSNotification.Name(rawValue: "stayWithSomeoneIKnowTextViewNextPressed"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(spawnPlaceForGroupOrJustYouQuestionView), name: NSNotification.Name(rawValue: "hotelDontNeedHelpBookingNextPressed"), object: nil)

//        NotificationCenter.default.addObserver(self, selector: #selector(removeHotelResultsViewController), name: NSNotification.Name(rawValue: "editHotelSearchButtonTouchedUpInside"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(spawnHotelBookingQuestionView), name: NSNotification.Name(rawValue: "hotelSelectButtonTouchedUpInside"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(hotelSelectedBooked), name: NSNotification.Name(rawValue: "bookHotelButtonTouchedUpInside"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(hotelSelectedSavedForLater), name: NSNotification.Name(rawValue: "saveHotelForLaterButtonTouchedUpInside"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(bookSelectedHotelToHotelResults), name: NSNotification.Name(rawValue: "bookSelectedHotelToHotelResults"), object: nil)
        
        
        //Contacts and messages
        NotificationCenter.default.addObserver(self, selector: #selector(handleContactsChanged), name: NSNotification.Name(rawValue: "contactsListChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(spawnContactPickerVC), name: NSNotification.Name(rawValue: "contactPickerVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(spawnMessageComposeVC), name: NSNotification.Name(rawValue: "messageComposeVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(delete), name: NSNotification.Name(rawValue: "deleteInvitee"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reviewItinerary), name: NSNotification.Name(rawValue: "reviewItinerary"), object: nil)
        
        //Flight Nav
        NotificationCenter.default.addObserver(self, selector: #selector(flightSearchResultsSceneViewController_ViewDidAppear), name: NSNotification.Name(rawValue: "flightSearchResultsSceneViewController_ViewDidAppear"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(flightSearchWaitingScreenViewController_ViewDidLoad), name: NSNotification.Name(rawValue: "flightSearchWaitingScreenViewController_ViewDidLoad"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(flightTicketViewViewController_ViewDidLoad), name: NSNotification.Name(rawValue: "flightTicketViewViewController_ViewDidLoad"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(flightSearchFormViewViewController_ViewDidAppear), name: NSNotification.Name(rawValue: "flightSearchFormViewViewController_ViewDidAppear"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(flightBookingBrowserClosed), name: NSNotification.Name(rawValue: "JRSDKFlightBrowserClosed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(flightBookingBrowserClosed_FlightBooked), name: NSNotification.Name(rawValue: "flightBookingBrowserClosed_FlightBooked"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(flightBookingBrowserClosed_FlightNotBooked), name: NSNotification.Name(rawValue: "flightBookingBrowserClosed_FlightNotBooked"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(spawnAlreadyHaveFlightsQuestionView), name: NSNotification.Name(rawValue: "iAlreadyHaveFlightsButtonTouchedUpInside"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(comeBackToPlanFlightLater), name: NSNotification.Name(rawValue: "comeBackToThisFlightsButtonTouchedUpInside"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(JRAirportPicker_ViewDidLoad), name: NSNotification.Name(rawValue: "JRAirportPicker_ViewDidLoad"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(JRDatePicker_ViewDidLoad), name: NSNotification.Name(rawValue: "JRDatePicker_ViewDidLoad"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(JRFilterVC_viewWillAppear), name: NSNotification.Name(rawValue: "JRFilterVC_viewWillAppear"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(flightSearchResultsSceneViewController_doneButtonTouchedUpInside), name: NSNotification.Name(rawValue: "flightSearchResultsSceneViewController_doneButtonTouchedUpInside"), object: nil)
        


        
        //Hotel Nav
        NotificationCenter.default.addObserver(self, selector: #selector(HLCommonResultsVC_viewWillAppear), name: NSNotification.Name(rawValue: "HLCommonResultsVC_viewWillAppear"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hotelSearchFormViewViewController_ViewDidAppear), name: NSNotification.Name(rawValue: "hotelSearchFormViewViewController_ViewDidAppear"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hotelSearchWaitingScreenViewController_ViewDidLoad), name: NSNotification.Name(rawValue: "hotelSearchWaitingScreenViewController_ViewDidLoad"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hotelDetailsViewController_ViewDidAppear), name: NSNotification.Name(rawValue: "hotelDetailsViewController_ViewDidAppear"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hotelBookingBrowserClosed), name: NSNotification.Name(rawValue: "HLWebBrowserClosed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hotelBookingBrowserClosed_HotelBooked), name: NSNotification.Name(rawValue: "hotelBookingBrowserClosed_HotelBooked"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hotelBookingBrowserClosed_HotelNotBooked), name: NSNotification.Name(rawValue: "hotelBookingBrowserClosed_HotelNotBooked"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(comeBackToPlanHotelLater), name: NSNotification.Name(rawValue: "comeBackToThisHotelsButtonTouchedUpInside"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hotelSearchCityPicker_ViewDidLoad), name: NSNotification.Name(rawValue: "hotelSearchCityPicker_ASTGroupedSearchVC_ViewDidLoad"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HLDatePicker_ViewDidLoad), name: NSNotification.Name(rawValue: "HLDatePicker_ViewDidLoad"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hotelSearchKidsPickerViewController_ViewDidLoad), name: NSNotification.Name(rawValue: "hotelSearchKidsPickerViewController_ViewDidLoad"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HLFiltersVC_viewWillAppear), name: NSNotification.Name(rawValue: "HLFiltersVC_viewWillAppear"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HLMapVC_viewWillAppear), name: NSNotification.Name(rawValue: "HLMapVC_viewWillAppear"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HLSortVC_viewWillAppear), name: NSNotification.Name(rawValue: "HLSortVC_viewWillAppear"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hotelSearchResultsViewController_doneButtonTouchedUpInside), name: NSNotification.Name(rawValue: "hotelSearchResultsViewController_doneButtonTouchedUpInside"), object: nil)

        
        
        
        setUpItinerary()
        
        handleScrollUpAndDownButtons()
        
        //COPY FOR CONTACTS
        addressBookStore = CNContactStore()
        retrieveContactsWithStore(store: addressBookStore)
        if (SavedPreferencesForTrip["contacts_in_group"] as? [NSString])?.count == 0 {
            itineraryButton.titleLabel?.textColor = UIColor.gray
            itineraryButton.isEnabled = false
            chatButton.titleLabel?.textColor = UIColor.gray
            chatButton.isEnabled = false
        } else {
            itineraryButton.titleLabel?.textColor = UIColor.white
            itineraryButton.isEnabled = true
            chatButton.titleLabel?.textColor = UIColor.white
            chatButton.isEnabled = true
        }
        
        let SavedPreferencesForTrip_updatedForViewDidLoad = fetchSavedPreferencesForTrip()
        if SavedPreferencesForTrip_updatedForViewDidLoad["assistantMode"] as! String != "initialItineraryBuilding" {
            self.disableAndResetAssistant_moveToItinerary()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if NewOrAddedTripFromSegue == 0 {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            if SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding" {
                updateHeightOfScrollView()
                scrollDownToTopSubview()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
    }
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    // MARK: Custom functions
//    func handleItinerary() {
//        //Handle destinationDatesCollectionView
//        destinationChosenUpdateDatesDestinationsDict()
//
//        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
////        var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])
//        var datesDestinationsDictionary = SavedPreferencesForTrip["datesDestinationsDictionary"] as! [String:[Date]]
////        var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
//        if datesDestinationsDictionary.count == 0 {
//            //hide dates and destination
//        } else if datesDestinationsDictionary["destinationTBD"] != nil {
//            //Show dates
//            //hide destination
//        } else {
//            //Show dates
//            //Show destination
//        }
//        
//    }
    
    func destinationChosenUpdateDatesDestinationsDict() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
        var datesDestinationsDictionary = SavedPreferencesForTrip["datesDestinationsDictionary"] as! [String:[Date]]
        if destinationsForTrip.count == 1 && datesDestinationsDictionary.count > 0 {
            if let dateDestinationForKeyUpdate = datesDestinationsDictionary["destinationTBD"] {
                datesDestinationsDictionary.removeValue(forKey: "destinationTBD")
                datesDestinationsDictionary[destinationsForTrip[0]] = dateDestinationForKeyUpdate
                //Update trip preferences in dictionary
                SavedPreferencesForTrip["datesDestinationsDictionary"] = datesDestinationsDictionary
                saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
            } else {
                
                let changedDestinationKey = Array(datesDestinationsDictionary.keys)
                let dateDestinationForKeyUpdate = datesDestinationsDictionary[changedDestinationKey[0]]
                datesDestinationsDictionary.removeAll()
                datesDestinationsDictionary[destinationsForTrip[0]] = dateDestinationForKeyUpdate
                //Update trip preferences in dictionary
                SavedPreferencesForTrip["datesDestinationsDictionary"] = datesDestinationsDictionary
                saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
            }            
        } else if destinationsForTrip.count > 1 {
            //SPAWN CALENDAR QUESTION VIEW TO PARSE DATES BY DESTINATION
            
            
            var datesDestinationsDictionary = SavedPreferencesForTrip["datesDestinationsDictionary"] as! [String:[Date]]
            if let dateDestinationForKeyUpdate = datesDestinationsDictionary["destinationTBD"] {
                datesDestinationsDictionary.removeValue(forKey: "destinationTBD")
                for i in 0 ... destinationsForTrip.count - 1 {
                    datesDestinationsDictionary[destinationsForTrip[i]] = dateDestinationForKeyUpdate
                }
                //Update trip preferences in dictionary
                SavedPreferencesForTrip["datesDestinationsDictionary"] = datesDestinationsDictionary
                saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
            } else {
                var keys = Array(datesDestinationsDictionary.keys)
                var changedDestinationKey = String()
                var changedDestinationIndex = -1
             //   for i in 0 ... destinationsForTrip.count - 1 {
               //     if !keys.contains(destinationsForTrip[i]) {
                 //       changedDestinationKey = keys[i]
                   //     changedDestinationIndex = i
                    //}
                //}
                var reorderedKeys = [String]()
                for destination in destinationsForTrip {
                    if keys.contains(destination) {
                        reorderedKeys.append(destination)
                    } else {
                        reorderedKeys.append("changedDestinationKey")
                    }
                }
                for i in 0 ... reorderedKeys.count - 1 {
                    if reorderedKeys[i] == "changedDestinationKey" {
                        changedDestinationIndex = i
                    }
                }
                for key in keys {
                    if !reorderedKeys.contains(key) {
                        changedDestinationKey = key
                    }
                }
                if changedDestinationIndex >= 0 {
                    let dateDestinationForKeyUpdate = datesDestinationsDictionary[changedDestinationKey]
                    datesDestinationsDictionary.removeValue(forKey: changedDestinationKey)
                    datesDestinationsDictionary[destinationsForTrip[changedDestinationIndex]] = dateDestinationForKeyUpdate
                    //Update trip preferences in dictionary
                    SavedPreferencesForTrip["datesDestinationsDictionary"] = datesDestinationsDictionary
                    saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
                }
            }
        }
    }
    
    func setUpProgressRing() {
//
//        
//        floaty = Floaty()
//        floaty?.autoCloseOnTap = false
//        floaty?.buttonColor = UIColor.clear
//        floaty?.buttonImage = #imageLiteral(resourceName: "transparent")
//        floaty?.fabDelegate = self
//        floaty?.rotationDegrees = 0
//        
//        placeToStayItem = FloatyItem()
//        placeToStayItem?.buttonColor = UIColor.flatSunFlower()
//        placeToStayItem?.title = "Place to stay"
//        placeToStayItem?.icon = UIImage(named: "changeHotel")
//        placeToStayItem?.handler = { item in
//            self.spawnDoYouKnowWhereYouWillBeStayingQuestionView()
//            self.floaty?.close()
//            self.scrolledToPlaceToStayItem()
//        }
//        floaty?.addItem(item: placeToStayItem!)
//        
//        travelItem = FloatyItem()
//        travelItem?.buttonColor = UIColor.flatCarrot()
//        travelItem?.title = "Travel"
//        travelItem?.icon = UIImage(named: "changeFlight")
//        travelItem?.handler = { item in
//            self.spawnHowDoYouWantToGetThereQuestionView()
////            self.floaty?.close()
//            self.scrolledToTravelItem()
//        }
//        floaty?.addItem(item: travelItem!)
//        
//        destinationItem = FloatyItem()
//        destinationItem?.buttonColor = UIColor.flatTurquoise()
//        destinationItem?.title = "Destination"
//        destinationItem?.icon = UIImage(named: "map")
//        destinationItem?.handler = { item in
//            self.spawnWhereTravellingFromQuestionView()
////            self.floaty?.close()
//            self.scrolledToDestinationItem()
//        }
//        floaty?.addItem(item: destinationItem!)
//        
//        datesItem = FloatyItem()
//        datesItem?.buttonColor = UIColor.flatPeterRiver()
//        datesItem?.title = "Dates"
//        datesItem?.icon = UIImage(named: "Calendar-Time")
//        datesItem?.handler = { item in
//            self.spawnDatesPickedOutCalendarView()
//            self.floaty?.close()
//            self.scrolledToDatesItem()
//        }
////        floaty?.addItem(item: datesItem!)
//
//        self.view.addSubview(floaty!)
    
        
        progressRing = UICircularProgressRingView(frame: CGRect(x: UIScreen.main.bounds.width - 10 - 40, y: 23, width: 40, height: 40))
        progressRing?.maxValue = 100
        progressRing?.startAngle = 270
        progressRing?.ringStyle = .ontop
        progressRing?.outerRingColor = UIColor.white.withAlphaComponent(0.2)
        progressRing?.outerRingWidth = 3
        progressRing?.innerRingColor = UIColor.white
        progressRing?.innerRingWidth = 3
        progressRing?.fontColor = UIColor.white
        progressRing?.font = UIFont.systemFont(ofSize: 13)
        progressRing?.layer.frame.size.height -= 3
        progressRing?.layer.frame.size.width -= 3
        progressRing?.setProgress(value: 0, animationDuration: 0.1) {
            // Do anything your heart desires...
        }
        self.view.addSubview(progressRing!)
        
//        progressRing?.layer.shadowColor = UIColor.black.cgColor
//        progressRing?.layer.shadowRadius = 1
//        progressRing?.layer.masksToBounds = false
//        progressRing?.layer.shadowOpacity = 0.4
//        progressRing?.layer.shadowOffset = CGSize(width: 2, height: 2)

    }
    
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth,height: newHeight))
        image.draw(in: CGRect(x: 0,y:  0,width: newWidth,height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
//    func scrolledToDatesItem() {
//        enableDatesItem()
////        self.floaty?.buttonColor = (self.datesItem?.buttonColor)!
////        self.floaty?.buttonImage = self.resizeImage(image: UIImage(named: "Calendar-Time")!, newWidth: ((self.floaty?.size)! - 25))
////        self.floaty?.removeItem(item: self.placeToStayItem!)
////        self.floaty?.removeItem(item: self.travelItem!)
////        self.floaty?.removeItem(item: self.destinationItem!)
////        self.floaty?.removeItem(item: self.datesItem!)
////        self.floaty?.addItem(item: self.placeToStayItem!)
////        self.floaty?.addItem(item: self.travelItem!)
////        self.floaty?.addItem(item: self.destinationItem!)
//    }
//    func scrolledToDestinationItem() {
//        enableDestinationItem()
////        self.floaty?.buttonColor = (self.destinationItem?.buttonColor)!
////        self.floaty?.buttonImage = self.resizeImage(image: UIImage(named: "map")!, newWidth: ((self.floaty?.size)! - 25))
////        self.floaty?.removeItem(item: self.placeToStayItem!)
////        self.floaty?.removeItem(item: self.travelItem!)
////        self.floaty?.removeItem(item: self.destinationItem!)
////        self.floaty?.removeItem(item: self.datesItem!)
////        self.floaty?.addItem(item: self.placeToStayItem!)
////        self.floaty?.addItem(item: self.travelItem!)
////        self.floaty?.addItem(item: self.datesItem!)
//    }
//    func scrolledToTravelItem() {
//        enableTravelItem()
////        self.floaty?.buttonColor = (self.travelItem?.buttonColor)!
////        self.floaty?.buttonImage = self.resizeImage(image: UIImage(named: "changeFlight")!, newWidth: ((self.floaty?.size)! - 25))
////        self.floaty?.removeItem(item: self.placeToStayItem!)
////        self.floaty?.removeItem(item: self.travelItem!)
////        self.floaty?.removeItem(item: self.destinationItem!)
////        self.floaty?.removeItem(item: self.datesItem!)
////        self.floaty?.addItem(item: self.placeToStayItem!)
////        self.floaty?.addItem(item: self.destinationItem!)
////        self.floaty?.addItem(item: self.datesItem!)
//    }
//    func scrolledToPlaceToStayItem() {
//        enablePlaceToStayItem()
////        self.floaty?.buttonColor = (self.placeToStayItem?.buttonColor)!
////        self.floaty?.buttonImage = self.resizeImage(image: UIImage(named: "changeHotel")!, newWidth: ((self.floaty?.size)! - 25))
////        self.floaty?.removeItem(item: self.placeToStayItem!)
////        self.floaty?.removeItem(item: self.travelItem!)
////        self.floaty?.removeItem(item: self.destinationItem!)
////        self.floaty?.removeItem(item: self.datesItem!)
////        self.floaty?.addItem(item: self.travelItem!)
////        self.floaty?.addItem(item: self.destinationItem!)
////        self.floaty?.addItem(item: self.datesItem!)
//    }

//    func disableDatesItem() {
//        datesItem?.handler = nil
//        datesItem?.buttonColor = UIColor.lightGray
//        datesItem?.titleColor = UIColor.lightGray
//        datesItem?.setNeedsDisplay()
//    }
//    func disableDestinationItem() {
//        destinationItem?.handler = nil
//        destinationItem?.buttonColor = UIColor.lightGray
//        destinationItem?.titleColor = UIColor.lightGray
//        destinationItem?.setNeedsDisplay()
//    }
//    func disableTravelItem() {
//        travelItem?.handler = nil
//        travelItem?.buttonColor = UIColor.lightGray
//        travelItem?.titleColor = UIColor.lightGray
//        travelItem?.setNeedsDisplay()
//    }
//    func disablePlaceToStayItem() {
//        placeToStayItem?.handler = nil
//        placeToStayItem?.buttonColor = UIColor.lightGray
//        placeToStayItem?.titleColor = UIColor.lightGray
//        placeToStayItem?.setNeedsDisplay()
//    }
//    func enableDatesItem() {
//        datesItem?.buttonColor = UIColor.flatPeterRiver()
//        datesItem?.titleColor = UIColor.white
//        datesItem?.handler = { item in
//            self.spawnDatesPickedOutCalendarView()
//            self.floaty?.close()
////            self.floaty?.buttonColor = (self.datesItem?.buttonColor)!
////            self.floaty?.buttonImage = self.resizeImage(image: UIImage(named: "Calendar-Time")!, newWidth: ((self.floaty?.size)! - 25))
////            self.floaty?.removeItem(item: self.placeToStayItem!)
////            self.floaty?.removeItem(item: self.travelItem!)
////            self.floaty?.removeItem(item: self.destinationItem!)
////            self.floaty?.removeItem(item: self.datesItem!)
////            self.floaty?.addItem(item: self.placeToStayItem!)
////            self.floaty?.addItem(item: self.travelItem!)
////            self.floaty?.addItem(item: self.destinationItem!)
//        }
//        datesItem?.setNeedsDisplay()
//    }
//    func enableDestinationItem() {
//        destinationItem?.buttonColor = UIColor.flatTurquoise()
//        destinationItem?.titleColor = UIColor.white
//        destinationItem?.handler = { item in
//            self.spawnWhereTravellingFromQuestionView()
//            self.floaty?.close()
////            self.floaty?.buttonColor = (self.destinationItem?.buttonColor)!
////            self.floaty?.buttonImage = self.resizeImage(image: UIImage(named: "map")!, newWidth: ((self.floaty?.size)! - 25))
////            self.floaty?.removeItem(item: self.placeToStayItem!)
////            self.floaty?.removeItem(item: self.travelItem!)
////            self.floaty?.removeItem(item: self.destinationItem!)
////            self.floaty?.removeItem(item: self.datesItem!)
////            self.floaty?.addItem(item: self.placeToStayItem!)
////            self.floaty?.addItem(item: self.travelItem!)
////            self.floaty?.addItem(item: self.datesItem!)
//        }
//        destinationItem?.setNeedsDisplay()
//    }
//    func enableTravelItem() {
//        travelItem?.buttonColor = UIColor.flatCarrot()
//        travelItem?.titleColor = UIColor.white
//        travelItem?.handler = { item in
//            self.spawnHowDoYouWantToGetThereQuestionView()
//            self.floaty?.close()
////            self.floaty?.buttonColor = (self.travelItem?.buttonColor)!
////            self.floaty?.buttonImage = self.resizeImage(image: UIImage(named: "changeFlight")!, newWidth: ((self.floaty?.size)! - 25))
////            self.floaty?.removeItem(item: self.placeToStayItem!)
////            self.floaty?.removeItem(item: self.travelItem!)
////            self.floaty?.removeItem(item: self.destinationItem!)
////            self.floaty?.removeItem(item: self.datesItem!)
////            self.floaty?.addItem(item: self.placeToStayItem!)
////            self.floaty?.addItem(item: self.destinationItem!)
////            self.floaty?.addItem(item: self.datesItem!)
//        }
//        travelItem?.setNeedsDisplay()
//    }
//    func enablePlaceToStayItem() {
//        placeToStayItem?.buttonColor = UIColor.flatSunFlower()
//        placeToStayItem?.titleColor = UIColor.white
//        placeToStayItem?.handler = { item in
//            self.spawnDoYouKnowWhereYouWillBeStayingQuestionView()
//            self.floaty?.close()
////            self.floaty?.buttonColor = (self.placeToStayItem?.buttonColor)!
////            self.floaty?.buttonImage = self.resizeImage(image: UIImage(named: "changeHotel")!, newWidth: ((self.floaty?.size)! - 25))
////            self.floaty?.removeItem(item: self.placeToStayItem!)
////            self.floaty?.removeItem(item: self.travelItem!)
////            self.floaty?.removeItem(item: self.destinationItem!)
////            self.floaty?.removeItem(item: self.datesItem!)
////            self.floaty?.addItem(item: self.travelItem!)
////            self.floaty?.addItem(item: self.destinationItem!)
////            self.floaty?.addItem(item: self.datesItem!)
//        }
//        placeToStayItem?.setNeedsDisplay()
//    }

    func buttonClicked(sender:UIButton) {
        if sender == itineraryButton2 {
            sender.setButtonWithTransparentText(button: sender, title: sender.currentTitle as! NSString, color: UIColor.white)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "messageComposeVC"), object: nil)
            
            itineraryButton2?.stopPulseEffect()
        }

        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.setButtonWithTransparentText(button: sender, title: sender.currentTitle as! NSString, color: UIColor.white)
            if sender == itineraryButton2 {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "messageComposeVC"), object: nil)
                
                itineraryButton2?.stopPulseEffect()
            }
        }
        
        
    }
    
    func spawnContactPickerVC() {
        
        checkContactsAccess()
    }
    func spawnMessageComposeVC() {
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
    func animateInSubview_Departure(){
        
//        var fromDate = Date()
//        var toDate = Date()
//        formatter.dateFormat = "MM/dd/yy"
//        if bookingMode == "flight" {
//            if flightSearchQuestionView?.returnDate?.isHidden == false {
//                let fromDateInTextfield = (flightSearchQuestionView?.departureDate?.text)!
//                let toDateInTextfield = (flightSearchQuestionView?.returnDate?.text)!
//                fromDate = formatter.date(from: fromDateInTextfield)!
//                toDate = formatter.date(from: toDateInTextfield)!
//                calendarView.selectDates(from: fromDate, to: toDate)
//            } else  {
//                let fromDateInTextfield = (flightSearchQuestionView?.departureDate?.text)!
//                fromDate = formatter.date(from: fromDateInTextfield)!
//                calendarView.selectDates([fromDate])
//            }
//        } else if bookingMode == "carRental" {
//            fromDate = formatter.date(from: (carRentalSearchQuestionView?.pickUpDate?.text)!)!
//            toDate = formatter.date(from: (carRentalSearchQuestionView?.dropOffDate?.text)!)!
//            calendarView.selectDates(from: fromDate, to: toDate)
//        } else if bookingMode == "hotel" {
//            fromDate = formatter.date(from: (hotelSearchQuestionView?.checkInDate?.text)!)!
//            toDate = formatter.date(from: (hotelSearchQuestionView?.checkOutDate?.text)!)!
//            calendarView.selectDates(from: fromDate, to: toDate)
//        }
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
        var heightOfScrollView: CGFloat = 0
        if scrollContentView.subviews.count > 0 {
            heightOfScrollView = scrollContentView.subviews[scrollContentView.subviews.count - 1].frame.maxY
        }
        scrollContentViewHeight?.constant = heightOfScrollView
        scrollContentView.frame.size.height = heightOfScrollView
        scrollView.contentSize.height = heightOfScrollView
    }
    func scrollDownToTopSubview(){
        let tagOfTopSubview = self.scrollContentView.subviews[self.scrollContentView.subviews.count - 1].tag
        self.scrollToSubviewWithTag(tag:tagOfTopSubview)
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
        
        // kill scrolling buttons
//        self.scrollUpButton.isHidden = true
//        self.scrollDownButton.isHidden = true
    }
    
    func addSubviewsBasedOnProgress() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let subviewTags = SavedPreferencesForTrip["progress"] as! [Int]
        for subviewTag in subviewTags {
            self.functionsToLoadSubviewsDictionary[subviewTag]!()
        }
//        progressRing?.layer.frame = (floaty?.frame)!
//        progressRing?.layer.frame.size.height -= 15
//        progressRing?.layer.frame.size.width -= 15
    }
    func updateProgress() {
        var currentSubviewsInScrollContentView = [Int]()
        for subview in scrollContentView.subviews {
            if subview != userNameQuestionView {
                currentSubviewsInScrollContentView.append(subview.tag)
                subviewFramesDictionary[subview.tag] = subview.frame.origin
            }
        }
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["progress"] = currentSubviewsInScrollContentView as [NSNumber]
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
        let SavedPreferencesForTripTEST = fetchSavedPreferencesForTrip()
        let subviewTags = SavedPreferencesForTripTEST["progress"] as! [Int]

    }
    func getCurrentSubview() {
        var currentSubview = Int()
        for subview in scrollContentView.subviews {
            if subview.frame.intersects(scrollView.bounds) {
                currentSubview = subview.tag
            }
        }
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["currentAssistantSubview"] = currentSubview as NSNumber
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    func checkInitiatorProgress() -> String {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let currentSubviewsInScrollContentView = SavedPreferencesForTrip["progress"] as! [Int]

        //UPDATE WHEN ADDING SUBVIEWS TO SCROLLVIEW
        let datesSubviews = [1,32]
        let destinationSubviews = [0,2,3,4,5,6,7,8,9]
        let travelSubviews = [10,11,12,13,14,15,16,17,19,20,21,35]
        let placeToStaySubviews = [18,22,23,24,25,26,27,28,30,31]
        let otherSubviews = [29,33,34]
        
        var initiatorProgress = ""
        
        for dateSubview in datesSubviews {
            if currentSubviewsInScrollContentView.contains(dateSubview) {
                initiatorProgress = "dates"
            }
        }
        for destinationSubview in destinationSubviews {
            if currentSubviewsInScrollContentView.contains(destinationSubview) {
                initiatorProgress = "destination"
            }
        }
        for travelSubview in travelSubviews {
            if currentSubviewsInScrollContentView.contains(travelSubview) {
                initiatorProgress = "travel"
            }
        }
        for placeToStaySubview in placeToStaySubviews {
            if currentSubviewsInScrollContentView.contains(placeToStaySubview) {
                initiatorProgress = "placeToStay"
            }
        }

        return initiatorProgress
    }
//    func handleFloatyBasedOnProgressOfInitiator() {
//        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//        let currentSubview = SavedPreferencesForTrip["currentAssistantSubview"] as! Int
//        
//        //UPDATE WHEN ADDING SUBVIEWS TO SCROLLVIEW
//        let datesSubviews = [1,32]
//        let destinationSubviews = [0,2,3,4,5,6,7,8,9]
//        let travelSubviews = [10,11,12,13,14,15,16,17,19,20,21,35]
//        let placeToStaySubviews = [18,22,23,24,25,26,27,28,30,31]
//        let otherSubviews = [29,33,34]
//        
//        if datesSubviews.contains(currentSubview) {
//            scrolledToDatesItem()
//        } else if destinationSubviews.contains(currentSubview) {
//            scrolledToDestinationItem()
//        } else if travelSubviews.contains(currentSubview) {
//            scrolledToTravelItem()
//        } else if placeToStaySubviews.contains(currentSubview) {
//            scrolledToPlaceToStayItem()
//        }
//    }
    func scrollToSubviewWithTag(tag:Int){
        let topOfSubview = subviewFramesDictionary[tag]
        UIView.animate(withDuration: 1) {
            self.scrollView.setContentOffset(topOfSubview!, animated: false)
        }
        asyncUpdateProgress()
    }
    func alignSubviews() {
        
        for i in 1 ... scrollContentView.subviews.count - 1 {
            let higherSubviewBottomY = scrollContentView.subviews[i - 1].frame.maxY
            let lowerSubviewTopY = scrollContentView.subviews[i].frame.minY
            let differenceToAdjustLowerSubviewBy = higherSubviewBottomY - lowerSubviewTopY
            if differenceToAdjustLowerSubviewBy != 0 && scrollContentView.subviews[i - 1] != instructionsQuestionView {
                scrollContentView.subviews[i].frame.origin.y += differenceToAdjustLowerSubviewBy
            }
        }
        updateHeightOfScrollView()
        updateProgress()
    }
    
    func increaseProgressCircle(byPercent: CGFloat, onlyIfFirstDestination: Bool) {
        if isLoadingSubviews {
            totalProgress += byPercent
        } else {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            if onlyIfFirstDestination {
                if indexOfDestinationBeingPlanned == 0 {
                    var currentProgress = self.progressRing?.currentValue
                    if currentProgress == nil {
                        currentProgress = 0
                    } else {
                        if (currentProgress! + byPercent) > 99 {
                            self.progressRing?.setProgress(value: 99, animationDuration: 1.0) {
                            }
                            return
                        }
                    }
                    
                    self.progressRing?.setProgress(value: currentProgress! + byPercent, animationDuration: 1.0) {
                    }
                }
            } else {
                var currentProgress = self.progressRing?.currentValue
                if currentProgress == nil {
                    currentProgress = 0
                } else {
                    if (currentProgress! + byPercent) > 99 {
                        self.progressRing?.setProgress(value: 99, animationDuration: 1.0) {
                        }
                        return
                    }
                }
                self.progressRing?.setProgress(value: currentProgress! + byPercent, animationDuration: 1.0) {
                }
            }

        }
    }
    
    
    
    
    
    
    
    
    //MARK: Functions for spawning subviews in scrollview
    func spawnUserNameQuestionView() {
        userNameQuestionView = Bundle.main.loadNibNamed("UserNameQuestionView", owner: self, options: nil)?.first! as? UserNameQuestionView
        self.scrollContentView.addSubview(userNameQuestionView!)
        userNameQuestionView?.userNameQuestionTextfield?.delegate = self
        userNameQuestionView?.userNameQuestionTextfield?.becomeFirstResponder()
        let bounds = UIScreen.main.bounds
        self.userNameQuestionView!.frame = CGRect(x: 0, y: self.topView.frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
        let heightConstraint = NSLayoutConstraint(item: userNameQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (userNameQuestionView?.frame.height)!)
        view.addConstraints([heightConstraint])
        updateHeightOfScrollView()
    }
    
    func spawnInstructionsQuestionView() {
        self.view.endEditing(true)
        if userNameQuestionView != nil {
            userNameQuestionView?.removeFromSuperview()
            userNameQuestionView = nil
        }
        if instructionsQuestionView == nil  {
            //Load next question
            instructionsQuestionView = Bundle.main.loadNibNamed("InstructionsQuestionView", owner: self, options: nil)?.first! as? InstructionsQuestionView
            instructionsQuestionView?.tag = 33
            self.scrollContentView.addSubview(instructionsQuestionView!)
            instructionsQuestionView?.button1?.addTarget(self, action: #selector(self.instructionsQuestionView_gotIt(sender:)), for: UIControlEvents.touchUpInside)
            let bounds = UIScreen.main.bounds
            
            if userNameQuestionView != nil {
                self.instructionsQuestionView!.frame = CGRect(x: 0, y: (userNameQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else {
                self.instructionsQuestionView!.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            }
            let heightConstraint = NSLayoutConstraint(item: instructionsQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (instructionsQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            let questionLabelValue = "Hi \(String(describing: DataContainerSingleton.sharedDataContainer.firstName!))!\n\nWith Planit it's easy\nto make an itinerary\nand share it with friends!"
            instructionsQuestionView?.questionLabel1?.text = questionLabelValue
        }
        if userNameQuestionView != nil {
            alignSubviews()
            scrollToSubviewWithTag(tag: 33)
        }
        if NewOrAddedTripFromSegue == 1 {
            updateProgress()
        } else  {
            for subview in scrollContentView.subviews {
                if subview != userNameQuestionView {
                    subviewFramesDictionary[subview.tag] = subview.frame.origin
                }
            }
        }

        increaseProgressCircle(byPercent: standardProgressIncrement, onlyIfFirstDestination: false)
    }
    
    func spawnTripNameQuestionView() {
        if tripNameQuestionView == nil {
            //Load next question
            tripNameQuestionView = Bundle.main.loadNibNamed("TripNameQuestionView", owner: self, options: nil)?.first! as? TripNameQuestionView
            tripNameQuestionView?.tripNameQuestionButton?.addTarget(self, action: #selector(self.tripNameQuestionButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
            self.scrollContentView.insertSubview(tripNameQuestionView!, aboveSubview: instructionsQuestionView!)
            
            tripNameQuestionView?.tripNameQuestionTextfield?.delegate = self
            if !isLoadingSubviews {
                tripNameQuestionView?.tripNameQuestionTextfield?.becomeFirstResponder()
            }

            tripNameQuestionView?.tag = 34
            let bounds = UIScreen.main.bounds
            
            self.tripNameQuestionView!.frame = CGRect(x: 0, y: (instructionsQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)

            let heightConstraint = NSLayoutConstraint(item: tripNameQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (tripNameQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 34)
        increaseProgressCircle(byPercent: standardProgressIncrement, onlyIfFirstDestination: false)
    }
    
    
    func spawnDatesPickedOutCalendarView() {
        tripNameQuestionView?.tripNameQuestionTextfield?.resignFirstResponder()
        self.view.endEditing(true)
        if datesPickedOutCalendarView == nil  {
            //handle floaty
//            disableDestinationItem()
//            disableTravelItem()
//            disablePlaceToStayItem()
//            floaty?.alpha = 0
//            progressRing?.layer.frame = CGRect(x: UIScreen.main.bounds.width - 10 - 30, y: 28, width: 30, height: 30)
//            progressRing?.layer.frame.size.height -= 15
//            progressRing?.layer.frame.size.width -= 15
            //progressRing?.alpha = 0
            //progressRing?.isHidden = false
            //let when = DispatchTime.now() + 0.8
            //DispatchQueue.main.asyncAfter(deadline: when) {
              //  UIView.animate(withDuration: 0.3) {
//                    self.floaty?.alpha = 1
                //    self.progressRing?.alpha = 1
                //}
            //}

            
//            scrolledToDatesItem()
            //Load next question
            datesPickedOutCalendarView = Bundle.main.loadNibNamed("DatesPickedOutCalendarView", owner: self, options: nil)?.first! as? DatesPickedOutCalendarView
            datesPickedOutCalendarView?.tag = 1
            let bounds = UIScreen.main.bounds
            if tripNameQuestionView != nil {
                self.scrollContentView.insertSubview(datesPickedOutCalendarView!, aboveSubview: tripNameQuestionView!)
                self.datesPickedOutCalendarView!.frame = CGRect(x: 0, y: (tripNameQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else {
                self.scrollContentView.addSubview(datesPickedOutCalendarView!)
                self.datesPickedOutCalendarView!.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            }
            datesPickedOutCalendarView?.button1?.addTarget(self, action: #selector(self.datesPickedOutCalendarView_backToTravelDates(sender:)), for: UIControlEvents.touchUpInside)
            
            let heightConstraint = NSLayoutConstraint(item: datesPickedOutCalendarView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (datesPickedOutCalendarView?.frame.height)!)
            let test = (datesPickedOutCalendarView?.frame.height)!
            view.addConstraints([heightConstraint])
        
        updateHeightOfScrollView()
        updateProgress()
        increaseProgressCircle(byPercent: standardProgressIncrement, onlyIfFirstDestination: false)
        }
        scrollToSubviewWithTag(tag: 1)
        
        let when = DispatchTime.now() + 1.4
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.datesPickedOutCalendarView?.calendarView.flashScrollIndicators()
        }
    }
    func spawnWhereTravellingFromQuestionView(){
        if whereTravellingFromQuestionView == nil {
            
            //Load next question
            whereTravellingFromQuestionView = Bundle.main.loadNibNamed("WhereTravellingFromQuestionView", owner: self, options: nil)?.first! as? WhereTravellingFromQuestionView
            whereTravellingFromQuestionView?.tag = 0
//            let fuckedSubviewIswhereTravellingFromQuestionView = whereTravellingFromQuestionView!
//            let fuckedSubviewIsdatesPickedOutCalendarView = datesPickedOutCalendarView!
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            if datesPickedOutCalendarView == nil && SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding"{
                spawnDatesPickedOutCalendarView()
            }
            let bounds = UIScreen.main.bounds
            if tripNameQuestionView != nil {
                self.scrollContentView.insertSubview(whereTravellingFromQuestionView!, aboveSubview: datesPickedOutCalendarView!)
                self.whereTravellingFromQuestionView!.frame = CGRect(x: 0, y: (datesPickedOutCalendarView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else {
                self.scrollContentView.addSubview(whereTravellingFromQuestionView!)
                self.whereTravellingFromQuestionView!.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            }
            
            if SavedPreferencesForTrip["assistantMode"] as! String == "startingPoint" {
                whereTravellingFromQuestionView?.button1?.addTarget(self, action: #selector(self.whereTravellingFromQuestionView_backToItinerary), for: UIControlEvents.touchUpInside)
                
            } else if SavedPreferencesForTrip["assistantMode"] as! String == "endingPoint" {
                self.whereTravellingFromQuestionView?.button1?.addTarget(self, action: #selector(self.whereTravellingFromQuestionView_backToItinerary), for: UIControlEvents.touchUpInside)
                self.whereTravellingFromQuestionView?.searchController?.searchBar.text = (SavedPreferencesForTrip["endingPoint"] as! String)
                self.whereTravellingFromQuestionView?.questionLabel?.text = "Where do you want to end your trip?"
            } else {
                whereTravellingFromQuestionView?.button1?.addTarget(self, action: #selector(self.spawnYesCityDecidedQuestionView), for: UIControlEvents.touchUpInside)
            }

            let heightConstraint = NSLayoutConstraint(item: whereTravellingFromQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (whereTravellingFromQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            
            increaseProgressCircle(byPercent: standardProgressIncrement, onlyIfFirstDestination: false)
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 0)
        //        whereTravellingFromQuestionView?.searchController?.searchBar.becomeFirstResponder()
    }
    func spawnDecidedOnCityQuestionView() {
        // LINK TO ITINERARY
        // SHOW USER WHERE CHOSE DATES ARE SAVED
        
        if decidedOnCityToVisitQuestionView == nil {
            //Load next question
            decidedOnCityToVisitQuestionView = Bundle.main.loadNibNamed("DecidedOnCityToVisitQuestionView", owner: self, options: nil)?.first! as? DecidedOnCityToVisitQuestionView
            decidedOnCityToVisitQuestionView?.tag = 2
            self.scrollContentView.insertSubview(decidedOnCityToVisitQuestionView!, aboveSubview: whereTravellingFromQuestionView!)
            let bounds = UIScreen.main.bounds
            decidedOnCityToVisitQuestionView?.button1?.addTarget(self, action: #selector(self.decidedOnCityToVisitQuestion_Yes(sender:)), for: UIControlEvents.touchUpInside)
            decidedOnCityToVisitQuestionView?.button2?.addTarget(self, action: #selector(self.decidedOnCityToVisitQuestion_No(sender:)), for: UIControlEvents.touchUpInside)
            self.decidedOnCityToVisitQuestionView!.frame = CGRect(x: 0, y: (whereTravellingFromQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: decidedOnCityToVisitQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (decidedOnCityToVisitQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            if indexOfDestinationBeingPlanned > 0 {
                decidedOnCityToVisitQuestionView?.questionLabel?.text = "Great, have you decided\nwhere else to visit?"
                decidedOnCityToVisitQuestionView?.questionLabel?.frame.size.height = 60
            }
        
            increaseProgressCircle(byPercent: standardProgressIncrement, onlyIfFirstDestination: false)
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 2)
    }
    
    func spawnNoCityDecidedAnyIdeasQuestionView() {
        if noCityDecidedAnyIdeasQuestionView == nil {
            //Load next question
            noCityDecidedAnyIdeasQuestionView = Bundle.main.loadNibNamed("NoCityDecidedAnyIdeasQuestionView", owner: self, options: nil)?.first! as? NoCityDecidedAnyIdeasQuestionView
            self.scrollContentView.insertSubview(noCityDecidedAnyIdeasQuestionView!, aboveSubview: decidedOnCityToVisitQuestionView!)
            noCityDecidedAnyIdeasQuestionView?.tag = 3
            let bounds = UIScreen.main.bounds
            noCityDecidedAnyIdeasQuestionView?.button?.addTarget(self, action: #selector(self.noCityDecidedAnyIdeasQuestionView_noIdeas(sender:)), for: UIControlEvents.touchUpInside)
            self.noCityDecidedAnyIdeasQuestionView!.frame = CGRect(x: 0, y: (decidedOnCityToVisitQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: noCityDecidedAnyIdeasQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (noCityDecidedAnyIdeasQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            
            increaseProgressCircle(byPercent: standardProgressIncrement, onlyIfFirstDestination: true)
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 3)
    }
    
    func spawnPlanIdeaAsDestinationQuestionView() {
        if planTripToIdeaQuestionView == nil {
            //Load next question
            planTripToIdeaQuestionView = Bundle.main.loadNibNamed("PlanTripToIdeaQuestionView", owner: self, options: nil)?.first! as? PlanTripToIdeaQuestionView
            planTripToIdeaQuestionView?.tag = 4
            if noCityDecidedAnyIdeasQuestionView?.searchController?.searchBar.text != nil && noCityDecidedAnyIdeasQuestionView?.searchController?.searchBar.text != "" {
                planTripToIdeaQuestionView?.questionLabel?.text = "Do you want to plan\nyour trip to \((noCityDecidedAnyIdeasQuestionView?.searchController?.searchBar.text!)!)?"
            }
            self.scrollContentView.insertSubview(planTripToIdeaQuestionView!, aboveSubview: noCityDecidedAnyIdeasQuestionView!)
            let bounds = UIScreen.main.bounds
            planTripToIdeaQuestionView?.button1?.addTarget(self, action: #selector(self.planTripToIdeaQuestionView_Yes(sender:)), for: UIControlEvents.touchUpInside)
            planTripToIdeaQuestionView?.button2?.addTarget(self, action: #selector(self.planTripToIdeaQuestionView_No(sender:)), for: UIControlEvents.touchUpInside)
            self.planTripToIdeaQuestionView!.frame = CGRect(x: 0, y: (noCityDecidedAnyIdeasQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: planTripToIdeaQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (planTripToIdeaQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            increaseProgressCircle(byPercent: standardProgressIncrement, onlyIfFirstDestination: true)
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 4)
    }
    func spawnWhatTypeOfTripQuestionView() {
        if whatTypeOfTripQuestionView == nil {
            //Load next question
            whatTypeOfTripQuestionView = Bundle.main.loadNibNamed("WhatTypeOfTripQuestionView", owner: self, options: nil)?.first! as? WhatTypeOfTripQuestionView
            whatTypeOfTripQuestionView?.tag = 5
            let bounds = UIScreen.main.bounds
            if planTripToIdeaQuestionView != nil {
                self.scrollContentView.insertSubview(whatTypeOfTripQuestionView!, aboveSubview: planTripToIdeaQuestionView!)
                self.whatTypeOfTripQuestionView!.frame = CGRect(x: 0, y: (planTripToIdeaQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else {
                self.scrollContentView.insertSubview(whatTypeOfTripQuestionView!, aboveSubview: yesCityDecidedQuestionView!)
                self.whatTypeOfTripQuestionView!.frame = CGRect(x: 0, y: (yesCityDecidedQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            }
            whatTypeOfTripQuestionView?.button1?.addTarget(self, action: #selector(self.whatTypeOfTripQuestionView_beaches(sender:)), for: UIControlEvents.touchUpInside)
            whatTypeOfTripQuestionView?.button2?.addTarget(self, action: #selector(self.whatTypeOfTripQuestionView_natureAdventuring(sender:)), for: UIControlEvents.touchUpInside)
            whatTypeOfTripQuestionView?.button3?.addTarget(self, action: #selector(self.whatTypeOfTripQuestionView_winterSports(sender:)), for: UIControlEvents.touchUpInside)
            whatTypeOfTripQuestionView?.button4?.addTarget(self, action: #selector(self.whatTypeOfTripQuestionView_partying(sender:)), for: UIControlEvents.touchUpInside)
            whatTypeOfTripQuestionView?.button5?.addTarget(self, action: #selector(self.whatTypeOfTripQuestionView_foodieHavens(sender:)), for: UIControlEvents.touchUpInside)
            let heightConstraint = NSLayoutConstraint(item: whatTypeOfTripQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (whatTypeOfTripQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            increaseProgressCircle(byPercent: standardProgressIncrement, onlyIfFirstDestination: true)
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 5)
    }
    func spawnHowFarAwayQuestion() {
        if howFarAwayQuestionView == nil {
            //Load next question
            howFarAwayQuestionView = Bundle.main.loadNibNamed("HowFarAwayQuestionView", owner: self, options: nil)?.first! as? HowFarAwayQuestionView
            howFarAwayQuestionView?.tag = 6
            self.scrollContentView.insertSubview(howFarAwayQuestionView!, aboveSubview: whatTypeOfTripQuestionView!)
            let bounds = UIScreen.main.bounds
            howFarAwayQuestionView?.button1?.addTarget(self, action: #selector(self.howFarAwayQuestionView_shortDrive(sender:)), for: UIControlEvents.touchUpInside)
            howFarAwayQuestionView?.button2?.addTarget(self, action: #selector(self.howFarAwayQuestionView_shortFlight(sender:)), for: UIControlEvents.touchUpInside)
            howFarAwayQuestionView?.button3?.addTarget(self, action: #selector(self.howFarAwayQuestionView_domestic(sender:)), for: UIControlEvents.touchUpInside)
            howFarAwayQuestionView?.button4?.addTarget(self, action: #selector(self.howFarAwayQuestionView_international(sender:)), for: UIControlEvents.touchUpInside)
            self.howFarAwayQuestionView!.frame = CGRect(x: 0, y: (whatTypeOfTripQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: howFarAwayQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (howFarAwayQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            increaseProgressCircle(byPercent: 5, onlyIfFirstDestination: true)
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 6)
    }

    func spawnDestinationOptionsCardView() {
        if destinationOptionsCardView == nil {
            //Load next question
            destinationOptionsCardView = Bundle.main.loadNibNamed("DestinationOptionsCardView", owner: self, options: nil)?.first! as? DestinationOptionsCardView
            destinationOptionsCardView?.tag = 7
            self.scrollContentView.insertSubview(destinationOptionsCardView!, aboveSubview: howFarAwayQuestionView!)
            let bounds = UIScreen.main.bounds
//            destinationOptionsCardView?.button1?.addTarget(self, action: #selector(self.destinationOptionsCardView_x(sender:)), for: UIControlEvents.touchUpInside)
//            destinationOptionsCardView?.button2?.addTarget(self, action: #selector(self.destinationOptionsCardView_heart(sender:)), for: UIControlEvents.touchUpInside)
            self.destinationOptionsCardView!.frame = CGRect(x: 0, y: (howFarAwayQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: destinationOptionsCardView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (destinationOptionsCardView?.frame.height)!)
            view.addConstraints([heightConstraint])
            increaseProgressCircle(byPercent: 5, onlyIfFirstDestination: true)
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 7)
    }
    func spawnAddAnotherDestinationQuestionView() {
        if addAnotherDestinationQuestionView == nil {
            //Load next question
            addAnotherDestinationQuestionView = Bundle.main.loadNibNamed("AddAnotherDestinationQuestionView", owner: self, options: nil)?.first! as? AddAnotherDestinationQuestionView
            addAnotherDestinationQuestionView?.tag = 8
            let bounds = UIScreen.main.bounds
            if destinationOptionsCardView != nil {
                self.scrollContentView.insertSubview(addAnotherDestinationQuestionView!, aboveSubview: destinationOptionsCardView!)
                self.addAnotherDestinationQuestionView!.frame = CGRect(x: 0, y: (destinationOptionsCardView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else if yesCityDecidedQuestionView != nil {
                self.scrollContentView.insertSubview(addAnotherDestinationQuestionView!, aboveSubview: yesCityDecidedQuestionView!)
                self.addAnotherDestinationQuestionView!.frame = CGRect(x: 0, y: (yesCityDecidedQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            }
            //else if planTripToIdeaQuestionView != nil && destinationOptionsCardView == nil {
            //    self.scrollContentView.insertSubview(addAnotherDestinationQuestionView!, aboveSubview: planTripToIdeaQuestionView!)
            //    self.addAnotherDestinationQuestionView!.frame = CGRect(x: 0, y: (planTripToIdeaQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            //}
            
            addAnotherDestinationQuestionView?.button1?.addTarget(self, action: #selector(self.addAnotherDestinationQuestionView_justDestination(sender:)), for: UIControlEvents.touchUpInside)
            addAnotherDestinationQuestionView?.button2?.addTarget(self, action: #selector(self.addAnotherDestinationQuestionView_addAnother(sender:)), for: UIControlEvents.touchUpInside)
            let heightConstraint = NSLayoutConstraint(item: addAnotherDestinationQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (addAnotherDestinationQuestionView?.frame.height)!)
            addAnotherDestinationQuestionView?.addConstraints([heightConstraint])
        }
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])
        var destinationsString = String()
        if destinationsForTrip.count == 1 {
            addAnotherDestinationQuestionView?.questionLabel?.text = "Woohoo! Let's plan a trip to \(destinationsForTrip[0]).\n\nWill this be your only destination on this trip?"
            addAnotherDestinationQuestionView?.button1?.setTitle("Yep, just \(destinationsForTrip[0])", for: .normal)
        } else if destinationsForTrip.count > 1 {
            for i in 0 ... destinationsForTrip.count - 2 {
                destinationsString.append(destinationsForTrip[i])
                if i + 1 == destinationsForTrip.count - 1 {
                    destinationsString.append(" and ")
                } else {
                    destinationsString.append(", ")
                }
            }
            destinationsString.append(destinationsForTrip[destinationsForTrip.count - 1])
            if destinationsForTrip.count == 2 {
                destinationsString = "\(destinationsForTrip[0]) and \(destinationsForTrip[1])"
            }
            addAnotherDestinationQuestionView?.questionLabel?.text = "Woohoo! Let's plan a trip to \(destinationsString).\n\nWill these be the only destinations on this trip?"
            addAnotherDestinationQuestionView?.button1?.setTitle("Yep, \(destinationsString)", for: .normal)
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 8)
        let when = DispatchTime.now() + 1.4
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.updateProgress()
        }

    }
    func spawnYesCityDecidedQuestionView() {
        if yesCityDecidedQuestionView == nil {
            //Load next question
            yesCityDecidedQuestionView = Bundle.main.loadNibNamed("YesCityDecidedQuestionView", owner: self, options: nil)?.first! as? YesCityDecidedQuestionView
            yesCityDecidedQuestionView?.tag = 9
            let bounds = UIScreen.main.bounds
            
            if whereTravellingFromQuestionView != nil {
                self.scrollContentView.insertSubview(yesCityDecidedQuestionView!, aboveSubview: whereTravellingFromQuestionView!)
                self.yesCityDecidedQuestionView!.frame = CGRect(x: 0, y: (whereTravellingFromQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else {
                self.scrollContentView.addSubview(yesCityDecidedQuestionView!)
                self.yesCityDecidedQuestionView!.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            }
            yesCityDecidedQuestionView?.button?.addTarget(self, action: #selector(self.yesCityDecidedQuestionView_actuallyDiscoverMoreOptions(sender:)), for: UIControlEvents.touchUpInside)
            yesCityDecidedQuestionView?.button1?.addTarget(self, action: #selector(self.destinationDecidedDestinationChosen), for: UIControlEvents.touchUpInside)

            let heightConstraint = NSLayoutConstraint(item: yesCityDecidedQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (yesCityDecidedQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            increaseProgressCircle(byPercent: standardProgressIncrement, onlyIfFirstDestination: true)
        }
        alignSubviews()
        yesCityDecidedQuestionView?.loadDestination()
        scrollToSubviewWithTag(tag: 9)
    }
    func spawnHowDoYouWantToGetThereQuestionView() {
        if howDoYouWantToGetThereQuestionView == nil {
            
            //Load next question
            howDoYouWantToGetThereQuestionView = Bundle.main.loadNibNamed("HowDoYouWantToGetThereQuestionView", owner: self, options: nil)?.first! as? HowDoYouWantToGetThereQuestionView
            let bounds = UIScreen.main.bounds
            if parseDatesForMultipleDestinationsCalendarView != nil {
                self.scrollContentView.insertSubview(howDoYouWantToGetThereQuestionView!, aboveSubview: parseDatesForMultipleDestinationsCalendarView!)
                self.howDoYouWantToGetThereQuestionView!.frame = CGRect(x: 0, y: (parseDatesForMultipleDestinationsCalendarView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else if addAnotherDestinationQuestionView != nil {
                self.scrollContentView.insertSubview(howDoYouWantToGetThereQuestionView!, aboveSubview: addAnotherDestinationQuestionView!)
                self.howDoYouWantToGetThereQuestionView!.frame = CGRect(x: 0, y: (addAnotherDestinationQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else {
                self.scrollContentView.addSubview(howDoYouWantToGetThereQuestionView!)
                self.howDoYouWantToGetThereQuestionView!.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            }
            howDoYouWantToGetThereQuestionView?.tag = 10
            howDoYouWantToGetThereQuestionView?.button1?.addTarget(self, action: #selector(self.howDoYouWantToGetThereQuestionView_fly(sender:)), for: UIControlEvents.touchUpInside)
            howDoYouWantToGetThereQuestionView?.button2?.addTarget(self, action: #selector(self.howDoYouWantToGetThereQuestionView_drive(sender:)), for: UIControlEvents.touchUpInside)
            howDoYouWantToGetThereQuestionView?.button3?.addTarget(self, action: #selector(self.howDoYouWantToGetThereQuestionView_busTrainOther(sender:)), for: UIControlEvents.touchUpInside)
            howDoYouWantToGetThereQuestionView?.button4?.addTarget(self, action: #selector(self.howDoYouWantToGetThereQuestionView_iDontKnowHelpMe(sender:)), for: UIControlEvents.touchUpInside)
            howDoYouWantToGetThereQuestionView?.button5?.addTarget(self, action: #selector(self.howDoYouWantToGetThereQuestionView_illAlreadyBeThere(sender:)), for: UIControlEvents.touchUpInside)
            howDoYouWantToGetThereQuestionView?.button6?.addTarget(self, action: #selector(self.howDoYouWantToGetThereQuestionView_skipThisIPlannedRoundTripTravel(sender:)), for: UIControlEvents.touchUpInside)
            let heightConstraint = NSLayoutConstraint(item: howDoYouWantToGetThereQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (howDoYouWantToGetThereQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            increaseProgressCircle(byPercent: standardProgressIncrement, onlyIfFirstDestination: true)

        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 10)
    }
    func spawnFlightSearchQuestionView(){
        
        if flightSearchQuestionView == nil {
            //Load next question
            flightSearchQuestionView = Bundle.main.loadNibNamed("FlightSearchQuestionView", owner: self, options: nil)?.first! as? FlightSearchQuestionView
            let bounds = UIScreen.main.bounds
            if howDoYouWantToGetThereQuestionView != nil {
                self.scrollContentView.insertSubview(flightSearchQuestionView!, aboveSubview: howDoYouWantToGetThereQuestionView!)
                self.flightSearchQuestionView!.frame = CGRect(x: 0, y: (howDoYouWantToGetThereQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else {
                self.scrollContentView.addSubview(flightSearchQuestionView!)
                self.flightSearchQuestionView!.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            }
            flightSearchQuestionView?.tag = 11
            flightSearchQuestionView?.searchButton?.addTarget(self, action: #selector(self.searchFlights(sender:)), for: UIControlEvents.touchUpInside)
            flightSearchQuestionView?.addButton?.addTarget(self, action: #selector(self.flightSearchQuestionView_alreadyHaveFlights(sender:)), for: UIControlEvents.touchUpInside)
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
                        flightSearchQuestionView?.returnDate?.text =  "\(returnDateValue)"
                    }
                    if departureKeys.count != 0 {
                        let departureDateValue = departureKeys[0]
                        flightSearchQuestionView?.departureDate?.text =  "\(departureDateValue)"
                    }
                }
            }
            increaseProgressCircle(byPercent: standardProgressIncrement, onlyIfFirstDestination: true)
        }

        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
        if destinationsForTrip.count > 1 {
            flightSearchQuestionView?.searchMode = "oneWay"
            flightSearchQuestionView?.handleSearchMode()
            flightSearchQuestionView?.searchModeControl.selectedSegmentIndex = 0
        }
        
        //TRAVELPAYOUTS
        flightResultsController = createTicketsVC()
//        let heightConstraint = NSLayoutConstraint(item: flightResultsController!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (flightSearchQuestionView?.frame.height)!)
//        view.addConstraints([heightConstraint])

        flightResultsController?.willMove(toParentViewController: self)
        self.addChildViewController(flightResultsController!)
        //        flightResultsController?.searchMode = flightSearchQuestionView?.searchMode
        flightResultsController?.loadView()
        flightResultsController?.viewDidLoad()
        flightResultsController?.view.frame = self.view.bounds
        for subview in (flightSearchQuestionView?.subviews)! {
            subview.isHidden = true
        }
        self.flightSearchQuestionView?.addSubview((flightResultsController?.view)!)
        flightResultsController?.view.tag = 12
        flightResultsController?.didMove(toParentViewController: self)
        
        updateProgress()

        
        alignSubviews()
        scrollToSubviewWithTag(tag: 11)
        
    }
    func spawnFlightResultsQuestionView() {
//        bookingMode = "flight"
//    
//        var originCity = String()
//        var originCityID = String()
//        var originStateAbbrev = String()
//        var isOriginCityInUS = true
//        var isOriginCityNearAirport = false
//        var destinationCity = String()
//        var destinationCityID = String()
//        var destinationStateAbbrev = String()
//        var isDestinationCityInUS = true
//        var isDestinationCityNearAirport = false
//        var originDay = String() //DD
//        var originMonth = String() //MM
//        var originYear = String() // YYYY
//        var returnDay = String() //DD
//        var returnMonth = String() //MM
//        var returnYear = String() //YYYY
//        
//        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
//        var destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
//        var destinationsForTripStates = SavedPreferencesForTrip["destinationsForTripStates"] as! [String]
//        
//        if indexOfDestinationBeingPlanned == 0 {
//            originCity = DataContainerSingleton.sharedDataContainer.homeAirport!
//            originStateAbbrev = findStateAbbreviationWith(state: DataContainerSingleton.sharedDataContainer.homeState!)
//            if originStateAbbrev == "noStateMatch" {
//                isOriginCityInUS = false
//                originStateAbbrev = findCountryAbbreviationWith(country:DataContainerSingleton.sharedDataContainer.homeState!)
//            }
//            originCityID = findCarCityIDWith(cityString: originCity, stateString: originStateAbbrev)
//            originCity = originCity.replacingOccurrences(of: " ", with: "+")
//            if !isOriginCityInUS {
//                originStateAbbrev = DataContainerSingleton.sharedDataContainer.homeState!
//            }
//            originStateAbbrev = originStateAbbrev.replacingOccurrences(of: " ", with: "+")
//        } else {
//            originCity = destinationsForTrip[indexOfDestinationBeingPlanned - 1]
//            originStateAbbrev = findStateAbbreviationWith(state: destinationsForTripStates[indexOfDestinationBeingPlanned - 1])
//            if originStateAbbrev == "noStateMatch" {
//                isOriginCityInUS = false
//                originStateAbbrev = findCountryAbbreviationWith(country: destinationsForTripStates[indexOfDestinationBeingPlanned - 1])
//            }
//            originCityID = findCarCityIDWith(cityString: originCity, stateString: originStateAbbrev)
//            originCity = originCity.replacingOccurrences(of: " ", with: "+")
//            if !isOriginCityInUS {
//                originStateAbbrev = destinationsForTripStates[indexOfDestinationBeingPlanned - 1]
//            }
//            originStateAbbrev = originStateAbbrev.replacingOccurrences(of: " ", with: "+")
//        }
//        if findAirportWith(cityID: originCityID).count > 0 {
//            isOriginCityNearAirport = true
//        }
//        
//        destinationCity = destinationsForTrip[indexOfDestinationBeingPlanned]
//        destinationStateAbbrev = findStateAbbreviationWith(state: destinationsForTripStates[indexOfDestinationBeingPlanned])
//        if destinationStateAbbrev == "noStateMatch" {
//            isDestinationCityInUS = false
//            destinationStateAbbrev = findCountryAbbreviationWith(country: destinationsForTripStates[indexOfDestinationBeingPlanned])
//        }
//        destinationCityID = findCarCityIDWith(cityString: destinationCity, stateString: destinationStateAbbrev)
//        destinationCity = destinationCity.replacingOccurrences(of: " ", with: "+")
//        if !isDestinationCityInUS {
//            destinationStateAbbrev = destinationsForTripStates[indexOfDestinationBeingPlanned]
//        }
//        destinationStateAbbrev = destinationStateAbbrev.replacingOccurrences(of: " ", with: "+")
//        if findAirportWith(cityID: destinationCityID).count > 0 {
//            isDestinationCityNearAirport = true
//        }
//        
//        let originDate = flightSearchQuestionView?.departureDate?.text
//        originMonth = (originDate?[0])! + (originDate?[1])!                   //DD
//        originDay = (originDate?[3])! + (originDate?[4])!                 //MM
//        originYear = (originDate?[6])! + (originDate?[7])! + (originDate?[8])! + (originDate?[9])!                   //YYYY
//        let returnDate = flightSearchQuestionView?.returnDate?.text
//        returnMonth = (returnDate?[0])! + (returnDate?[1])!                   //DD
//        returnDay = (returnDate?[3])! + (returnDate?[4])!                 //MM
//        returnYear = (returnDate?[6])! + (returnDate?[7])! + (returnDate?[8])! + (returnDate?[9])!                  //YYYY
//        
//        var stringForURL = "http://secure.rezserver.com/flights/home/?refid=8056"
//        if (originCityID != "noMatchingCity" && destinationCityID != "noMatchingCity") && flightSearchQuestionView?.searchMode == "roundtrip" {
//            stringForURL = "http://secure.rezserver.com/flights/results/depart/?rs_o_city=\(originCity)%2C+\(originStateAbbrev)&rs_d_city=\(destinationCity)%2C+\(destinationStateAbbrev)&rs_chk_in=\(originMonth)%2F\(originDay)%2F\(originYear)&rs_chk_out=\(returnMonth)%2F\(returnDay)%2F\(returnYear)&rs_adults=1&rs_children=0&refid=8056&rs_o_aircode=\(originCityID)&rs_d_aircode=\(destinationCityID)&air_search_type=\((flightSearchQuestionView?.searchMode)!)&preferred_airline=&cabin_class="
//        } else if (originCityID != "noMatchingCity" && destinationCityID != "noMatchingCity")  && flightSearchQuestionView?.searchMode == "oneWay" {
//            stringForURL = "http://secure.rezserver.com/flights/results/depart/?rs_o_city1=\(originCity)%2C+\(originStateAbbrev)&rs_d_city1=\(destinationCity)%2C+\(destinationStateAbbrev)&rs_chk_in1=\(originMonth)%2F\(originDay)%2F\(originYear)&rs_adults=1&rs_children=0&refid=8056&rs_o_aircode1=\(originCityID)&rs_d_aircode1=\(destinationCityID)&air_search_type=\((flightSearchQuestionView?.searchMode)!)&preferred_airline=&cabin_class="
//        }
//        let whiteLabelURL_FlightSearchQuery = URL(string: stringForURL)!
//        
//        
//        showWebsite(URL: whiteLabelURL_FlightSearchQuery)
        
    }
    func spawnFlightBookingQuestionView() {
//        reviewAndBookFlightsController = self.storyboard!.instantiateViewController(withIdentifier: "ReviewAndBookViewController") as? ReviewAndBookViewController
//        reviewAndBookFlightsController?.willMove(toParentViewController: self)
//        self.addChildViewController(reviewAndBookFlightsController!)
//        reviewAndBookFlightsController?.bookingMode = "flight"
//        reviewAndBookFlightsController?.loadView()
//        reviewAndBookFlightsController?.viewDidLoad()
//        reviewAndBookFlightsController?.view.frame = self.view.bounds
//        flightResultsController?.view.isHidden = true
//        self.flightSearchQuestionView?.addSubview((reviewAndBookFlightsController?.view)!)
//        reviewAndBookFlightsController?.view.tag = 13
//        reviewAndBookFlightsController?.didMove(toParentViewController: self)
//        
//        updateProgress()
    }
    func spawnDoYouNeedARentalCarQuestionView() {
        if doYouNeedARentalCarQuestionView == nil {
            //Load next question
            doYouNeedARentalCarQuestionView = Bundle.main.loadNibNamed("DoYouNeedARentalCarQuestionView", owner: self, options: nil)?.first! as? DoYouNeedARentalCarQuestionView
            let bounds = UIScreen.main.bounds
            if flightSearchQuestionView == nil && busTrainOtherQuestionView == nil {
                self.scrollContentView.insertSubview(doYouNeedARentalCarQuestionView!, aboveSubview: howDoYouWantToGetThereQuestionView!)
                self.doYouNeedARentalCarQuestionView!.frame = CGRect(x: 0, y: (howDoYouWantToGetThereQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else if flightSearchQuestionView != nil && busTrainOtherQuestionView == nil {
                if alreadyHaveFlightsQuestionView != nil {
                    self.scrollContentView.insertSubview(doYouNeedARentalCarQuestionView!, aboveSubview: alreadyHaveFlightsQuestionView!)
                    self.doYouNeedARentalCarQuestionView!.frame = CGRect(x: 0, y: (alreadyHaveFlightsQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
                } else {
                    self.scrollContentView.insertSubview(doYouNeedARentalCarQuestionView!, aboveSubview: flightSearchQuestionView!)
                    self.doYouNeedARentalCarQuestionView!.frame = CGRect(x: 0, y: (flightSearchQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
                }
            } else if flightSearchQuestionView == nil && busTrainOtherQuestionView != nil {
                self.scrollContentView.insertSubview(doYouNeedARentalCarQuestionView!, aboveSubview: busTrainOtherQuestionView!)
                self.doYouNeedARentalCarQuestionView!.frame = CGRect(x: 0, y: (busTrainOtherQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            }
            doYouNeedARentalCarQuestionView?.tag = 14
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            if SavedPreferencesForTrip["assistantMode"] as! String == "travel" {
                doYouNeedARentalCarQuestionView?.button1?.addTarget(self, action: #selector(self.doYouNeedARentalCarQuestionView_yes_backToItinerary(sender:)), for: UIControlEvents.touchUpInside)
                doYouNeedARentalCarQuestionView?.button2?.addTarget(self, action: #selector(self.doYouNeedARentalCarQuestionView_no_backToItinerary(sender:)), for: UIControlEvents.touchUpInside)
            } else if SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding" {
                doYouNeedARentalCarQuestionView?.button1?.addTarget(self, action: #selector(self.doYouNeedARentalCarQuestionView_yes(sender:)), for: UIControlEvents.touchUpInside)
                doYouNeedARentalCarQuestionView?.button2?.addTarget(self, action: #selector(self.doYouNeedARentalCarQuestionView_no(sender:)), for: UIControlEvents.touchUpInside)
            }
            let heightConstraint = NSLayoutConstraint(item: doYouNeedARentalCarQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (doYouNeedARentalCarQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 14)
    }
    func spawnCarRentalSearchQuestionView() {
        if carRentalSearchQuestionView == nil {
            //Load next question
            carRentalSearchQuestionView = Bundle.main.loadNibNamed("CarRentalSearchQuestionView", owner: self, options: nil)?.first! as? CarRentalSearchQuestionView
            self.scrollContentView.insertSubview(carRentalSearchQuestionView!, aboveSubview: doYouNeedARentalCarQuestionView!)
            carRentalSearchQuestionView?.tag = 15
            let bounds = UIScreen.main.bounds
            carRentalSearchQuestionView?.searchButton?.addTarget(self, action: #selector(self.searchRentalCars(sender:)), for: UIControlEvents.touchUpInside)
            self.carRentalSearchQuestionView!.frame = CGRect(x: 0, y: (doYouNeedARentalCarQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: carRentalSearchQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (carRentalSearchQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 15)
    }
    func spawnRentalCarResultsQuestionView() {
        bookingMode = "carRental"
        
        var originCity = String()
        var originCityID = String()
        var originStateAbbrev = String()
        var isOriginCityInUS = true
        var isOriginCityNearAirport = false
        var destinationCity = String()
        var destinationCityID = String()
        var destinationStateAbbrev = String()
        var isDestinationCityInUS = true
        var isDestinationCityNearAirport = false
        var originDay = String() //DD
        var originMonth = String() //MM
        var originYear = String() // YYYY
        var returnDay = String() //DD
        var returnMonth = String() //MM
        var returnYear = String() //YYYY
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        var destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
        var destinationsForTripStates = SavedPreferencesForTrip["destinationsForTripStates"] as! [String]
        var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
        if travelDictionaryArray[indexOfDestinationBeingPlanned]["modeOfTransportation"] as! String == "drive" {
            originCity = DataContainerSingleton.sharedDataContainer.homeAirport!
            originStateAbbrev = findStateAbbreviationWith(state: DataContainerSingleton.sharedDataContainer.homeState!)
            if originStateAbbrev == "noStateMatch" {
                isOriginCityInUS = false
                originStateAbbrev = findCountryAbbreviationWith(country:DataContainerSingleton.sharedDataContainer.homeState!)
            }
            originCityID = findCarCityIDWith(cityString: originCity, stateString: originStateAbbrev)
            originCity = originCity.replacingOccurrences(of: " ", with: "+")
            if !isOriginCityInUS {
                originStateAbbrev = DataContainerSingleton.sharedDataContainer.homeState!
            }
            originStateAbbrev = originStateAbbrev.replacingOccurrences(of: " ", with: "+")
        } else {
            originCity = destinationsForTrip[indexOfDestinationBeingPlanned]
            originStateAbbrev = findStateAbbreviationWith(state: destinationsForTripStates[indexOfDestinationBeingPlanned])
            if originStateAbbrev == "noStateMatch" {
                isOriginCityInUS = false
                originStateAbbrev = findCountryAbbreviationWith(country: destinationsForTripStates[indexOfDestinationBeingPlanned])
            }
            originCityID = findCarCityIDWith(cityString: originCity, stateString: originStateAbbrev)
            originCity = originCity.replacingOccurrences(of: " ", with: "+")
            if !isOriginCityInUS {
                originStateAbbrev = destinationsForTripStates[indexOfDestinationBeingPlanned]
            }
            originStateAbbrev = originStateAbbrev.replacingOccurrences(of: " ", with: "+")
        }
        if findAirportWith(cityID: originCityID).count > 0 {
            isOriginCityNearAirport = true
        }
        
        destinationCity = destinationsForTrip[indexOfDestinationBeingPlanned]
        destinationStateAbbrev = findStateAbbreviationWith(state: destinationsForTripStates[indexOfDestinationBeingPlanned])
        if destinationStateAbbrev == "noStateMatch" {
            isDestinationCityInUS = false
            destinationStateAbbrev = findCountryAbbreviationWith(country: destinationsForTripStates[indexOfDestinationBeingPlanned])
        }
        destinationCityID = findCarCityIDWith(cityString: destinationCity, stateString: destinationStateAbbrev)
        destinationCity = destinationCity.replacingOccurrences(of: " ", with: "+")
        if !isDestinationCityInUS {
            destinationStateAbbrev = destinationsForTripStates[indexOfDestinationBeingPlanned]
        }
        destinationStateAbbrev = destinationStateAbbrev.replacingOccurrences(of: " ", with: "+")
        if findAirportWith(cityID: destinationCityID).count > 0 {
            isDestinationCityNearAirport = true
        }
        
        let originDate = carRentalSearchQuestionView?.pickUpDate?.text
        originMonth = (originDate?[0])! + (originDate?[1])!                   //DD
        originDay = (originDate?[3])! + (originDate?[4])!                 //MM
        originYear = (originDate?[6])! + (originDate?[7])! + (originDate?[8])! + (originDate?[9])!                   //YYYY
        let returnDate = carRentalSearchQuestionView?.dropOffDate?.text
        returnMonth = (returnDate?[0])! + (returnDate?[1])!                   //DD
        returnDay = (returnDate?[3])! + (returnDate?[4])!                 //MM
        returnYear = (returnDate?[6])! + (returnDate?[7])! + (returnDate?[8])! + (returnDate?[9])!                  //YYYY
        
        var stringForURL = "http://secure.rezserver.com/car_rentals/home/?refid=8056"
        if (originCityID != "noMatchingCity" && destinationCityID != "noMatchingCity") && carRentalSearchQuestionView?.searchMode == "Same drop-off" {
            stringForURL = "http://secure.rezserver.com/car_rentals/results/?rs_pu_city=\(originCity)%2C+\(originStateAbbrev)&rs_pu_date=\(originMonth)%2F\(originDay)%2F\(originYear)&rs_pu_time=8%3A30&rs_pu_cityid=\(originCityID)&rs_do_city=&rs_do_date=\(returnMonth)%2F\(returnDay)%2F\(returnYear)&rs_do_time=8%3A30&rs_company_code=&rs_cartype=&rs_company=&refid=8056"
        } else if (originCityID != "noMatchingCity" && destinationCityID != "noMatchingCity")  && carRentalSearchQuestionView?.searchMode == "Different drop-off" {
        }
        let whiteLabelURL_CarRentalSearchQuery = URL(string: stringForURL)!
        
        
        showWebsite(URL: whiteLabelURL_CarRentalSearchQuery)
        
//        carRentalResultsController = self.storyboard!.instantiateViewController(withIdentifier: "carRentalResultsViewController") as? carRentalResultsViewController
//        carRentalResultsController?.willMove(toParentViewController: self)
//        self.addChildViewController(carRentalResultsController!)
//        carRentalResultsController?.searchMode = carRentalSearchQuestionView?.searchMode
//        carRentalResultsController?.loadView()
//        carRentalResultsController?.viewDidLoad()
//        carRentalResultsController?.view.frame = self.view.bounds
//        for subview in (carRentalSearchQuestionView?.subviews)! {
//            subview.isHidden = true
//        }
//        self.carRentalSearchQuestionView?.addSubview((carRentalResultsController?.view)!)
//        carRentalResultsController?.view.tag = 16
//        carRentalResultsController?.didMove(toParentViewController: self)
//        
//        updateProgress()
    }
    func spawnCarRentalBookingQuestionView() {
//        reviewAndBookCarRentalController = self.storyboard!.instantiateViewController(withIdentifier: "ReviewAndBookViewController") as? ReviewAndBookViewController
//        reviewAndBookCarRentalController?.willMove(toParentViewController: self)
//        self.addChildViewController(reviewAndBookCarRentalController!)
//        reviewAndBookCarRentalController?.bookingMode = "carRental"
//        reviewAndBookCarRentalController?.loadView()
//        reviewAndBookCarRentalController?.viewDidLoad()
//        reviewAndBookCarRentalController?.view.frame = self.view.bounds
//        carRentalResultsController?.view.isHidden = true
//        self.carRentalSearchQuestionView?.addSubview((reviewAndBookCarRentalController?.view)!)
//        reviewAndBookCarRentalController?.view.tag = 17
//        reviewAndBookCarRentalController?.didMove(toParentViewController: self)
//        
//        updateProgress()
    }
    func spawnDoYouKnowWhereYouWillBeStayingQuestionView() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()

        if doYouKnowWhereYouWillBeStayingQuestionView == nil {
            //Load next question
            doYouKnowWhereYouWillBeStayingQuestionView = Bundle.main.loadNibNamed("DoYouKnowWhereYouWillBeStayingQuestionView", owner: self, options: nil)?.first! as? DoYouKnowWhereYouWillBeStayingQuestionView
            let bounds = UIScreen.main.bounds
            var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int

            //PlaceToStayEdit
            if SavedPreferencesForTrip["assistantMode"] as! String == "placeToStay" {
                self.scrollContentView.addSubview(doYouKnowWhereYouWillBeStayingQuestionView!)
                self.doYouKnowWhereYouWillBeStayingQuestionView!.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else if travelDictionaryArray[indexOfDestinationBeingPlanned]["modeOfTransportation"] as! String == "drive" {
                self.scrollContentView.insertSubview(doYouKnowWhereYouWillBeStayingQuestionView!, aboveSubview: aboutWhatTimeWillYouStartDrivingQuestionView!)
                self.doYouKnowWhereYouWillBeStayingQuestionView!.frame = CGRect(x: 0, y: (aboutWhatTimeWillYouStartDrivingQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else if travelDictionaryArray[indexOfDestinationBeingPlanned]["modeOfTransportation"] as! String == "busTrainOther" || travelDictionaryArray[indexOfDestinationBeingPlanned]["modeOfTransportation"] as! String == "fly" {
                if doYouNeedARentalCarQuestionView == nil {
                    self.scrollContentView.insertSubview(doYouKnowWhereYouWillBeStayingQuestionView!, aboveSubview: flightSearchQuestionView!)
                    self.doYouKnowWhereYouWillBeStayingQuestionView!.frame = CGRect(x: 0, y: (flightSearchQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
                } else if carRentalSearchQuestionView == nil {
                    self.scrollContentView.insertSubview(doYouKnowWhereYouWillBeStayingQuestionView!, aboveSubview: doYouNeedARentalCarQuestionView!)
                    self.doYouKnowWhereYouWillBeStayingQuestionView!.frame = CGRect(x: 0, y: (doYouNeedARentalCarQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
                } else {
                    self.scrollContentView.insertSubview(doYouKnowWhereYouWillBeStayingQuestionView!, aboveSubview: carRentalSearchQuestionView!)
                    self.doYouKnowWhereYouWillBeStayingQuestionView!.frame = CGRect(x: 0, y: (carRentalSearchQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
                }
            } else if travelDictionaryArray[indexOfDestinationBeingPlanned]["modeOfTransportation"] as! String == "illAlreadyBeThere" {
                self.scrollContentView.insertSubview(doYouKnowWhereYouWillBeStayingQuestionView!, aboveSubview: howDoYouWantToGetThereQuestionView!)
                self.doYouKnowWhereYouWillBeStayingQuestionView!.frame = CGRect(x: 0, y: (howDoYouWantToGetThereQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            }
            doYouKnowWhereYouWillBeStayingQuestionView?.tag = 18
            doYouKnowWhereYouWillBeStayingQuestionView?.button1?.addTarget(self, action: #selector(self.doYouKnowWhereYouWillBeStaying_yes(sender:)), for: UIControlEvents.touchUpInside)
            doYouKnowWhereYouWillBeStayingQuestionView?.button2?.addTarget(self, action: #selector(self.doYouKnowWhereYouWillBeStaying_noPlanNow(sender:)), for: UIControlEvents.touchUpInside)
            doYouKnowWhereYouWillBeStayingQuestionView?.button3?.addTarget(self, action: #selector(self.doYouKnowWhereYouWillBeStaying_noPlanLater(sender:)), for: UIControlEvents.touchUpInside)
            let heightConstraint = NSLayoutConstraint(item: doYouKnowWhereYouWillBeStayingQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (doYouKnowWhereYouWillBeStayingQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            increaseProgressCircle(byPercent: standardProgressIncrement, onlyIfFirstDestination: true)
        }
        
        if SavedPreferencesForTrip["assistantMode"] as! String == "placeToStay" {
            updateProgress()
            updateHeightOfScrollView()
        } else {
            alignSubviews()
        }
        scrollToSubviewWithTag(tag: 18)
    }

    func spawnAboutWhatTimeWillYouStartDrivingQuestionView() {
        if aboutWhatTimeWillYouStartDrivingQuestionView == nil {
            //Load next question
            aboutWhatTimeWillYouStartDrivingQuestionView = Bundle.main.loadNibNamed("AboutWhatTimeWillYouStartDrivingQuestionView", owner: self, options: nil)?.first! as? AboutWhatTimeWillYouStartDrivingQuestionView
            let bounds = UIScreen.main.bounds
            if carRentalSearchQuestionView == nil {
                self.scrollContentView.insertSubview(aboutWhatTimeWillYouStartDrivingQuestionView!, aboveSubview: doYouNeedARentalCarQuestionView!)
                self.aboutWhatTimeWillYouStartDrivingQuestionView!.frame = CGRect(x: 0, y: (doYouNeedARentalCarQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else {
                self.scrollContentView.insertSubview(aboutWhatTimeWillYouStartDrivingQuestionView!, aboveSubview: carRentalSearchQuestionView!)
                self.aboutWhatTimeWillYouStartDrivingQuestionView!.frame = CGRect(x: 0, y: (carRentalSearchQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            }
                aboutWhatTimeWillYouStartDrivingQuestionView?.tag = 19
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            if SavedPreferencesForTrip["assistantMode"] as! String == "travel" {
                aboutWhatTimeWillYouStartDrivingQuestionView?.button1?.addTarget(self, action: #selector(self.notSureYetWhenStartDriving_backToItinerary(sender:)), for: UIControlEvents.touchUpInside)
                aboutWhatTimeWillYouStartDrivingQuestionView?.button2?.addTarget(self, action: #selector(self.timeChosenWhenStartDriving_backToItinerary(sender:)), for: UIControlEvents.touchUpInside)
            } else if SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding" {
                aboutWhatTimeWillYouStartDrivingQuestionView?.button1?.addTarget(self, action: #selector(self.notSureYetWhenStartDriving(sender:)), for: UIControlEvents.touchUpInside)
                aboutWhatTimeWillYouStartDrivingQuestionView?.button2?.addTarget(self, action: #selector(self.timeChosenWhenStartDriving(sender:)), for: UIControlEvents.touchUpInside)
            }
            let heightConstraint = NSLayoutConstraint(item: aboutWhatTimeWillYouStartDrivingQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (aboutWhatTimeWillYouStartDrivingQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 19)
    }
    func spawnBusTrainOtherQuestionView() {
        if busTrainOtherQuestionView == nil {
            //Load next question
            busTrainOtherQuestionView = Bundle.main.loadNibNamed("BusTrainOtherQuestionView", owner: self, options: nil)?.first! as? BusTrainOtherQuestionView
            self.scrollContentView.insertSubview(busTrainOtherQuestionView!, aboveSubview: howDoYouWantToGetThereQuestionView!)
            busTrainOtherQuestionView?.tag = 20
            let bounds = UIScreen.main.bounds
            busTrainOtherQuestionView?.button1?.addTarget(self, action: #selector(self.busTrainOtherTravelPlans_done(sender:)), for: UIControlEvents.touchUpInside)
            busTrainOtherQuestionView?.button2?.addTarget(self, action: #selector(self.busTrainOtherTravelPlans_addLater(sender:)), for: UIControlEvents.touchUpInside)
            self.busTrainOtherQuestionView!.frame = CGRect(x: 0, y: (howDoYouWantToGetThereQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: busTrainOtherQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (busTrainOtherQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            increaseProgressCircle(byPercent: standardProgressIncrement, onlyIfFirstDestination: true)
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 20)
    }
    
    func spawnidkHowToGetThereQuestionView() {
        if idkHowToGetThereQuestionView == nil {
            //Load next question
            idkHowToGetThereQuestionView = Bundle.main.loadNibNamed("idkHowToGetThereQuestionView", owner: self, options: nil)?.first! as? idkHowToGetThereQuestionView
            self.scrollContentView.insertSubview(idkHowToGetThereQuestionView!, aboveSubview: howDoYouWantToGetThereQuestionView!)
            idkHowToGetThereQuestionView?.tag = 21
            let bounds = UIScreen.main.bounds
            idkHowToGetThereQuestionView?.button1?.addTarget(self, action: #selector(self.idkHowToGetThere_readyToPlan(sender:)), for: UIControlEvents.touchUpInside)
            self.idkHowToGetThereQuestionView!.frame = CGRect(x: 0, y: (howDoYouWantToGetThereQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: idkHowToGetThereQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (idkHowToGetThereQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 21)
    }
    func spawnWhatTypeOfPlaceToStayQuestionView() {
        self.view.endEditing(true)
        if whatTypeOfPlaceToStayQuestionView == nil {
            //Load next question
            whatTypeOfPlaceToStayQuestionView = Bundle.main.loadNibNamed("WhatTypeOfPlaceToStayQuestionView", owner: self, options: nil)?.first! as? WhatTypeOfPlaceToStayQuestionView
            self.scrollContentView.insertSubview(whatTypeOfPlaceToStayQuestionView!, aboveSubview: doYouKnowWhereYouWillBeStayingQuestionView!)
            whatTypeOfPlaceToStayQuestionView?.tag = 22
            let bounds = UIScreen.main.bounds
            whatTypeOfPlaceToStayQuestionView?.button1?.addTarget(self, action: #selector(self.whatTypeOfPlaceToStayQuestionView_hotel(sender:)), for: UIControlEvents.touchUpInside)
            whatTypeOfPlaceToStayQuestionView?.button2?.addTarget(self, action: #selector(self.whatTypeOfPlaceToStayQuestionView_shortTermRental(sender:)), for: UIControlEvents.touchUpInside)
//            whatTypeOfPlaceToStayQuestionView?.button3?.addTarget(self, action: #selector(self.whatTypeOfPlaceToStayQuestionView_stayWithSomeoneIKnow(sender:)), for: UIControlEvents.touchUpInside)
            self.whatTypeOfPlaceToStayQuestionView!.frame = CGRect(x: 0, y: (doYouKnowWhereYouWillBeStayingQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: whatTypeOfPlaceToStayQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (whatTypeOfPlaceToStayQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            increaseProgressCircle(byPercent: 5, onlyIfFirstDestination: true)
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 22)
    }
    func spawnHotelSearchQuestionView() {
        self.view.endEditing(true)
        if hotelSearchQuestionView == nil {
            //Load next question
            hotelSearchQuestionView = Bundle.main.loadNibNamed("HotelSearchQuestionView", owner: self, options: nil)?.first! as? HotelSearchQuestionView
            let bounds = UIScreen.main.bounds
            if whatTypeOfPlaceToStayQuestionView != nil {
                self.scrollContentView.insertSubview(hotelSearchQuestionView!, aboveSubview: whatTypeOfPlaceToStayQuestionView!)
                self.hotelSearchQuestionView!.frame = CGRect(x: 0, y: (whatTypeOfPlaceToStayQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else if doYouNeedHelpBookingAHotelQuestionView != nil {
                self.scrollContentView.insertSubview(hotelSearchQuestionView!, aboveSubview: doYouNeedHelpBookingAHotelQuestionView!)
                self.hotelSearchQuestionView!.frame = CGRect(x: 0, y: (doYouNeedHelpBookingAHotelQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else {
                self.scrollContentView.addSubview(hotelSearchQuestionView!)
                self.hotelSearchQuestionView!.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            }
            hotelSearchQuestionView?.tag = 23
            hotelSearchQuestionView?.searchButton?.addTarget(self, action: #selector(self.hotelSearchQuestionView_searchButtonTouchedUpInside(sender:)), for: UIControlEvents.touchUpInside)
            let heightConstraint = NSLayoutConstraint(item: hotelSearchQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (hotelSearchQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            increaseProgressCircle(byPercent: standardProgressIncrement, onlyIfFirstDestination: true)
        }
        
        //TRAVELPAYOUTS
        hotelResultsController = createHotelsVC()
        hotelResultsController?.willMove(toParentViewController: self)
        self.addChildViewController(hotelResultsController!)
        //        flightResultsController?.searchMode = flightSearchQuestionView?.searchMode
        hotelResultsController?.loadView()
        hotelResultsController?.viewDidLoad()
        hotelResultsController?.view.frame = self.view.bounds
        for subview in (hotelSearchQuestionView?.subviews)! {
            subview.isHidden = true
        }
        self.hotelSearchQuestionView?.addSubview((hotelResultsController?.view)!)
        hotelResultsController?.view.tag = 12
        hotelResultsController?.didMove(toParentViewController: self)

        
        alignSubviews()
        scrollToSubviewWithTag(tag: 23)
    }
    func spawnShortTermRentalSearchQuestionView() {
        if shortTermRentalSearchQuestionView == nil {
            //Load next question
            shortTermRentalSearchQuestionView = Bundle.main.loadNibNamed("ShortTermRentalSearchQuestionView", owner: self, options: nil)?.first! as? ShortTermRentalSearchQuestionView
            let bounds = UIScreen.main.bounds
            if whatTypeOfPlaceToStayQuestionView != nil {
                self.scrollContentView.insertSubview(shortTermRentalSearchQuestionView!, aboveSubview: whatTypeOfPlaceToStayQuestionView!)
                self.shortTermRentalSearchQuestionView!.frame = CGRect(x: 0, y: (whatTypeOfPlaceToStayQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else if yesIKnowWhereImStayingQuestionView != nil {
                self.scrollContentView.insertSubview(shortTermRentalSearchQuestionView!, aboveSubview: yesIKnowWhereImStayingQuestionView!)
                self.shortTermRentalSearchQuestionView!.frame = CGRect(x: 0, y: (yesIKnowWhereImStayingQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            }
            shortTermRentalSearchQuestionView?.tag = 24
            shortTermRentalSearchQuestionView?.button1?.addTarget(self, action: #selector(self.shortTermRentalSearchQuestionView_done(sender:)), for: UIControlEvents.touchUpInside)
            shortTermRentalSearchQuestionView?.button2?.addTarget(self, action: #selector(self.shortTermRentalSearchQuestionView_addLater(sender:)), for: UIControlEvents.touchUpInside)
            let heightConstraint = NSLayoutConstraint(item: shortTermRentalSearchQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (shortTermRentalSearchQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            increaseProgressCircle(byPercent: standardProgressIncrement, onlyIfFirstDestination: true)
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 24)
    }
    func spawnStayWithSomeoneIKnowQuestionView() {
        if stayWithSomeoneIKnowQuestionView == nil {
            //Load next question
            stayWithSomeoneIKnowQuestionView = Bundle.main.loadNibNamed("StayWithSomeoneIKnowQuestionView", owner: self, options: nil)?.first! as? StayWithSomeoneIKnowQuestionView
            let bounds = UIScreen.main.bounds
            if whatTypeOfPlaceToStayQuestionView != nil {
                self.scrollContentView.insertSubview(stayWithSomeoneIKnowQuestionView!, aboveSubview: whatTypeOfPlaceToStayQuestionView!)
                self.stayWithSomeoneIKnowQuestionView!.frame = CGRect(x: 0, y: (whatTypeOfPlaceToStayQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else if yesIKnowWhereImStayingQuestionView != nil {
                self.scrollContentView.insertSubview(stayWithSomeoneIKnowQuestionView!, aboveSubview: yesIKnowWhereImStayingQuestionView!)
                self.stayWithSomeoneIKnowQuestionView!.frame = CGRect(x: 0, y: (yesIKnowWhereImStayingQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            }
            stayWithSomeoneIKnowQuestionView?.tag = 25
            stayWithSomeoneIKnowQuestionView?.button1?.addTarget(self, action: #selector(self.stayWithSomeoneIKnowQuestionView_done(sender:)), for: UIControlEvents.touchUpInside)
            stayWithSomeoneIKnowQuestionView?.button2?.addTarget(self, action: #selector(self.stayWithSomeoneIKnowQuestionView_addLater(sender:)), for: UIControlEvents.touchUpInside)
            let heightConstraint = NSLayoutConstraint(item: stayWithSomeoneIKnowQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (stayWithSomeoneIKnowQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            increaseProgressCircle(byPercent: standardProgressIncrement, onlyIfFirstDestination: true)
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 25)
    }

    func spawnHotelResultsQuestionView() {
        bookingMode = "hotel"
        
        var destinationCity = String()
        var destinationCityID = String()
        var destinationStateAbbrev = String()
        var isDestinationCityInUS = true
        var isDestinationCityNearAirport = false
        var originDay = String() //DD
        var originMonth = String() //MM
        var originYear = String() // YYYY
        var returnDay = String() //DD
        var returnMonth = String() //MM
        var returnYear = String() //YYYY
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        var destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
        var destinationsForTripStates = SavedPreferencesForTrip["destinationsForTripStates"] as! [String]
        
        destinationCity = destinationsForTrip[indexOfDestinationBeingPlanned]
        destinationStateAbbrev = findStateAbbreviationWith(state: destinationsForTripStates[indexOfDestinationBeingPlanned])
        if destinationStateAbbrev == "noStateMatch" {
            isDestinationCityInUS = false
            destinationStateAbbrev = findCountryAbbreviationWith(country: destinationsForTripStates[indexOfDestinationBeingPlanned])
        }
        destinationCityID = findCarCityIDWith(cityString: destinationCity, stateString: destinationStateAbbrev)
        
        if !isDestinationCityInUS {
            destinationStateAbbrev = destinationsForTripStates[indexOfDestinationBeingPlanned]
        }
        destinationStateAbbrev = destinationStateAbbrev.replacingOccurrences(of: " ", with: "+")
        destinationCity = destinationCity + ", \(destinationStateAbbrev)"
        destinationCity = destinationCity.replacingOccurrences(of: " ", with: "%20")
        
        if findAirportWith(cityID: destinationCityID).count > 0 {
            isDestinationCityNearAirport = true
        }
        
        let originDate = carRentalSearchQuestionView?.pickUpDate?.text
        originMonth = (originDate?[0])! + (originDate?[1])!                   //DD
        originDay = (originDate?[3])! + (originDate?[4])!                 //MM
        originYear = (originDate?[6])! + (originDate?[7])! + (originDate?[8])! + (originDate?[9])!                   //YYYY
        let returnDate = carRentalSearchQuestionView?.dropOffDate?.text
        returnMonth = (returnDate?[0])! + (returnDate?[1])!                   //DD
        returnDay = (returnDate?[3])! + (returnDate?[4])!                 //MM
        returnYear = (returnDate?[6])! + (returnDate?[7])! + (returnDate?[8])! + (returnDate?[9])!                  //YYYY
        
        var stringForURL = "http://secure.rezserver.com/hotels/home/?refid=8056"
        if destinationCityID != "noMatchingCity" {
            stringForURL = "http://secure.rezserver.com/hotels/results/?query=\(destinationCity)&check_in=\(originMonth)%2F\(originDay)%2F\(originYear)&check_out=\(returnMonth)%2F\(returnDay)%2F\(returnYear)&rooms=1&adults=2&refid=8056&city_id=\(destinationCityID)"
        }
        let whiteLabelURL_HotelSearchQuery = URL(string: stringForURL)!
        
        
        showWebsite(URL: whiteLabelURL_HotelSearchQuery)
        
//        self.view.endEditing(true)
//        hotelResultsController = self.storyboard!.instantiateViewController(withIdentifier: "exploreHotelsViewController") as? exploreHotelsViewController
//        hotelResultsController?.willMove(toParentViewController: self)
//        self.addChildViewController(hotelResultsController!)
//        hotelResultsController?.loadView()
//        hotelResultsController?.viewDidLoad()
//        hotelResultsController?.view.frame = self.view.bounds
//        for subview in (hotelSearchQuestionView?.subviews)! {
//            subview.isHidden = true
//        }
//        self.hotelSearchQuestionView?.addSubview((hotelResultsController?.view)!)
//        hotelResultsController?.view.tag = 26
//        hotelResultsController?.didMove(toParentViewController: self)
//        
//        updateProgress()

    }
    
    func spawnHotelBookingQuestionView() {
        
//        self.view.endEditing(true)
//        reviewAndBookHotelController = self.storyboard!.instantiateViewController(withIdentifier: "ReviewAndBookViewController") as? ReviewAndBookViewController
//        reviewAndBookHotelController?.willMove(toParentViewController: self)
//        self.addChildViewController(reviewAndBookHotelController!)
//        reviewAndBookHotelController?.bookingMode = "hotel"
//        reviewAndBookHotelController?.loadView()
//        reviewAndBookHotelController?.viewDidLoad()
//        reviewAndBookHotelController?.view.frame = self.view.bounds
//        hotelResultsController?.view.isHidden = true
//        self.hotelSearchQuestionView?.addSubview((reviewAndBookHotelController?.view)!)
//        reviewAndBookHotelController?.view.tag = 27
//        reviewAndBookHotelController?.didMove(toParentViewController: self)
//        
//        updateProgress()
    }
    
    func spawnPlaceForGroupOrJustYouQuestionView() {
        self.view.endEditing(true)
        if placeForGroupOrJustYouQuestionView == nil {
            //Load next question
            placeForGroupOrJustYouQuestionView = Bundle.main.loadNibNamed("PlaceForGroupOrJustYouQuestionView", owner: self, options: nil)?.first! as? PlaceForGroupOrJustYouQuestionView
            let bounds = UIScreen.main.bounds
            if hotelSearchQuestionView != nil {
                self.scrollContentView.insertSubview(placeForGroupOrJustYouQuestionView!, aboveSubview: hotelSearchQuestionView!)
                self.placeForGroupOrJustYouQuestionView!.frame = CGRect(x: 0, y: (hotelSearchQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else if stayWithSomeoneIKnowQuestionView != nil {
                self.scrollContentView.insertSubview(placeForGroupOrJustYouQuestionView!, aboveSubview: stayWithSomeoneIKnowQuestionView!)
                self.placeForGroupOrJustYouQuestionView!.frame = CGRect(x: 0, y: (stayWithSomeoneIKnowQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else if shortTermRentalSearchQuestionView != nil {
                self.scrollContentView.insertSubview(placeForGroupOrJustYouQuestionView!, aboveSubview: shortTermRentalSearchQuestionView!)
                self.placeForGroupOrJustYouQuestionView!.frame = CGRect(x: 0, y: (shortTermRentalSearchQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else if doYouNeedHelpBookingAHotelQuestionView != nil {
                self.scrollContentView.insertSubview(placeForGroupOrJustYouQuestionView!, aboveSubview: doYouNeedHelpBookingAHotelQuestionView!)
                self.placeForGroupOrJustYouQuestionView!.frame = CGRect(x: 0, y: (doYouNeedHelpBookingAHotelQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            }
            placeForGroupOrJustYouQuestionView?.tag = 28

            //PlaceToStayEdit
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            if SavedPreferencesForTrip["assistantMode"] as! String == "placeToStay" {
                placeForGroupOrJustYouQuestionView?.button1?.addTarget(self, action: #selector(self.placeForGroupOrJustYouQuestionView_entireGroup_backToItinerary(sender:)), for: UIControlEvents.touchUpInside)
                placeForGroupOrJustYouQuestionView?.button2?.addTarget(self, action: #selector(self.placeForGroupOrJustYouQuestionView_someOfGroup_backToItinerary(sender:)), for: UIControlEvents.touchUpInside)
                placeForGroupOrJustYouQuestionView?.button3?.addTarget(self, action: #selector(self.placeForGroupOrJustYouQuestionView_justMe_backToItinerary(sender:)), for: UIControlEvents.touchUpInside)
            } else if SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding" {
                placeForGroupOrJustYouQuestionView?.button1?.addTarget(self, action: #selector(self.placeForGroupOrJustYouQuestionView_entireGroup(sender:)), for: UIControlEvents.touchUpInside)
                placeForGroupOrJustYouQuestionView?.button2?.addTarget(self, action: #selector(self.placeForGroupOrJustYouQuestionView_someOfGroup(sender:)), for: UIControlEvents.touchUpInside)
                placeForGroupOrJustYouQuestionView?.button3?.addTarget(self, action: #selector(self.placeForGroupOrJustYouQuestionView_justMe(sender:)), for: UIControlEvents.touchUpInside)
            }
            let heightConstraint = NSLayoutConstraint(item: placeForGroupOrJustYouQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (placeForGroupOrJustYouQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            
            increaseProgressCircle(byPercent: 5, onlyIfFirstDestination: true)
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 28)
    }
    
    func spawnSendProposalQuestionView() {
        self.view.endEditing(true)
        if sendProposalQuestionView == nil {
            //Load next question
            sendProposalQuestionView = Bundle.main.loadNibNamed("SendProposalQuestionView", owner: self, options: nil)?.first! as? SendProposalQuestionView
            let bounds = UIScreen.main.bounds
            if placeForGroupOrJustYouQuestionView != nil {
                self.scrollContentView.insertSubview(sendProposalQuestionView!, aboveSubview: placeForGroupOrJustYouQuestionView!)
                self.sendProposalQuestionView!.frame = CGRect(x: 0, y: (placeForGroupOrJustYouQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else if hotelSearchQuestionView != nil {
                self.scrollContentView.insertSubview(sendProposalQuestionView!, aboveSubview: hotelSearchQuestionView!)
                self.sendProposalQuestionView!.frame = CGRect(x: 0, y: (hotelSearchQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            } else {
                self.scrollContentView.insertSubview(sendProposalQuestionView!, aboveSubview: doYouKnowWhereYouWillBeStayingQuestionView!)
                self.sendProposalQuestionView!.frame = CGRect(x: 0, y: (doYouKnowWhereYouWillBeStayingQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            }
            sendProposalQuestionView?.tag = 29
            let heightConstraint = NSLayoutConstraint(item: sendProposalQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (sendProposalQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            progressRing?.setProgress(value: 99, animationDuration: 1.0)
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 29)
    }

    func spawnYesIKnowWhereImStayingQuestionView() {
        self.view.endEditing(true)
        if yesIKnowWhereImStayingQuestionView == nil {
            //Load next question
            yesIKnowWhereImStayingQuestionView = Bundle.main.loadNibNamed("YesIKnowWhereImStayingQuestionView", owner: self, options: nil)?.first! as? YesIKnowWhereImStayingQuestionView
            self.scrollContentView.insertSubview(yesIKnowWhereImStayingQuestionView!, aboveSubview: doYouKnowWhereYouWillBeStayingQuestionView!)
            yesIKnowWhereImStayingQuestionView?.tag = 30
            let bounds = UIScreen.main.bounds
            yesIKnowWhereImStayingQuestionView?.button1?.addTarget(self, action: #selector(self.yesIKnowWhereImStayingQuestionView_hotel(sender:)), for: UIControlEvents.touchUpInside)
            yesIKnowWhereImStayingQuestionView?.button2?.addTarget(self, action: #selector(self.yesIKnowWhereImStayingQuestionView_shortTermRental(sender:)), for: UIControlEvents.touchUpInside)
            yesIKnowWhereImStayingQuestionView?.button3?.addTarget(self, action: #selector(self.yesIKnowWhereImStayingQuestionView_stayWithSomeoneIKnow(sender:)), for: UIControlEvents.touchUpInside)
            self.yesIKnowWhereImStayingQuestionView!.frame = CGRect(x: 0, y: (doYouKnowWhereYouWillBeStayingQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: yesIKnowWhereImStayingQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (yesIKnowWhereImStayingQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            increaseProgressCircle(byPercent: 5, onlyIfFirstDestination: true)
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 30)
    }
    func spawnDoYouNeedHelpBookingAHotelQuestionView() {
        self.view.endEditing(true)
        if doYouNeedHelpBookingAHotelQuestionView == nil {
            //Load next question
            doYouNeedHelpBookingAHotelQuestionView = Bundle.main.loadNibNamed("DoYouNeedHelpBookingAHotelQuestionView", owner: self, options: nil)?.first! as? DoYouNeedHelpBookingAHotelQuestionView
            self.scrollContentView.insertSubview(doYouNeedHelpBookingAHotelQuestionView!, aboveSubview: yesIKnowWhereImStayingQuestionView!)
            doYouNeedHelpBookingAHotelQuestionView?.tag = 31
            let bounds = UIScreen.main.bounds
            doYouNeedHelpBookingAHotelQuestionView?.button1?.addTarget(self, action: #selector(self.doYouNeedHelpBookingAHotelQuestionView_Yes(sender:)), for: UIControlEvents.touchUpInside)
            doYouNeedHelpBookingAHotelQuestionView?.button2?.addTarget(self, action: #selector(self.doYouNeedHelpBookingAHotelQuestionView_Done(sender:)), for: UIControlEvents.touchUpInside)
            doYouNeedHelpBookingAHotelQuestionView?.button3?.addTarget(self, action: #selector(self.doYouNeedHelpBookingAHotelQuestionView_illAddLater(sender:)), for: UIControlEvents.touchUpInside)
            self.doYouNeedHelpBookingAHotelQuestionView!.frame = CGRect(x: 0, y: (yesIKnowWhereImStayingQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: doYouNeedHelpBookingAHotelQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (doYouNeedHelpBookingAHotelQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            increaseProgressCircle(byPercent: 5, onlyIfFirstDestination: true)
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 31)
    }
    func spawnParseDatesForMultipleDestinationsCalendarView() {
        self.view.endEditing(true)
        if parseDatesForMultipleDestinationsCalendarView == nil  {
            //Load next question
            parseDatesForMultipleDestinationsCalendarView = Bundle.main.loadNibNamed("ParseDatesForMultipleDestinationsCalendarView", owner: self, options: nil)?.first! as? ParseDatesForMultipleDestinationsCalendarView
            parseDatesForMultipleDestinationsCalendarView?.tag = 32
            let bounds = UIScreen.main.bounds
            if addAnotherDestinationQuestionView != nil {
                self.scrollContentView.insertSubview(parseDatesForMultipleDestinationsCalendarView!, aboveSubview: addAnotherDestinationQuestionView!)
                self.parseDatesForMultipleDestinationsCalendarView!.frame = CGRect(x: 0, y: (addAnotherDestinationQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
                self.parseDatesForMultipleDestinationsCalendarView?.button1?.isHidden = false
            } else {
                self.scrollContentView.addSubview(parseDatesForMultipleDestinationsCalendarView!)
                self.parseDatesForMultipleDestinationsCalendarView!.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
                self.parseDatesForMultipleDestinationsCalendarView?.button1?.isHidden = true
            }
            parseDatesForMultipleDestinationsCalendarView?.button1?.addTarget(self, action: #selector(self.parseDatesForMultipleDestinationsCalendarView_changeDates(sender:)), for: UIControlEvents.touchUpInside)
            
            let heightConstraint = NSLayoutConstraint(item: parseDatesForMultipleDestinationsCalendarView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (parseDatesForMultipleDestinationsCalendarView?.frame.height)!)
            view.addConstraints([heightConstraint])
            increaseProgressCircle(byPercent: 5, onlyIfFirstDestination: true)
            
            
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 32)
        self.parseDatesForMultipleDestinationsCalendarView?.scrollToDate()
        let when = DispatchTime.now() + 1.4
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.parseDatesForMultipleDestinationsCalendarView?.calendarView.flashScrollIndicators()
        }
    }
    func spawnAlreadyHaveFlightsQuestionView() {
        self.view.endEditing(true)
        if alreadyHaveFlightsQuestionView == nil {
            //Load next question
            alreadyHaveFlightsQuestionView = Bundle.main.loadNibNamed("AlreadyHaveFlightsQuestionView", owner: self, options: nil)?.first! as? AlreadyHaveFlightsQuestionView
            self.scrollContentView.insertSubview(alreadyHaveFlightsQuestionView!, aboveSubview: flightSearchQuestionView!)
            alreadyHaveFlightsQuestionView?.tag = 35
            let bounds = UIScreen.main.bounds
            alreadyHaveFlightsQuestionView?.addButton?.addTarget(self, action: #selector(self.alreadyHaveFlightsQuestionView_save(sender:)), for: UIControlEvents.touchUpInside)
            self.alreadyHaveFlightsQuestionView!.frame = CGRect(x: 0, y: (flightSearchQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: alreadyHaveFlightsQuestionView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (alreadyHaveFlightsQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            increaseProgressCircle(byPercent: 5, onlyIfFirstDestination: true)
        }
        alignSubviews()
        scrollToSubviewWithTag(tag: 35)
    }

    
    
    
    
    
    
    
    
    

//    //FLIGHT SEARCH -> RESULTS -> BOOK FUNCTIONS
//    func removeFlightResultsViewController() {
//        self.willMove(toParentViewController: nil)
//        flightResultsController?.view.removeFromSuperview()
//        flightResultsController?.removeFromParentViewController()
//        if flightSearchQuestionView?.subviews != nil {
//            for subview in (flightSearchQuestionView?.subviews)! {
//                subview.isHidden = false
//            }
//        }
//        flightSearchQuestionView?.handleSearchMode()
//        flightSearchQuestionView?.searchButton?.isSelected = false
//        flightSearchQuestionView?.searchButton?.layer.borderWidth = 1
//    }
//    func removeBookSelectedFlightViewController() {
//        self.willMove(toParentViewController: nil)
//        reviewAndBookFlightsController?.view.removeFromSuperview()
//        reviewAndBookFlightsController?.removeFromParentViewController()
//    }
//    
//    func bookSelectedFlightToFlightResults() {
//        removeBookSelectedFlightViewController()
//        flightResultsController?.view.isHidden = false
//    }
//    
//    func flightSelectedBooked() {
//        removeFlightResultsViewController()
//        removeBookSelectedFlightViewController()
//        spawnDoYouNeedARentalCarQuestionView()
        
        // LINK TO ITINERARY
        // SHOW USER WHERE ITINERARY SAVED
//    }
//
//    func flightSelectedSavedForLater() {
//        spawnDoYouNeedARentalCarQuestionView()
//        
//        // LINK TO ITINERARY
//        // SHOW USER WHERE SELECTED FLIGHT SAVED AND WHERE TO BOOK QUICKLY
//    }

    
    
    
    
    
//    //CAR RENTAL SEARCH -> RESULTS -> BOOK FUNCTIONS
//    func removeCarRentalResultsViewController() {
//        self.willMove(toParentViewController: nil)
//        carRentalResultsController?.view.removeFromSuperview()
//        carRentalResultsController?.removeFromParentViewController()
//        if carRentalSearchQuestionView?.subviews != nil {
//            for subview in (carRentalSearchQuestionView?.subviews)! {
//                subview.isHidden = false
//            }
//        }
//        carRentalSearchQuestionView?.handleSearchMode()
//        carRentalSearchQuestionView?.searchButton?.isSelected = false
//        carRentalSearchQuestionView?.searchButton?.layer.borderWidth = 1
//        
//    }
//    func removeBookSelectedCarRentalViewController() {
//        self.willMove(toParentViewController: nil)
//        reviewAndBookCarRentalController?.view.removeFromSuperview()
//        reviewAndBookCarRentalController?.removeFromParentViewController()
//    }
//    
//    func bookSelectedCarRentalToCarRentalResults() {
//        removeBookSelectedCarRentalViewController()
//        carRentalResultsController?.view.isHidden = false
//    }
//    
    func carRentalSelectedBooked() {
//        removeCarRentalResultsViewController()
//        removeBookSelectedCarRentalViewController()
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        if travelDictionaryArray[indexOfDestinationBeingPlanned]["modeOfTransportation"] as! String == "drive" {
            spawnAboutWhatTimeWillYouStartDrivingQuestionView()
        } else {
            planPlaceToStayOrReviewItinerary()
        }
        
        // LINK TO ITINERARY
        // SHOW USER WHERE ITINERARY SAVED
    }
//    
//    func carRentalSelectedSavedForLater() {
//        spawnDoYouKnowWhereYouWillBeStayingQuestionView()
//        
//        // LINK TO ITINERARY
//        // SHOW USER WHERE SELECTED FLIGHT SAVED AND WHERE TO BOOK QUICKLY
//    }

    
    
    
    
//    //CAR RENTAL SEARCH -> RESULTS -> BOOK FUNCTIONS
//    func removeHotelResultsViewController() {
//        self.willMove(toParentViewController: nil)
//        hotelResultsController?.view.removeFromSuperview()
//        hotelResultsController?.removeFromParentViewController()
//        if hotelSearchQuestionView?.subviews != nil {
//            for subview in (hotelSearchQuestionView?.subviews)! {
//                subview.isHidden = false
//            }
//        }
//        hotelSearchQuestionView?.searchButton?.isSelected = false
//        hotelSearchQuestionView?.searchButton?.removeMask(button: (hotelSearchQuestionView?.searchButton)!)
//        
//    }
//    func removeBookSelectedHotelViewController() {
//        self.willMove(toParentViewController: nil)
//        reviewAndBookHotelController?.view.removeFromSuperview()
//        reviewAndBookHotelController?.removeFromParentViewController()
//    }
//    func bookSelectedHotelToHotelResults() {
//        removeBookSelectedHotelViewController()
//        hotelResultsController?.view.isHidden = false
//    }
    //func hotelSelectedBooked() {
//        removeHotelResultsViewController()
//        removeBookSelectedHotelViewController()
      //  spawnPlaceForGroupOrJustYouQuestionView()
        // LINK TO ITINERARY
        // SHOW USER WHERE ITINERARY SAVED
    //}
//    func hotelSelectedSavedForLater() {
//        spawnPlaceForGroupOrJustYouQuestionView()
//        
//        // LINK TO ITINERARY
//        // SHOW USER WHERE SELECTED FLIGHT SAVED AND WHERE TO BOOK QUICKLY
//    }
    
    
    
    
    
    // MARK: Sent events
    func instructionsQuestionView_gotIt(sender:UIButton) {
        if sender.isSelected == true {
            spawnTripNameQuestionView()
        }
    }
    func tripNameQuestionButtonClicked(sender:UIButton) {
        if sender.isSelected == true {
            tripNameQuestionView?.tripNameQuestionTextfield?.resignFirstResponder()
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["trip_name"] = tripNameQuestionView?.tripNameQuestionTextfield?.text
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            spawnDatesPickedOutCalendarView()
        }
    }
    func asyncUpdateProgress() {
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.updateProgress()
        }
    }
    func handleCalendarRangeSelected() {
        asyncUpdateProgress()
    }
    func destinationOptionsCardViewSwiped() {
        let when = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.updateProgress()
        }
    }
    func parseDatesForMultipleDestinationsDateSelected () {
        asyncUpdateProgress()
    }
    func tripCalendarRangeSelectedDoneButtonTouchedUpInside() {
        if parseDatesForMultipleDestinationsCalendarView != nil {
        } else {
            spawnWhereTravellingFromQuestionView()
        }
        asyncUpdateProgress()
    }
    
    func decidedOnCityToVisitQuestion_No(sender:UIButton) {
        if sender.isSelected == true {
            if yesCityDecidedQuestionView != nil {
                yesCityDecidedQuestionView?.removeFromSuperview()
                yesCityDecidedQuestionView = nil
                if addAnotherDestinationQuestionView != nil {
                    addAnotherDestinationQuestionView?.removeFromSuperview()
                    addAnotherDestinationQuestionView = nil
                }
                alignSubviews()
            }
            spawnNoCityDecidedAnyIdeasQuestionView()
        }
    }
    func decidedOnCityToVisitQuestion_Yes(sender:UIButton) {
        if sender.isSelected == true {
            if noCityDecidedAnyIdeasQuestionView != nil {
                noCityDecidedAnyIdeasQuestionView?.removeFromSuperview()
                noCityDecidedAnyIdeasQuestionView = nil
                if planTripToIdeaQuestionView != nil {
                    planTripToIdeaQuestionView?.removeFromSuperview()
                    planTripToIdeaQuestionView = nil
                }
                if whatTypeOfTripQuestionView != nil {
                    whatTypeOfTripQuestionView?.removeFromSuperview()
                    whatTypeOfTripQuestionView = nil
                }
                if howFarAwayQuestionView != nil {
                    howFarAwayQuestionView?.removeFromSuperview()
                    howFarAwayQuestionView = nil
                }
                if destinationOptionsCardView != nil {
                    destinationOptionsCardView?.removeFromSuperview()
                    destinationOptionsCardView = nil
                }
                if addAnotherDestinationQuestionView != nil {
                    addAnotherDestinationQuestionView?.removeFromSuperview()
                    addAnotherDestinationQuestionView = nil
                }
                alignSubviews()
            }
            spawnYesCityDecidedQuestionView()
        }
    }
    func yesCityDecidedQuestionView_actuallyDiscoverMoreOptions(sender:UIButton) {
        if sender.isSelected == true {
            //decidedOnCityToVisitQuestionView?.button2?.sendActions(for: .touchUpInside)
            
            //if yesCityDecidedQuestionView != nil {
              //  yesCityDecidedQuestionView?.removeFromSuperview()
               // yesCityDecidedQuestionView = nil
                if addAnotherDestinationQuestionView != nil {
                    addAnotherDestinationQuestionView?.removeFromSuperview()
                    addAnotherDestinationQuestionView = nil
                }
                alignSubviews()
            //}
            //spawnNoCityDecidedAnyIdeasQuestionView()
            spawnWhatTypeOfTripQuestionView()
            
        }
    }
    
    func noCityDecidedAnyIdeasQuestionView_noIdeas(sender:UIButton) {
        if sender.isSelected == true {
            if planTripToIdeaQuestionView != nil {
                planTripToIdeaQuestionView?.removeFromSuperview()
                planTripToIdeaQuestionView = nil
            }
            spawnWhatTypeOfTripQuestionView()
        }
    }
    func noCityDecidedAnyIdeasQuestionView_ideaEntered() {
        if whatTypeOfTripQuestionView != nil {
            whatTypeOfTripQuestionView?.removeFromSuperview()
            whatTypeOfTripQuestionView = nil
        }
        if howFarAwayQuestionView != nil {
            howFarAwayQuestionView?.removeFromSuperview()
            howFarAwayQuestionView = nil
        }
        if destinationOptionsCardView != nil {
            destinationOptionsCardView?.removeFromSuperview()
            destinationOptionsCardView = nil
        }
        if addAnotherDestinationQuestionView != nil {
            addAnotherDestinationQuestionView?.removeFromSuperview()
            addAnotherDestinationQuestionView = nil
        }
        alignSubviews()
        spawnPlanIdeaAsDestinationQuestionView()
    }
    
    func planTripToIdeaQuestionView_Yes(sender:UIButton) {
        if sender.isSelected == true {
            if whatTypeOfTripQuestionView != nil {
                whatTypeOfTripQuestionView?.removeFromSuperview()
                whatTypeOfTripQuestionView = nil
            }
            if howFarAwayQuestionView != nil {
                howFarAwayQuestionView?.removeFromSuperview()
                howFarAwayQuestionView = nil
            }
            if destinationOptionsCardView != nil {
                destinationOptionsCardView?.removeFromSuperview()
                destinationOptionsCardView = nil
            }
            if addAnotherDestinationQuestionView != nil {
                addAnotherDestinationQuestionView?.removeFromSuperview()
                addAnotherDestinationQuestionView = nil
            }
            spawnAddAnotherDestinationQuestionView()
        }
    }
    func planTripToIdeaQuestionView_No(sender:UIButton) {
        if sender.isSelected == true {
            if addAnotherDestinationQuestionView != nil {
                addAnotherDestinationQuestionView?.removeFromSuperview()
                addAnotherDestinationQuestionView = nil
            }
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
            destinationChosenUpdateDatesDestinationsDict()
            
            addAnotherDestinationQuestionView?.button2?.isHidden = true
            
            //set planning index to 0
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            indexOfDestinationBeingPlanned = 0
            SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = indexOfDestinationBeingPlanned as NSNumber
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            if (SavedPreferencesForTrip["destinationsForTrip"] as! [String]).count > 1 {
                spawnParseDatesForMultipleDestinationsCalendarView()
            } else {
                spawnHowDoYouWantToGetThereQuestionView()
            }
        }
    }
    func addAnotherDestinationQuestionView_addAnother(sender:UIButton) {
        if sender.isSelected == true {
            //Increment index of destinationBeingPlanned
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            
            indexOfDestinationBeingPlanned += 1
            SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = indexOfDestinationBeingPlanned as NSNumber
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let bounds = UIScreen.main.bounds
            if yesCityDecidedQuestionView != nil {
                self.scrollContentView.bringSubview(toFront: yesCityDecidedQuestionView!)
                self.yesCityDecidedQuestionView!.frame = CGRect(x: 0, y: (addAnotherDestinationQuestionView?.frame.maxY)!, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
                self.yesCityDecidedQuestionView?.searchController?.searchBar.text = ""
                self.yesCityDecidedQuestionView?.questionLabel?.text = "Where else do you want to go?"
                self.yesCityDecidedQuestionView?.questionLabel?.font = UIFont.boldSystemFont(ofSize: 24)
                updateProgress()
                scrollToSubviewWithTag(tag: 9)
            }
            if indexOfDestinationBeingPlanned > 0 {
                self.yesCityDecidedQuestionView?.questionLabel?.text = "Where else do you want to go?"
            }
            
            let when = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.alignSubviews()
                self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollContentView.subviews[self.scrollContentView.subviews.count - 1].frame.minY), animated: false)
            }
            let when2 = DispatchTime.now() + 1.2
            DispatchQueue.main.asyncAfter(deadline: when2) {
                if self.decidedOnCityToVisitQuestionView != nil {
                    self.decidedOnCityToVisitQuestionView?.removeFromSuperview()
                    self.decidedOnCityToVisitQuestionView = nil
                }
                if self.noCityDecidedAnyIdeasQuestionView != nil {
                    self.noCityDecidedAnyIdeasQuestionView?.removeFromSuperview()
                    self.noCityDecidedAnyIdeasQuestionView = nil
                    if self.planTripToIdeaQuestionView != nil {
                        self.planTripToIdeaQuestionView?.removeFromSuperview()
                        self.planTripToIdeaQuestionView = nil
                    }
                    if self.whatTypeOfTripQuestionView != nil {
                        self.whatTypeOfTripQuestionView?.removeFromSuperview()
                        self.whatTypeOfTripQuestionView = nil
                    }
                    if self.howFarAwayQuestionView != nil {
                        self.howFarAwayQuestionView?.removeFromSuperview()
                        self.howFarAwayQuestionView = nil
                    }
                    if self.destinationOptionsCardView != nil {
                        self.destinationOptionsCardView?.removeFromSuperview()
                        self.destinationOptionsCardView = nil
                    }
                }
                if self.addAnotherDestinationQuestionView != nil {
                    self.addAnotherDestinationQuestionView?.removeFromSuperview()
                    self.addAnotherDestinationQuestionView = nil
                }
                self.alignSubviews()
                self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollContentView.subviews[self.scrollContentView.subviews.count - 1].frame.minY), animated: false)
            }

        }
    }

    func test() {
        if decidedOnCityToVisitQuestionView != nil {
            decidedOnCityToVisitQuestionView?.removeFromSuperview()
            decidedOnCityToVisitQuestionView = nil
        }
        if noCityDecidedAnyIdeasQuestionView != nil {
            noCityDecidedAnyIdeasQuestionView?.removeFromSuperview()
            noCityDecidedAnyIdeasQuestionView = nil
            if planTripToIdeaQuestionView != nil {
                planTripToIdeaQuestionView?.removeFromSuperview()
                planTripToIdeaQuestionView = nil
            }
            if whatTypeOfTripQuestionView != nil {
                whatTypeOfTripQuestionView?.removeFromSuperview()
                whatTypeOfTripQuestionView = nil
            }
            if howFarAwayQuestionView != nil {
                howFarAwayQuestionView?.removeFromSuperview()
                howFarAwayQuestionView = nil
            }
            if destinationOptionsCardView != nil {
                destinationOptionsCardView?.removeFromSuperview()
                destinationOptionsCardView = nil
            }
        }
        if addAnotherDestinationQuestionView != nil {
            addAnotherDestinationQuestionView?.removeFromSuperview()
            addAnotherDestinationQuestionView = nil
        }
        alignSubviews()
        
        //LINK TO ITINERARY AND SHOW WERE DESTINATION WAS SAVED
        
        //spawn new destination flow
        //spawnYesCityDecidedQuestionView()

    }
    func howDoYouWantToGetThereQuestionView_fly(sender:UIButton) {
        if sender.isSelected == true {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            let destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
            if indexOfDestinationBeingPlanned >= travelDictionaryArray.count {
                if destinationsForTrip.count == 1 {
                    travelDictionaryArray.append(["modeOfTransportation":"fly","isRoundtrip":true])
                } else if destinationsForTrip.count > 1 {
                    travelDictionaryArray.append(["modeOfTransportation":"fly","isRoundtrip":false])
                }
            } else if indexOfDestinationBeingPlanned < travelDictionaryArray.count {
                if travelDictionaryArray[indexOfDestinationBeingPlanned]["modeOfTransportation"] as! String != "fly" {
                    if doYouNeedARentalCarQuestionView != nil {
                        doYouNeedARentalCarQuestionView?.removeFromSuperview()
                        doYouNeedARentalCarQuestionView = nil
                        if carRentalSearchQuestionView != nil {
                            carRentalSearchQuestionView?.removeFromSuperview()
                            carRentalSearchQuestionView = nil
                        }
                        if aboutWhatTimeWillYouStartDrivingQuestionView != nil {
                            aboutWhatTimeWillYouStartDrivingQuestionView?.removeFromSuperview()
                            aboutWhatTimeWillYouStartDrivingQuestionView = nil
                        }
                    }
                    if busTrainOtherQuestionView != nil {
                        busTrainOtherQuestionView?.removeFromSuperview()
                        busTrainOtherQuestionView = nil
                    }
                    if idkHowToGetThereQuestionView != nil {
                        idkHowToGetThereQuestionView?.removeFromSuperview()
                        idkHowToGetThereQuestionView = nil
                    }
                }
                if destinationsForTrip.count == 1 {
                    travelDictionaryArray[indexOfDestinationBeingPlanned] = ["modeOfTransportation":"fly","isRoundtrip":true]
                } else if destinationsForTrip.count > 1 {
                    travelDictionaryArray[indexOfDestinationBeingPlanned] = ["modeOfTransportation":"fly","isRoundtrip":false]
                }

            }
            SavedPreferencesForTrip["travelDictionaryArray"] = travelDictionaryArray
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            spawnFlightSearchQuestionView()
        }
    }
    func howDoYouWantToGetThereQuestionView_drive(sender:UIButton) {
        if sender.isSelected == true {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            let destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
            if indexOfDestinationBeingPlanned >= travelDictionaryArray.count {
                if destinationsForTrip.count == 1 {
                    travelDictionaryArray.append(["modeOfTransportation":"fly","isRoundtrip":true])
                } else if destinationsForTrip.count > 1 {
                    travelDictionaryArray.append(["modeOfTransportation":"fly","isRoundtrip":false])
                }
            } else if indexOfDestinationBeingPlanned < travelDictionaryArray.count {
                if travelDictionaryArray[indexOfDestinationBeingPlanned]["modeOfTransportation"] as! String != "drive" {
                    if flightSearchQuestionView != nil {
                        flightSearchQuestionView?.removeFromSuperview()
                        flightSearchQuestionView = nil
                        alreadyHaveFlightsQuestionView?.removeFromSuperview()
                        alreadyHaveFlightsQuestionView = nil
                        if doYouNeedARentalCarQuestionView != nil {
                            doYouNeedARentalCarQuestionView?.removeFromSuperview()
                            doYouNeedARentalCarQuestionView = nil
                            if carRentalSearchQuestionView != nil {
                                carRentalSearchQuestionView?.removeFromSuperview()
                                carRentalSearchQuestionView = nil
                            }
                        }
                    }
                    if busTrainOtherQuestionView != nil {
                        busTrainOtherQuestionView?.removeFromSuperview()
                        busTrainOtherQuestionView = nil
                    }
                    if idkHowToGetThereQuestionView != nil {
                        idkHowToGetThereQuestionView?.removeFromSuperview()
                        idkHowToGetThereQuestionView = nil
                    }
                        
                }
                if destinationsForTrip.count == 1 {
                    travelDictionaryArray[indexOfDestinationBeingPlanned] = ["modeOfTransportation":"drive","isRoundtrip":true]
                } else if destinationsForTrip.count > 1 {
                    travelDictionaryArray[indexOfDestinationBeingPlanned] = ["modeOfTransportation":"drive","isRoundtrip":false]
                }
            }
            SavedPreferencesForTrip["travelDictionaryArray"] = travelDictionaryArray
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            spawnDoYouNeedARentalCarQuestionView()
        }
    }
    func howDoYouWantToGetThereQuestionView_busTrainOther(sender:UIButton) {
        if sender.isSelected == true {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            if indexOfDestinationBeingPlanned >= travelDictionaryArray.count {
                travelDictionaryArray.append(["modeOfTransportation":"busTrainOther"])
            } else if indexOfDestinationBeingPlanned < travelDictionaryArray.count {
                if travelDictionaryArray[indexOfDestinationBeingPlanned]["modeOfTransportation"] as! String != "busTrainOther" {
                    if  flightSearchQuestionView != nil {
                        flightSearchQuestionView?.removeFromSuperview()
                        flightSearchQuestionView = nil
                        alreadyHaveFlightsQuestionView?.removeFromSuperview()
                        alreadyHaveFlightsQuestionView = nil
                        if doYouNeedARentalCarQuestionView != nil {
                            doYouNeedARentalCarQuestionView?.removeFromSuperview()
                            doYouNeedARentalCarQuestionView = nil
                            if carRentalSearchQuestionView != nil {
                                carRentalSearchQuestionView?.removeFromSuperview()
                                carRentalSearchQuestionView = nil
                            }
                        }
                    }
                    if doYouNeedARentalCarQuestionView != nil {
                        doYouNeedARentalCarQuestionView?.removeFromSuperview()
                        doYouNeedARentalCarQuestionView = nil
                        if carRentalSearchQuestionView != nil {
                            carRentalSearchQuestionView?.removeFromSuperview()
                            carRentalSearchQuestionView = nil
                        }
                        if aboutWhatTimeWillYouStartDrivingQuestionView != nil {
                            aboutWhatTimeWillYouStartDrivingQuestionView?.removeFromSuperview()
                            aboutWhatTimeWillYouStartDrivingQuestionView = nil
                        }
                    }
                    if idkHowToGetThereQuestionView != nil {
                        idkHowToGetThereQuestionView?.removeFromSuperview()
                        idkHowToGetThereQuestionView = nil
                    }
                }

                travelDictionaryArray[indexOfDestinationBeingPlanned] = ["modeOfTransportation":"busTrainOther"]
            }
            SavedPreferencesForTrip["travelDictionaryArray"] = travelDictionaryArray
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            spawnBusTrainOtherQuestionView()
        }
    }
    func howDoYouWantToGetThereQuestionView_iDontKnowHelpMe(sender:UIButton) {
        if sender.isSelected == true {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            if indexOfDestinationBeingPlanned >= travelDictionaryArray.count {
                travelDictionaryArray.append(["modeOfTransportation":"iDontKnowHelpMe"])
            } else if indexOfDestinationBeingPlanned < travelDictionaryArray.count {
                if travelDictionaryArray[indexOfDestinationBeingPlanned]["modeOfTransportation"] as! String != "iDontKnowHelpMe" {
                    if flightSearchQuestionView != nil {
                        flightSearchQuestionView?.removeFromSuperview()
                        flightSearchQuestionView = nil
                        alreadyHaveFlightsQuestionView?.removeFromSuperview()
                        alreadyHaveFlightsQuestionView = nil
                        if doYouNeedARentalCarQuestionView != nil {
                            doYouNeedARentalCarQuestionView?.removeFromSuperview()
                            doYouNeedARentalCarQuestionView = nil
                            if carRentalSearchQuestionView != nil {
                                carRentalSearchQuestionView?.removeFromSuperview()
                                carRentalSearchQuestionView = nil
                            }
                        }
                    }
                    if doYouNeedARentalCarQuestionView != nil {
                        doYouNeedARentalCarQuestionView?.removeFromSuperview()
                        doYouNeedARentalCarQuestionView = nil
                        if carRentalSearchQuestionView != nil {
                            carRentalSearchQuestionView?.removeFromSuperview()
                            carRentalSearchQuestionView = nil
                        }
                        if aboutWhatTimeWillYouStartDrivingQuestionView != nil {
                            aboutWhatTimeWillYouStartDrivingQuestionView?.removeFromSuperview()
                            aboutWhatTimeWillYouStartDrivingQuestionView = nil
                        }
                    }
                    if busTrainOtherQuestionView != nil {
                        busTrainOtherQuestionView?.removeFromSuperview()
                        busTrainOtherQuestionView = nil
                    }
                }

                travelDictionaryArray[indexOfDestinationBeingPlanned] = ["modeOfTransportation":"iDontKnowHelpMe"]
            }
            SavedPreferencesForTrip["travelDictionaryArray"] = travelDictionaryArray
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            spawnidkHowToGetThereQuestionView()
        }
    }
    func howDoYouWantToGetThereQuestionView_illAlreadyBeThere(sender:UIButton) {
        if sender.isSelected == true {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            if indexOfDestinationBeingPlanned >= travelDictionaryArray.count {
                travelDictionaryArray.append(["modeOfTransportation":"illAlreadyBeThere"])
            } else if indexOfDestinationBeingPlanned < travelDictionaryArray.count {
                if travelDictionaryArray[indexOfDestinationBeingPlanned]["modeOfTransportation"] as! String != "illAlreadyBeThere" {
                    if flightSearchQuestionView != nil {
                        flightSearchQuestionView?.removeFromSuperview()
                        flightSearchQuestionView = nil
                        alreadyHaveFlightsQuestionView?.removeFromSuperview()
                        alreadyHaveFlightsQuestionView = nil
                        if doYouNeedARentalCarQuestionView != nil {
                            doYouNeedARentalCarQuestionView?.removeFromSuperview()
                            doYouNeedARentalCarQuestionView = nil
                            if carRentalSearchQuestionView != nil {
                                carRentalSearchQuestionView?.removeFromSuperview()
                                carRentalSearchQuestionView = nil
                            }
                        }
                    }
                    if doYouNeedARentalCarQuestionView != nil {
                        doYouNeedARentalCarQuestionView?.removeFromSuperview()
                        doYouNeedARentalCarQuestionView = nil
                        if carRentalSearchQuestionView != nil {
                            carRentalSearchQuestionView?.removeFromSuperview()
                            carRentalSearchQuestionView = nil
                        }
                        if aboutWhatTimeWillYouStartDrivingQuestionView != nil {
                            aboutWhatTimeWillYouStartDrivingQuestionView?.removeFromSuperview()
                            aboutWhatTimeWillYouStartDrivingQuestionView = nil
                        }
                    }
                    if busTrainOtherQuestionView != nil {
                        busTrainOtherQuestionView?.removeFromSuperview()
                        busTrainOtherQuestionView = nil
                    }
                    if idkHowToGetThereQuestionView != nil {
                        idkHowToGetThereQuestionView?.removeFromSuperview()
                        idkHowToGetThereQuestionView = nil
                    }
                }
                travelDictionaryArray[indexOfDestinationBeingPlanned] = ["modeOfTransportation":"illAlreadyBeThere"]
            }
            
            travelDictionaryArray[indexOfDestinationBeingPlanned]["illAlreadyBeThereText"] = "I'll already be there."
            
            SavedPreferencesForTrip["travelDictionaryArray"] = travelDictionaryArray
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            planPlaceToStayOrReviewItinerary()
        }
    }
    func howDoYouWantToGetThereQuestionView_skipThisIPlannedRoundTripTravel(sender:UIButton) {
        initialItineraryBuildingCompleteReviewItinerary()
    }
    func searchFlights(sender:UIButton) {
        if alreadyHaveFlightsQuestionView != nil {
            alreadyHaveFlightsQuestionView?.removeFromSuperview()
            alreadyHaveFlightsQuestionView = nil
        }
        spawnFlightResultsQuestionView()
    }
    func flightSearchQuestionView_alreadyHaveFlights(sender:UIButton) {
        if sender.isSelected == true {
            spawnAlreadyHaveFlightsQuestionView()
        }
    }
    func alreadyHaveFlightsQuestionView_save(sender:UIButton) {
        if sender.isSelected == true {
            spawnDoYouNeedARentalCarQuestionView()
        }
    }
    func doYouNeedARentalCarQuestionView_yes(sender:UIButton) {
        if sender.isSelected == true {
            spawnCarRentalSearchQuestionView()
        }
    }
    func doYouNeedARentalCarQuestionView_no(sender:UIButton) {
        if sender.isSelected == true {
            if carRentalSearchQuestionView != nil {
                carRentalSearchQuestionView?.removeFromSuperview()
                carRentalSearchQuestionView = nil
            }
            
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            if travelDictionaryArray[indexOfDestinationBeingPlanned]["modeOfTransportation"] as! String == "drive" {
                spawnAboutWhatTimeWillYouStartDrivingQuestionView()
            } else {
                planPlaceToStayOrReviewItinerary()
            }
        }
    }
    
    func doYouNeedARentalCarQuestionView_yes_backToItinerary(sender:UIButton) {
        if sender.isSelected == true {
            disableAndResetAssistant_moveToItinerary()
        }
    }
    func doYouNeedARentalCarQuestionView_no_backToItinerary(sender:UIButton) {
        if sender.isSelected == true {
            if carRentalSearchQuestionView != nil {
                carRentalSearchQuestionView?.removeFromSuperview()
                carRentalSearchQuestionView = nil
            }
            
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            if travelDictionaryArray[indexOfDestinationBeingPlanned]["modeOfTransportation"] as! String == "drive" {
                spawnAboutWhatTimeWillYouStartDrivingQuestionView()
            } else {
                disableAndResetAssistant_moveToItinerary()
            }
        }
    }

    
    
    
    func searchRentalCars(sender:UIButton) {
        spawnRentalCarResultsQuestionView()
    }
    func notSureYetWhenStartDriving(sender:UIButton) {
        if sender.isSelected == true {
            planPlaceToStayOrReviewItinerary()
        }
    }
    func timeChosenWhenStartDriving(sender:UIButton) {
        if sender.isSelected == true {
            planPlaceToStayOrReviewItinerary()
        }
    }
    
    func notSureYetWhenStartDriving_backToItinerary(sender:UIButton) {
        if sender.isSelected == true {
            disableAndResetAssistant_moveToItinerary()
        }
    }
    func timeChosenWhenStartDriving_backToItinerary(sender:UIButton) {
        if sender.isSelected == true {
            disableAndResetAssistant_moveToItinerary()
        }
    }
    

    
    func doYouKnowWhereYouWillBeStaying_yes(sender:UIButton) {
        if sender.isSelected == true {
            if doYouKnowWhereYouWillBeStayingQuestionView != nil {
                if whatTypeOfPlaceToStayQuestionView != nil {
                    whatTypeOfPlaceToStayQuestionView?.removeFromSuperview()
                    whatTypeOfPlaceToStayQuestionView = nil
                    if hotelSearchQuestionView != nil {
                        hotelSearchQuestionView?.removeFromSuperview()
                        hotelSearchQuestionView = nil
                    }
                    if shortTermRentalSearchQuestionView != nil {
                        shortTermRentalSearchQuestionView?.removeFromSuperview()
                        shortTermRentalSearchQuestionView = nil
                    }
                    if stayWithSomeoneIKnowQuestionView != nil {
                        stayWithSomeoneIKnowQuestionView?.removeFromSuperview()
                        stayWithSomeoneIKnowQuestionView = nil
                    }
                    if placeForGroupOrJustYouQuestionView != nil {
                        placeForGroupOrJustYouQuestionView?.removeFromSuperview()
                        placeForGroupOrJustYouQuestionView = nil
                    }
                }
            }
            
            
            spawnYesIKnowWhereImStayingQuestionView()
        }
    }
    func doYouKnowWhereYouWillBeStaying_noPlanNow(sender:UIButton) {
        if sender.isSelected == true {
            if yesIKnowWhereImStayingQuestionView != nil {
                yesIKnowWhereImStayingQuestionView?.removeFromSuperview()
                yesIKnowWhereImStayingQuestionView = nil
            }
            if doYouNeedHelpBookingAHotelQuestionView != nil {
                doYouNeedHelpBookingAHotelQuestionView?.removeFromSuperview()
                doYouNeedHelpBookingAHotelQuestionView = nil
            }
            if whatTypeOfPlaceToStayQuestionView != nil {
                whatTypeOfPlaceToStayQuestionView?.removeFromSuperview()
                whatTypeOfPlaceToStayQuestionView = nil
                if hotelSearchQuestionView != nil {
                    hotelSearchQuestionView?.removeFromSuperview()
                    hotelSearchQuestionView = nil
                }
                if shortTermRentalSearchQuestionView != nil {
                    shortTermRentalSearchQuestionView?.removeFromSuperview()
                    shortTermRentalSearchQuestionView = nil
                }
                if stayWithSomeoneIKnowQuestionView != nil {
                    stayWithSomeoneIKnowQuestionView?.removeFromSuperview()
                    stayWithSomeoneIKnowQuestionView = nil
                }
                if placeForGroupOrJustYouQuestionView != nil {
                    placeForGroupOrJustYouQuestionView?.removeFromSuperview()
                    placeForGroupOrJustYouQuestionView = nil
                }
            }
            spawnWhatTypeOfPlaceToStayQuestionView()
        }
    }
    func doYouKnowWhereYouWillBeStaying_noPlanLater(sender:UIButton) {
        if sender.isSelected == true {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            if SavedPreferencesForTrip["assistantMode"] as! String == "placeToStay" {
                disableAndResetAssistant_moveToItinerary()
            } else if whatTypeOfPlaceToStayQuestionView != nil {
                whatTypeOfPlaceToStayQuestionView?.removeFromSuperview()
                whatTypeOfPlaceToStayQuestionView = nil
                if hotelSearchQuestionView != nil {
                    hotelSearchQuestionView?.removeFromSuperview()
                    hotelSearchQuestionView = nil
                }
                if shortTermRentalSearchQuestionView != nil {
                    shortTermRentalSearchQuestionView?.removeFromSuperview()
                    shortTermRentalSearchQuestionView = nil
                }
                if stayWithSomeoneIKnowQuestionView != nil {
                    stayWithSomeoneIKnowQuestionView?.removeFromSuperview()
                    stayWithSomeoneIKnowQuestionView = nil
                }
                if placeForGroupOrJustYouQuestionView != nil {
                    placeForGroupOrJustYouQuestionView?.removeFromSuperview()
                    placeForGroupOrJustYouQuestionView = nil
                }
        
                planTravelAndPlaceToStayForAnotherDestinationOrSendProposalQuestionView()
                
            } else {
                planTravelAndPlaceToStayForAnotherDestinationOrSendProposalQuestionView()
            }
        }
    }
    
    func busTrainOtherTravelPlans_done(sender:UIButton) {
        if sender.isSelected == true {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            travelDictionaryArray[indexOfDestinationBeingPlanned]["busTrainOtherText"] = busTrainOtherQuestionView?.textView?.text
            SavedPreferencesForTrip["travelDictionaryArray"] = travelDictionaryArray
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            spawnDoYouNeedARentalCarQuestionView()
        }
    }
    func busTrainOtherTravelPlans_addLater(sender:UIButton) {
        if sender.isSelected == true {
            spawnDoYouNeedARentalCarQuestionView()
        }
    }
    func idkHowToGetThere_readyToPlan(sender:UIButton) {
        if sender.isSelected == true {
            scrollToSubviewWithTag(tag: 10)
            let when = DispatchTime.now() + 1.1
            DispatchQueue.main.asyncAfter(deadline: when) {
                if self.idkHowToGetThereQuestionView != nil {
                    self.idkHowToGetThereQuestionView?.removeFromSuperview()
                    self.idkHowToGetThereQuestionView = nil
                    self.alignSubviews()
                }

            }
        }        
    }
    func whatTypeOfPlaceToStayQuestionView_hotel(sender:UIButton) {
        if sender.isSelected == true {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var placeToStayDictionaryArray = SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]]
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            if indexOfDestinationBeingPlanned >= placeToStayDictionaryArray.count {
                placeToStayDictionaryArray.append(["typeOfPlaceToStay":"hotel"])
            } else if indexOfDestinationBeingPlanned < placeToStayDictionaryArray.count {
                if placeToStayDictionaryArray[indexOfDestinationBeingPlanned]["typeOfPlaceToStay"] as! String != "hotel" {

                    if yesIKnowWhereImStayingQuestionView != nil {
                        yesIKnowWhereImStayingQuestionView?.removeFromSuperview()
                        yesIKnowWhereImStayingQuestionView = nil
                    }
                    if doYouNeedHelpBookingAHotelQuestionView != nil {
                        doYouNeedHelpBookingAHotelQuestionView?.removeFromSuperview()
                        doYouNeedHelpBookingAHotelQuestionView = nil
                    }
                    if shortTermRentalSearchQuestionView != nil {
                        shortTermRentalSearchQuestionView?.removeFromSuperview()
                        shortTermRentalSearchQuestionView = nil
                    }
                    if stayWithSomeoneIKnowQuestionView != nil {
                        stayWithSomeoneIKnowQuestionView?.removeFromSuperview()
                        stayWithSomeoneIKnowQuestionView = nil
                    }
                    if placeForGroupOrJustYouQuestionView != nil {
                        placeForGroupOrJustYouQuestionView?.removeFromSuperview()
                        placeForGroupOrJustYouQuestionView = nil
                    }
                    
                    placeToStayDictionaryArray[indexOfDestinationBeingPlanned] = ["typeOfPlaceToStay":"hotel"]
                }
            }
            SavedPreferencesForTrip["placeToStayDictionaryArray"] = placeToStayDictionaryArray
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            spawnHotelSearchQuestionView()
        }
    }
    func whatTypeOfPlaceToStayQuestionView_shortTermRental(sender:UIButton) {
        if sender.isSelected == true {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var placeToStayDictionaryArray = SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]]
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            if indexOfDestinationBeingPlanned >= placeToStayDictionaryArray.count {
                placeToStayDictionaryArray.append(["typeOfPlaceToStay":"shortTermRental"])
            } else if indexOfDestinationBeingPlanned < placeToStayDictionaryArray.count {
                if placeToStayDictionaryArray[indexOfDestinationBeingPlanned]["typeOfPlaceToStay"] as! String != "shortTermRental" {
                    if yesIKnowWhereImStayingQuestionView != nil {
                        yesIKnowWhereImStayingQuestionView?.removeFromSuperview()
                        yesIKnowWhereImStayingQuestionView = nil
                    }
                    if doYouNeedHelpBookingAHotelQuestionView != nil {
                        doYouNeedHelpBookingAHotelQuestionView?.removeFromSuperview()
                        doYouNeedHelpBookingAHotelQuestionView = nil
                    }
                    if hotelSearchQuestionView != nil {
                        hotelSearchQuestionView?.removeFromSuperview()
                        hotelSearchQuestionView = nil
                    }
                    if stayWithSomeoneIKnowQuestionView != nil {
                        stayWithSomeoneIKnowQuestionView?.removeFromSuperview()
                        stayWithSomeoneIKnowQuestionView = nil
                    }
                    if placeForGroupOrJustYouQuestionView != nil {
                        placeForGroupOrJustYouQuestionView?.removeFromSuperview()
                        placeForGroupOrJustYouQuestionView = nil
                    }
                    
                    placeToStayDictionaryArray[indexOfDestinationBeingPlanned] = ["typeOfPlaceToStay":"shortTermRental"]
                }
            }
            SavedPreferencesForTrip["placeToStayDictionaryArray"] = placeToStayDictionaryArray
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)

            spawnShortTermRentalSearchQuestionView()
        }
    }
//    func whatTypeOfPlaceToStayQuestionView_stayWithSomeoneIKnow(sender:UIButton) {
//        if sender.isSelected == true {
//            if yesIKnowWhereImStayingQuestionView != nil {
//                yesIKnowWhereImStayingQuestionView?.removeFromSuperview()
//                yesIKnowWhereImStayingQuestionView = nil
//            }
//            if doYouNeedHelpBookingAHotelQuestionView != nil {
//                doYouNeedHelpBookingAHotelQuestionView?.removeFromSuperview()
//                doYouNeedHelpBookingAHotelQuestionView = nil
//            }
//            if hotelSearchQuestionView != nil {
//                hotelSearchQuestionView?.removeFromSuperview()
//                hotelSearchQuestionView = nil
//            }
//            if shortTermRentalSearchQuestionView != nil {
//                shortTermRentalSearchQuestionView?.removeFromSuperview()
//                shortTermRentalSearchQuestionView = nil
//            }
//            if placeForGroupOrJustYouQuestionView != nil {
//                placeForGroupOrJustYouQuestionView?.removeFromSuperview()
//                placeForGroupOrJustYouQuestionView = nil
//            }
//
//            spawnStayWithSomeoneIKnowQuestionView()
//        }
//    }
    
    func hotelSearchQuestionView_searchButtonTouchedUpInside(sender:UIButton) {
        if sender.isSelected == true {
            spawnHotelResultsQuestionView()
        }
    }
    func shortTermRentalSearchQuestionView_done(sender:UIButton) {
        if sender.isSelected == true {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var placeToStayDictionaryArray = SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]]
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            placeToStayDictionaryArray[indexOfDestinationBeingPlanned]["shortTermRentalText"] = shortTermRentalSearchQuestionView?.textView?.text
            SavedPreferencesForTrip["placeToStayDictionaryArray"] = placeToStayDictionaryArray
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            spawnPlaceForGroupOrJustYouQuestionView()
        }
    }
    func shortTermRentalSearchQuestionView_addLater(sender:UIButton) {
        if sender.isSelected == true {
            spawnPlaceForGroupOrJustYouQuestionView()
        }
    }
    func stayWithSomeoneIKnowQuestionView_done(sender:UIButton) {
        if sender.isSelected == true {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var placeToStayDictionaryArray = SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]]
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            placeToStayDictionaryArray[indexOfDestinationBeingPlanned]["stayWithSomeoneIKnowText"] = stayWithSomeoneIKnowQuestionView?.textView?.text
            SavedPreferencesForTrip["placeToStayDictionaryArray"] = placeToStayDictionaryArray
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            spawnPlaceForGroupOrJustYouQuestionView()
        }
    }
    func stayWithSomeoneIKnowQuestionView_addLater(sender:UIButton) {
        if sender.isSelected == true {
            spawnPlaceForGroupOrJustYouQuestionView()
        }
    }
    func placeForGroupOrJustYouQuestionView_entireGroup(sender:UIButton) {
        if sender.isSelected == true {
            planTravelAndPlaceToStayForAnotherDestinationOrSendProposalQuestionView()
        }
    }
    func placeForGroupOrJustYouQuestionView_someOfGroup(sender:UIButton) {
        if sender.isSelected == true {
            planTravelAndPlaceToStayForAnotherDestinationOrSendProposalQuestionView()
        }
    }
    func placeForGroupOrJustYouQuestionView_justMe(sender:UIButton) {
        if sender.isSelected == true {
            planTravelAndPlaceToStayForAnotherDestinationOrSendProposalQuestionView()
        }
    }
    func placeForGroupOrJustYouQuestionView_entireGroup_backToItinerary(sender:UIButton) {
        if sender.isSelected == true {
            disableAndResetAssistant_moveToItinerary()
        }
    }
    func placeForGroupOrJustYouQuestionView_someOfGroup_backToItinerary(sender:UIButton) {
        if sender.isSelected == true {
            disableAndResetAssistant_moveToItinerary()
        }
    }
    func placeForGroupOrJustYouQuestionView_justMe_backToItinerary(sender:UIButton) {
        if sender.isSelected == true {
            disableAndResetAssistant_moveToItinerary()
        }
    }
    func yesIKnowWhereImStayingQuestionView_hotel(sender:UIButton) {
        if sender.isSelected == true {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var placeToStayDictionaryArray = SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]]
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            if indexOfDestinationBeingPlanned >= placeToStayDictionaryArray.count {
                placeToStayDictionaryArray.append(["typeOfPlaceToStay":"hotel"])
            } else if indexOfDestinationBeingPlanned < placeToStayDictionaryArray.count {
                if placeToStayDictionaryArray[indexOfDestinationBeingPlanned]["typeOfPlaceToStay"] as! String != "hotel" {

                    if hotelSearchQuestionView != nil {
                        hotelSearchQuestionView?.removeFromSuperview()
                        hotelSearchQuestionView = nil
                    }
                    if stayWithSomeoneIKnowQuestionView != nil {
                        stayWithSomeoneIKnowQuestionView?.removeFromSuperview()
                        stayWithSomeoneIKnowQuestionView = nil
                    }
                    if placeForGroupOrJustYouQuestionView != nil {
                        placeForGroupOrJustYouQuestionView?.removeFromSuperview()
                        placeForGroupOrJustYouQuestionView = nil
                    }
                    if whatTypeOfPlaceToStayQuestionView != nil {
                        whatTypeOfPlaceToStayQuestionView?.removeFromSuperview()
                        whatTypeOfPlaceToStayQuestionView = nil
                    }
                    if shortTermRentalSearchQuestionView != nil {
                        shortTermRentalSearchQuestionView?.removeFromSuperview()
                        shortTermRentalSearchQuestionView = nil
                    }
                    placeToStayDictionaryArray[indexOfDestinationBeingPlanned] = ["typeOfPlaceToStay":"hotel"]
                }
            }
            SavedPreferencesForTrip["placeToStayDictionaryArray"] = placeToStayDictionaryArray
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            spawnDoYouNeedHelpBookingAHotelQuestionView()
        }
    }
    func yesIKnowWhereImStayingQuestionView_shortTermRental(sender:UIButton) {
        if sender.isSelected == true {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var placeToStayDictionaryArray = SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]]
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            if indexOfDestinationBeingPlanned >= placeToStayDictionaryArray.count {
                placeToStayDictionaryArray.append(["typeOfPlaceToStay":"shortTermRental"])
            } else if indexOfDestinationBeingPlanned < placeToStayDictionaryArray.count {
                if placeToStayDictionaryArray[indexOfDestinationBeingPlanned]["typeOfPlaceToStay"] as! String != "shortTermRental" {

                    if doYouNeedHelpBookingAHotelQuestionView != nil {
                        doYouNeedHelpBookingAHotelQuestionView?.removeFromSuperview()
                        doYouNeedHelpBookingAHotelQuestionView = nil
                    }
                    if hotelSearchQuestionView != nil {
                        hotelSearchQuestionView?.removeFromSuperview()
                        hotelSearchQuestionView = nil
                    }
                    if stayWithSomeoneIKnowQuestionView != nil {
                        stayWithSomeoneIKnowQuestionView?.removeFromSuperview()
                        stayWithSomeoneIKnowQuestionView = nil
                    }
                    if placeForGroupOrJustYouQuestionView != nil {
                        placeForGroupOrJustYouQuestionView?.removeFromSuperview()
                        placeForGroupOrJustYouQuestionView = nil
                    }
                    if whatTypeOfPlaceToStayQuestionView != nil {
                        whatTypeOfPlaceToStayQuestionView?.removeFromSuperview()
                        whatTypeOfPlaceToStayQuestionView = nil
                    }
                    if shortTermRentalSearchQuestionView != nil {
                        shortTermRentalSearchQuestionView?.removeFromSuperview()
                        shortTermRentalSearchQuestionView = nil
                    }
                    
                    placeToStayDictionaryArray[indexOfDestinationBeingPlanned] = ["typeOfPlaceToStay":"shortTermRental"]
                }
            }
            SavedPreferencesForTrip["placeToStayDictionaryArray"] = placeToStayDictionaryArray
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                    
            spawnShortTermRentalSearchQuestionView()
        }
    }
    func yesIKnowWhereImStayingQuestionView_stayWithSomeoneIKnow(sender:UIButton) {
        if sender.isSelected == true {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var placeToStayDictionaryArray = SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]]
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            if indexOfDestinationBeingPlanned >= placeToStayDictionaryArray.count {
                placeToStayDictionaryArray.append(["typeOfPlaceToStay":"stayWithSomeoneIKnow"])
            } else if indexOfDestinationBeingPlanned < placeToStayDictionaryArray.count {
                if placeToStayDictionaryArray[indexOfDestinationBeingPlanned]["typeOfPlaceToStay"] as! String != "stayWithSomeoneIKnow" {
                    
                    if doYouNeedHelpBookingAHotelQuestionView != nil {
                        doYouNeedHelpBookingAHotelQuestionView?.removeFromSuperview()
                        doYouNeedHelpBookingAHotelQuestionView = nil
                    }
                    if hotelSearchQuestionView != nil {
                        hotelSearchQuestionView?.removeFromSuperview()
                        hotelSearchQuestionView = nil
                    }
                    if stayWithSomeoneIKnowQuestionView != nil {
                        stayWithSomeoneIKnowQuestionView?.removeFromSuperview()
                        stayWithSomeoneIKnowQuestionView = nil
                    }
                    if placeForGroupOrJustYouQuestionView != nil {
                        placeForGroupOrJustYouQuestionView?.removeFromSuperview()
                        placeForGroupOrJustYouQuestionView = nil
                    }
                    if whatTypeOfPlaceToStayQuestionView != nil {
                        whatTypeOfPlaceToStayQuestionView?.removeFromSuperview()
                        whatTypeOfPlaceToStayQuestionView = nil
                    }
                    if shortTermRentalSearchQuestionView != nil {
                        shortTermRentalSearchQuestionView?.removeFromSuperview()
                        shortTermRentalSearchQuestionView = nil
                    }
                    
                    placeToStayDictionaryArray[indexOfDestinationBeingPlanned] = ["typeOfPlaceToStay":"stayWithSomeoneIKnow"]
                }
            }
            SavedPreferencesForTrip["placeToStayDictionaryArray"] = placeToStayDictionaryArray
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)

            spawnStayWithSomeoneIKnowQuestionView()
        }
    }

    func doYouNeedHelpBookingAHotelQuestionView_Yes(sender:UIButton) {
        if sender.isSelected == true {
            spawnHotelSearchQuestionView()
        }
    }
    
    func doYouNeedHelpBookingAHotelQuestionView_Done(sender:UIButton) {
        if sender.isSelected == true {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var placeToStayDictionaryArray = SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]]
            let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
            if indexOfDestinationBeingPlanned >= placeToStayDictionaryArray.count {
                placeToStayDictionaryArray.append(["typeOfPlaceToStay":"hotelText"])
            } else if indexOfDestinationBeingPlanned < placeToStayDictionaryArray.count {
                if placeToStayDictionaryArray[indexOfDestinationBeingPlanned]["typeOfPlaceToStay"] as! String != "hotelText" {
                    placeToStayDictionaryArray[indexOfDestinationBeingPlanned] = ["typeOfPlaceToStay":"hotelText"]
                }
            }
            placeToStayDictionaryArray[indexOfDestinationBeingPlanned]["hotelText"] = doYouNeedHelpBookingAHotelQuestionView?.textView?.text
            SavedPreferencesForTrip["placeToStayDictionaryArray"] = placeToStayDictionaryArray
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)

            
            
            spawnPlaceForGroupOrJustYouQuestionView()
        }        
    }
    func doYouNeedHelpBookingAHotelQuestionView_illAddLater(sender:UIButton) {
        if sender.isSelected == true {
            spawnPlaceForGroupOrJustYouQuestionView()
        }
    }
    func parseDatesForMultipleDestinationsCalendarView_changeDates(sender:UIButton) {
        if sender.isSelected == true {
            scrollToSubviewWithTag(tag: 1)
            datesPickedOutCalendarView?.button1?.isHidden = false
            datesPickedOutCalendarView?.button2?.isHidden = true
        }
    }
    func datesPickedOutCalendarView_backToTravelDates(sender:UIButton) {
        if sender.isSelected == true {
            scrollToSubviewWithTag(tag: 32)
            parseDatesForMultipleDestinationsCalendarView?.button1?.buttonClicked(sender: (parseDatesForMultipleDestinationsCalendarView?.button1)!)
            parseDatesForMultipleDestinationsCalendarView?.loadDates()
        }
    }
    func comeBackToPlanHotelLater() {
        scrollView.isScrollEnabled = true
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if SavedPreferencesForTrip["assistantMode"] as! String == "placeToStay" {
            disableAndResetAssistant_moveToItinerary()
        } else {
            planTravelAndPlaceToStayForAnotherDestinationOrSendProposalQuestionView()
        }
    }
    func comeBackToPlanFlightLater() {
        scrollView.isScrollEnabled = true
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if SavedPreferencesForTrip["assistantMode"] as! String == "travel" {
            disableAndResetAssistant_moveToItinerary()
        } else {
            planPlaceToStayOrReviewItinerary()
        }
    }
    func tripCalendarRangeSelected_backToItinerary() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var numberDestinations = 0
        numberDestinations = (SavedPreferencesForTrip["destinationsForTrip"] as! [String]).count
        if numberDestinations > 1 {
            spawnParseDatesForMultipleDestinationsCalendarView()
        } else {
            disableAndResetAssistant_moveToItinerary()
        }
    }
    func destinationNotDecidedDestinationChosen() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if SavedPreferencesForTrip["assistantMode"] as! String == "destination" {
            self.disableAndResetAssistant_moveToItinerary()
        } else if SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding" {
            self.spawnAddAnotherDestinationQuestionView()
        }
    }
    func destinationDecidedDestinationChosen() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if SavedPreferencesForTrip["assistantMode"] as! String == "destination" {
            self.destinationChosenUpdateDatesDestinationsDict()
            self.disableAndResetAssistant_moveToItinerary()
        } else if SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding" {
            self.spawnAddAnotherDestinationQuestionView()
        }
    }
    func whereTravellingFromQuestionView_backToItinerary() {
        disableAndResetAssistant_moveToItinerary()
    }
    func whereTravellingFromEntered() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding" {
            spawnYesCityDecidedQuestionView()
        } else if SavedPreferencesForTrip["assistantMode"] as! String == "startingPoint" || SavedPreferencesForTrip["assistantMode"] as! String == "endingPoint"{
            disableAndResetAssistant_moveToItinerary()
        }
    }
    
    
    
    // MARK: iterative travel and accomodation planning function
    func planTravelAndPlaceToStayForAnotherDestinationOrSendProposalQuestionView() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        let destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
        if indexOfDestinationBeingPlanned < destinationsForTrip.count - 1 {
            //increment destination being planned
            indexOfDestinationBeingPlanned += 1
            SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = indexOfDestinationBeingPlanned
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            moveHowDoYouWantToGetThereQuestionViewAndScrollDown()
        } else if indexOfDestinationBeingPlanned == destinationsForTrip.count - 1 {
            var didPlanRoundTripTravel = false
            //PLANNED update didPlanRoundTripTravel bool based on travel dictionary "roundtrip" tag
            for i in 0 ... destinationsForTrip.count - 1 {
                var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
                if travelDictionaryArray[i]["modeOfTransportation"] as! String == "illAlreadyBeThere" {
                    didPlanRoundTripTravel = true
                } else if travelDictionaryArray[i]["modeOfTransportation"] as! String == "fly" {
                    if travelDictionaryArray[i]["isRoundtrip"] as! Bool != nil {
                        if travelDictionaryArray[i]["isRoundtrip"] as! Bool == true {
                            didPlanRoundTripTravel = true
                        }
                    }
                } else if travelDictionaryArray[i]["modeOfTransportation"] as! String == "drive" {
                    if travelDictionaryArray[i]["isRoundtrip"] as! Bool != nil {
                        if travelDictionaryArray[i]["isRoundtrip"] as! Bool == true {
                            didPlanRoundTripTravel = true
                        }
                    }
                }
            }
            
            if didPlanRoundTripTravel {
                initialItineraryBuildingCompleteReviewItinerary()
                
            } else {
                //increment destination being planned
                indexOfDestinationBeingPlanned += 1
                SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = indexOfDestinationBeingPlanned
                saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                
                moveHowDoYouWantToGetThereQuestionViewAndScrollDown()
                
            }
        } else {
            //spawnSendProposalQuestionView()
            initialItineraryBuildingCompleteReviewItinerary()
        }
    }
    func moveHowDoYouWantToGetThereQuestionViewAndScrollDown(){        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        let destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
        let bounds = UIScreen.main.bounds
        if howDoYouWantToGetThereQuestionView != nil {
            self.howDoYouWantToGetThereQuestionView!.frame = CGRect(x: 0, y: self.scrollContentView.subviews[self.scrollContentView.subviews.count - 1].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            if indexOfDestinationBeingPlanned == destinationsForTrip.count {
                self.howDoYouWantToGetThereQuestionView?.questionLabel?.text = "How do you want to get back?"
                self.howDoYouWantToGetThereQuestionView?.button6?.isHidden = false
            } else {
                self.howDoYouWantToGetThereQuestionView?.questionLabel?.text = "How do you want to get to\n\(destinationsForTrip[indexOfDestinationBeingPlanned])?"
            }            
            self.scrollContentView.bringSubview(toFront: howDoYouWantToGetThereQuestionView!)
            updateProgress()
            scrollToSubviewWithTag(tag: 10)
            
        }
        
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.alignSubviews()
            self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollContentView.subviews[self.scrollContentView.subviews.count - 1].frame.minY), animated: false)
        }
        
        let when2 = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when2) {
            
            //Remove travel and place to stay subviews
            if self.flightSearchQuestionView != nil {
                self.flightSearchQuestionView?.removeFromSuperview()
                self.flightSearchQuestionView = nil
                if self.doYouNeedARentalCarQuestionView != nil {
                    self.doYouNeedARentalCarQuestionView?.removeFromSuperview()
                    self.doYouNeedARentalCarQuestionView = nil
                    if self.carRentalSearchQuestionView != nil {
                        self.carRentalSearchQuestionView?.removeFromSuperview()
                        self.carRentalSearchQuestionView = nil
                    }
                }
            }
            if self.doYouNeedARentalCarQuestionView != nil {
                self.doYouNeedARentalCarQuestionView?.removeFromSuperview()
                self.doYouNeedARentalCarQuestionView = nil
                if self.carRentalSearchQuestionView != nil {
                    self.carRentalSearchQuestionView?.removeFromSuperview()
                    self.carRentalSearchQuestionView = nil
                }
                if self.aboutWhatTimeWillYouStartDrivingQuestionView != nil {
                    self.aboutWhatTimeWillYouStartDrivingQuestionView?.removeFromSuperview()
                    self.aboutWhatTimeWillYouStartDrivingQuestionView = nil
                }
            }
            if self.busTrainOtherQuestionView != nil {
                self.busTrainOtherQuestionView?.removeFromSuperview()
                self.busTrainOtherQuestionView = nil
            }
            if self.idkHowToGetThereQuestionView != nil {
                self.idkHowToGetThereQuestionView?.removeFromSuperview()
                self.idkHowToGetThereQuestionView = nil
            }
            if self.doYouKnowWhereYouWillBeStayingQuestionView != nil {
                self.doYouKnowWhereYouWillBeStayingQuestionView?.removeFromSuperview()
                self.doYouKnowWhereYouWillBeStayingQuestionView = nil
                
                if self.yesIKnowWhereImStayingQuestionView != nil {
                    self.yesIKnowWhereImStayingQuestionView?.removeFromSuperview()
                    self.yesIKnowWhereImStayingQuestionView = nil
                }
                if self.doYouNeedHelpBookingAHotelQuestionView != nil {
                    self.doYouNeedHelpBookingAHotelQuestionView?.removeFromSuperview()
                    self.doYouNeedHelpBookingAHotelQuestionView = nil
                }
                if self.whatTypeOfPlaceToStayQuestionView != nil {
                    self.whatTypeOfPlaceToStayQuestionView?.removeFromSuperview()
                    self.whatTypeOfPlaceToStayQuestionView = nil
                    if self.hotelSearchQuestionView != nil {
                        self.hotelSearchQuestionView?.removeFromSuperview()
                        self.hotelSearchQuestionView = nil
                    }
                    if self.shortTermRentalSearchQuestionView != nil {
                        self.shortTermRentalSearchQuestionView?.removeFromSuperview()
                        self.shortTermRentalSearchQuestionView = nil
                    }
                    if self.stayWithSomeoneIKnowQuestionView != nil {
                        self.stayWithSomeoneIKnowQuestionView?.removeFromSuperview()
                        self.stayWithSomeoneIKnowQuestionView = nil
                    }
                    if self.placeForGroupOrJustYouQuestionView != nil {
                        self.placeForGroupOrJustYouQuestionView?.removeFromSuperview()
                        self.placeForGroupOrJustYouQuestionView = nil
                    }
                }
            }
            
            self.alignSubviews()
            self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollContentView.subviews[self.scrollContentView.subviews.count - 1].frame.minY), animated: false)
        }
    }
    
    func planPlaceToStayOrReviewItinerary() {
        var isFinalDestinationTravelBeingPlanned = false
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        let destinationsForTrip = SavedPreferencesForTrip["destinationsForTrip"] as! [String]
        
        if indexOfDestinationBeingPlanned == destinationsForTrip.count {
            isFinalDestinationTravelBeingPlanned = true
        }
        
        if isFinalDestinationTravelBeingPlanned {
            initialItineraryBuildingCompleteReviewItinerary()
        } else {
            self.spawnDoYouKnowWhereYouWillBeStayingQuestionView()
        }
    }
    
    func initialItineraryBuildingCompleteReviewItinerary() {
        
        let alert = UIAlertController(title: "Great work!",
                                      message: "Time to review your itinerary\nand invite some friends.",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Let's go", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.disableAndResetAssistant_moveToItinerary()
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    //MARK: UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            if detailedInformationSubviewMode == "stayWithSomeoneIKnow" {
                let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                var placeToStayDictionaryArray = SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]]
                let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
                placeToStayDictionaryArray[indexOfDestinationBeingPlanned]["stayWithSomeoneIKnowText"] = textView.text
                SavedPreferencesForTrip["placeToStayDictionaryArray"] = placeToStayDictionaryArray
                saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            } else if detailedInformationSubviewMode == "shortTermRental" {
                let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                var placeToStayDictionaryArray = SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]]
                let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
                placeToStayDictionaryArray[indexOfDestinationBeingPlanned]["shortTermRentalText"] = textView.text
                SavedPreferencesForTrip["placeToStayDictionaryArray"] = placeToStayDictionaryArray
                saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                
            } else if detailedInformationSubviewMode == "hotel" {
                let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                var placeToStayDictionaryArray = SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]]
                let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
                placeToStayDictionaryArray[indexOfDestinationBeingPlanned]["hotelText"] = textView.text
                SavedPreferencesForTrip["placeToStayDictionaryArray"] = placeToStayDictionaryArray
                saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)

            } else if detailedInformationSubviewMode == "busTrainOther" {
                let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
                let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
                travelDictionaryArray[indexOfDestinationBeingPlanned]["busTrainOtherText"] = textView.text
                SavedPreferencesForTrip["placeToStayDictionaryArray"] = travelDictionaryArray
                saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                
            } else if detailedInformationSubviewMode == "illAlreadyBeThere" {
                let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
                let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
                travelDictionaryArray[indexOfDestinationBeingPlanned]["illAlreadyBeThereText"] = textView.text
                SavedPreferencesForTrip["placeToStayDictionaryArray"] = travelDictionaryArray
                saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                
            }
            return false
        }
        
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        var topCorrect: CGFloat? = textView.bounds.size.height - textView.contentSize.height
        topCorrect = (topCorrect! < CGFloat(0.0) ? 0.0 : topCorrect)
        textView.contentOffset = CGPoint()
        textView.contentOffset.x = 0
        textView.contentOffset.y = -topCorrect!
    }

    // MARK: UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == tripNameQuestionView?.tripNameQuestionTextfield {
            tripNameQuestionView?.tripNameQuestionButton?.setTitle("Done", for: .normal)
        }
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        
        if textField == userNameQuestionView?.userNameQuestionTextfield {
            if userNameQuestionView?.userNameQuestionTextfield?.text == nil || userNameQuestionView?.userNameQuestionTextfield?.text == "" {
                return false
            } else {
                DataContainerSingleton.sharedDataContainer.firstName = textField.text
                spawnInstructionsQuestionView()
            }
        }
        
        if textField == tripNameQuestionView?.tripNameQuestionTextfield {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["trip_name"] = textField.text
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            return true
        }
        //Itinerary view
        if textField == tripNameTextField {
            tripNameTextField.resignFirstResponder()
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["trip_name"] = tripNameTextField.text
            //Save
            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func handleContactsChanged() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if (SavedPreferencesForTrip["contacts_in_group"] as? [NSString])?.count == 0 {
            itineraryButton.titleLabel?.textColor = UIColor.gray
            itineraryButton.isEnabled = false
            chatButton.titleLabel?.textColor = UIColor.gray
            chatButton.isEnabled = false
        } else {
            itineraryButton.titleLabel?.textColor = UIColor.white
            itineraryButton.isEnabled = true
            chatButton.titleLabel?.textColor = UIColor.white
            chatButton.isEnabled = true
        }
    }

    //MARK: Scrollview delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isHidden == false {
            handleScrollUpAndDownButtons()
//            UIView.animate(withDuration: 0.3) {
//                self.scrollUpButton.alpha = 1
//                self.scrollDownButton.alpha = 1
//            }
        }
        animateOutSubview()
        getCurrentSubview()
//        handleFloatyBasedOnProgressOfInitiator()
        if parseDatesForMultipleDestinationsCalendarView != nil {
            if (parseDatesForMultipleDestinationsCalendarView?.frame.intersects(scrollView.bounds))! {
                parseDatesForMultipleDestinationsCalendarView?.loadDates()
            }
        }
    }
//    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
//        
//        return true
//    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        UIView.animate(withDuration: 1) {
//            self.scrollUpButton.alpha = 0
//            self.scrollDownButton.alpha = 0
//        }

    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)

        //        UIView.animate(withDuration: 0.3) {
//            self.scrollUpButton.alpha = 1
//            self.scrollDownButton.alpha = 1
//        }
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
        var destinationsForTripStates = [NSString]()
        var travelDictionaryArray = [NSDictionary]()
        var placeToStayDictionaryArray = [NSDictionary]()
        var indexOfDestinationBeingPlanned = NSNumber(value: 0)
        var isInitiator = NSNumber(value: 1)
        var currentAssistantSubview = NSNumber(value: 0)
        var datesDestinationsDictionary = NSDictionary()
        var savedFlightTickets = [NSData]()
        var savedHotelItems = [NSData]()
        var lastFlightOpenInBrowser = NSDictionary()
        var lastHotelOpenInBrowser = NSDictionary()
        var assistantMode = NSString()
        var endingPoint = NSString()
        var destinationsForTripDictArray = [NSDictionary]()
        var endingPointDict = NSDictionary()
        var startingPointDict = NSDictionary()
        var JRSDKSearchInfo = NSData()
        var HDKSearchInfo = NSData()
        
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
            destinationsForTripStates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "destinationsForTripStates") as? [NSString] ?? [NSString]()
            travelDictionaryArray = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "travelDictionaryArray") as? [NSDictionary] ?? [NSDictionary]()
            placeToStayDictionaryArray = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "placeToStayDictionaryArray") as? [NSDictionary] ?? [NSDictionary]()
            indexOfDestinationBeingPlanned = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "indexOfDestinationBeingPlanned") as? NSNumber ?? NSNumber()
            isInitiator = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "isInitiator") as? NSNumber ?? NSNumber()
            currentAssistantSubview = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "currentAssistantSubview") as? NSNumber ?? NSNumber()
            datesDestinationsDictionary = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "datesDestinationsDictionary") as? NSDictionary ?? NSDictionary()
            savedFlightTickets = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "savedFlightTickets") as? [NSData] ?? [NSData]()
            savedHotelItems = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "savedHotelItems") as? [NSData] ?? [NSData]()
            lastFlightOpenInBrowser = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "lastFlightOpenInBrowser") as? NSDictionary ?? NSDictionary()
            lastHotelOpenInBrowser = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "lastHotelOpenInBrowser") as? NSDictionary ?? NSDictionary()
            assistantMode = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "assistantMode") as? NSString ?? NSString()
            endingPoint = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "endingPoint") as? NSString ?? NSString()
            destinationsForTripDictArray = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "destinationsForTripDictArray") as? [NSDictionary] ?? [NSDictionary]()
            endingPointDict = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "endingPointDict") as? NSDictionary ?? NSDictionary()
            startingPointDict = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "startingPointDict") as? NSDictionary ?? NSDictionary()
            JRSDKSearchInfo = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "JRSDKSearchInfo") as? NSData ?? NSData()
            HDKSearchInfo = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "HDKSearchInfo") as? NSData ?? NSData()

            //Activities VC
            selectedActivities = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_activities") as? [NSString] ?? [NSString]()
            //Ranking VC
            topTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "top_trips") as? [NSString] ?? [NSString]()
            rankedPotentialTripsDictionary = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionary") as? [NSDictionary] ?? [NSDictionary]()
            rankedPotentialTripsDictionaryArrayIndex = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionaryArrayIndex") as? NSNumber ?? NSNumber()
            
        }
        
        //SavedPreferences
        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus,"progress": progress, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips,"numberDestinations":numberDestinations,"nonSpecificDates":nonSpecificDates, "rankedPotentialTripsDictionary": rankedPotentialTripsDictionary, "tripID": tripID,"lastVC": lastVC,"firebaseChannelKey": firebaseChannelKey,"rankedPotentialTripsDictionaryArrayIndex": rankedPotentialTripsDictionaryArrayIndex, "timesViewed": timesViewed, "destinationsForTrip": destinationsForTrip,"travelDictionaryArray":travelDictionaryArray, "indexOfDestinationBeingPlanned": indexOfDestinationBeingPlanned,"isInitiator":isInitiator,"currentAssistantSubview":currentAssistantSubview,"datesDestinationsDictionary":datesDestinationsDictionary,"destinationsForTripStates":destinationsForTripStates,"savedFlightTickets":savedFlightTickets,"savedHotelItems":savedHotelItems,"lastFlightOpenInBrowser":lastFlightOpenInBrowser,"lastHotelOpenInBrowser":lastHotelOpenInBrowser,"assistantMode":assistantMode, "placeToStayDictionaryArray":placeToStayDictionaryArray,"endingPoint":endingPoint,"destinationsForTripDictArray":destinationsForTripDictArray,"startingPointDict":startingPointDict,"endingPointDict":endingPointDict,"JRSDKSearchInfo":JRSDKSearchInfo,"HDKSearchInfo":HDKSearchInfo] as NSMutableDictionary
        
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
        chatController = self.storyboard!.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        chatController?.willMove(toParentViewController: self)
        self.addChildViewController(chatController!)
        chatController?.loadView()
        chatController?.viewDidLoad()
        chatController?.view.frame = self.view.bounds
        self.chatView.addSubview((chatController?.view)!)
        constrain((chatController?.view)!, chatView) { view1, view2 in
            view1.left == view2.left
            view1.top == view2.top
            view1.width == view2.width
            view1.height == view2.height
        }
        chatController?.didMove(toParentViewController: self)
        chatView.isHidden = true
    }
    func assistantViewIsHiddenTrue() {
        scrollView.isHidden = true
        scrollUpButton.isHidden = true
        scrollDownButton.isHidden = true
//        floaty?.isHidden = true
        progressRing?.isHidden = true
        filterButton.isHidden = true
        sortButton.isHidden = true
    }
    func assistantViewIsHiddenFalse() {
        scrollView.isHidden = false
        scrollUpButton.isHidden = false
        scrollDownButton.isHidden = false
//        floaty?.isHidden = false
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding" {
            progressRing?.isHidden = false
        } else {
            progressRing?.isHidden = true
        }
    }
    func assistant() {
//        UIView.animate(withDuration: 0.4) {
//            self.underline.layer.frame = CGRect(x: 36, y: 25, width: 90, height: 51)
//        }
        assistantViewIsHiddenFalse()
        itineraryView.isHidden = true
        infoButton.isHidden = true
        chatView.isHidden = true
        self.view.endEditing(true)
    }
    func itinerary() {
//        UIView.animate(withDuration: 0.4) {
//            self.underline.layer.frame = CGRect(x: 163, y: 25, width: 85, height: 51)
//        }
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var tripName = SavedPreferencesForTrip["trip_name"] as! String
        tripNameTextField.text = tripName
        destinationChosenUpdateDatesDestinationsDict()
        assistantViewIsHiddenTrue()
        itineraryView.isHidden = false
        infoButton.isHidden = false
        retrieveContactsWithStore(store: addressBookStore)
        contactsCollectionView.reloadData()
        handleAddInviteesButton()
        editItineraryModeEnabled = false
        editSwitch.isOn = false
        for visibleCell in (self.destinationsDatesCollectionView!.visibleCells as! [destinationsDatesCollectionViewCell]) {
            visibleCell.stopShakingIcons()
        }
        destinationsDatesCollectionView.reloadData()
        handleSendInvitesButton()
        chatView.isHidden = true
        if isAssistantEnabled {
            segmentedControl?.move(to: 1)
        } else {
            segmentedControl?.move(to: 0)
        }
        self.view.endEditing(true)
        
        
        timesViewed = (SavedPreferencesForTrip["timesViewed"] as? [String : Int])!
        
        if timesViewed["itinerary"] == nil {
            let when = DispatchTime.now() + 0.3
            //PLANNED: SMcalloutView
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.handleItineraryTutorial()
                
//                self.popupBackgroundFilterView.alpha = 0
//                let bounds = UIScreen.main.bounds
//                self.popupBackgroundFilterView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
//                self.popupBackgroundFilterView.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
//                
//                self.animateInBackgroundFilterView(withInfoView: true, withBlurEffect: true, withCloseButton: true)
                self.timesViewed["itinerary"] = 1
                SavedPreferencesForTrip["timesViewed"] = self.timesViewed as NSDictionary
                self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
//
//                UIView.animate(withDuration: 0.5) {
//                    self.popupBackgroundFilterView.alpha = 1
//                    self.popupBackgroundFilterView.transform = CGAffineTransform.identity
//                }
            }
        }

    }
    func handleAddInviteesButton(){
        let bounds = UIScreen.main.bounds
        var numberOfContacts = 0
        if contacts != nil {
            numberOfContacts += contacts!.count
        }
        addInviteeButton.setTitleColor(UIColor.white, for: .normal)
        addInviteeButton.setBackgroundColor(color: UIColor.clear, forState: .normal)
//        addInviteeButton.layer.masksToBounds = false
        addInviteeButton.titleLabel?.numberOfLines = 0
        addInviteeButton.titleLabel?.textAlignment = .center
//        addInviteeButton.translatesAutoresizingMaskIntoConstraints = false
        
        if numberOfContacts == 0 {
            contactsCollectionView.isHidden = true
            addInviteeButton.setTitle("Invite travelmates", for: .normal)
            addInviteeButton.titleLabel?.font = UIFont.italicSystemFont(ofSize: 22)
            addInviteeButton.frame.size.height = 30
            addInviteeButton.frame.size.width = 200
            addInviteeButton.frame.origin.x = (bounds.size.width - (addInviteeButton.frame.width)) / 2
            addInviteeButton.frame.origin.y = 70
            addInviteeButton.setTitleColor(completeColor, for: .normal)
            addInviteeButton.layer.borderWidth = 2
            addInviteeButton.layer.borderColor = UIColor.white.cgColor
            addInviteeButton.layer.cornerRadius = (addInviteeButton.frame.height) / 2
            addInviteeButton_badge.layer.frame.origin = CGPoint(x: addInviteeButton.layer.frame.maxX - 54, y: addInviteeButton.layer.frame.minY + 1)
            addInviteeButton_badge.badgeString = "!"
            addInviteeButton_badge.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            addInviteeButton_badge.badgeTextColor = UIColor.white
            addInviteeButton_badge.badgeBackgroundColor = UIColor.red
            addInviteeButton_badge.isHidden = false
            self.itineraryView.bringSubview(toFront: addInviteeButton_badge)

        } else {
            contactsCollectionView.isHidden = false
            if addInviteeButton.layer.sublayers != nil {
                for sublayer in addInviteeButton.layer.sublayers! {
                    if sublayer.isKind(of: CAShapeLayer.self) {
                        sublayer.removeFromSuperlayer()
                    }
                }
            }
            addInviteeButton.setTitle("+", for: .normal)
            addInviteeButton.titleLabel?.font = UIFont.systemFont(ofSize: 39)
            addInviteeButton.setTitleColor(completeColor, for: .normal)
            addInviteeButton.frame.size.height = 47
            addInviteeButton.frame.size.width = 43
            addInviteeButton.layer.borderWidth = 0
            if numberOfContacts < 4 {
                addInviteeButton.frame.origin.x = CGFloat(100 + 65 * numberOfContacts)
            } else {
                addInviteeButton.frame.origin.x = bounds.size.width - 53
            }
            addInviteeButton.frame.origin.y = 63

            addInviteeButton_badge.isHidden = true
        }
    }
    func disableAndResetAssistant_moveToItinerary() {
        isAssistantEnabled = false
        handleTwicketSegmentedControl()
        
        itinerary()
        
        let when = DispatchTime.now() + 0.3
        DispatchQueue.main.asyncAfter(deadline: when) {
            let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["assistantMode"] = "disabled" as! NSString
            self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
        }
        //delete all subviews in assistant
        userNameQuestionView = nil
        tripNameQuestionView = nil
        whereTravellingFromQuestionView = nil
        datesPickedOutCalendarView = nil
        decidedOnCityToVisitQuestionView = nil
        yesCityDecidedQuestionView = nil
        noCityDecidedAnyIdeasQuestionView = nil
        planTripToIdeaQuestionView = nil
        whatTypeOfTripQuestionView = nil
        howFarAwayQuestionView = nil
        destinationOptionsCardView = nil
        addAnotherDestinationQuestionView = nil
        howDoYouWantToGetThereQuestionView = nil
        flightSearchQuestionView = nil
        doYouNeedARentalCarQuestionView = nil
        carRentalSearchQuestionView = nil
        doYouKnowWhereYouWillBeStayingQuestionView = nil
        aboutWhatTimeWillYouStartDrivingQuestionView = nil
        busTrainOtherQuestionView = nil
        idkHowToGetThereQuestionView = nil
        whatTypeOfPlaceToStayQuestionView = nil
        hotelSearchQuestionView = nil
        shortTermRentalSearchQuestionView = nil
        stayWithSomeoneIKnowQuestionView = nil
        placeForGroupOrJustYouQuestionView = nil
        sendProposalQuestionView = nil
        yesIKnowWhereImStayingQuestionView = nil
        doYouNeedHelpBookingAHotelQuestionView = nil
        parseDatesForMultipleDestinationsCalendarView = nil
//        instructionsQuestionView = nil
        alreadyHaveFlightsQuestionView = nil
        //Popover Views
        didYouBuyTheFlightQuestionPopover = nil
        didYouBuyTheHotelQuestionView = nil

//        scrollContentView.removeAllSubviews()
        for subview in scrollContentView.subviews {
            if subview != instructionsQuestionView {
                subview.removeFromSuperview()
            }
        }
        //Hide instructions view
        if let qLabel1 = instructionsQuestionView?.questionLabel1 {
            qLabel1.isHidden = true
        }
        if let qLabel2 = instructionsQuestionView?.questionLabel2 {
            qLabel2.isHidden = true
        }
        if let bLabel1 = instructionsQuestionView?.button1 {
            bLabel1.isHidden = true
        }
        instructionsQuestionView?.exampleItineraryImageView.isHidden = true
        
        
        updateHeightOfScrollView()
        updateProgress()
        progressRing?.setProgress(value: 0, animationDuration: 0.1)
    }
    func reviewItinerary() {
        disableAndResetAssistant_moveToItinerary()
    }
    func chat() {
//        UIView.animate(withDuration: 0.4) {
//            self.underline.layer.frame = CGRect(x: 288, y: 25, width: 50, height: 51)
//        }
        assistantViewIsHiddenTrue()
        itineraryView.isHidden = true
        infoButton.isHidden = true
        chatView.isHidden = false
        self.view.endEditing(true)
        chatController?.inputToolbar.contentView.textView.becomeFirstResponder()
    }
    func animateInBackgroundFilterView(withInfoView: Bool, withBlurEffect: Bool, withCloseButton: Bool) {
        popupBackgroundViewDeleteContacts.isHidden = true
        
        if withBlurEffect {
            popupBackgroundFilterViewVisualEffectView.isHidden = false
        } else {
            popupBackgroundFilterViewVisualEffectView.isHidden = true
        }
        popupBackgroundFilterView.alpha = 1
        popupBackgroundFilterView.isHidden = false
        
        if withInfoView {
            infoKeyButton_1.isHidden = false
            infoKeyButton_1_text.isHidden = false
            infoKeyButton_2.isHidden = false
            infoKeyButton_3.isHidden = false
            infoKeyButton_3_badgeButton?.isHidden = false
            infoKeyButton_4_badgeButton?.isHidden = false
            infoKeyButton_5_badgeButton?.isHidden = false
            infoKeyButton_4.isHidden = false
            infoKeyButton_5.isHidden = false
            infoKeyButton_6.isHidden = false
            infoKeyButton_6_text.isHidden = false
            infoKeyButton_7.isHidden = false
            infoKeyButton_7_text.isHidden = false
            infoKeyLabel_1.isHidden = false
            infoKeyLabel_2.isHidden = false
            
        } else {
            infoKeyButton_1.isHidden = true
            infoKeyButton_1_text.isHidden = true
            infoKeyButton_2.isHidden = true
            infoKeyButton_3.isHidden = true
            infoKeyButton_3_badgeButton?.isHidden = true
            infoKeyButton_4_badgeButton?.isHidden = true
            infoKeyButton_5_badgeButton?.isHidden = true
            infoKeyButton_4.isHidden = true
            infoKeyButton_5.isHidden = true
            infoKeyButton_6.isHidden = true
            infoKeyButton_6_text.isHidden = true
            infoKeyButton_7.isHidden = true
            infoKeyButton_7_text.isHidden = true
            infoKeyLabel_1.isHidden = true
            infoKeyLabel_2.isHidden = true
        }
        if withCloseButton {
            popupBackgroundFilterViewCloseButton.isHidden = false
        } else {
            popupBackgroundFilterViewCloseButton.isHidden = true
        }
        self.view.addSubview(popupBackgroundFilterView)
    }
    func animateOutBackgroundFilterView() {
        self.popupBackgroundFilterView.removeFromSuperview()
        popupBackgroundFilterView.isHidden = true
        popupBackgroundViewDeleteContacts.isHidden = true
    }
    func handleSendInvitesButton() {
        if editItineraryModeEnabled == true {
            itineraryButton2?.isHidden = true
            itineraryButton2?.stopPulseEffect()
        } else {
            var itinerarySendable = false
            if contacts != nil {
                if (contacts?.count)! > 0 {
                    itinerarySendable = true
                    editSwitchLabel.frame.origin.x = 80
                    editSwitch.frame.origin.x = 187
                }
            }
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])
            
            if ((SavedPreferencesForTrip["selected_dates"] as? [Date])?.count)! == 0 || destinationsForTrip.count == 0 {
                itinerarySendable = false
                
                editSwitchLabel.frame.origin.x = 110
                editSwitch.frame.origin.x = 217
            }            

            if itinerarySendable {
                itineraryButton2?.isHidden = false
                itineraryButton2?.startPulse(with: UIColor.white, offset: CGSize(width: 0, height: 0), frequency:0.5)
                
                //PLANNED:             
                //Move switch and label to the left
                //pulse button
            } else {
                itineraryButton2?.isHidden = true
                itineraryButton2?.stopPulseEffect()
            }

        }
    }
    
    // MARK: Actions
    @IBAction func itineraryTutorialView1_nextButtonTouchedUpInside(_ sender: Any) {
        handleItineraryTutorial()
    }
    @IBAction func editSwitchValueChanged(_ sender: Any) {
        if editSwitch.isOn {
            editItineraryModeEnabled = true
            turnOnItineraryEditing()
        } else {
            editItineraryModeEnabled = false
            dismissEditItineraryMode()
        }
        handleSendInvitesButton()
    }
    @IBAction func infoViewCloseButtonTouchedUpInside(_ sender: Any) {
        animateOutBackgroundFilterView()
    }
    @IBAction func addInviteesButtonTouchedUpInside(_ sender: Any) {
        checkContactsAccess()
    }
    @IBAction func infoButtonTouchedUpInside(_ sender: Any) {
//        self.popupBackgroundFilterView.alpha = 0
//        let bounds = UIScreen.main.bounds
//        self.popupBackgroundFilterView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
//        self.popupBackgroundFilterView.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
//        
        self.animateInBackgroundFilterView(withInfoView: true, withBlurEffect: true, withCloseButton: true)
//
//        UIView.animate(withDuration: 0.5) {
//            self.popupBackgroundFilterView.alpha = 1
//            self.popupBackgroundFilterView.transform = CGAffineTransform.identity
//        }
    }
    @IBAction func filterButtonTouchedUpInside(_ sender: Any) {
        
        getCurrentSubview()
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let currentSubview = SavedPreferencesForTrip["currentAssistantSubview"] as! NSNumber
        
        if currentSubview == 11 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "flightFilterResultsButtonTouchedUpInside"), object: nil)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hotelFilterResultsButtonTouchedUpInside"), object: nil)
        }

    }
    @IBAction func sortButtonTouchedUpInside(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hotelSortResultsButtonTouchedUpInside"), object: nil)

    }
    @IBAction func hotelMapButtonTouchedUpInside(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hotelMapResultsButtonTouchedUpInside"), object: nil)
    }
//    @IBAction func assistantButtonTouchedUpInside(_ sender: Any) {
//        assistant()
//    }
//    @IBAction func itineraryButtonTouchedUpInside(_ sender: Any) {
//        itinerary()
//    }
//    @IBAction func chatButtonTouchedUpInside(_ sender: Any) {
//        chat()
//    }
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
            formatter.dateFormat = "MM/dd/yyyy"
            let leftDate = formatter.date(from: leftKeys[0] as! String)
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
            formatter.dateFormat = "MM/dd/yyyy"
            let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
            leftDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
            flightSearchQuestionView?.departureDate?.text =  "\(mostRecentSelectedCellDateAsNSString)"
            carRentalSearchQuestionView?.pickUpDate?.text =  "\(mostRecentSelectedCellDateAsNSString)"
            hotelSearchQuestionView?.checkInDate?.text =  "\(mostRecentSelectedCellDateAsNSString)"
        }
        if cell?.selectedPosition() == .right {
            formatter.dateFormat = "MM/dd/yyyy"
            let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
            rightDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
            flightSearchQuestionView?.returnDate?.text =  "\(mostRecentSelectedCellDateAsNSString)"
            carRentalSearchQuestionView?.dropOffDate?.text =  "\(mostRecentSelectedCellDateAsNSString)"
            hotelSearchQuestionView?.checkOutDate?.text =  "\(mostRecentSelectedCellDateAsNSString)"
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
                    formatter.dateFormat = "MM/dd/yyyy"
                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
                    leftDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
                    flightSearchQuestionView?.departureDate?.text =  "\(mostRecentSelectedCellDateAsNSString)"
                    carRentalSearchQuestionView?.pickUpDate?.text =  "\(mostRecentSelectedCellDateAsNSString)"
                    hotelSearchQuestionView?.checkInDate?.text =  "\(mostRecentSelectedCellDateAsNSString)"

                }
                if cell?.selectedPosition() == .right {
                    formatter.dateFormat = "MM/dd/yyyy"
                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
                    rightDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
                    flightSearchQuestionView?.returnDate?.text =  "\(mostRecentSelectedCellDateAsNSString)"
                    carRentalSearchQuestionView?.dropOffDate?.text =  "\(mostRecentSelectedCellDateAsNSString)"
                    hotelSearchQuestionView?.checkOutDate?.text =  "\(mostRecentSelectedCellDateAsNSString)"
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
                    formatter.dateFormat = "MM/dd/yyyy"
                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
                    leftDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
                    flightSearchQuestionView?.departureDate?.text =  "\(mostRecentSelectedCellDateAsNSString)"
                    carRentalSearchQuestionView?.pickUpDate?.text =  "\(mostRecentSelectedCellDateAsNSString)"
                    hotelSearchQuestionView?.checkInDate?.text =  "\(mostRecentSelectedCellDateAsNSString)"
                }
                if cell?.selectedPosition() == .right {
                    formatter.dateFormat = "MM/dd/yyyy"
                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
                    rightDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
                    flightSearchQuestionView?.returnDate?.text =  "\(mostRecentSelectedCellDateAsNSString)"
                    carRentalSearchQuestionView?.dropOffDate?.text =  "\(mostRecentSelectedCellDateAsNSString)"
                    hotelSearchQuestionView?.checkOutDate?.text =  "\(mostRecentSelectedCellDateAsNSString)"
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
        
        formatter.dateFormat = "MMMM yyyy"
        let stringForHeader = formatter.string(from: range.start)
        headerCell.monthLabel.text = stringForHeader
        
        return headerCell
}
}

extension TripViewController {
    // MARK: CONTACTS
    fileprivate func checkContactsAccess() {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        // Update our UI if the user has granted access to their Contacts
        case .authorized:            
            // Obtain a configured MFMessageComposeViewController
            let addInviteesAlert = UIAlertController(title: "We won't send your itinerary\nuntil you say so!", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let continueAction = UIAlertAction(title: "Sounds good", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                self.showContactsPicker()
            }
            addInviteesAlert.addAction(continueAction)
            self.present(addInviteesAlert, animated: true, completion: nil)
            
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
                    let addInviteesAlert = UIAlertController(title: "Great! We won't send them the itinerary until you say so!", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    let continueAction = UIAlertAction(title: "Sounds good", style: UIAlertActionStyle.default) {
                        (result : UIAlertAction) -> Void in
                        self.showContactsPicker()
                    }
                    addInviteesAlert.addAction(continueAction)
                    self.present(addInviteesAlert, animated: true, completion: nil)
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
            if sendProposalQuestionView != nil {
                    sendProposalQuestionView?.contactsTableView?.insertRows(at: addedRowIndexPath as [IndexPath], with: .left)
            }
            let addedRowIndexPathCollectionView = [IndexPath(row: numberContactsInTable + 1, section: 0)]
            contactsCollectionView.insertItems(at: addedRowIndexPathCollectionView)
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
            if sendProposalQuestionView != nil {
                sendProposalQuestionView?.contactsTableView?.insertRows(at: addedRowIndexPath, with: .left)
            }
            let addedRowIndexPathCollectionView = [addedRowIndexPath[0],IndexPath(row: 1, section: 0)]
            contactsCollectionView.insertItems(at: addedRowIndexPathCollectionView)
        }
        if sendProposalQuestionView != nil {
            sendProposalQuestionView?.contactsTableView?.isHidden = false
            sendProposalQuestionView?.button3?.isHidden = false
        }
        updateProgress()
        handleAddInviteesButton()
        handleSendInvitesButton()
        //        //Uncomment for testing on Simulator
        //        //        chatButton.isHidden = true
        //        //        subviewDoneButton.isHidden = false
        //
        //        //Uncomment for testing on iPhone
        //        if (contacts?.count)! > 0 {
        //            chatButton.isHidden = false
        //            subviewDoneButton.isHidden = true
        //
        //        } else {
        //            chatButton.isHidden = true
        //            subviewDoneButton.isHidden = false
        //        }
    }
    func spawnMessages() {
        // Make sure the device can send text messages
        if (messageComposer.canSendText()) {
            // Obtain a configured MFMessageComposeViewController
                let messageComposeVC = self.messageComposer.configuredMessageComposeViewController()
                // Present the configured MFMessageComposeViewController instance
                self.present(messageComposeVC, animated: true, completion: nil)
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
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        updateProgress()
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
            if sendProposalQuestionView != nil {
                sendProposalQuestionView?.contactsTableView?.insertRows(at: addedRowIndexPath as [IndexPath], with: .left)
            }
            let addedRowIndexPathCollectionView = [IndexPath(row: numberContactsInTable + 1, section: 0)]
            contactsCollectionView.insertItems(at: addedRowIndexPathCollectionView)
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
            if sendProposalQuestionView != nil {
                sendProposalQuestionView?.contactsTableView?.insertRows(at: addedRowIndexPath, with: .left)
            }
            let addedRowIndexPathCollectionView = [addedRowIndexPath[0],IndexPath(row: 1, section: 0)]
            contactsCollectionView.insertItems(at: addedRowIndexPathCollectionView)
        }
        
        if sendProposalQuestionView != nil {
            sendProposalQuestionView?.contactsTableView?.isHidden = false
            sendProposalQuestionView?.button3?.isHidden = false
            
        }
        updateProgress()
        handleAddInviteesButton()
        handleSendInvitesButton()
        //        //Uncomment for testing on Simulator
        //        //        chatButton.isHidden = true
        //        //        subviewDoneButton.isHidden = false
        //
        //        //Uncomment for testing on iPhone
        //        if (contacts?.count)! > 0 {
        //            chatButton.isHidden = false
        //            subviewDoneButton.isHidden = true
        //            
        //        } else {
        //            chatButton.isHidden = true
        //            subviewDoneButton.isHidden = false
        //        }
    }
}

//MARK: UICollectionViewDelegate & UICollectionViewDatasource
extension TripViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == destinationsDatesCollectionView {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var countDestinations = (SavedPreferencesForTrip["destinationsForTrip"] as! [String]).count
            
            
            if countDestinations != 0 {
                return countDestinations + 2
            }
            return 3
        }
//        else if collectionView == contactsCollectionView
        //This includes the user
        var numberOfContacts = 0
        if contacts != nil {
            if (contacts?.count)! != 0 {
                numberOfContacts += contacts!.count + 1
            }
        }
        
        return numberOfContacts
    }
    
    func setBadgeWithType(badge: MIBadgeButton, type: badgeButtonType) {
        switch type {
        case .userActionRequired :
            badge.badgeString = "!"
            badge.badgeBackgroundColor = UIColor.red
            badge.isHidden = false
        case .groupMemberActionRequired :
            badge.badgeString = "!"
            badge.badgeBackgroundColor = UIColor.orange
            badge.isHidden = false
        case .plannedAndConfirmed :
            badge.badgeString = "✓"
            badge.badgeBackgroundColor = UIColor(red: 0, green: 149/255, blue: 0, alpha: 1)
            badge.isHidden = false
        }
    }
    
    //MARK: CollectionViewDataSource CellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == destinationsDatesCollectionView {
            let destinationsDatesCell = destinationsDatesCollectionView.dequeueReusableCell(withReuseIdentifier: "destinationsDatesCollectionViewCell", for: indexPath) as! destinationsDatesCollectionViewCell
            
            
            //Badge textcolor, tags, and selectors
            destinationsDatesCell.destinationButton_badge.badgeTextColor = UIColor.white
            destinationsDatesCell.travelButton_badge.badgeTextColor = UIColor.white
            destinationsDatesCell.travelDateButton_badge.badgeTextColor = UIColor.white
            destinationsDatesCell.placeToStayButton_badge.badgeTextColor = UIColor.white
            destinationsDatesCell.placeToStayButton.tag = indexPath.row
            destinationsDatesCell.travelButton.tag = indexPath.row
            destinationsDatesCell.travelDateButton.tag = indexPath.row
            destinationsDatesCell.destinationButton.tag = indexPath.row
            destinationsDatesCell.placeToStayButton.addTarget(self, action: #selector(self.placeToStayButtonTouchedUpInside(sender:)), for: UIControlEvents.touchUpInside)
            destinationsDatesCell.travelButton.addTarget(self, action: #selector(self.travelButtonTouchedUpInside(sender:)), for: UIControlEvents.touchUpInside)
            destinationsDatesCell.travelDateButton.addTarget(self, action: #selector(self.travelDateButtonTouchedUpInside(sender:)), for: UIControlEvents.touchUpInside)
            destinationsDatesCell.destinationButton.addTarget(self, action: #selector(self.destinationButtonTouchedUpInside(sender:)), for: UIControlEvents.touchUpInside)

            
            //Button textcolor, outline, tags, and Selectors
            destinationsDatesCell.destinationButton.layer.borderWidth = 2
            destinationsDatesCell.destinationButton.layer.borderColor = completeColor.cgColor
            destinationsDatesCell.travelDateButton.layer.borderWidth = 2
            destinationsDatesCell.travelDateButton.layer.borderColor = completeColor.cgColor
            destinationsDatesCell.travelDateButton.backgroundColor = UIColor.clear
            destinationsDatesCell.placeToStayButton.setTitleColor(completeColor, for: .normal)
            destinationsDatesCell.travelButton.setTitleColor(completeColor, for: .normal)
            destinationsDatesCell.travelDateButton.setTitleColor(completeColor, for: .normal)
            destinationsDatesCell.destinationButton.setTitleColor(completeColor, for: .normal)
            destinationsDatesCell.placeToStayButton.tag = indexPath.row
            destinationsDatesCell.travelButton.tag = indexPath.row
            destinationsDatesCell.travelDateButton.tag = indexPath.row
            destinationsDatesCell.destinationButton.tag = indexPath.row
            destinationsDatesCell.placeToStayButton.addTarget(self, action: #selector(self.placeToStayButtonTouchedUpInside(sender:)), for: UIControlEvents.touchUpInside)
            destinationsDatesCell.travelButton.addTarget(self, action: #selector(self.travelButtonTouchedUpInside(sender:)), for: UIControlEvents.touchUpInside)
            destinationsDatesCell.travelDateButton.addTarget(self, action: #selector(self.travelDateButtonTouchedUpInside(sender:)), for: UIControlEvents.touchUpInside)
            destinationsDatesCell.destinationButton.addTarget(self, action: #selector(self.destinationButtonTouchedUpInside(sender:)), for: UIControlEvents.touchUpInside)
            
            //Editing
            let tapDeadSpaceInItineraryCollectionViewCell = UITapGestureRecognizer(target: self, action: #selector(self.dismissEditItineraryMode))
            tapDeadSpaceInItineraryCollectionViewCell.numberOfTapsRequired = 1
            tapDeadSpaceInItineraryCollectionViewCell.delegate = self
            destinationsDatesCell.popupBackgroundViewEditItineraryWithinCell.addGestureRecognizer(tapDeadSpaceInItineraryCollectionViewCell)
            destinationsDatesCell.popupBackgroundViewEditItineraryWithinCell.isHidden = true
            destinationsDatesCell.popupBackgroundViewEditItineraryWithinCell.isUserInteractionEnabled = true

            
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])
            var datesDestinationsDictionary = SavedPreferencesForTrip["datesDestinationsDictionary"] as! [String:[Date]]
            var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
            var placeToStayDictionaryArray = SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]]

            if destinationsDatesCell.travelDateButton.layer.sublayers != nil {
                for sublayer in destinationsDatesCell.travelDateButton.layer.sublayers! {
                    if sublayer.isKind(of: CAShapeLayer.self) {
                        sublayer.removeFromSuperlayer()
                    }
                }
            }
            if destinationsDatesCell.destinationButton.layer.sublayers != nil {
                for sublayer in destinationsDatesCell.destinationButton.layer.sublayers! {
                    if sublayer.isKind(of: CAShapeLayer.self) {
                        sublayer.removeFromSuperlayer()
                    }
                }
            }
            
            //Trip beginning date
            if indexPath.row == 0 {
                
                //Set start location
                if DataContainerSingleton.sharedDataContainer.homeAirport != nil && DataContainerSingleton.sharedDataContainer.homeAirport != "" {
                    destinationsDatesCell.destinationButton.setTitle(DataContainerSingleton.sharedDataContainer.homeAirport, for: .normal)
                } else {
                    destinationsDatesCell.destinationButton.setTitle("Add starting point", for: .normal)
                }
                destinationsDatesCell.destinationButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
                destinationsDatesCell.destinationButton.titleLabel?.textAlignment = .left
                destinationsDatesCell.destinationButton.sizeToFit()
                destinationsDatesCell.destinationButton.frame.size.height = 30
                destinationsDatesCell.destinationButton.frame.size.width += 20
                destinationsDatesCell.destinationButton.layer.cornerRadius = (destinationsDatesCell.destinationButton.frame.height) / 2
                destinationsDatesCell.destinationButton.frame.origin.y = 1
                
                destinationsDatesCell.destinationButton_badge.layer.frame.origin = CGPoint(x: destinationsDatesCell.destinationButton.layer.frame.maxX - 27, y: destinationsDatesCell.destinationButton.layer.frame.minY + 11)
                destinationsDatesCell.destinationButton_badge.isHidden = false
                
                if DataContainerSingleton.sharedDataContainer.homeAirport == nil || DataContainerSingleton.sharedDataContainer.homeAirport == "" {
                    setBadgeWithType(badge: destinationsDatesCell.destinationButton_badge, type: .userActionRequired)
                    destinationsDatesCell.destinationButton.titleLabel?.font = UIFont.italicSystemFont(ofSize: 22)
                } else {
                    setBadgeWithType(badge: destinationsDatesCell.destinationButton_badge, type: .plannedAndConfirmed)
                    destinationsDatesCell.destinationButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
                }

                
                //Show destination
                destinationsDatesCell.destinationButton.isHidden = false
                
                //Hide dates and accomodation
                destinationsDatesCell.travelDateButton.isHidden = true
                destinationsDatesCell.inBetweenDatesLine.isHidden = true
                destinationsDatesCell.travelButton.isHidden = true
                destinationsDatesCell.placeToStayButton.isHidden = true
                destinationsDatesCell.travelDateButton_badge.isHidden = true
                destinationsDatesCell.travelButton_badge.isHidden = true
                destinationsDatesCell.placeToStayButton_badge.isHidden = true
                
                return destinationsDatesCell
            }
            
            //Trip end date
            if indexPath.row == destinationsDatesCollectionView.numberOfItems(inSection: 0) - 1 {
                destinationsDatesCell.travelDateButton_badge.layer.frame.origin = CGPoint(x: destinationsDatesCell.travelDateButton.layer.frame.maxX - 33, y: destinationsDatesCell.travelDateButton.layer.frame.minY + 11)
                destinationsDatesCell.travelDateButton_badge.isHidden = false

                //Set final location
                if SavedPreferencesForTrip["endingPoint"] as! String == "" {
                    if DataContainerSingleton.sharedDataContainer.homeAirport != nil && DataContainerSingleton.sharedDataContainer.homeAirport != "" {
                        destinationsDatesCell.destinationButton.setTitle(DataContainerSingleton.sharedDataContainer.homeAirport, for: .normal)
                    } else {
                        destinationsDatesCell.destinationButton.setTitle("Add ending point", for: .normal)
                    }
                } else {
                    destinationsDatesCell.destinationButton.setTitle((SavedPreferencesForTrip["endingPoint"] as! String) , for: .normal)

                }
                
                destinationsDatesCell.destinationButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
                destinationsDatesCell.destinationButton.titleLabel?.textAlignment = .left
                destinationsDatesCell.destinationButton.sizeToFit()
                destinationsDatesCell.destinationButton.frame.size.height = 30
                destinationsDatesCell.destinationButton.frame.size.width += 20
                destinationsDatesCell.destinationButton.layer.cornerRadius = (destinationsDatesCell.destinationButton.frame.height) / 2
                destinationsDatesCell.destinationButton.frame.origin.y = 73
                
                destinationsDatesCell.destinationButton_badge.layer.frame.origin = CGPoint(x: destinationsDatesCell.destinationButton.layer.frame.maxX - 28, y: destinationsDatesCell.destinationButton.layer.frame.minY + 4)
                destinationsDatesCell.destinationButton_badge.isHidden = false

                
                destinationsDatesCell.travelDateButton.titleLabel?.textAlignment = .center
                destinationsDatesCell.travelDateButton.titleLabel?.numberOfLines = 0
                destinationsDatesCell.travelDateButton.titleLabel?.font = UIFont.systemFont(ofSize: 19)
                destinationsDatesCell.travelDateButton.layer.cornerRadius = destinationsDatesCell.travelDateButton.frame.size.height / 2
                
                //Show destination
                destinationsDatesCell.destinationButton.isHidden = false
                destinationsDatesCell.travelDateButton.isHidden = false
                destinationsDatesCell.travelButton.isHidden = false
                
                //Hide accomodation
                destinationsDatesCell.placeToStayButton.isHidden = true
                destinationsDatesCell.inBetweenDatesLine.isHidden = true
                destinationsDatesCell.placeToStayButton_badge.isHidden = true
                
                
                var rightDatesDestinations = [String:Date]()
                if destinationsForTrip.count > 0 {
                    if datesDestinationsDictionary[destinationsForTrip[indexPath.row - 2]] != nil {
                        
                        //Set date
                        rightDatesDestinations[destinationsForTrip[indexPath.row - 2]] = datesDestinationsDictionary[destinationsForTrip[indexPath.row - 2]]?[(datesDestinationsDictionary[destinationsForTrip[indexPath.row - 2]]?.count)! - 1]
                        formatter.dateFormat = "MMM\nd"
                        let rightDateAsString = formatter.string(from: rightDatesDestinations[destinationsForTrip[indexPath.row - 2]]!)
                        destinationsDatesCell.travelDateButton.setTitle(rightDateAsString, for: .normal)
                        destinationsDatesCell.travelDateButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
                        setBadgeWithType(badge: destinationsDatesCell.destinationButton_badge, type: .groupMemberActionRequired)
                    }
                } else {
                    destinationsDatesCell.travelDateButton.setTitle("Add\ndates", for: .normal)
                    setBadgeWithType(badge: destinationsDatesCell.destinationButton_badge, type: .userActionRequired)
                    destinationsDatesCell.travelDateButton.titleLabel?.font = UIFont.italicSystemFont(ofSize: 18)

                }

              
                
                if DataContainerSingleton.sharedDataContainer.homeAirport == nil || DataContainerSingleton.sharedDataContainer.homeAirport == "" {
                    setBadgeWithType(badge: destinationsDatesCell.destinationButton_badge, type: .userActionRequired)
                    destinationsDatesCell.destinationButton.titleLabel?.font = UIFont.italicSystemFont(ofSize: 22)
                } else {
                    setBadgeWithType(badge: destinationsDatesCell.destinationButton_badge, type: .plannedAndConfirmed)
                    destinationsDatesCell.destinationButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
                }
                
                
                if let selectedDatesValue = SavedPreferencesForTrip["selected_dates"] as? [Date] {
                    if selectedDatesValue.count == 0 {
                        setBadgeWithType(badge: destinationsDatesCell.destinationButton_badge, type: .userActionRequired)
                        destinationsDatesCell.travelDateButton.titleLabel?.font = UIFont.italicSystemFont(ofSize: 18)
                    } else if selectedDatesValue.count != 0 {
                        let endDate = selectedDatesValue[selectedDatesValue.count - 1]
                        formatter.dateFormat = "MMM\nd"
                        let endDateAsString = formatter.string(from: endDate)
                        destinationsDatesCell.travelDateButton.setTitle(endDateAsString, for: .normal)
                        destinationsDatesCell.travelDateButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
                        setBadgeWithType(badge: destinationsDatesCell.destinationButton_badge, type: .groupMemberActionRequired)
                        
                    }
                }

                //Travel button badge
                destinationsDatesCell.travelButton_badge.layer.frame.origin = CGPoint(x: destinationsDatesCell.travelButton.layer.frame.maxX - 28, y: destinationsDatesCell.travelButton.layer.frame.minY + 11)
                destinationsDatesCell.travelButton_badge.isHidden = false
                destinationsDatesCell.travelButton.setBackgroundImage(#imageLiteral(resourceName: "airplaneTakingOff").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
                
                //PLANNED: more detailed travel planned logic
                if travelDictionaryArray.count < indexPath.row {
                    setBadgeWithType(badge: destinationsDatesCell.destinationButton_badge, type: .userActionRequired)
                } else {
                    setBadgeWithType(badge: destinationsDatesCell.destinationButton_badge, type: .plannedAndConfirmed)
                }
                
                return destinationsDatesCell
            }
            
            //2nd to (n - 1)th cell

            //Find left and right dates
            var leftDatesDestinations = [String:Date]()
            var rightDatesDestinations = [String:Date]()
            
            //SetupInBetweenDatesLine
            destinationsDatesCell.inBetweenDatesLine.backgroundColor = completeColor

            
            
            //Travel date button
            destinationsDatesCell.travelDateButton.titleLabel?.textAlignment = .center
            destinationsDatesCell.travelDateButton.titleLabel?.numberOfLines = 0
//            destinationsDatesCell.travelDateButton.titleLabel?.font = UIFont.italicSystemFont(ofSize: 18)
            destinationsDatesCell.travelDateButton.layer.cornerRadius = destinationsDatesCell.travelDateButton.frame.size.height / 2
            //Travel date badge
//            destinationsDatesCell.travelDateButton_badge.badgeString = "!"
//            destinationsDatesCell.travelDateButton_badge.badgeBackgroundColor = UIColor.red
            destinationsDatesCell.travelDateButton_badge.layer.frame.origin = CGPoint(x: destinationsDatesCell.travelDateButton.layer.frame.maxX - 33, y: destinationsDatesCell.travelDateButton.layer.frame.minY + 10)
            destinationsDatesCell.travelDateButton_badge.isHidden = false

            
            //Destination button
            destinationsDatesCell.destinationButton.titleLabel?.textAlignment = .center
            
            //Destination badge
            setBadgeWithType(badge: destinationsDatesCell.destinationButton_badge, type: .groupMemberActionRequired)


            
            if destinationsForTrip.count == 0 && indexPath.row != destinationsDatesCollectionView.numberOfItems(inSection: 0) - 1 && indexPath.row != 0 && ((SavedPreferencesForTrip["selected_dates"] as? [Date])?.count)! == 0 {
//                destinationsDatesCell.travelDateButton.addDashedBorder(lineWidth: 2, lineColor: incompleteColor, height:destinationsDatesCell.travelDateButton.frame.height)
//                destinationsDatesCell.travelDateButton_badge.badgeString = "!"
//                destinationsDatesCell.travelDateButton_badge.badgeBackgroundColor = UIColor.red
            }
            if destinationsForTrip.count == 0 && indexPath.row != destinationsDatesCollectionView.numberOfItems(inSection: 0) - 1 && indexPath.row != 0 {
                setBadgeWithType(badge: destinationsDatesCell.destinationButton_badge, type: .userActionRequired)
            }
            
            var isRoundtripTravelPlanned = false
            if destinationsForTrip.count > 0 {
                for i in 0 ... destinationsForTrip.count - 1 {
                    var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
                    if i < travelDictionaryArray.count {
                        if travelDictionaryArray[i]["isRoundtrip"] as? Bool != nil {
                            if travelDictionaryArray[i]["isRoundtrip"] as! Bool == true {
                                isRoundtripTravelPlanned = true
                            }
                        }
                    }
                }
            }
            destinationsDatesCell.travelButton.setBackgroundImage(#imageLiteral(resourceName: "airplaneTakingOff").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
            destinationsDatesCell.travelButton.tintColor = completeColor
            destinationsDatesCell.travelButton_badge.layer.frame.origin = CGPoint(x: destinationsDatesCell.travelButton.layer.frame.maxX - 28, y: destinationsDatesCell.travelButton.layer.frame.minY + 11)
            destinationsDatesCell.travelButton_badge.isHidden = false

            if travelDictionaryArray.count < indexPath.row && !isRoundtripTravelPlanned {
                setBadgeWithType(badge: destinationsDatesCell.destinationButton_badge, type: .userActionRequired)

            } else {
                setBadgeWithType(badge: destinationsDatesCell.destinationButton_badge, type: .plannedAndConfirmed)
            }

            
            destinationsDatesCell.placeToStayButton.setBackgroundImage(#imageLiteral(resourceName: "apartmentAngledRoof").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
            destinationsDatesCell.placeToStayButton.tintColor = completeColor
            
            
            if indexPath.row != destinationsDatesCollectionView.numberOfItems(inSection: 0) - 1 && indexPath.row != 0 {
                
                destinationsDatesCell.inBetweenDatesLine.isHidden = false
                destinationsDatesCell.inBetweenDatesLine.frame = CGRect(x: destinationsDatesCell.travelDateButton.frame.midX - 2 / 2, y: destinationsDatesCell.travelDateButton.frame.maxY, width: 2, height: destinationsDatesCell.frame.maxY - destinationsDatesCell.travelDateButton.frame.maxY)
                
            } else {
                destinationsDatesCell.inBetweenDatesLine.isHidden = true
            }
            
    
            //Show destination
            destinationsDatesCell.destinationButton.isHidden = false
            destinationsDatesCell.destinationButton_badge.isHidden = false
            destinationsDatesCell.travelDateButton.isHidden = false
            destinationsDatesCell.travelDateButton_badge.isHidden = false
            destinationsDatesCell.placeToStayButton.isHidden = false
            destinationsDatesCell.placeToStayButton_badge.isHidden = false
            destinationsDatesCell.travelButton.isHidden = false
            destinationsDatesCell.destinationButton_badge.isHidden = false

            
            if destinationsForTrip.count == 0 {
                
                if ((SavedPreferencesForTrip["selected_dates"] as? [Date])?.count)! != 0 {
                    let startDate = (SavedPreferencesForTrip["selected_dates"] as? [Date])?[0]
                    formatter.dateFormat = "MMM\nd"
                    let startDateAsString = formatter.string(from: startDate!)
                    destinationsDatesCell.destinationButton.setTitle("Add destination", for: .normal)
                    destinationsDatesCell.destinationButton.titleLabel?.font = UIFont.italicSystemFont(ofSize: 22)
                    destinationsDatesCell.travelDateButton.setTitle(startDateAsString, for: .normal)
                    setBadgeWithType(badge: destinationsDatesCell.destinationButton_badge, type: .groupMemberActionRequired)
                    destinationsDatesCell.travelDateButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
                    
                } else {
                    destinationsDatesCell.destinationButton.setTitle("Add destination", for: .normal)
                    destinationsDatesCell.destinationButton.titleLabel?.font = UIFont.italicSystemFont(ofSize: 22)
                    destinationsDatesCell.travelDateButton.setTitle("Add\ndates", for: .normal)
                    setBadgeWithType(badge: destinationsDatesCell.destinationButton_badge, type: .userActionRequired)
                    destinationsDatesCell.travelDateButton.titleLabel?.font = UIFont.italicSystemFont(ofSize: 18)
                }
            } else if destinationsForTrip.count > 0 {
                if datesDestinationsDictionary[destinationsForTrip[indexPath.row - 1]] != nil {
                    leftDatesDestinations[destinationsForTrip[indexPath.row - 1]] = datesDestinationsDictionary[destinationsForTrip[indexPath.row - 1]]?[0]
                    rightDatesDestinations[destinationsForTrip[indexPath.row - 1]] = datesDestinationsDictionary[destinationsForTrip[indexPath.row - 1]]?[(datesDestinationsDictionary[destinationsForTrip[indexPath.row - 1]]?.count)! - 1]
                    formatter.dateFormat = "MMM\nd"
                    
                    let leftDateAsString = formatter.string(from: leftDatesDestinations[destinationsForTrip[indexPath.row - 1]]!)
                    destinationsDatesCell.travelDateButton.setTitle(leftDateAsString, for: .normal)
                    
                    let tripDates = SavedPreferencesForTrip["selected_dates"] as? [Date]
                    var segmentDates = [Date]()
                    for tripDate in tripDates! {
                        if tripDate <= rightDatesDestinations[destinationsForTrip[indexPath.row - 1]]! && tripDate >= leftDatesDestinations[destinationsForTrip[indexPath.row - 1]]! {
                            segmentDates.append(tripDate)
                        }
                    }
                    
                    destinationsDatesCell.destinationButton.titleLabel?.numberOfLines = 0
                    destinationsDatesCell.destinationButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
                    destinationsDatesCell.destinationButton.setTitle("\(destinationsForTrip[indexPath.row - 1])\nfor \(segmentDates.count - 1) nights", for: .normal)
                } else {
                    destinationsDatesCell.destinationButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
                    destinationsDatesCell.destinationButton.setTitle("\(destinationsForTrip[indexPath.row - 1])", for: .normal)
                }
            }

            destinationsDatesCell.destinationButton.sizeToFit()
            destinationsDatesCell.destinationButton.frame.size.height = 60
            destinationsDatesCell.destinationButton.frame.size.width += 20
            destinationsDatesCell.destinationButton.frame.origin.y = 83
            destinationsDatesCell.destinationButton.layer.cornerRadius = (destinationsDatesCell.destinationButton.frame.height) / 2

            destinationsDatesCell.destinationButton_badge.layer.frame.origin = CGPoint(x: destinationsDatesCell.destinationButton.layer.frame.maxX - 33, y: destinationsDatesCell.destinationButton.layer.frame.minY + 10)
            destinationsDatesCell.destinationButton_badge.isHidden = false
            
            if placeToStayDictionaryArray.count < indexPath.row {
                setBadgeWithType(badge: destinationsDatesCell.destinationButton_badge, type: .userActionRequired)
            } else {
                setBadgeWithType(badge: destinationsDatesCell.destinationButton_badge, type: .groupMemberActionRequired)
                
            }
            destinationsDatesCell.placeToStayButton.frame.origin.x = destinationsDatesCell.destinationButton.frame.maxX + 18
            destinationsDatesCell.placeToStayButton.frame.origin.y = destinationsDatesCell.destinationButton.frame.midY - destinationsDatesCell.placeToStayButton.frame.size.height / 2
            
            destinationsDatesCell.placeToStayButton_badge.layer.frame.origin = CGPoint(x: destinationsDatesCell.placeToStayButton.layer.frame.maxX - 5, y: destinationsDatesCell.placeToStayButton.layer.frame.minY + 11)
            destinationsDatesCell.placeToStayButton_badge.isHidden = false
            
            return destinationsDatesCell
        }
        
        
        //        else if collectionView == contactsCollectionView
        let contactsCell = contactsCollectionView.dequeueReusableCell(withReuseIdentifier: "contactsCollectionPrototypeCell", for: indexPath) as! contactsCollectionViewCell
        if indexPath == IndexPath(item: 0, section: 0) {
            contactsCell.thumbnailImage.image = UIImage(named: "no_contact_image_selected")
            contactsCell.initialsLabel.textColor = UIColor.darkGray
            contactsCell.thumbnailImageFilter.isHidden = true
            contactsCell.initialsLabel.isHidden = false
            let firstInitial = "M"
            let secondInitial = "E"
            contactsCell.initialsLabel.text = firstInitial + secondInitial
            
            //Delete button
            contactsCell.deleteButton.isHidden = true
            // Give the delete button an index number
            contactsCell.deleteButton.layer.setValue(indexPath.row, forKey: "index")
            // Add an action function to the delete button
            contactsCell.deleteButton.addTarget(self, action: #selector(self.deleteContactButtonTouchedUpInside(sender:)), for: UIControlEvents.touchUpInside)
            return contactsCell
        }
//        else
        
        let contact = contacts?[indexPath.row - 1]
        
//        if (contact?.imageDataAvailable)! {
//            contactsCell.thumbnailImage.image = UIImage(data: (contact?.thumbnailImageData!)!)
//            contactsCell.thumbnailImage.contentMode = .scaleToFill
//            let reCenter = contactsCell.thumbnailImage.center
//            contactsCell.thumbnailImage.layer.frame = CGRect(x: contactsCell.thumbnailImage.layer.frame.minX
//                , y: contactsCell.thumbnailImage.layer.frame.minY, width: contactsCell.thumbnailImage.layer.frame.width * 0.91, height: contactsCell.thumbnailImage.layer.frame.height * 0.91)
//            contactsCell.thumbnailImage.center = reCenter
//            contactsCell.thumbnailImage.layer.cornerRadius = contactsCell.thumbnailImage.frame.height / 2
//            contactsCell.thumbnailImage.layer.masksToBounds = true
//            contactsCell.initialsLabel.isHidden = true
//            contactsCell.thumbnailImageFilter.isHidden = false
//            contactsCell.thumbnailImageFilter.image = UIImage(named: "no_contact_image_selected")!
//            contactsCell.thumbnailImageFilter.alpha = 0.5
//        } else {
            contactsCell.thumbnailImage.image = UIImage(named: "no_contact_image")!
            contactsCell.thumbnailImageFilter.isHidden = true
            contactsCell.initialsLabel.isHidden = false
            let firstInitial = contact?.givenName[0]
            let secondInitial = contact?.familyName[0]
            contactsCell.initialsLabel.text = firstInitial! + secondInitial!
            contactsCell.initialsLabel.textColor = UIColor.white
//        }
        
        //Delete button
        contactsCell.deleteButton.isHidden = true
        // Give the delete button an index number
        contactsCell.deleteButton.layer.setValue(indexPath.row, forKey: "index")
        // Add an action function to the delete button
        contactsCell.deleteButton.addTarget(self, action: #selector(self.deleteContactButtonTouchedUpInside(sender:)), for: UIControlEvents.touchUpInside)
        
        return contactsCell
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == destinationsDatesCollectionView {
            let visibleCells = self.destinationsDatesCollectionView.visibleCells
            if editItineraryModeEnabled == true {
                for cell in visibleCells {
                    let visibleCellIndexPath = destinationsDatesCollectionView.indexPath(for: cell)
                    let visibleCell = destinationsDatesCollectionView.cellForItem(at: visibleCellIndexPath!) as! destinationsDatesCollectionViewCell
                    // Shake all of the collection view cells
                    visibleCell.shakeIcons()
                }
            }
        }
        
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
        if collectionView == destinationsDatesCollectionView {
            let visibleCells = self.destinationsDatesCollectionView.visibleCells
            
            if editItineraryModeEnabled == true {
                for cell in visibleCells {
                    let visibleCellIndexPath = destinationsDatesCollectionView.indexPath(for: cell)
                    let visibleCell = destinationsDatesCollectionView.cellForItem(at: visibleCellIndexPath!) as! destinationsDatesCollectionViewCell
                    // Shake all of the collection view cells
                    visibleCell.shakeIcons()
                }
            }
        }
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
    // Item SELECTED: update border color and save data when
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == contactsCollectionView {
            // Change border color to grey
            let selectedCell = contactsCollectionView.cellForItem(at: indexPath) as! contactsCollectionViewCell
            selectedCell.thumbnailImage.image = UIImage(named: "no_contact_image_selected")
            selectedCell.initialsLabel.textColor = UIColor.darkGray
            //SET DATA MODEL TO SHOW TRAVEL AND PLACE TO STAY INFO FOR THIS CONTACT
            
            for item in 0 ... (contacts?.count)! {
                let cell = contactsCollectionView.cellForItem(at: IndexPath(item: item, section: 0)) as! contactsCollectionViewCell
                if cell.initialsLabel.textColor == UIColor.darkGray && IndexPath(item: item, section: 0) != indexPath {
                    cell.thumbnailImage.image = UIImage(named: "no_contact_image")
                    cell.initialsLabel.textColor = UIColor.white
                }
            }
            turnOnItineraryEditing()
            //PLANNED: Reload itinerary collection view with selected contacts' plans
            let when = DispatchTime.now() + 0.6
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.dismissEditItineraryMode()
            }

        }
    }

    // MARK: - UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == destinationsDatesCollectionView {
            let bounds = UIScreen.main.bounds
            if indexPath.row == 0 {
                return CGSize(width: bounds.width, height: 54)
            } else if indexPath.row == destinationsDatesCollectionView.numberOfItems(inSection: 0) - 1 {
                return CGSize(width: bounds.width, height: 104)
            }

            return CGSize(width: bounds.width, height: 173)
        }
        
        //        else if collectionView == contactsCollectionView {
            let picDimension = 55
            return CGSize(width: picDimension, height: picDimension)
//        }
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        if collectionView == destinationsDatesCollectionView {
//            return UIEdgeInsets(top: 0, left: 37.5, bottom: 0, right: 37.5)
//        }
//        //        else if collectionView == contactsCollectionView {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        // }
//    }
    
    // MARK: Custom functions for contacts
    // COPY for Contacts
    func deleteContactButtonTouchedUpInside(sender:UIButton) {
        let i: Int = (sender.layer.value(forKey: "index")) as! Int
        deleteContact(indexPath: IndexPath(row: i, section: 0))
    }
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizerState.began {
            editModeEnabled = true
            popupBackgroundViewDeleteContacts.isHidden = false
            popupBackgroundViewDeleteContactsWithinCollectionView.isHidden = false
            
            for item in self.contactsCollectionView!.visibleCells as! [contactsCollectionViewCell] {
                let indexPath: IndexPath = self.contactsCollectionView!.indexPath(for: item as contactsCollectionViewCell)!
                if indexPath != IndexPath(row: 0, section: 0) {
                    let cell: contactsCollectionViewCell = self.contactsCollectionView!.cellForItem(at: indexPath) as! contactsCollectionViewCell!
                    cell.deleteButton.isHidden = false
                cell.shakeIcons()
                }
            }
        }
    }
    
    func handleLongPressItinerary(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizerState.began {
            editItineraryModeEnabled = true
            turnOnItineraryEditing()
            editSwitch.setOn(true, animated: true)
        }
    }
    func turnOnItineraryEditing() {
        popupBackgroundViewEditItineraryWithinCollectionView.isHidden = false
        for item in self.destinationsDatesCollectionView!.visibleCells as! [destinationsDatesCollectionViewCell] {
            let indexPath: IndexPath = self.destinationsDatesCollectionView!.indexPath(for: item as destinationsDatesCollectionViewCell)!
            let cell: destinationsDatesCollectionViewCell = self.destinationsDatesCollectionView!.cellForItem(at: indexPath) as! destinationsDatesCollectionViewCell!
            cell.shakeIcons()
            cell.popupBackgroundViewEditItineraryWithinCell.isHidden = false
        }
    }
    
    func deleteContact(indexPath: IndexPath) {
        contacts?.remove(at: indexPath.row - 1)
        contactIDs?.remove(at: indexPath.row - 1)
        contactPhoneNumbers.remove(at: indexPath.row - 1)
        
        //Update trip preferences dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["contacts_in_group"] = contactIDs
        SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
        //Save updated trip preferences dictionary
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
        //Delete rows in sendProposalQuestionView
        sendProposalQuestionView?.contactsTableView?.deleteRows(at: [IndexPath(row: indexPath.row - 1, section: 0)], with: .left)
        if contacts?.count == 0 || contacts == nil {
            sendProposalQuestionView?.button3?.isHidden = true
        }
        
        //Delete user contact bubble if last contact deleted
        if (contacts?.count)! == 0 {
            contactsCollectionView.deleteItems(at: [indexPath,IndexPath(item:0,section:0)])
        } else {
            contactsCollectionView.deleteItems(at: [indexPath])
        }
        
        let visibleContactsCells = contactsCollectionView.visibleCells as! [contactsCollectionViewCell]
        for visibleContactCell in visibleContactsCells {
            let newIndexPathForItem = contactsCollectionView.indexPath(for: visibleContactCell)
            visibleContactCell.deleteButton.layer.setValue(newIndexPathForItem?.row, forKey: "index")
        }
        
        if contacts?.count == 0 || contacts == nil {
            dismissDeleteContactsMode()
        }
        handleAddInviteesButton()
        handleSendInvitesButton()
    }

    //    func leaveDeleteContactsMode(touch: UITapGestureRecognizer) {
    //        dismissDeleteContactsMode()
    //    }
    //
    //    func leaveDeleteContactsMode2(touch: UITapGestureRecognizer) {
    //        dismissDeleteContactsMode()
    //    }
    
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
    
    func dismissEditItineraryMode(){
        self.popupBackgroundViewEditItineraryWithinCollectionView.isHidden = true
        
        for item in self.destinationsDatesCollectionView!.visibleCells as! [destinationsDatesCollectionViewCell] {
            let indexPath: IndexPath = self.destinationsDatesCollectionView!.indexPath(for: item as destinationsDatesCollectionViewCell)!
            let cell: destinationsDatesCollectionViewCell = self.destinationsDatesCollectionView!.cellForItem(at: indexPath) as! destinationsDatesCollectionViewCell!
            cell.popupBackgroundViewEditItineraryWithinCell.isHidden = true

            cell.stopShakingIcons()
        }
        editItineraryModeEnabled = false
        editSwitch.setOn(false, animated: true)
    }

}

//MARK: SFSafariViewControllerDelegate
extension TripViewController: SFSafariViewControllerDelegate {
    func showWebsite(URL: URL) {
        let webVC = SFSafariViewController(url: URL)
        webVC.delegate = self
        webVC.preferredBarTintColor = UIColor(red: 25/255, green: 134/255, blue: 191/255, alpha: 1)
        webVC.preferredControlTintColor = UIColor.white
        self.present(webVC, animated: true, completion: nil)
    }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
        
//        if bookingMode == "flight" {
//            flightSelectedBooked()
//        } else
            if bookingMode == "carRental" {
            carRentalSelectedBooked()
        }
//            else if bookingMode == "hotel" {
//            hotelSelectedBooked()
//        }
    }
    func openRome2RioSFSafariViewer() {
        let rome2RioURLString = "https://www.rome2rio.com"
        let rome2RioURL = URL(string: rome2RioURLString)
        showWebsite(URL: rome2RioURL!)
    }
    
    func openGoogleMapsSFSafariViewer() {
        let googleMapsURLString = "https://www.google.com/maps"
        let googleMapsURL = URL(string: googleMapsURLString)
        showWebsite(URL: googleMapsURL!)
    }

    func openAirbnbSFSafariViewer() {
        let airbnbURLString = "https://www.airbnb.com"
        let airbnbURL = URL(string: airbnbURLString)
        showWebsite(URL: airbnbURL!)
    }
    func openWanderuSFSafariViewer() {
        let wanderuURLString = "https://www.wanderu.com"
        let wanderuURL = URL(string: wanderuURLString)
        showWebsite(URL: wanderuURL!)
    }
    func openAmtrakSFSafariViewer() {
        let amtrakURLString = "https://www.amtrak.com"
        let amtrakURL = URL(string: amtrakURLString)
        showWebsite(URL: amtrakURL!)
    }
}

//MARK: Custom functions for loading and translating cities
extension TripViewController {
    func getCarRentalCities() {
        let bundle = Bundle.main
        let path = bundle.path(forResource: "Car-Cities", ofType: "csv")
        let importer = CSVImporter<[String: String]>(path: path!)
        importer.startImportingRecords(structure: { (headerValues) -> Void in
            
        }) { $0 }.onFinish { importedRecords in
            self.ppnCarRentalCities = importedRecords
        }
    }
    func getHotelCities() {
        let bundle = Bundle.main
        let path = bundle.path(forResource: "Hotel-Cities", ofType: "csv")
        let importer = CSVImporter<[String: String]>(path: path!)
        importer.startImportingRecords(structure: { (headerValues) -> Void in
            
        }) { $0 }.onFinish { importedRecords in
            self.ppnHotelCities = importedRecords
        }
    }
    func getAirportCities() {
        let bundle = Bundle.main
        let path = bundle.path(forResource: "Air-Airports", ofType: "csv")
        let importer = CSVImporter<[String: String]>(path: path!)
        importer.startImportingRecords(structure: { (headerValues) -> Void in
            
        }) { $0 }.onFinish { importedRecords in
            self.ppnAirportCities = importedRecords
        }
    }
    func getStateAbbreviations() {
        let bundle = Bundle.main
        let path = bundle.path(forResource: "states", ofType: "csv")
        let importer = CSVImporter<[String: String]>(path: path!)
        importer.startImportingRecords(structure: { (headerValues) -> Void in
            
        }) { $0 }.onFinish { importedRecords in
            self.stateAbbreviationsDict = importedRecords
            
        }
    }
    func getCountryAbbreviations() {
        let bundle = Bundle.main
        let path = bundle.path(forResource: "countryAbbreviations", ofType: "csv")
        let importer = CSVImporter<[String: String]>(path: path!)
        importer.startImportingRecords(structure: { (headerValues) -> Void in
            
        }) { $0 }.onFinish { importedRecords in
            self.countryAbbreviationsDict = importedRecords
            
        }
    }
    
    
    func findCarCityIDWith(cityString: String, stateString: String) -> String {
        for PPNCityDictionary in ppnCarRentalCities {
            if PPNCityDictionary["city"] == cityString {
                
                if PPNCityDictionary["state_code"] == stateString || PPNCityDictionary["country_code"] == stateString {
                    let cityIDWithNameMatch = PPNCityDictionary["cityid_ppn"]!
                        return cityIDWithNameMatch
                }
            }
        }
        return "noMatchingCity"
    }
    func findAirportWith(cityID: String) -> [String] {
        var airports = [String]()
        for PPNAirportDictionary in ppnAirportCities {
            if PPNAirportDictionary["cityid_ppn"] == cityID {
                airports.append(PPNAirportDictionary["airport"]!)
            }
        }
        return airports
    }
    func findStateAbbreviationWith(state: String) -> String {
        for stateAbbreviationDict in stateAbbreviationsDict {
            if stateAbbreviationDict["State"] == state {
                return stateAbbreviationDict["Abbreviation"]!
            }
        }
        return "noStateMatch"
    }
    func findCountryAbbreviationWith(country: String) -> String {
        for countryAbbreviationDict in countryAbbreviationsDict {
            if countryAbbreviationDict["name"] == country {
                return countryAbbreviationDict["ISO3166-1-Alpha-2"]!
            }
        }
        
        return "noCountryMatch"
    }

}

//Custom functions for TravelPayout Flights and Hotels Nav
extension TripViewController {
    func createTicketsVC() -> UIViewController {
        let rootViewController = iPhone() ? ASTContainerSearchFormViewController() : ASTSearchFormSceneViewController()
        return JRNavigationController(rootViewController: rootViewController)
    }
    func createHotelsVC() -> UIViewController {
        let searchVC = iPad() ? HLIpadSearchVC() : HLSearchVC()
        return JRNavigationController(rootViewController: searchVC)
    }
    func flightBookingBrowserClosed() {
        spawnDidYouBuyTheFlightQuestionPopover()
    }
    func spawnDidYouBuyTheFlightQuestionPopover (){
        animateInBackgroundFilterView(withInfoView: false, withBlurEffect: true, withCloseButton: false)

        didYouBuyTheFlightQuestionPopover = Bundle.main.loadNibNamed("DidYouBuyTheFlightQuestionPopover", owner: self, options: nil)?.first! as? DidYouBuyTheFlightQuestionPopover
        
        let bounds = UIScreen.main.bounds
        self.didYouBuyTheFlightQuestionPopover!.frame = CGRect(x: 25, y: -240, width: 325, height: 240)
        self.didYouBuyTheFlightQuestionPopover?.layer.cornerRadius = 7
        self.view.addSubview(didYouBuyTheFlightQuestionPopover!)
        
        

        //        self.view.insertSubview(popupBackgroundFilterView, belowSubview: didYouBuyTheFlightQuestionPopover!)
//        self.popupBackgroundFilterView.isHidden = false
//        self.infoKeyButton_1.isHidden = true
//        self.infoKeyButton_2.isHidden = true
//        self.infoKeyButton_3.isHidden = true
//        self.popupBackgroundFilterViewCloseButton.isHidden = true
        let when = DispatchTime.now() + 0.6
        self.popupBackgroundFilterView.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: when) {
            UIView.animate(withDuration: 1) {
                self.popupBackgroundFilterView.alpha = 0.75
                self.didYouBuyTheFlightQuestionPopover!.frame = CGRect(x: 25, y: -40, width: 325, height: 240)
            }
        }
        
    }
    func flightBookingBrowserClosed_FlightBooked(){
        scrollView.isScrollEnabled = true
        self.flightResultsController?.navigationController?.popToRootViewController(animated: false)
        
        UIView.animate(withDuration: 1) {
            self.didYouBuyTheFlightQuestionPopover!.frame = CGRect(x: 25, y: -240, width: 325, height: 240)
            self.popupBackgroundFilterView.alpha = 0
        }
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.didYouBuyTheFlightQuestionPopover?.removeFromSuperview()
            self.didYouBuyTheFlightQuestionPopover = nil
            self.popupBackgroundFilterView.removeFromSuperview()
            self.popupBackgroundFilterView.isHidden = true
            
            self.spawnDoYouNeedARentalCarQuestionView()
        }
    }
    func flightBookingBrowserClosed_FlightNotBooked(){
        scrollView.isScrollEnabled = true
        self.flightResultsController?.navigationController?.popToRootViewController(animated: false)

        UIView.animate(withDuration: 1) {
            self.didYouBuyTheFlightQuestionPopover!.frame = CGRect(x: 25, y: -240, width: 325, height: 240)
            self.popupBackgroundFilterView.alpha = 0
        }
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.didYouBuyTheFlightQuestionPopover?.removeFromSuperview()
            self.didYouBuyTheFlightQuestionPopover = nil
            self.popupBackgroundFilterView.removeFromSuperview()
            self.popupBackgroundFilterView.isHidden = true
            self.spawnDoYouNeedARentalCarQuestionView()
        }
    }
    
    
    func hotelBookingBrowserClosed() {
        spawnDidYouBuyTheHotelQuestionPopover()
    }
    func spawnDidYouBuyTheHotelQuestionPopover (){
        animateInBackgroundFilterView(withInfoView: false, withBlurEffect: true, withCloseButton: false)
        didYouBuyTheHotelQuestionView = Bundle.main.loadNibNamed("DidYouBuyTheHotelQuestionView", owner: self, options: nil)?.first! as? DidYouBuyTheHotelQuestionView
        
        let bounds = UIScreen.main.bounds
        self.didYouBuyTheHotelQuestionView!.frame = CGRect(x: 25, y: -240, width: 325, height: 240)
        self.didYouBuyTheHotelQuestionView?.layer.cornerRadius = 7
        self.view.addSubview(didYouBuyTheHotelQuestionView!)
//        self.view.insertSubview(popupBackgroundFilterView, belowSubview: didYouBuyTheHotelQuestionView!)
//        self.popupBackgroundFilterView.isHidden = false
//        self.infoKeyButton_1.isHidden = true
//        self.infoKeyButton_2.isHidden = true
//        self.infoKeyButton_3.isHidden = true
//        self.popupBackgroundFilterViewCloseButton.isHidden = true
        let when = DispatchTime.now() + 0.6
        self.popupBackgroundFilterView.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: when) {
            UIView.animate(withDuration: 1) {
                self.popupBackgroundFilterView.alpha = 0.75
                self.didYouBuyTheHotelQuestionView!.frame = CGRect(x: 25, y: -40, width: 325, height: 240)
            }
        }
        
    }
    func hotelBookingBrowserClosed_HotelBooked(){
        scrollView.isScrollEnabled = true
        self.hotelResultsController?.navigationController?.popToRootViewController(animated: false)

        UIView.animate(withDuration: 1) {
            self.didYouBuyTheHotelQuestionView!.frame = CGRect(x: 25, y: -240, width: 325, height: 240)
            self.popupBackgroundFilterView.alpha = 0
        }
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.didYouBuyTheHotelQuestionView?.removeFromSuperview()
            self.didYouBuyTheHotelQuestionView = nil
            self.popupBackgroundFilterView.removeFromSuperview()
            self.popupBackgroundFilterView.isHidden = true
            self.spawnPlaceForGroupOrJustYouQuestionView()
        }
    }
    func hotelBookingBrowserClosed_HotelNotBooked(){
        scrollView.isScrollEnabled = true
        self.hotelResultsController?.navigationController?.popToRootViewController(animated: false)

        UIView.animate(withDuration: 1) {
            self.didYouBuyTheHotelQuestionView!.frame = CGRect(x: 25, y: -240, width: 325, height: 240)
            self.popupBackgroundFilterView.alpha = 0
        }
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.didYouBuyTheHotelQuestionView?.removeFromSuperview()
            self.didYouBuyTheHotelQuestionView = nil
            self.popupBackgroundFilterView.removeFromSuperview()
            self.popupBackgroundFilterView.isHidden = true
            self.planTravelAndPlaceToStayForAnotherDestinationOrSendProposalQuestionView()
        }
    }
    
    
    
    func back() {
        self.performSegue(withIdentifier: "tripVCtoTripListVC", sender: self)
    }
    func popFromFlightSearchResultsSceneViewControllerToFlightSearch() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "popFromFlightSearchResultsSceneViewControllerToFlightSearch"), object: nil)
        
    }
    func popFromWaitingScreenViewControllerToFlightSearch() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "popFromWaitingScreenViewControllerToFlightSearch"), object: nil)
    }
    func popFromTicketViewViewControllerToFlightResults() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "popFromTicketViewControllerToFlightResults"), object: nil)
    }
    
    //MARK: twicketsegmentedcontroldelegate
    func didSelect(_ segmentIndex: Int) {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let assistantMode = SavedPreferencesForTrip["assistantMode"] as! String
        if isAssistantEnabled {
            if segmentIndex == 0 {
                assistant()
            } else if segmentIndex == 1 {
                itinerary()
            } else if segmentIndex == 2 {
                chat()
            }
        } else {
            if segmentIndex == 0 {
                itinerary()
            } else if segmentIndex == 1 {
                chat()
            }
        }
    }
    
    func flightSearchResultsSceneViewController_ViewDidAppear() {
        
        self.backButton?.removeFromSuperview()
        backButton = nil
        let backButtonImage = #imageLiteral(resourceName: "backToSearch")
        backButton = UIButton(frame: CGRect(x: 10,y: 28,width: 80, height: 26))
        backButton?.setBackgroundImage(backButtonImage, for: .normal)
        backButton?.addTarget(self, action: #selector(popFromFlightSearchResultsSceneViewControllerToFlightSearch), for: UIControlEvents.touchUpInside)
        self.topView.addSubview(backButton!)
        
        self.segmentedControl?.isHidden = true
        self.searchSummaryLabelTopView.isHidden = false
        self.filterButton.isHidden = false
        self.sortButton.isHidden = true
        self.progressRing?.isHidden = true
    }
    func flightSearchFormViewViewController_ViewDidAppear() {
        addBackButtonPointedAtTripList()
        asyncUpdateProgress()
        
        self.segmentedControl?.isHidden = false
        self.searchSummaryLabelTopView.isHidden = true
        self.filterButton.isHidden = true
        self.sortButton.isHidden = true
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding" {
            self.progressRing?.isHidden = false
        } else {
            self.progressRing?.isHidden = true
        }
        
    }

    func flightSearchWaitingScreenViewController_ViewDidLoad() {
        //disable scrolling
        scrollView.isScrollEnabled = false
        
        self.backButton?.removeFromSuperview()
        backButton = nil
        let backButtonImage = #imageLiteral(resourceName: "backToSearch")
        backButton = UIButton(frame: CGRect(x: 10,y: 28,width: 80, height: 26))
        backButton?.setBackgroundImage(backButtonImage, for: .normal)
        backButton?.addTarget(self, action: #selector(popFromWaitingScreenViewControllerToFlightSearch), for: UIControlEvents.touchUpInside)
        self.topView.addSubview(backButton!)
        
        self.segmentedControl?.isHidden = true
        self.searchSummaryLabelTopView.isHidden = false
        self.filterButton.isHidden = true
        self.sortButton.isHidden = true
        self.progressRing?.isHidden = true
        
        //Create searchSummaryLabelTopView text
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        let numberDestinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String]).count

        let JRSDKSearchInfoAsData = SavedPreferencesForTrip["JRSDKSearchInfo"] as! Data
        let JRSDKSearchInfo = NSKeyedUnarchiver.unarchiveObject(with: JRSDKSearchInfoAsData) as? JRSDKSearchInfo
        let travelSegments = JRSDKSearchInfo?.travelSegments
        let firstLeg = travelSegments?[0] as! JRSDKTravelSegment
        let departureDate = firstLeg.departureDate
        formatter.dateFormat = "MM/dd"
        let departureDateAsString = formatter.string(from: departureDate as Date)

        let departureAirport = firstLeg.originAirport
        let arrivalAirport = firstLeg.destinationAirport
        
        let flightTicketsAccessoryMethodPerformer = FlightTicketsAccessoryMethodPerformer()
        
        if flightTicketsAccessoryMethodPerformer.fetchIsRoundtrip() {
            let secondLeg = travelSegments?[1] as! JRSDKTravelSegment
            let returnDate = secondLeg.departureDate
            let returnDateAsString = formatter.string(from: returnDate as Date)

            self.searchSummaryLabelTopView.text = "\((departureAirport.iata)) ⇄ \((arrivalAirport.iata))\n\(departureDateAsString) - \(returnDateAsString)"
        } else {
            self.searchSummaryLabelTopView.text = "\((departureAirport.iata)) → \((arrivalAirport.iata))\n\(departureDateAsString)"

        }
    }
    func flightTicketViewViewController_ViewDidLoad() {
        self.backButton?.removeFromSuperview()
        backButton = nil
        let backButtonImage = #imageLiteral(resourceName: "backToResults")
        backButton = UIButton(frame: CGRect(x: 10,y: 28,width: 83, height: 25))
        backButton?.setBackgroundImage(backButtonImage, for: .normal)
        backButton?.addTarget(self, action: #selector(popFromTicketViewViewControllerToFlightResults), for: UIControlEvents.touchUpInside)
        self.topView.addSubview(backButton!)
        
        self.filterButton.isHidden = true
        
    }
    func JRDatePicker_ViewDidLoad() {
        self.backButton?.removeFromSuperview()
        backButton = nil
        let backButtonImage = #imageLiteral(resourceName: "backButton")
        backButton = UIButton(frame: CGRect(x: 10,y: 33,width: 11, height: 14))
        backButton?.setBackgroundImage(backButtonImage, for: .normal)
        backButton?.addTarget(self, action: #selector(popFromJRDatePickerToFlightSearch), for: UIControlEvents.touchUpInside)
        self.topView.addSubview(backButton!)
    }
    func JRAirportPicker_ViewDidLoad() {
        self.backButton?.removeFromSuperview()
        backButton = nil
        let backButtonImage = #imageLiteral(resourceName: "backButton")
        backButton = UIButton(frame: CGRect(x: 10,y: 33,width: 11, height: 14))
        backButton?.setBackgroundImage(backButtonImage, for: .normal)
        backButton?.addTarget(self, action: #selector(popFromJRAirportPickerToFlightSearch), for: UIControlEvents.touchUpInside)
        self.topView.addSubview(backButton!)
    }
    func popFromJRDatePickerToFlightSearch() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "popFromJRDatePickerToFlightSearch"), object: nil)
        self.segmentedControl?.isHidden = false
        self.searchSummaryLabelTopView.isHidden = true
        self.filterButton.isHidden = true
        self.sortButton.isHidden = true
        self.hotelMapButton.isHidden = true
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding" {
            self.progressRing?.isHidden = false
        } else {
            self.progressRing?.isHidden = true
        }
        
    }
    func popFromJRAirportPickerToFlightSearch() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "popFromJRAirportPickerToFlightSearch"), object: nil)
        self.segmentedControl?.isHidden = false
        self.searchSummaryLabelTopView.isHidden = true
        self.filterButton.isHidden = true
        self.sortButton.isHidden = true
        self.hotelMapButton.isHidden = true
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding" {
            self.progressRing?.isHidden = false
        } else {
            self.progressRing?.isHidden = true
        }
    }
    func JRFilterVC_viewWillAppear() {
        self.filterButton?.isHidden = true
        
        self.backButton?.removeFromSuperview()
        backButton = nil
        backButton = UIButton(frame: CGRect(x: 5,y: 25,width: 50, height: 25))
        backButton?.setTitle("Done", for: .normal)
        backButton?.addTarget(self, action: #selector(popFromJRFilterToFlightResults), for: UIControlEvents.touchUpInside)
        self.topView.addSubview(backButton!)

    }
    func flightSearchResultsSceneViewController_doneButtonTouchedUpInside() {
        comeBackToPlanFlightLater()
    }
    func hotelSearchResultsViewController_doneButtonTouchedUpInside() {
        comeBackToPlanHotelLater()
    }
    func popFromJRFilterToFlightResults() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "popFromJRFilterToFlightResults"), object: nil)

        self.segmentedControl?.isHidden = true
        self.searchSummaryLabelTopView.isHidden = false
        self.filterButton.isHidden = false
        self.sortButton.isHidden = true
        self.hotelMapButton.isHidden = true
        self.progressRing?.isHidden = true
    }
    func addBackButtonPointedAtTripList() {
        self.filterButton.isHidden = true
        self.sortButton.isHidden = true
        self.hotelMapButton.isHidden = true

        
        if backButton != nil {
            self.backButton?.removeFromSuperview()
            backButton = nil
        }
        

        
        backButton = UIButton(frame: CGRect(x: 10,y: 28,width: 62, height: 25))
        backButton?.setBackgroundImage(#imageLiteral(resourceName: "backToTripsLeftFacingArrow"), for: .normal)
//        backButton?.setTitle("< Trips", for: .normal)
//        backButton?.setImage(#imageLiteral(resourceName: "backButton"), for: .normal)
//        backButton = UIButton(frame: CGRect(x: 10,y: 25,width: 60, height: 33))
//        backButton?.setImage(backButtonImage, for: .normal)
        backButton?.addTarget(self, action: #selector(back), for: UIControlEvents.touchUpInside)
        backButton?.setTitleColor(UIColor.white, for: .normal)
        
        self.topView.addSubview(backButton!)

    }
    func handleTwicketSegmentedControl() {
        if isAssistantEnabled {
            let segmentedControlTitles = ["Assistant","Itinerary","Chat"]
            segmentedControl?.setSegmentItems(segmentedControlTitles)
        } else {
            let segmentedControlTitles = ["Itinerary","Chat"]
            segmentedControl?.setSegmentItems(segmentedControlTitles)
        }
        segmentedControl?.backgroundColor = .clear // This is important!
    }
    func addTwicketSegmentedControl() {
        let segmentedControlTitles = ["Assistant","Itinerary","Chat"]
        segmentedControl = TwicketSegmentedControl(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 125 + 15, y: 20, width: 250, height: 40))
        segmentedControl?.setSegmentItems(segmentedControlTitles)
        segmentedControl?.delegate = self
        segmentedControl?.segmentsBackgroundColor = UIColor.clear
        segmentedControl?.isSliderShadowHidden = false
        segmentedControl?.backgroundColor = .clear // This is important!
        
        self.topView.addSubview(segmentedControl!)
    }
    func hotelSearchFormViewViewController_ViewDidAppear() {
        addBackButtonPointedAtTripList()
        asyncUpdateProgress()
        
        self.segmentedControl?.isHidden = false
        self.searchSummaryLabelTopView.isHidden = true
        self.filterButton.isHidden = true
        self.sortButton.isHidden = true
        self.hotelMapButton.isHidden = true
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding" {
            self.progressRing?.isHidden = false
        } else {
            self.progressRing?.isHidden = true
        }
    }
    func HLCommonResultsVC_viewWillAppear(){
        self.backButton?.removeFromSuperview()
        backButton = nil
        let backButtonImage = #imageLiteral(resourceName: "backButton")
        backButton = UIButton(frame: CGRect(x: 10,y: 33,width: 11, height: 14))
        backButton?.setBackgroundImage(backButtonImage, for: .normal)
        backButton?.addTarget(self, action: #selector(popFromHotelResultsViewControllerToHotelSearch), for: UIControlEvents.touchUpInside)
        self.topView.addSubview(backButton!)
        
        self.segmentedControl?.isHidden = true
        self.searchSummaryLabelTopView.isHidden = false
        self.filterButton.isHidden = false
        self.sortButton.isHidden = false
        self.hotelMapButton.isHidden = false
        self.progressRing?.isHidden = true
        
        //Create searchSummaryLabelTopView text
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let HDKSearchInfoAsData = SavedPreferencesForTrip["HDKSearchInfo"] as! Data
        let HDKSearchInfo = NSKeyedUnarchiver.unarchiveObject(with: HDKSearchInfoAsData) as? HDKSearchInfo
        let checkInDate = HDKSearchInfo?.checkInDate
        formatter.dateFormat = "MM/dd"
        let checkInDateAsString = formatter.string(from: checkInDate as! Date)
        let checkOutDate = HDKSearchInfo?.checkOutDate
        let checkOutDateAsString = formatter.string(from: checkOutDate as! Date)
        let city = HDKSearchInfo?.city
        let days = DateUtil.hl_daysBetweenDate(checkInDate, andOtherDate:checkOutDate)
        self.searchSummaryLabelTopView.text = "\((city?.name)!)\n\(checkInDateAsString) - \(checkOutDateAsString) (\(days) ☾)"
        
    }
    func hotelDetailsViewController_ViewDidAppear() {
        self.filterButton.isHidden = true
        self.sortButton.isHidden = true
        self.hotelMapButton.isHidden = true
    }
    func popFromHotelResultsViewControllerToHotelSearch(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "popFromHotelResultsViewControllerToHotelSearch"), object: nil)
        
        self.segmentedControl?.isHidden = false
        self.searchSummaryLabelTopView.isHidden = true
        self.filterButton.isHidden = true
        self.sortButton.isHidden = true
        self.hotelMapButton.isHidden = true
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding" {
            self.progressRing?.isHidden = false
        } else {
            self.progressRing?.isHidden = true
        }
    }
    func hotelSearchWaitingScreenViewController_ViewDidLoad() {
        //disable scrolling
        scrollView.isScrollEnabled = false
        
        self.backButton?.removeFromSuperview()
        backButton = nil
        let backButtonImage = #imageLiteral(resourceName: "backButton")
        backButton = UIButton(frame: CGRect(x: 10,y: 33,width: 11, height: 14))
        backButton?.setBackgroundImage(backButtonImage, for: .normal)
        backButton?.addTarget(self, action: #selector(popFromWaitingViewControllerToHotelSearch), for: UIControlEvents.touchUpInside)
        self.topView.addSubview(backButton!)
        
        self.segmentedControl?.isHidden = true
        self.searchSummaryLabelTopView.isHidden = false
        self.filterButton.isHidden = true
        self.sortButton.isHidden = true
        self.hotelMapButton.isHidden = true
        self.progressRing?.isHidden = true                    
        
        //Create searchSummaryLabelTopView text
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let HDKSearchInfoAsData = SavedPreferencesForTrip["HDKSearchInfo"] as! Data
        let HDKSearchInfo = NSKeyedUnarchiver.unarchiveObject(with: HDKSearchInfoAsData) as? HDKSearchInfo
        let checkInDate = HDKSearchInfo?.checkInDate
        formatter.dateFormat = "MM/dd"
        let checkInDateAsString = formatter.string(from: checkInDate as! Date)
        let checkOutDate = HDKSearchInfo?.checkOutDate
        let checkOutDateAsString = formatter.string(from: checkOutDate as! Date)
        let city = HDKSearchInfo?.city
        let days = DateUtil.hl_daysBetweenDate(checkInDate, andOtherDate:checkOutDate)
        self.searchSummaryLabelTopView.text = "\((city?.name)!)\n\(checkInDateAsString) - \(checkOutDateAsString) (\(days) ☾)"

    }
    func hotelSearchCityPicker_ViewDidLoad() {
        self.backButton?.removeFromSuperview()
        backButton = nil
        let backButtonImage = #imageLiteral(resourceName: "backButton")
        backButton = UIButton(frame: CGRect(x: 10,y: 33,width: 11, height: 14))
        backButton?.setBackgroundImage(backButtonImage, for: .normal)
        backButton?.addTarget(self, action: #selector(popFromCityPickerToHotelSearch), for: UIControlEvents.touchUpInside)
        self.topView.addSubview(backButton!)

    }
    func HLDatePicker_ViewDidLoad() {
        self.backButton?.removeFromSuperview()
        backButton = nil
        let backButtonImage = #imageLiteral(resourceName: "backButton")
        backButton = UIButton(frame: CGRect(x: 10,y: 33,width: 11, height: 14))
        backButton?.setBackgroundImage(backButtonImage, for: .normal)
        backButton?.addTarget(self, action: #selector(popFromHLDatePickerToHotelSearch), for: UIControlEvents.touchUpInside)
        self.topView.addSubview(backButton!)

    }
    func hotelSearchKidsPickerViewController_ViewDidLoad() {
        self.backButton?.removeFromSuperview()
        backButton = nil
        let backButtonImage = #imageLiteral(resourceName: "backButton")
        backButton = UIButton(frame: CGRect(x: 10,y: 33,width: 11, height: 14))
        backButton?.setBackgroundImage(backButtonImage, for: .normal)
        backButton?.addTarget(self, action: #selector(popFromKidsPickerToHotelSearch), for: UIControlEvents.touchUpInside)
        self.topView.addSubview(backButton!)

    }
    func HLFiltersVC_viewWillAppear() {
        self.segmentedControl?.isHidden = true
        self.searchSummaryLabelTopView.isHidden = false
        self.filterButton.isHidden = true
        self.sortButton.isHidden = true
        self.hotelMapButton.isHidden = true
    }
    func HLSortVC_viewWillAppear() {
        self.segmentedControl?.isHidden = true
        self.searchSummaryLabelTopView.isHidden = false
        self.filterButton.isHidden = true
        self.sortButton.isHidden = true
        self.hotelMapButton.isHidden = true
    }
    func HLMapVC_viewWillAppear() {
        self.segmentedControl?.isHidden = true
        self.searchSummaryLabelTopView.isHidden = false
        self.filterButton.isHidden = true
        self.sortButton.isHidden = true
        self.hotelMapButton.isHidden = true
        
        self.backButton?.removeFromSuperview()
        backButton = nil
        let backButtonImage = #imageLiteral(resourceName: "backButton")
        backButton = UIButton(frame: CGRect(x: 10,y: 33,width: 11, height: 14))
        backButton?.setBackgroundImage(backButtonImage, for: .normal)
        backButton?.addTarget(self, action: #selector(popFromMapVCToHotelSearch), for: UIControlEvents.touchUpInside)
        self.topView.addSubview(backButton!)
    }
    func popFromMapVCToHotelSearch() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "popFromMapVCToHotelSearch"), object: nil)
    }
    

    func popFromWaitingViewControllerToHotelSearch() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "popFromWaitingScreenViewControllerToHotelSearch"), object: nil)
        
        self.segmentedControl?.isHidden = false
        self.searchSummaryLabelTopView.isHidden = true
        self.filterButton.isHidden = true
        self.sortButton.isHidden = true
        self.hotelMapButton.isHidden = true
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if SavedPreferencesForTrip["assistantMode"] as! String == "initialItineraryBuilding" {
            self.progressRing?.isHidden = false
        } else {
            self.progressRing?.isHidden = true
        }
    }
    func popFromCityPickerToHotelSearch() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "popFromCityPickerToHotelSearch"), object: nil)
    }
    func popFromHLDatePickerToHotelSearch() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "popFromHLDatePickerToHotelSearch"), object: nil)
    }
    func popFromKidsPickerToHotelSearch() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "popFromKidsPickerToHotelSearch"), object: nil)
    }

//    func addBackButtonPointedAtItineraryFromHotelDetails() {
//        if backButton != nil {
//            self.backButton?.removeFromSuperview()
//            backButton = nil
//        }
//        let backButtonImage = #imageLiteral(resourceName: "backButton")
//        backButton = UIButton(frame: CGRect(x: 5,y: 25,width: 28, height: 25))
//        backButton?.setBackgroundImage(backButtonImage, for: .normal)
//        backButton?.addTarget(self, action: #selector(bookedHotelDetailsBackToItinerary), for: UIControlEvents.touchUpInside)
//        self.topView.addSubview(backButton!)
//    }
    func bookedHotelDetailsBackToItinerary() {
        for subview in itineraryView.subviews {
            subview.isHidden = false
        }
        
        self.willMove(toParentViewController: nil)
        hotelBookedOnPlanitController?.view.removeFromSuperview()
        hotelBookedOnPlanitController?.removeFromParentViewController()
        hotelBookedOnPlanitController = nil
        
        self.doneButton?.removeFromSuperview()
        doneButton = nil
        
        animateOutBackgroundFilterView()
        
//        addBackButtonPointedAtTripList()
    }
    func bookedFlightDetailsBackToItinerary() {
        for subview in itineraryView.subviews {
            subview.isHidden = false
        }
        
        self.willMove(toParentViewController: nil)
        flightBookedOnPlanitController?.view.removeFromSuperview()
        flightBookedOnPlanitController?.removeFromParentViewController()
        flightBookedOnPlanitController = nil
        
        self.doneButton?.removeFromSuperview()
        doneButton = nil
        
        animateOutBackgroundFilterView()
        
        //        addBackButtonPointedAtTripList()

    }
}

//MARK: custom functions for itinerary
extension TripViewController {
    
    func setUpItinerary() {
        handleAddInviteesButton()
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        
        //MARK: Itinerary viewDidLoad
        self.tripNameTextField.delegate = self
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        //Install the value into the label.
        if tripNameValue != nil {
            self.tripNameTextField.text =  "\(tripNameValue!)"
        }
        let bounds = UIScreen.main.bounds
        tripNameTextField.adjustsFontSizeToFitWidth = true
        tripNameTextField.minimumFontSize = 10
        tripNameTextField?.frame.size.height = 50
        tripNameTextField?.frame.size.width = bounds.width - 40
        tripNameTextField?.frame.origin.x = (bounds.size.width - (tripNameTextField?.frame.width)!) / 2
        tripNameTextField?.frame.origin.y = 0
        tripNameTextField?.rightView?.tintColor = UIColor.white
        tripNameTextField.setBottomBorder(borderColor: UIColor.white)
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gestureReconizer:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        contactsCollectionView.dataSource = self
        contactsCollectionView.delegate = self
        self.contactsCollectionView.addGestureRecognizer(lpgr)
        //
        let lpgrItinerary = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressItinerary(gestureReconizer:)))
        lpgrItinerary.minimumPressDuration = 0.5
        lpgrItinerary.delaysTouchesBegan = true
        lpgrItinerary.delegate = self
        self.destinationsDatesCollectionView.addGestureRecognizer(lpgrItinerary)
        //
        let tapDeadSpaceInItineraryCollectionView = UITapGestureRecognizer(target: self, action: #selector(self.dismissEditItineraryMode))
        tapDeadSpaceInItineraryCollectionView.numberOfTapsRequired = 1
        tapDeadSpaceInItineraryCollectionView.delegate = self
        self.popupBackgroundViewEditItineraryWithinCollectionView.addGestureRecognizer(tapDeadSpaceInItineraryCollectionView)
        popupBackgroundViewEditItineraryWithinCollectionView.isHidden = true
        popupBackgroundViewEditItineraryWithinCollectionView.isUserInteractionEnabled = true

        //
        let tapOutsideContacts = UITapGestureRecognizer(target: self, action: #selector(self.dismissDeleteContactsMode))
        tapOutsideContacts.numberOfTapsRequired = 1
        tapOutsideContacts.delegate = self
        self.popupBackgroundViewDeleteContacts.addGestureRecognizer(tapOutsideContacts)
        popupBackgroundViewDeleteContacts.isHidden = true
        popupBackgroundViewDeleteContacts.isUserInteractionEnabled = true
        //
        let tapOutsideContact = UITapGestureRecognizer(target: self, action: #selector(self.dismissDeleteContactsMode))
        tapOutsideContact.numberOfTapsRequired = 1
        tapOutsideContact.delegate = self
        self.popupBackgroundViewDeleteContactsWithinCollectionView.addGestureRecognizer(tapOutsideContact)
        popupBackgroundViewDeleteContactsWithinCollectionView.isHidden = true
        popupBackgroundViewDeleteContactsWithinCollectionView.isUserInteractionEnabled = true
        if SavedPreferencesForTrip["isInitiator"] as! Int == 0 {
            itineraryButton1?.setTitle("I'm in and ready to book", for: .normal)
            itineraryButton2?.setTitle("I'd be in if we changed...", for: .normal)
            itineraryButton3?.setTitle("I'm out", for: .normal)
            itineraryButton1?.isHidden = false
            itineraryButton2?.isHidden = false
            itineraryButton3?.isHidden = false
        } else if SavedPreferencesForTrip["isInitiator"] as! Int == 1 {
            itineraryButton1?.setTitle("I'm ready to book!", for: .normal)
            itineraryButton2?.setBackgroundImage(#imageLiteral(resourceName: "paperPlaneIcon"), for: .normal)
            itineraryButton1?.isHidden = false
            itineraryButton2?.isHidden = true
            itineraryButton3?.isHidden = true
        }
        itineraryButton1?.setTitleColor(UIColor.white, for: .normal)
        itineraryButton1?.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        itineraryButton1?.setBackgroundColor(color: UIColor.white.withAlphaComponent(0.25), forState: .normal)
        itineraryButton1?.layer.borderWidth = 1
        itineraryButton1?.layer.borderColor = UIColor.white.cgColor
        itineraryButton1?.layer.masksToBounds = true
        itineraryButton1?.titleLabel?.numberOfLines = 0
        itineraryButton1?.titleLabel?.textAlignment = .center
        itineraryButton1?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        itineraryButton1?.sizeToFit()
        itineraryButton1?.frame.size.height = 30
        itineraryButton1?.frame.size.width += 20
        itineraryButton1?.frame.origin.x = (bounds.size.width - (itineraryButton1?.frame.width)!) / 2
        itineraryButton1?.frame.origin.y = 492
        itineraryButton1?.layer.cornerRadius = (itineraryButton1?.frame.height)! / 2
        
        
        itineraryButton2 = UIButton(type: .custom)
        itineraryButton2?.frame = CGRect.zero
//        itineraryButton2?.setTitleColor(UIColor.white, for: .normal)
//        itineraryButton2?.setBackgroundColor(color: UIColor.clear, forState: .normal)
//        itineraryButton2?.layer.borderWidth = 1
//        itineraryButton2?.layer.borderColor = UIColor.white.cgColor
//        itineraryButton2?.layer.masksToBounds = true
        itineraryButton2?.titleLabel?.numberOfLines = 0
        itineraryButton2?.titleLabel?.textAlignment = .center
//        itineraryButton2?.setTitle("Send itinerary", for: .normal)
        itineraryButton2?.setBackgroundImage(#imageLiteral(resourceName: "paperPlaneIcon"), for: .normal)
//        itineraryButton2?.translatesAutoresizingMaskIntoConstraints = false
        itineraryButton2?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.itineraryView.addSubview(itineraryButton2!)
        itineraryButton2?.frame.size.height = 45
        itineraryButton2?.frame.size.width = 45
        itineraryButton2?.frame.origin.x = 255
        itineraryButton2?.frame.origin.y = 118
        itineraryButton2?.layer.cornerRadius = (itineraryButton2?.frame.height)! / 2

        
//        itineraryButton2?.setTitleColor(UIColor.white, for: .normal)
//        itineraryButton2?.titleLabel?.font = UIFont.systemFont(ofSize: 18)
//        itineraryButton2?.setBackgroundColor(color: UIColor.clear, forState: .normal)
//        itineraryButton2?.setBackgroundColor(color: UIColor.clear, forState: .selected)
//        itineraryButton2?.setBackgroundColor(color: UIColor.clear, forState: .highlighted)
//        itineraryButton2?.layer.borderWidth = 1
//        itineraryButton2?.layer.borderColor = UIColor.white.cgColor
//        itineraryButton2?.layer.masksToBounds = true
//        itineraryButton2?.titleLabel?.numberOfLines = 0
//        itineraryButton2?.titleLabel?.textAlignment = .center
//        itineraryButton2?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
//        itineraryButton2?.sizeToFit()
//        itineraryButton2?.frame.size.height = 30
//        itineraryButton2?.frame.size.width += 20
//        itineraryButton2?.frame.origin.x = 225
//        itineraryButton2?.frame.origin.y = 128
//        itineraryButton2?.layer.cornerRadius = (itineraryButton2?.frame.height)! / 2
        
        itineraryButton3?.setTitleColor(UIColor.white, for: .normal)
        itineraryButton3?.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        itineraryButton3?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        itineraryButton3?.layer.borderWidth = 1
        itineraryButton3?.layer.borderColor = UIColor.white.cgColor
        itineraryButton3?.layer.masksToBounds = true
        itineraryButton3?.titleLabel?.numberOfLines = 0
        itineraryButton3?.titleLabel?.textAlignment = .center
        itineraryButton3?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        itineraryButton3?.sizeToFit()
        itineraryButton3?.frame.size.height = 30
        itineraryButton3?.frame.size.width += 20
        itineraryButton3?.frame.origin.x = (bounds.size.width - (itineraryButton3?.frame.width)!) / 2
        itineraryButton3?.frame.origin.y = (itineraryButton2?.frame.origin.y)! + 35
        itineraryButton3?.layer.cornerRadius = (itineraryButton3?.frame.height)! / 2
        //if SavedPreferencesForTrip["isInitiator"] as! Int == 0 {
        //    itineraryButton2?.frame.origin.y = itineraryButton1.frame.origin.y + 35
        //} else if SavedPreferencesForTrip["isInitiator"] as! Int == 1 {
          //  itineraryButton2?.frame.origin.y = itineraryButton1.frame.origin.y + 55
        //}
        destinationsDatesCollectionView.dataSource = self
        destinationsDatesCollectionView.delegate = self
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        destinationsDatesCollectionView.collectionViewLayout = layout
        //        travelButton.layer.cornerRadius = travelButton.frame.size.height / 2
        //        travelButton.backgroundColor = travelItem?.buttonColor
        //        travelButton.imageEdgeInsets = UIEdgeInsetsMake(10,10,10,10)
        //        travelButton.layer.shadowColor = UIColor.black.cgColor
        //        travelButton.layer.shadowRadius = 1
        //        travelButton.layer.masksToBounds = false
        //        travelButton.layer.shadowOpacity = 0.4
        //        travelButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        //        placeToStayButton.layer.cornerRadius = placeToStayButton.frame.size.height / 2
        //        placeToStayButton.backgroundColor = placeToStayItem?.buttonColor
        //        placeToStayButton.imageEdgeInsets = UIEdgeInsetsMake(10,10,10,10)
        //        placeToStayButton.layer.shadowColor = UIColor.black.cgColor
        //        placeToStayButton.layer.shadowRadius = 1
        //        placeToStayButton.layer.masksToBounds = false
        //        placeToStayButton.layer.shadowOpacity = 0.4
        //        placeToStayButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        //END ITINERARY viewDidLoad
    }
    
    func setupItineraryInfoView() {
//        //incomplete item
//        infoKeyButton_2.layer.cornerRadius = (infoKeyButton_2.frame.height) / 2
//        infoKeyButton_2.addDashedBorder(lineWidth: 2, lineColor: incompleteColor, height:infoKeyButton_2.frame.height)
//        infoKeyButton_2.setTitleColor(incompleteColor, for: .normal)
        
        //item requires action by you
        infoKeyButton_3.layer.cornerRadius = (infoKeyButton_3.frame.height) / 2
        infoKeyButton_3.layer.borderWidth = 2
        infoKeyButton_3.layer.borderColor = completeColor.cgColor
        infoKeyButton_3.setTitleColor(completeColor, for: .normal)
        //badge button
        infoKeyButton_3_badgeButton = MIBadgeButton()
        infoKeyButton_3_badgeButton?.layer.frame.origin = CGPoint(x: infoKeyButton_3.layer.frame.maxX - 5, y: infoKeyButton_3.layer.frame.minY + 1)
        infoKeyButton_3_badgeButton?.badgeString = "!"
        infoKeyButton_3_badgeButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        infoKeyButton_3_badgeButton?.badgeTextColor = UIColor.white
        infoKeyButton_3_badgeButton?.badgeBackgroundColor = UIColor.red
        self.popupBackgroundFilterView.insertSubview(infoKeyButton_3_badgeButton!, aboveSubview: infoKeyButton_3!)
        
        
        //item requires action by group
        infoKeyButton_4.layer.cornerRadius = (infoKeyButton_4.frame.height) / 2
        infoKeyButton_4.layer.borderWidth = 2
        infoKeyButton_4.layer.borderColor = completeColor.cgColor
        infoKeyButton_4.setTitleColor(completeColor, for: .normal)
        //badge button
        infoKeyButton_4_badgeButton = MIBadgeButton()
        infoKeyButton_4_badgeButton?.layer.frame.origin = CGPoint(x: infoKeyButton_4.layer.frame.maxX - 5, y: infoKeyButton_4.layer.frame.minY + 1)
        infoKeyButton_4_badgeButton?.badgeString = "!"
        infoKeyButton_4_badgeButton?.badgeTextColor = UIColor.white
        infoKeyButton_4_badgeButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        infoKeyButton_4_badgeButton?.badgeBackgroundColor = UIColor.orange
        self.popupBackgroundFilterView.insertSubview(infoKeyButton_4_badgeButton!, aboveSubview: infoKeyButton_4!)
        
        //item complete
        infoKeyButton_5.layer.cornerRadius = (infoKeyButton_5.frame.height) / 2
        infoKeyButton_5.layer.borderWidth = 2
        infoKeyButton_5.layer.borderColor = completeColor.cgColor
        infoKeyButton_5.setTitleColor(completeColor, for: .normal)
        //badge button
        infoKeyButton_5_badgeButton = MIBadgeButton()
        infoKeyButton_5_badgeButton?.layer.frame.origin = CGPoint(x: infoKeyButton_5.layer.frame.maxX - 5, y: infoKeyButton_5.layer.frame.minY + 1)
        infoKeyButton_5_badgeButton?.badgeString = "✓"
        infoKeyButton_5_badgeButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        infoKeyButton_5_badgeButton?.badgeTextColor = UIColor.white
        infoKeyButton_5_badgeButton?.badgeBackgroundColor = UIColor(red: 0, green: 149/255, blue: 0, alpha: 1)
        self.popupBackgroundFilterView.insertSubview(infoKeyButton_5_badgeButton!, aboveSubview: infoKeyButton_5!)
    }
    
    func showFinishPlanningTripAlert(title: String, message: String, okButtonTitle: String, cancelButtonTitle: String){
        //Finish planning trip first
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
        }
        let okAction = UIAlertAction(title: okButtonTitle, style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.isAssistantEnabled = true
            self.handleTwicketSegmentedControl()
            self.segmentedControl?.move(to: 0)
            self.assistant()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func placeToStayButtonTouchedUpInside(sender:UIButton) {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let assistantMode = SavedPreferencesForTrip["assistantMode"] as! String
        let bounds = UIScreen.main.bounds
        
        //Go back to assistant where user left off if still building itinerary
        if isAssistantEnabled == true && assistantMode == "initialItineraryBuilding" {
            showFinishPlanningTripAlert(title: "Almost there...", message: "Let's finish building your itinerary!", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        } else if assistantMode == "travel" {
            showFinishPlanningTripAlert(title: "Let's finish changing your travel first!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        } else if assistantMode == "dates" {
            showFinishPlanningTripAlert(title: "Let's finish updating your dates first!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        } else if assistantMode == "destination" {
            showFinishPlanningTripAlert(title: "Let's finish updating your destination first!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        } else if assistantMode == "startingPoint" {
            showFinishPlanningTripAlert(title: "Let's finish updating your starting point first!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        } else if assistantMode == "endingPoint" {
            showFinishPlanningTripAlert(title: "Let's finish updating your ending point first!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        }
        //
        if editItineraryModeEnabled {
//            let initiatorProgress = checkInitiatorProgress()
            
            //Edit place to stay
            if assistantMode == "disabled" {
                let alertController = UIAlertController(title: "Change place to stay?", message: "Are you sure you want to change your place to stay?", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
                }
                let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    SavedPreferencesForTrip["assistantMode"] = "placeToStay" as NSString
                    SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = sender.tag - 1
                    self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                    
                    self.spawnDoYouKnowWhereYouWillBeStayingQuestionView()
                    
                    self.isAssistantEnabled = true
                    self.handleTwicketSegmentedControl()
                    self.segmentedControl?.move(to: 0)
                    self.assistant()
                }
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else if assistantMode == "placeToStay" {
                showFinishPlanningTripAlert(title: "Let's finish changing your place to stay!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            }
        } else if !editItineraryModeEnabled {
            if assistantMode == "placeToStay" {
                showFinishPlanningTripAlert(title: "Let's finish changing your place to stay!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            }
            if sender.tag <= (SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]]).count  {
                var placeToStayDictionaryArray = SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]]
                if placeToStayDictionaryArray[sender.tag - 1]["typeOfPlaceToStay"] as! String == "hotel" {
                    if (SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]])[sender.tag - 1]["placeToStayBookedOnPlanit"] != nil {
                        //TRAVELPAYOUTS
                        for subview in itineraryView.subviews {
                            subview.isHidden = true
                        }
                        
                        let variantAsData = (SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]])[sender.tag - 1]["placeToStayBookedOnPlanit"] as! Data
                        let variant = NSKeyedUnarchiver.unarchiveObject(with: variantAsData) as? HLResultVariant
                        let filter = Filter()
                        
                        let decorator = HLHotelDetailsDecorator(variant: variant, photoIndex: 0, photoIndexUpdater: nil, filter: filter)
                        hotelBookedOnPlanitController = JRNavigationController(rootViewController: decorator.detailsVC)
                        hotelBookedOnPlanitController?.isNavigationBarHidden = true
                        hotelBookedOnPlanitController?.willMove(toParentViewController: self)
                        self.addChildViewController(hotelBookedOnPlanitController!)
                        hotelBookedOnPlanitController?.loadView()
                        hotelBookedOnPlanitController?.viewDidLoad()
                        
                        animateInBackgroundFilterView(withInfoView: false, withBlurEffect: true, withCloseButton: false)
                        let bounds = UIScreen.main.bounds
                        setupDetailedInformationView(size: CGSize(width: bounds.width-6, height: 650), withTextView:false,withDoneButton:false)
                        button1?.frame.origin.y = 610
                        self.detailedInformationSubview.addSubview((hotelBookedOnPlanitController?.view)!)
                        hotelBookedOnPlanitController?.view.frame = CGRect(x: 10, y: 100, width: bounds.width-20, height: bounds.height - 150)
                        hotelBookedOnPlanitController?.view.layer.cornerRadius = 5
                        self.popupBackgroundFilterView?.addSubview((hotelBookedOnPlanitController?.view)!)
                        hotelBookedOnPlanitController?.didMove(toParentViewController: self)
                        
                        doneButton = UIButton(type: .custom)
                        doneButton?.frame = CGRect.zero
                        doneButton?.setTitleColor(UIColor.white, for: .normal)
                        doneButton?.setBackgroundColor(color: UIColor.clear, forState: .normal)
                        doneButton?.layer.borderWidth = 1
                        doneButton?.layer.borderColor = UIColor.white.cgColor
                        doneButton?.titleLabel?.numberOfLines = 0
                        doneButton?.titleLabel?.textAlignment = .center
                        doneButton?.setTitle("Done", for: .normal)
                        doneButton?.addTarget(self, action: #selector(bookedHotelDetailsBackToItinerary), for: UIControlEvents.touchUpInside)
                        popupBackgroundFilterView.addSubview(doneButton!)
                        doneButton?.sizeToFit()
                        doneButton?.frame.size.height = 30
                        doneButton?.frame.size.width += 20
                        doneButton?.frame.origin.x = ((bounds.width) - (doneButton?.frame.width)!) / 2 - itineraryView.frame.minX
                        doneButton?.frame.origin.y = 600
                        doneButton?.layer.cornerRadius = (doneButton?.frame.height)! / 2
                        
                    } else if (SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]])[sender.tag - 1]["hotelsSavedOnPlanit"] != nil {
                        let alertController = UIAlertController(title: "Choose a place to stay!", message: "See how your favorites stack up in the refreshed results.", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
                        }
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                            
                            //SHOW SAVED HOTELS in Assistant
                            SavedPreferencesForTrip["assistantMode"] = "placeToStay" as! NSString
                            SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = sender.tag - 1
                            self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                            
                            self.spawnHotelSearchQuestionView()
                            
                            self.isAssistantEnabled = true
                            self.handleTwicketSegmentedControl()
                            self.segmentedControl?.move(to: 0)
                            self.assistant()
                            
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "searchSpawnedFromItinerary"), object: nil)

                            
                            
                            
                        }
                        alertController.addAction(cancelAction)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        let alertController = UIAlertController(title: "Check out hotels!", message: "", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
                        }
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                            //No hotel booked, no saved hotels, should hotel search in Assistant
                            SavedPreferencesForTrip["assistantMode"] = "placeToStay" as! NSString
                            SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = sender.tag - 1
                            self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                            
                            self.spawnHotelSearchQuestionView()
                            
                            self.isAssistantEnabled = true
                            self.handleTwicketSegmentedControl()
                            self.segmentedControl?.move(to: 0)
                            self.assistant()
                        }
                        alertController.addAction(cancelAction)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                } else if placeToStayDictionaryArray[sender.tag - 1]["typeOfPlaceToStay"] as! String == "hotelText"{
                    if (SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]])[sender.tag - 1]["hotelText"] != nil {
                        detailedInformationSubviewMode = "hotel"
                        //Show texted entered
                        animateInBackgroundFilterView(withInfoView: false, withBlurEffect: true, withCloseButton: false)
                        setupDetailedInformationView(size: CGSize(width: 250, height: 350), withTextView:true,withDoneButton:true)
                        textView?.text = placeToStayDictionaryArray[sender.tag - 1]["hotelText"] as! String
                        var topCorrect: CGFloat? = (textView?.bounds.size.height)! - (textView?.contentSize.height)!
                        topCorrect = (topCorrect! < CGFloat(0.0) ? 0.0 : topCorrect)
                        textView?.contentOffset = CGPoint()
                        textView?.contentOffset.x = 0
                        textView?.contentOffset.y = -topCorrect!
                        textView?.resignFirstResponder()
                        self.view.addSubview(detailedInformationSubview)
                    }
                }
                else if placeToStayDictionaryArray[sender.tag - 1]["typeOfPlaceToStay"] as! String == "shortTermRental"{
                    detailedInformationSubviewMode = "shortTermRental"
                    //Show texted entered, with clickable links
                    animateInBackgroundFilterView(withInfoView: false, withBlurEffect: true, withCloseButton: false)
                    setupDetailedInformationView(size: CGSize(width: 250, height: 350), withTextView:true,withDoneButton:true)
                    textView?.text = placeToStayDictionaryArray[sender.tag - 1]["shortTermRentalText"] as! String
                    var topCorrect: CGFloat? = (textView?.bounds.size.height)! - (textView?.contentSize.height)!
                    topCorrect = (topCorrect! < CGFloat(0.0) ? 0.0 : topCorrect)
                    textView?.contentOffset = CGPoint()
                    textView?.contentOffset.x = 0
                    textView?.contentOffset.y = -topCorrect!
                    textView?.resignFirstResponder()
                    self.view.addSubview(detailedInformationSubview)
                    
                } else if placeToStayDictionaryArray[sender.tag - 1]["typeOfPlaceToStay"] as! String == "stayWithSomeoneIKnow"{
                    detailedInformationSubviewMode = "stayWithSomeoneIKnow"
                    //Show texted entered
                    animateInBackgroundFilterView(withInfoView: false, withBlurEffect: true, withCloseButton: false)
                    setupDetailedInformationView(size: CGSize(width: 250, height: 350), withTextView:true,withDoneButton:true)
                    textView?.text = placeToStayDictionaryArray[sender.tag - 1]["stayWithSomeoneIKnowText"] as! String
                    var topCorrect: CGFloat? = (textView?.bounds.size.height)! - (textView?.contentSize.height)!
                    topCorrect = (topCorrect! < CGFloat(0.0) ? 0.0 : topCorrect)
                    textView?.contentOffset = CGPoint()
                    textView?.contentOffset.x = 0
                    textView?.contentOffset.y = -topCorrect!
                    textView?.resignFirstResponder()
                    self.view.addSubview(detailedInformationSubview)
                } else {
                    showFinishPlanningTripAlert(title: "Almost there...", message: "Let's finish building your itinerary!", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
                }
            } else if assistantMode == "disabled" {
                let alertController = UIAlertController(title: "Plan a place to stay!", message: "", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
                }
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    SavedPreferencesForTrip["assistantMode"] = "placeToStay" as NSString
                    SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = sender.tag - 1
                    self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                    
                    self.spawnDoYouKnowWhereYouWillBeStayingQuestionView()
                    
                    self.isAssistantEnabled = true
                    self.handleTwicketSegmentedControl()
                    self.segmentedControl?.move(to: 0)
                    self.assistant()
                }
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    func travelButtonTouchedUpInside(sender:UIButton) {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])

        var isRoundtripTravelPlanned = false
        if destinationsForTrip.count > 0 {
            for i in 0 ... destinationsForTrip.count - 1 {
                var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
                if travelDictionaryArray[i]["isRoundtrip"] as! Bool != nil {
                    if travelDictionaryArray[i]["isRoundtrip"] as! Bool == true {
                        isRoundtripTravelPlanned = true
                    }
                }
            }
        }
        
        
        let assistantMode = SavedPreferencesForTrip["assistantMode"] as! String
//        let bounds = UIScreen.main.bounds
        
        //Go back to assistant where user left off if still building itinerary
        if isAssistantEnabled == true && assistantMode == "initialItineraryBuilding" {
            showFinishPlanningTripAlert(title: "Almost there...", message: "Let's finish building your itinerary!", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        } else if assistantMode == "placeToStay" {
            showFinishPlanningTripAlert(title: "Let's finish changing your place to stay!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        } else if assistantMode == "dates" {
            showFinishPlanningTripAlert(title: "Let's finish updating your dates first!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        } else if assistantMode == "destination" {
            showFinishPlanningTripAlert(title: "Let's finish updating your destination first!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        } else if assistantMode == "startingPoint" {
            showFinishPlanningTripAlert(title: "Let's finish updating your starting point first!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        } else if assistantMode == "endingPoint" {
            showFinishPlanningTripAlert(title: "Let's finish updating your ending point first!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        }
        //
        if editItineraryModeEnabled {
//            let initiatorProgress = checkInitiatorProgress()
            
            //Edit travel plan
            if assistantMode == "disabled" {
                let alertController = UIAlertController(title: "Change travel?", message: "Are you sure you want to change your travel?", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
                }
                let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    SavedPreferencesForTrip["assistantMode"] = "travel" as NSString
                    SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = sender.tag - 1
                    self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                    
                    self.spawnHowDoYouWantToGetThereQuestionView()
                    
                    self.isAssistantEnabled = true
                    self.handleTwicketSegmentedControl()
                    self.segmentedControl?.move(to: 0)
                    self.assistant()
                }
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else if assistantMode == "travel" {
                showFinishPlanningTripAlert(title: "Let's finish changing your travel!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            }
        } else if !editItineraryModeEnabled {
            if assistantMode == "travel" {
                showFinishPlanningTripAlert(title: "Let's finish changing your travel!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            }
            if sender.tag == (SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]).count && isRoundtripTravelPlanned {
                detailedInformationSubviewMode = "roundTripTravelComments"
                //Show text entered
                animateInBackgroundFilterView(withInfoView: false, withBlurEffect: true, withCloseButton: false)
                setupDetailedInformationView(size: CGSize(width: 250, height: 350), withTextView:true,withDoneButton:true)
                textView?.text = "Roundtrip travel planned - see other travel segments for details."
                var topCorrect: CGFloat? = (textView?.bounds.size.height)! - (textView?.contentSize.height)!
                topCorrect = (topCorrect! < CGFloat(0.0) ? 0.0 : topCorrect)
                textView?.contentOffset = CGPoint()
                textView?.contentOffset.x = 0
                textView?.contentOffset.y = -topCorrect!
                textView?.resignFirstResponder()
                self.view.addSubview(detailedInformationSubview)

            }
            if sender.tag <= (SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]).count  {
                var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
                if travelDictionaryArray[sender.tag - 1]["modeOfTransportation"] as! String == "fly" {
                    if (SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]])[sender.tag - 1]["flightBookedOnPlanit"] != nil {
                        //TRAVELPAYOUTS
                        for subview in itineraryView.subviews {
                            subview.isHidden = true
                        }
                        
                        let ticketAsData = (SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]])[sender.tag - 1]["flightBookedOnPlanit"] as! Data
                        let ticket = NSKeyedUnarchiver.unarchiveObject(with: ticketAsData) as? JRSDKTicket
//                        let ticketVC = JRTicketVC(searchInfo: searchInfo, search: response.searchResultInfo.searchID)
                        let ticketVC = JRTicketVC(searchInfo: (ticket?.searchResultInfo.searchInfo)!, searchID: (ticket?.searchResultInfo.searchID)!)
                        ticketVC?.setTicket(ticket)
                        
                        flightBookedOnPlanitController = JRNavigationController(rootViewController: ticketVC!)
                        flightBookedOnPlanitController?.isNavigationBarHidden = true
                        flightBookedOnPlanitController?.willMove(toParentViewController: self)
                        self.addChildViewController(flightBookedOnPlanitController!)
                        flightBookedOnPlanitController?.loadView()
                        flightBookedOnPlanitController?.viewDidLoad()
                        
                        animateInBackgroundFilterView(withInfoView: false, withBlurEffect: true, withCloseButton: false)
                        let bounds = UIScreen.main.bounds
                        setupDetailedInformationView(size: CGSize(width: bounds.width-6, height: 650), withTextView:false,withDoneButton:false)
                        button1?.frame.origin.y = 610
                        self.detailedInformationSubview.addSubview((flightBookedOnPlanitController?.view)!)
                        flightBookedOnPlanitController?.view.frame = CGRect(x: 10, y: 100, width: bounds.width-20, height: bounds.height - 150)
                        flightBookedOnPlanitController?.view.layer.cornerRadius = 5
                        self.popupBackgroundFilterView?.addSubview((flightBookedOnPlanitController?.view)!)
                        flightBookedOnPlanitController?.didMove(toParentViewController: self)
                        
                        doneButton = UIButton(type: .custom)
                        doneButton?.frame = CGRect.zero
                        doneButton?.setTitleColor(UIColor.white, for: .normal)
                        doneButton?.setBackgroundColor(color: UIColor.clear, forState: .normal)
                        doneButton?.layer.borderWidth = 1
                        doneButton?.layer.borderColor = UIColor.white.cgColor
                        doneButton?.titleLabel?.numberOfLines = 0
                        doneButton?.titleLabel?.textAlignment = .center
                        doneButton?.setTitle("Done", for: .normal)
                        doneButton?.addTarget(self, action: #selector(bookedFlightDetailsBackToItinerary), for: UIControlEvents.touchUpInside)
                        popupBackgroundFilterView.addSubview(doneButton!)
                        doneButton?.sizeToFit()
                        doneButton?.frame.size.height = 30
                        doneButton?.frame.size.width += 20
                        doneButton?.frame.origin.x = ((bounds.width) - (doneButton?.frame.width)!) / 2 - itineraryView.frame.minX
                        doneButton?.frame.origin.y = 600
                        doneButton?.layer.cornerRadius = (doneButton?.frame.height)! / 2
                        
                    } else if (SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]])[sender.tag - 1]["flightsSavedOnPlanit"] != nil {
                        let alertController = UIAlertController(title: "Choose a flight!", message: "Search and see how your favorites stack up in the refreshed results.", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
                        }
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                            
                            //SHOW SAVED Flights in Assistant
                            SavedPreferencesForTrip["assistantMode"] = "travel" as! NSString
                            SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = sender.tag - 1
                            self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                            
                            self.spawnFlightSearchQuestionView()
                            
                            self.isAssistantEnabled = true
                            self.handleTwicketSegmentedControl()
                            self.segmentedControl?.move(to: 0)
                            self.assistant()
                        }
                        alertController.addAction(cancelAction)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                        
                    } else if (SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]])[sender.tag - 1]["flightNotFromPlanitDict"] != nil {
                        //PLANNED: ADD DETAILED INFORMATION VIEW WITH SPACES FOR FLIGHTS BOUGHT ALREADY
                    } else {
                        let alertController = UIAlertController(title: "Check out flights!", message: "", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
                        }
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                            //No flight booked, no saved flights, should flight search in Assistant
                            SavedPreferencesForTrip["assistantMode"] = "travel" as! NSString
                            SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = sender.tag - 1
                            self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                            
                            self.spawnFlightSearchQuestionView()
                            
                            self.isAssistantEnabled = true
                            self.handleTwicketSegmentedControl()
                            self.segmentedControl?.move(to: 0)
                            self.assistant()
                        }
                        alertController.addAction(cancelAction)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                } else if travelDictionaryArray[sender.tag - 1]["modeOfTransportation"] as! String == "busTrainOther"{
                    if (SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]])[sender.tag - 1]["busTrainOtherText"] != nil {
                        detailedInformationSubviewMode = "busTrainOther"
                        //Show text entered
                        animateInBackgroundFilterView(withInfoView: false, withBlurEffect: true, withCloseButton: false)
                        setupDetailedInformationView(size: CGSize(width: 250, height: 350), withTextView:true,withDoneButton:true)
                        textView?.text = travelDictionaryArray[sender.tag - 1]["busTrainOtherText"] as! String
                        var topCorrect: CGFloat? = (textView?.bounds.size.height)! - (textView?.contentSize.height)!
                        topCorrect = (topCorrect! < CGFloat(0.0) ? 0.0 : topCorrect)
                        textView?.contentOffset = CGPoint()
                        textView?.contentOffset.x = 0
                        textView?.contentOffset.y = -topCorrect!
                        textView?.resignFirstResponder()
                        self.view.addSubview(detailedInformationSubview)
                    }
                } else if travelDictionaryArray[sender.tag - 1]["modeOfTransportation"] as! String == "illAlreadyBeThere"{
                    detailedInformationSubviewMode = "illAlreadyBeThere"
                    // Show text "I'll already be there"
                    animateInBackgroundFilterView(withInfoView: false, withBlurEffect: true, withCloseButton: false)
                    setupDetailedInformationView(size: CGSize(width: 250, height: 350), withTextView:true,withDoneButton:true)
                    textView?.text = travelDictionaryArray[sender.tag - 1]["illAlreadyBeThereText"] as! String
                    var topCorrect: CGFloat? = (textView?.bounds.size.height)! - (textView?.contentSize.height)!
                    topCorrect = (topCorrect! < CGFloat(0.0) ? 0.0 : topCorrect)
                    textView?.contentOffset = CGPoint()
                    textView?.contentOffset.x = 0
                    textView?.contentOffset.y = -topCorrect!
                    textView?.resignFirstResponder()
                    self.view.addSubview(detailedInformationSubview)
                    
                } else if travelDictionaryArray[sender.tag - 1]["modeOfTransportation"] as! String == "drive"{
                    if (SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]])[sender.tag - 1]["rentalCar"] != nil {
                        //PLANNED: FETCH DETAILS FROM PRICELINE
                    } else if (SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]])[sender.tag - 1]["personalCar"] != nil {
                        detailedInformationSubviewMode = "stayWithSomeoneIKnow"
                        animateInBackgroundFilterView(withInfoView: false, withBlurEffect: true, withCloseButton: false)
                        setupDetailedInformationView(size: CGSize(width: 250, height: 350), withTextView:false,withDoneButton:true)
                        
                        //PLANNED: SHOW "Driving" title and time leaving selector
                        
                        
                        //                        textView?.text = placeToStayDictionaryArray[sender.tag - 1]["stayWithSomeoneIKnowText"] as! String
                        //                        var topCorrect: CGFloat? = (textView?.bounds.size.height)! - (textView?.contentSize.height)!
                        //                        topCorrect = (topCorrect! < CGFloat(0.0) ? 0.0 : topCorrect)
                        //                        textView?.contentOffset = CGPoint()
                        //                        textView?.contentOffset.x = 0
                        //                        textView?.contentOffset.y = -topCorrect!
                        //                        textView?.resignFirstResponder()
                        self.view.addSubview(detailedInformationSubview)
                    }
                    
                } else {
                    showFinishPlanningTripAlert(title: "Almost there...", message: "Let's finish building your itinerary!", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
                }
            } else if assistantMode == "disabled" {
                let alertController = UIAlertController(title: "Plan your travel!", message: "", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
                }
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    SavedPreferencesForTrip["assistantMode"] = "travel" as NSString
                    SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = sender.tag - 1
                    self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                    
                    self.spawnHowDoYouWantToGetThereQuestionView()
                    
                    self.isAssistantEnabled = true
                    self.handleTwicketSegmentedControl()
                    self.segmentedControl?.move(to: 0)
                    self.assistant()
                }
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    func travelDateButtonTouchedUpInside(sender:UIButton) {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let assistantMode = SavedPreferencesForTrip["assistantMode"] as! String
//        let bounds = UIScreen.main.bounds
        
        //Go back to assistant where user left off if still building itinerary
        if isAssistantEnabled == true && assistantMode == "initialItineraryBuilding" {
            showFinishPlanningTripAlert(title: "Almost there...", message: "Let's finish building your itinerary!", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        } else if assistantMode == "placeToStay" {
            showFinishPlanningTripAlert(title: "Let's finish changing your place to stay!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        } else if assistantMode == "travel" {
            showFinishPlanningTripAlert(title: "Let's finish changing your travel first!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        } else if assistantMode == "destination" {
            showFinishPlanningTripAlert(title: "Let's finish updating your destination first!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        } else if assistantMode == "startingPoint" {
            showFinishPlanningTripAlert(title: "Let's finish updating your starting point first!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        } else if assistantMode == "endingPoint" {
            showFinishPlanningTripAlert(title: "Let's finish updating your ending point first!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        }
        //
//        if editItineraryModeEnabled {
//            let initiatorProgress = checkInitiatorProgress()
            
            //Edit dates
            if assistantMode == "disabled" {
//                if destinationsDatesCollectionView.numberOfItems(inSection: 0) > 3 {
//                    let alertController = UIAlertController(title: "Change your travel dates?", message: "", preferredStyle: .alert)
//                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
//                    }
//                    let tripDatesAction = UIAlertAction(title: "Departure and return dates", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
//                        SavedPreferencesForTrip["assistantMode"] = "dates" as NSString
////                        SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = sender.tag - 1
//                        self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
//                        
//                        self.spawnDatesPickedOutCalendarView()
//                        
//                        self.isAssistantEnabled = true
//                        self.handleTwicketSegmentedControl()
//                        self.segmentedControl?.move(to: 0)
//                        self.assistant()
//                    }
//                    let travelDatesAction = UIAlertAction(title: "Number of nights in each destination", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
//                        SavedPreferencesForTrip["assistantMode"] = "dates" as NSString
////                        SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = sender.tag - 1
//                        self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
//                        
//                        self.spawnParseDatesForMultipleDestinationsCalendarView()
//                        
//                        self.isAssistantEnabled = true
//                        self.handleTwicketSegmentedControl()
//                        self.segmentedControl?.move(to: 0)
//                        self.assistant()
//                    }
//                    alertController.addAction(cancelAction)
//                    alertController.addAction(tripDatesAction)
//                    alertController.addAction(travelDatesAction)
//                    self.present(alertController, animated: true, completion: nil)
//                } else {
                    //Single destination trip
                    let alertController = UIAlertController(title: "Change your travel dates?", message: "", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
                    }
                    let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                        SavedPreferencesForTrip["assistantMode"] = "dates" as NSString
//                        SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = sender.tag - 1
                        self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                        
                        self.spawnDatesPickedOutCalendarView()
                        
                        self.isAssistantEnabled = true
                        self.handleTwicketSegmentedControl()
                        self.segmentedControl?.move(to: 0)
                        self.assistant()
                    }
                    alertController.addAction(cancelAction)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)

//                }
            } else if assistantMode == "dates" {
                showFinishPlanningTripAlert(title: "Let's finish updating your dates!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            }
//        } else if !editItineraryModeEnabled {
//            //Edit dates
//            if assistantMode == "disabled" {
//                if destinationsDatesCollectionView.numberOfItems(inSection: 0) > 3 {
//                    let alertController = UIAlertController(title: "Dates", message: "Which do you want to review?", preferredStyle: .alert)
//                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
//                    }
//                    let tripDatesAction = UIAlertAction(title: "Departure and return dates", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
//                        SavedPreferencesForTrip["assistantMode"] = "dates" as NSString
//                        //                        SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = sender.tag - 1
//                        self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
//                        
//                        self.spawnDatesPickedOutCalendarView()
//                        
//                        self.isAssistantEnabled = true
//                        self.handleTwicketSegmentedControl()
//                        self.segmentedControl?.move(to: 0)
//                        self.assistant()
//                    }
//                    let travelDatesAction = UIAlertAction(title: "Number of nights in each destination", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
//                        SavedPreferencesForTrip["assistantMode"] = "dates" as NSString
//                        //                        SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = sender.tag - 1
//                        self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
//                        
//                        self.spawnParseDatesForMultipleDestinationsCalendarView()
//                        
//                        self.isAssistantEnabled = true
//                        self.handleTwicketSegmentedControl()
//                        self.segmentedControl?.move(to: 0)
//                        self.assistant()
//                    }
//                    alertController.addAction(cancelAction)
//                    alertController.addAction(tripDatesAction)
//                    alertController.addAction(travelDatesAction)
//                    self.present(alertController, animated: true, completion: nil)
//                } else {
//                    //Single destination trip
//                    let alertController = UIAlertController(title: "Review your dates?", message: "", preferredStyle: .alert)
//                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
//                    }
//                    let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
//                        SavedPreferencesForTrip["assistantMode"] = "dates" as NSString
//                        //                        SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = sender.tag - 1
//                        self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
//                        
//                        self.spawnDatesPickedOutCalendarView()
//                        
//                        self.isAssistantEnabled = true
//                        self.handleTwicketSegmentedControl()
//                        self.segmentedControl?.move(to: 0)
//                        self.assistant()
//                    }
//                    alertController.addAction(cancelAction)
//                    alertController.addAction(okAction)
//                    self.present(alertController, animated: true, completion: nil)
//                    
//                }
//            } else if assistantMode == "dates" {
//                showFinishPlanningTripAlert(title: "Dates", message: "Let's finish updating your dates!", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
//            }
//        }
    }
    func destinationButtonTouchedUpInside(sender:UIButton) {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let assistantMode = SavedPreferencesForTrip["assistantMode"] as! String
        //        let bounds = UIScreen.main.bounds
//        
//        //Go back to assistant where user left off if still building itinerary
        if isAssistantEnabled == true && assistantMode == "initialItineraryBuilding" {
            showFinishPlanningTripAlert(title: "Almost there...", message: "Let's finish building your itinerary!", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        } else if assistantMode == "placeToStay" {
            showFinishPlanningTripAlert(title: "Let's finish changing your place to stay!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        } else if assistantMode == "travel" {
            showFinishPlanningTripAlert(title: "Let's finish changing your travel first!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        } else if assistantMode == "dates" {
            showFinishPlanningTripAlert(title: "Let's finish updating your dates first!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
            return
        }
        
        if editItineraryModeEnabled {
//            //            let initiatorProgress = checkInitiatorProgress()
            var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])

            if sender.tag == 0 {
                //Edit starting point
                if assistantMode == "disabled" {
                    let alertController = UIAlertController(title: "Change your starting point?", message: "", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
                    }
                    let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                        SavedPreferencesForTrip["assistantMode"] = "startingPoint" as NSString
                        SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = sender.tag - 1
                        self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                        
                        self.spawnWhereTravellingFromQuestionView()
                        
                        self.isAssistantEnabled = true
                        self.handleTwicketSegmentedControl()
                        self.segmentedControl?.move(to: 0)
                        self.assistant()
                    }
                    alertController.addAction(cancelAction)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                } else if assistantMode == "startingPoint" {
                    showFinishPlanningTripAlert(title: "Let's finish updating your starting point!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
                }
            
            } else if sender.tag == destinationsForTrip.count + 1 {
                //Edit final destination
                if assistantMode == "disabled" {
                    let alertController = UIAlertController(title: "Change your ending point?", message: "", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
                    }
                    let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                        SavedPreferencesForTrip["assistantMode"] = "endingPoint" as NSString
                        SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = sender.tag - 1
                        self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                        
                        self.spawnWhereTravellingFromQuestionView()
                        
                        self.isAssistantEnabled = true
                        self.handleTwicketSegmentedControl()
                        self.segmentedControl?.move(to: 0)
                        self.assistant()
                    }
                    alertController.addAction(cancelAction)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                } else if assistantMode == "endingPoint" {
                    showFinishPlanningTripAlert(title: "Let's finish updating your ending point!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
                }
                
            } else {
                //Edit destination
                if assistantMode == "disabled" {
                    let alertController = UIAlertController(title: "Change your destination?", message: "", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
                    }
                    let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                        SavedPreferencesForTrip["assistantMode"] = "destination" as NSString
                        SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] = sender.tag - 1
                        self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
                        
                        self.spawnYesCityDecidedQuestionView()
                        
                        self.isAssistantEnabled = true
                        self.handleTwicketSegmentedControl()
                        self.segmentedControl?.move(to: 0)
                        self.assistant()
                    }
                    alertController.addAction(cancelAction)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    //                }
                } else if assistantMode == "destination" {
                    showFinishPlanningTripAlert(title: "Let's finish updating your destination!", message: "", okButtonTitle: "OK", cancelButtonTitle: "Cancel")
                }
            }
        } else if !editItineraryModeEnabled {
            //PLANNED: Show map
        }
    
    }
    func setupDetailedInformationView(size: CGSize, withTextView: Bool, withDoneButton: Bool) {
        let bounds = UIScreen.main.bounds
        detailedInformationSubview.layer.cornerRadius = 5
        detailedInformationSubview.isHidden = false
        detailedInformationSubview.frame.size = size
        detailedInformationSubview.frame.origin = CGPoint(x: (bounds.width - detailedInformationSubview.frame.width) / 2, y: (bounds.height - detailedInformationSubview.frame.height) / 2)
        
        if withDoneButton {
            //Button1
            button1 = UIButton(type: .custom)
            button1?.frame = CGRect.zero
            button1?.setTitleColor(UIColor.white, for: .normal)
            button1?.setBackgroundColor(color: UIColor.clear, forState: .normal)
            button1?.layer.borderWidth = 1
            button1?.layer.borderColor = UIColor.white.cgColor
            //        button1?.layer.masksToBounds = true
            button1?.titleLabel?.numberOfLines = 0
            button1?.titleLabel?.textAlignment = .center
            button1?.setTitle("Done", for: .normal)
            //        button1?.translatesAutoresizingMaskIntoConstraints = false
            button1?.addTarget(self, action: #selector(self.detailedInformationDoneButtonTouchedUpInside(sender:)), for: UIControlEvents.touchUpInside)
            detailedInformationSubview.addSubview(button1!)
            button1?.sizeToFit()
            button1?.frame.size.height = 30
            button1?.frame.size.width += 20
            button1?.frame.origin.x = ((bounds.width) - (button1?.frame.width)!) / 2 - detailedInformationSubview.frame.minX
            button1?.frame.origin.y = 300
            button1?.layer.cornerRadius = (button1?.frame.height)! / 2
        }
        
        if withTextView {
            //Textview
            textView = UITextView(frame: CGRect.zero)
            textView?.delegate = self
            textView?.dataDetectorTypes = .all
            textView?.textColor = UIColor.white
            textView?.contentMode = .bottomLeft
            textView?.layer.masksToBounds = true
            textView?.textAlignment = .left
            textView?.returnKeyType = .next
            textView?.backgroundColor = UIColor.clear
            textView?.font = UIFont.systemFont(ofSize: 18)
            let textViewPlaceholder = "\nExample: A few Airbnb options:\nLink 1\nLink 2\nLink 3"
            textView?.text = textViewPlaceholder
            textView?.indicatorStyle = .white
            textView?.clearsOnInsertion = true
            textView?.translatesAutoresizingMaskIntoConstraints = false
            detailedInformationSubview.addSubview(textView!)
            textView?.frame = CGRect(x: 25, y: 130, width: 200, height: 140)
            let width = 1.0
            let borderLine = UIView()
            borderLine.frame = CGRect(x: Double((textView?.frame.minX)!), y: Double((textView?.frame.maxY)!) - width, width: Double((textView?.frame.width)!), height: width)
            borderLine.backgroundColor = UIColor.white
            self.detailedInformationSubview.addSubview(borderLine)
            
        }
        
    }
    func detailedInformationDoneButtonTouchedUpInside(sender:UIButton) {
        animateOutBackgroundFilterView()
        detailedInformationSubview.isHidden = true
        self.detailedInformationSubview.removeFromSuperview()
        self.detailedInformationSubview.removeAllSubviews()
    }
}
