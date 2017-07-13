//
//  NewTripNameViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/17/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import ContactsUI
import Contacts
import JTAppleCalendar
import Cartography
import Firebase

class NewTripNameViewController: UIViewController, UITextFieldDelegate, CNContactPickerDelegate, CNContactViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    //Times VC viewed
    var timesViewed = [String: Int]()
    
    //Firebase channel
    var channelsRef: DatabaseReference = Database.database().reference().child("channels")
    var newChannelRef: DatabaseReference?

    //City dict
    var rankedPotentialTripsDictionary = [Dictionary<String, Any>]()
    
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
    
    //Contacts vars COPY
    fileprivate var addressBookStore: CNContactStore!
    let picker = CNContactPickerViewController()
    var contacts: [CNContact]?
    var contactIDs: [NSString]?
    var contactPhoneNumbers = [NSString]()
    var NewOrAddedTripFromSegue: Int?
    var editModeEnabled = false
    
    //Popup subview vars
    var homeAirportValue = DataContainerSingleton.sharedDataContainer.homeAirport ?? ""
    var leftDates = [Date]()
    var rightDates = [Date]()
    var fullDates = [Date]()
    var lengthOfAvailabilitySegmentsArray = [Int]()
    var leftDateTimeArrays = NSMutableDictionary()
    var rightDateTimeArrays = NSMutableDictionary()
    var mostRecentSelectedCellDate = NSDate()
    
    //Instructions
    var instructionsView: instructionsView?
    
    // MARK: Outlets
    @IBOutlet weak var groupMemberListTable: UITableView!
    @IBOutlet weak var addFromContactsButton: UIButton!
    @IBOutlet weak var addFromFacebookButton: UIButton!
    @IBOutlet weak var soloForNowButton: UIButton!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var popupBackgroundViewMainVC: UIVisualEffectView!
    @IBOutlet weak var subviewWhereButton: UIButton!
    @IBOutlet weak var subviewWhoButton: UIButton!
    @IBOutlet weak var subviewWhenButton: UIButton!
    @IBOutlet weak var subviewDoneButton: UIButton!
    @IBOutlet weak var homeAirportTextField: UITextField!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var month1: UIButton!
    @IBOutlet weak var month2: UIButton!
    @IBOutlet weak var month3: UIButton!
    @IBOutlet weak var month4: UIButton!
    @IBOutlet weak var specificDatesButton: UIButton!
    @IBOutlet weak var weekend: UIButton!
    @IBOutlet weak var oneWeek: UIButton!
    @IBOutlet weak var twoWeeks: UIButton!
    @IBOutlet weak var noSpecificDatesButton: UIButton!
    @IBOutlet weak var numberDestinationsSlider: UISlider!
    @IBOutlet weak var numberDestinationsStackView: UIStackView!
    @IBOutlet weak var tripNameLabel: UITextField!
    @IBOutlet weak var dayOfWeekStackView: UIStackView!
    @IBOutlet weak var instructionsGotItButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var whiteLine: UIImageView!
    @IBOutlet weak var pickADurationLabel: UILabel!
    @IBOutlet weak var pickAMonthLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatButton.isHidden = true
        
        //Set to when
        whiteLine.layer.frame = CGRect(x: 61, y: 104, width: 55, height: 51)
        subviewWhen()
        
        updateLastVC()

        //Setup instructions collection view
        instructionsView = Bundle.main.loadNibNamed("instructionsView", owner: self, options: nil)?.first! as? instructionsView
        instructionsView?.frame.origin.y = 200
        self.view.insertSubview(instructionsView!, aboveSubview: popupBackgroundViewMainVC)
        instructionsView?.isHidden = true
        instructionsGotItButton.isHidden = true
        
        //City data
        let SavedPreferencesForTrip_1 = self.fetchSavedPreferencesForTrip()
        timesViewed = (SavedPreferencesForTrip_1["timesViewed"] as? [String : Int])!
        if timesViewed["newTrip"] == nil {
                timesViewed = ["newTrip":0, "swiping":0, "ranking":0, "flightSearch":0,"flightResults":0,"hotelResults":0,"booking":0]
                SavedPreferencesForTrip_1["timesViewed"] = timesViewed
                saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip_1)
        }
            
        
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                rankedPotentialTripsDictionary = rankedPotentialTripsDictionaryFromSingleton as! [Dictionary<String, AnyObject>]
            } else {
                //Load from server
                var rankedPotentialTripsDictionaryFromServer = [["price":"$1,000","percentSwipedRight":"100","destination":"Miami","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()],"destinationPhotos":["miami_1","miami_2"],"topThingsToDo":["Vizcaya Museum and Gardens", "American Airlines Arena", "Wynwood Walls", "Boat tours","Zoological Wildlife Foundation"],"averageMonthlyHighs":[String()],"averageMonthlyLows":[String()]]]
                
                rankedPotentialTripsDictionaryFromServer.append(["price":"$???","percentSwipedRight":"75","destination":"Washington DC","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()],"destinationPhotos":["washingtonDC_1","washingtonDC_2","washingtonDC_3","washingtonDC_4"],"topThingsToDo":["National Mall", "Smithsonian Air and Space Museum" ,"Logan Circle"],"averageMonthlyHighs":[String()],"averageMonthlyLows":[String()]])
                
                rankedPotentialTripsDictionaryFromServer.append(["price":"$???","percentSwipedRight":"75","destination":"San Diego","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()],"destinationPhotos":["sanDiego_1","sanDiego_2","sanDiego_3","sanDiego_4"],"topThingsToDo":["Sunset Cliffs", "San Diego Zoo" ,"Petco Park"],"averageMonthlyHighs":[String()],"averageMonthlyLows":[String()]])
                
                rankedPotentialTripsDictionaryFromServer.append(["price":"$???","percentSwipedRight":"75","destination":"Nashville","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()],"destinationPhotos":["nashville_1","nashville_2","nashville_3","nashville_4"],"topThingsToDo":["Grand Ole Opry", "Broadway" ,"Country Music Hall of Fame"],"averageMonthlyHighs":[String()],"averageMonthlyLows":[String()]])
                
                rankedPotentialTripsDictionaryFromServer.append(["price":"$???","percentSwipedRight":"50","destination":"New Orleans","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()],"destinationPhotos":["newOrleans_1","newOrleans_2","newOrleans_3","newOrleans_4"],"topThingsToDo":["Bourbon Street", "National WWII Museum" ,"Jackson Square"],"averageMonthlyHighs":[String()],"averageMonthlyLows":[String()]])
                
                rankedPotentialTripsDictionaryFromServer.append(["price":"$???","percentSwipedRight":"50","destination":"Austin","flightOptions":[NSDictionary()],"hotelOptions":[NSDictionary()],"destinationPhotos":["austin_1","austin_2","austin_3","austin_4"],"topThingsToDo":["Zilker Park", "6th Street" ,"University of Texas"],"averageMonthlyHighs":[String()],"averageMonthlyLows":[String()]])
                
                rankedPotentialTripsDictionary = rankedPotentialTripsDictionaryFromServer
            }
        }
        

        SavedPreferencesForTrip["rankedPotentialTripsDictionary"] = self.rankedPotentialTripsDictionary
        //Save
        self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
//        self.hideKeyboardWhenTappedAround()
        
        //Load the values from our shared data container singleton
        if NewOrAddedTripFromSegue != 1 {
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        //Install the value into the label.
        if tripNameValue != nil {
            self.tripNameLabel.text =  "\(tripNameValue!)"
        }
        }
        tripNameLabel.adjustsFontSizeToFitWidth = true
        tripNameLabel.minimumFontSize = 10
        
        weekend.layer.cornerRadius = 15
        oneWeek.layer.cornerRadius = 15
        twoWeeks.layer.cornerRadius = 15
        month1.layer.cornerRadius = 15
        month2.layer.cornerRadius = 15
        month3.layer.cornerRadius = 15
        month4.layer.cornerRadius = 15
        
        weekend.backgroundColor = UIColor.clear
        oneWeek.backgroundColor = UIColor.clear
        twoWeeks.backgroundColor = UIColor.clear
        month1.backgroundColor = UIColor.clear
        month2.backgroundColor = UIColor.clear
        month3.backgroundColor = UIColor.clear
        month4.backgroundColor = UIColor.clear
        
        weekend.layer.borderColor = UIColor.white.cgColor
        oneWeek.layer.borderColor = UIColor.white.cgColor
        twoWeeks.layer.borderColor = UIColor.white.cgColor
        month1.layer.borderColor = UIColor.white.cgColor
        month2.layer.borderColor = UIColor.white.cgColor
        month3.layer.borderColor = UIColor.white.cgColor
        month4.layer.borderColor = UIColor.white.cgColor

        weekend.layer.borderWidth = 1
        oneWeek.layer.borderWidth = 1
        twoWeeks.layer.borderWidth = 1
        month1.layer.borderWidth = 1
        month2.layer.borderWidth = 1
        month3.layer.borderWidth = 1
        month4.layer.borderWidth = 1
        
        let monthDateFormatter = DateFormatter()
        monthDateFormatter.dateFormat = "MM"
        let currentMonth = monthDateFormatter.string(from: Date())
        let month1Numerical = Int(currentMonth)
        let month2Numerical = month1Numerical! + 1
        let month3Numerical = month1Numerical! + 2
        let month4Numerical = month1Numerical! + 3
        month1.setTitle("\(getMonth(Month: month1Numerical!))",for: .normal)
        month2.setTitle("\(getMonth(Month: month2Numerical))",for: .normal)
        month3.setTitle("\(getMonth(Month: month3Numerical))",for: .normal)
        month4.setTitle("\(getMonth(Month: month4Numerical))",for: .normal)
        month1.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        month2.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        month3.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        month4.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        weekend.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        oneWeek.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        twoWeeks.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        
        subviewDoneButton.isHidden = true
        
        //Number Destinations Slider
        numberDestinationsSlider.isContinuous = false
        numberDestinationsSlider.isHidden = true
        numberDestinationsStackView.isHidden = true
        if let numberDestinationsValue = SavedPreferencesForTrip["numberDestinations"] as? Float {
            numberDestinationsSlider.setValue(numberDestinationsValue, animated: false)
        }
                
        //Trip Name textField
        self.tripNameLabel.delegate = self
        
        //home airport textfield
        self.homeAirportTextField.delegate = self
        homeAirportTextField.layer.borderWidth = 1
        homeAirportTextField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        homeAirportTextField.layer.masksToBounds = true
        homeAirportTextField.layer.cornerRadius = 5
        homeAirportTextField.text =  "\(homeAirportValue)"
        let homeAirportLabelPlaceholder = homeAirportTextField!.value(forKey: "placeholderLabel") as? UILabel
        homeAirportLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
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
        
        // Load trip preferences and install
        if let selectedDatesValue = SavedPreferencesForTrip["selected_dates"] as? [Date] {
            if selectedDatesValue.count > 0 {
                self.calendarView.selectDates(selectedDatesValue as [Date],triggerSelectionDelegate: false)
            }
        }
        
        //COPY FOR CONTACTS
        addressBookStore = CNContactStore()
        
        //
        let atap = UITapGestureRecognizer(target: self, action: #selector(self.dismissInstructions(touch:)))
        atap.numberOfTapsRequired = 1
        atap.delegate = self
        self.popupBackgroundViewMainVC.addGestureRecognizer(atap)
        popupBackgroundViewMainVC.isHidden = true
        popupBackgroundViewMainVC.isUserInteractionEnabled = true
        //
        
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        
        view.autoresizingMask = .flexibleTopMargin
        view.sizeToFit()
        
        if NewOrAddedTripFromSegue == 1 {
            let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
            
                //Create trip and trip data model
                if tripNameLabel.text == "New Trip" {
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
                    
                    tripNameLabel.text = tripNameValue
                    
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
            
            let SavedPreferencesForTrip_2 = fetchSavedPreferencesForTrip()
            timesViewed = (SavedPreferencesForTrip_2["timesViewed"] as? [String : Int])!
            
            if timesViewed["newTrip"] == 0 {
                let when = DispatchTime.now()
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.animateInstructionsIn()
                    let currentTimesViewed = self.timesViewed["newTrip"]
                    self.timesViewed["newTrip"]! = currentTimesViewed! + 1
                    SavedPreferencesForTrip_2["timesViewed"] = self.timesViewed as NSDictionary
                    self.saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip_2)
                }
            }
        }
        else {
            retrieveContactsWithStore(store: addressBookStore)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        timesViewed = (SavedPreferencesForTrip["timesViewed"] as? [String : Int])!
        if segue.identifier == "newTripToSwiping" && timesViewed["swiping"] == 0 {
            UIView.animate(withDuration: 0.24) {
                self.popupBackgroundViewMainVC.isHidden = false
            }
        }
    }
    
    func roundSlider() {
        let numberDestinationsValue = NSNumber(value: (round(numberDestinationsSlider.value / sliderStep)))
        numberDestinationsSlider.setValue(Float(numberDestinationsValue), animated: true)
        
        //Update trip preferences dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["numberDestinations"] = numberDestinationsValue
        //Save updated trip preferences dictionary
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }

    
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith
        otherGestureRecognizer : UIGestureRecognizer)->Bool {
        return true
    }
    
    
    func animateInstructionsIn(){
        instructionsView?.isHidden = false
        instructionsView?.instructionsCollectionView?.scrollToItem(at: IndexPath(item: 0,section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        
        instructionsView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        instructionsView?.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.popupBackgroundViewMainVC.isHidden = false
            self.instructionsView?.alpha = 1
            self.instructionsView?.transform = CGAffineTransform.identity
            self.instructionsGotItButton.isHidden = false
        }        
    }
    
    func animateInstructionsOut(){
        UIView.animate(withDuration: 0.3, animations: {
            self.instructionsView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.instructionsView?.alpha = 0
            self.popupBackgroundViewMainVC.isHidden = true
            self.instructionsGotItButton.isHidden = true
        }) { (Success:Bool) in
            self.instructionsView?.layer.isHidden = true
            self.instructionsView?.instructionsCollectionView?.scrollToItem(at: IndexPath(item: 0,section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        }

    }

    func buttonClicked(sender:UIButton)
    {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true {
            sender.backgroundColor = UIColor.white
            sender.titleLabel?.textColor = UIColor.black
        } else {
            sender.backgroundColor = UIColor.clear
            sender.titleLabel?.textColor = UIColor.white
        }
        updateNonSpecificDatesDictionary()
        nonSpecificDatesToWhereLogic()
    }
    
    func getMonth(Month: Int) -> String {
        var monthLongForm = ""
        // Update header
        if Month == 01 {
            monthLongForm = "January"
        } else if Month == 02 {
            monthLongForm = "February"
        } else if Month == 03 {
            monthLongForm = "March"
        } else if Month == 04 {
            monthLongForm = "April"
        } else if Month == 05 {
            monthLongForm = "May"
        } else if Month == 06 {
            monthLongForm = "June"
        } else if Month == 07 {
            monthLongForm = "July"
        } else if Month == 08 {
            monthLongForm = "August"
        } else if Month == 09 {
            monthLongForm = "September"
        } else if Month == 10 {
            monthLongForm = "October"
        } else if Month == 11 {
            monthLongForm = "November"
        } else if Month == 12 {
            monthLongForm = "December"
        }
        return monthLongForm
    }
    
    //UITapGestureRecognizer
//    func dismissPopup(touch: UITapGestureRecognizer) {
//        if timeOfDayTableView.indexPathsForSelectedRows != nil {
//            dismissTimeOfDayTableOut()
//            popupBackgroundView.isHidden = true
//            
//            let when = DispatchTime.now() + 0.4
//            DispatchQueue.main.asyncAfter(deadline: when) {
//                if self.leftDateTimeArrays.count == self.rightDateTimeArrays.count {
//                }
//            }
//        }
//    }
    
    func dismissInstructions(touch: UITapGestureRecognizer) {
        animateInstructionsOut()
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
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let addedRowIndexPath = [IndexPath(row: numberContactsInTable, section: 0)]
            
            groupMemberListTable.insertRows(at: addedRowIndexPath as [IndexPath], with: .left)
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
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let addedRowIndexPath = [IndexPath(row: 0, section: 0)]
            groupMemberListTable.insertRows(at: addedRowIndexPath, with: .left)
        }
            addFromContactsButton.layer.frame = CGRect(x: 89, y: 330, width: 198, height: 22)
            addFromFacebookButton.layer.frame = CGRect(x: 88, y: 375, width: 200, height: 22)
            soloForNowButton.isHidden = true
            groupMemberListTable.isHidden = false
            groupMemberListTable.layer.frame = CGRect(x: 29, y: 200, width: 292, height: 221)
        
        //Uncomment for testing on Simulator
//        chatButton.isHidden = true
//        subviewDoneButton.isHidden = false
        
        //Uncomment for testing on iPhone
        if (contacts?.count)! > 0 {
            chatButton.isHidden = false
            subviewDoneButton.isHidden = true
            
        } else {
            chatButton.isHidden = true
            subviewDoneButton.isHidden = false
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
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let addedRowIndexPath = [IndexPath(row: numberContactsInTable, section: 0)]
            groupMemberListTable.insertRows(at: addedRowIndexPath as [IndexPath], with: .left)
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
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let addedRowIndexPath = [IndexPath(row: 0, section: 0)]
            groupMemberListTable.insertRows(at: addedRowIndexPath, with: .left)
        }
        
        addFromContactsButton.layer.frame = CGRect(x: 89, y: 330, width: 198, height: 22)
        addFromFacebookButton.layer.frame = CGRect(x: 88, y: 375, width: 200, height: 22)
        soloForNowButton.isHidden = true
        groupMemberListTable.isHidden = false
        groupMemberListTable.layer.frame = CGRect(x: 29, y: 200, width: 292, height: 221)
        
        //Uncomment for testing on Simulator
//        chatButton.isHidden = true
//        subviewDoneButton.isHidden = false
        
        //Uncomment for testing on iPhone
        if (contacts?.count)! > 0 {
            chatButton.isHidden = false
            subviewDoneButton.isHidden = true
            
        } else {
            chatButton.isHidden = true
            subviewDoneButton.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let hideKeyboardTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAndRemoveHideKeyboardTap(touch:)))
        self.view.addGestureRecognizer(hideKeyboardTap)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        homeAirportTextField.resignFirstResponder()
        tripNameLabel.resignFirstResponder()
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        
        if textField == tripNameLabel {
            SavedPreferencesForTrip["trip_name"] = tripNameLabel.text
            //Save
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
        }
        
        if textField == homeAirportTextField {
            let segmentLengthValue = SavedPreferencesForTrip["Availability_segment_lengths"] as! [NSNumber]
            let nonSpecificDatesValue = SavedPreferencesForTrip["nonSpecificDates"] as! NSDictionary
            if let nonSpecificDuration = nonSpecificDatesValue["duration"] as? String  {
                if nonSpecificDuration != "weekend" {
                    numberDestinationsStackView.isHidden = false
                    numberDestinationsSlider.isHidden = false
                    homeAirportTextField.isHidden = true
                    questionLabel.text = "How many destinations?"
                } else {
                    subviewWho()
                }
            } else if segmentLengthValue.count > 0 {
                var maxSegmentLength = 0
                for segmentIndex in 0...(segmentLengthValue.count-1) {
                    if (Int(segmentLengthValue[segmentIndex])) > maxSegmentLength {
                        maxSegmentLength = (Int(segmentLengthValue[segmentIndex]))
                    }
                }
                if maxSegmentLength >= 4 {
                    numberDestinationsStackView.isHidden = false
                    numberDestinationsSlider.isHidden = false
                    homeAirportTextField.isHidden = true
                    questionLabel.text = "How many destinations?"
                } else {
                    subviewWho()
                }
            } else {
                subviewWho()
            }
        }
        dismiss()
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func dismiss() {
        view.endEditing(true)
        
        for gestureRecognizer in self.view.gestureRecognizers! {
            self.view.removeGestureRecognizer(gestureRecognizer)
        }

    }
    func dismissKeyboardAndRemoveHideKeyboardTap(touch: UITapGestureRecognizer) {
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        
        if homeAirportTextField.isEditing {
            let segmentLengthValue = SavedPreferencesForTrip["Availability_segment_lengths"] as! [NSNumber]
            let nonSpecificDatesValue = SavedPreferencesForTrip["nonSpecificDates"] as! NSDictionary
            if let nonSpecificDuration = nonSpecificDatesValue["duration"] as? String  {
                if nonSpecificDuration != "weekend" {
                    numberDestinationsStackView.isHidden = false
                    numberDestinationsSlider.isHidden = false
                    homeAirportTextField.isHidden = true
                    questionLabel.text = "How many destinations?"
                } else {
                    subviewWho()
                }
            } else if segmentLengthValue.count > 0 {
                var maxSegmentLength = 0
                for segmentIndex in 0...(segmentLengthValue.count-1) {
                    if (Int(segmentLengthValue[segmentIndex])) > maxSegmentLength {
                        maxSegmentLength = (Int(segmentLengthValue[segmentIndex]))
                    }
                }
                if maxSegmentLength >= 4 {
                    numberDestinationsStackView.isHidden = false
                    numberDestinationsSlider.isHidden = false
                    homeAirportTextField.isHidden = true
                    questionLabel.text = "How many destinations?"
                } else {
                    subviewWho()
                }
            } else {
                subviewWho()
            }
        }
        dismiss()
    }
    
    // MARK: UITableviewdelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        
        if tableView == groupMemberListTable {
            if contacts != nil {
                numberOfRows += contacts!.count
            }
        }
        return numberOfRows
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if tableView == groupMemberListTable {
            return 55
//        }

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == groupMemberListTable {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactsPrototypeCell", for: indexPath) as! contactsTableViewCell
        
        if contacts != nil {
            let contact = contacts?[indexPath.row]
            cell.nameLabel.text = (contact?.givenName)! + " " + (contact?.familyName)!
            
            if (contact?.imageDataAvailable)! {
                cell.thumbnailImage.image = UIImage(data: (contact?.thumbnailImageData!)!)
                cell.thumbnailImage.contentMode = .scaleToFill
                let reCenter = cell.thumbnailImage.center
                cell.thumbnailImage.layer.frame = CGRect(x: cell.thumbnailImage.layer.frame.minX
                    , y: cell.thumbnailImage.layer.frame.minY, width: cell.thumbnailImage.layer.frame.width * 0.96, height: cell.thumbnailImage.layer.frame.height * 0.96)
                cell.thumbnailImage.center = reCenter
                cell.thumbnailImage.layer.cornerRadius = cell.thumbnailImage.frame.height / 2
                cell.thumbnailImage.layer.masksToBounds = true
                cell.initialsLabel.isHidden = true
            } else {
                cell.thumbnailImage.image = UIImage(named: "no_contact_image")!
                cell.initialsLabel.isHidden = false
                let firstInitial = contact?.givenName[0]
                let secondInitial = contact?.familyName[0]
                cell.initialsLabel.text = firstInitial! + secondInitial!
            }
            }
            
            return cell
        }
        // else if tableView == sortFilterFlightsCalloutTableView
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellID")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cellID")
        }
        
        cell?.textLabel?.textColor = UIColor.black
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell?.textLabel?.numberOfLines = 0
        cell?.backgroundColor = UIColor.clear
        
        return cell!
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        if tableView == timeOfDayTableView {
////        let topRows = [IndexPath(row:0, section: 0),IndexPath(row:1, section: 0),IndexPath(row:2, section: 0),IndexPath(row:3, section: 0),IndexPath(row:4, section: 0),IndexPath(row:5, section: 0)]
////        if indexPath == IndexPath(row:6, section: 0) {
////            for rowIndex in topRows {
////                self.timeOfDayTableView.deselectRow(at: rowIndex, animated: false)
////            }
////        }
////        if topRows.contains(indexPath) {
////            self.timeOfDayTableView.deselectRow(at: IndexPath(row:6, section:0), animated: false)
////        }
////        
////        let selectedTimesOfDay = timeOfDayTableView.indexPathsForSelectedRows
//        var availableTimeOfDayInCell = ["Anytime"]
////        for indexPath in selectedTimesOfDay! {
////            let cell = timeOfDayTableView.cellForRow(at: indexPath) as! timeOfDayTableViewCell
////            availableTimeOfDayInCell.append(cell.timeOfDayTableLabel.text!)
////        }
//        let timeOfDayToAddToArray = availableTimeOfDayInCell.joined(separator: ", ") as NSString
//        
//        let cell = calendarView.cellStatus(for: mostRecentSelectedCellDate as Date)
//        if cell?.selectedPosition() == .full || cell?.selectedPosition() == .left {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "MM/dd/yyyy"
//            let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
//            leftDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
//        }
//        if cell?.selectedPosition() == .right {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "MM/dd/yyyy"
//            let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
//            rightDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
//        }
//        
//        //Update trip preferences in dictionary
//        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//        SavedPreferencesForTrip["origin_departure_times"] = leftDateTimeArrays as NSDictionary
//        SavedPreferencesForTrip["return_departure_times"] = rightDateTimeArrays as NSDictionary
//            
//        //Save
//        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
//    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            deleteContact(indexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "👋🏼"
    }
    
    func subviewWhere() {
        //Set to where
        questionLabel.text = "Where are you leaving from?"
        questionLabel.isHidden = false
        homeAirportTextField.isHidden = false
        homeAirportTextField.becomeFirstResponder()
        groupMemberListTable.isHidden = true
        addFromContactsButton.isHidden = true
        addFromFacebookButton.isHidden = true
        soloForNowButton.isHidden = true
        calendarView.isHidden = true
        subviewDoneButton.isHidden = true
        month1.isHidden = true
        month2.isHidden = true
        month3.isHidden = true
        month4.isHidden = true
        weekend.isHidden = true
        oneWeek.isHidden = true
        twoWeeks.isHidden = true
        specificDatesButton.isHidden = true
        noSpecificDatesButton.isHidden = true
        numberDestinationsSlider.isHidden = true
        numberDestinationsStackView.isHidden = true
        dayOfWeekStackView.isHidden = true
        pickAMonthLabel.isHidden = true
        pickADurationLabel.isHidden = true
        UIView.animate(withDuration: 0.4) {
            self.whiteLine.layer.frame = CGRect(x: 160, y: 104, width: 55, height: 51)
        }
    }

    func subviewWho(){
        subviewWhereButton.tintColor = UIColor.green
        questionLabel.text = "Do you have a group in mind?"
        questionLabel.isHidden = false
        homeAirportTextField.isHidden = true
        homeAirportTextField.resignFirstResponder()
        groupMemberListTable.isHidden = true
        addFromContactsButton.isHidden = false
        addFromFacebookButton.isHidden = false
        soloForNowButton.isHidden = false
        calendarView.isHidden = true
        subviewDoneButton.isHidden = true
        month1.isHidden = true
        month2.isHidden = true
        month3.isHidden = true
        month4.isHidden = true
        weekend.isHidden = true
        oneWeek.isHidden = true
        twoWeeks.isHidden = true
        specificDatesButton.isHidden = true
        noSpecificDatesButton.isHidden = true
        numberDestinationsSlider.isHidden = true
        numberDestinationsStackView.isHidden = true
        dayOfWeekStackView.isHidden = true
        pickAMonthLabel.isHidden = true
        pickADurationLabel.isHidden = true
        
        
        if contacts != nil {
            addFromContactsButton.layer.frame = CGRect(x: 89, y: 330, width: 198, height: 22)
            addFromFacebookButton.layer.frame = CGRect(x: 88, y: 375, width: 200, height: 22)
            soloForNowButton.isHidden = true
            groupMemberListTable.isHidden = false
            groupMemberListTable.layer.frame = CGRect(x: 29, y: 200, width: 292, height: 221)
            subviewDoneButton.isHidden = false
        } else {
            addFromContactsButton.layer.frame = CGRect(x: 89, y: 290, width: 198, height: 22)
            addFromFacebookButton.layer.frame = CGRect(x: 88, y: 339, width: 200, height: 22)
            soloForNowButton.isHidden = false
            soloForNowButton.layer.frame = CGRect(x: 133, y: 388, width: 109, height: 22)
            groupMemberListTable.isHidden = true
        }
        
        UIView.animate(withDuration: 0.4) {
            self.whiteLine.layer.frame = CGRect(x: 254, y: 104, width: 55, height: 51)
        }
    }
    
    func subviewWhen() {
        questionLabel.text = "When are you thinking?"
        questionLabel.isHidden = false
        homeAirportTextField.isHidden = true
        homeAirportTextField.resignFirstResponder()
        groupMemberListTable.isHidden = true
        addFromContactsButton.isHidden = true
        addFromFacebookButton.isHidden = true
        soloForNowButton.isHidden = true
        calendarView.isHidden = true
        subviewDoneButton.isHidden = true
        month1.isHidden = true
        month2.isHidden = true
        month3.isHidden = true
        month4.isHidden = true
        weekend.isHidden = true
        oneWeek.isHidden = true
        twoWeeks.isHidden = true
        specificDatesButton.isHidden = false
        noSpecificDatesButton.isHidden = false
        numberDestinationsSlider.isHidden = true
        numberDestinationsStackView.isHidden = true
        dayOfWeekStackView.isHidden = true
        pickAMonthLabel.isHidden = true
        pickADurationLabel.isHidden = true
    }

    
    func deleteContact(indexPath: IndexPath) {
        contacts?.remove(at: indexPath.row)
        contactIDs?.remove(at: indexPath.row)
        contactPhoneNumbers.remove(at: indexPath.row)
        groupMemberListTable.deleteRows(at: [indexPath], with: .left)
        
        if contacts?.count == 0 || contacts == nil {
            addFromContactsButton.layer.frame = CGRect(x: 89, y: 290, width: 198, height: 22)
            addFromFacebookButton.layer.frame = CGRect(x: 88, y: 339, width: 200, height: 22)
            soloForNowButton.isHidden = false
            soloForNowButton.layer.frame = CGRect(x: 133, y: 388, width: 109, height: 22)
            groupMemberListTable.isHidden = true
        } else {
            addFromContactsButton.layer.frame = CGRect(x: 89, y: 150, width: 198, height: 22)
            addFromFacebookButton.layer.frame = CGRect(x: 88, y: 199, width: 200, height: 22)
            soloForNowButton.isHidden = true
            soloForNowButton.layer.frame = CGRect(x: 101, y: 248, width: 109, height: 22)
            groupMemberListTable.isHidden = true
            subviewDoneButton.isHidden = true
            chatButton.isHidden = false
        }
        
        //Update trip preferences dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["contacts_in_group"] = contactIDs
        SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
        //Save updated trip preferences dictionary
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }

    //MARK: Actions
    @IBAction func infoButtonTouchedUpInside(_ sender: Any) {
        animateInstructionsIn()
    }
    @IBAction func numberDestinationsValueChanged(_ sender: Any) {
        roundSlider()
        let when = DispatchTime.now() + 0.15
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.subviewWho()
        }

    }
    func deleteContactButtonTouchedUpInside(sender:UIButton) {
        let i: Int = (sender.layer.value(forKey: "index")) as! Int
        deleteContact(indexPath: IndexPath(row:i, section: 0))
    }
    @IBAction func instructionsGotItTouchedUpInside(_ sender: Any) {
        animateInstructionsOut()
    }
    
    @IBAction func tripNameLabelEditingChanged(_ sender: Any) {
        let tripNameValue = tripNameLabel.text! as NSString
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["trip_name"] = tripNameValue
        //Save
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    @IBAction func specificDatesButtonTouchedUpInside(_ sender: Any) {
        month1.isHidden = true
        month2.isHidden = true
        month3.isHidden = true
        month4.isHidden = true
        weekend.isHidden = true
        oneWeek.isHidden = true
        twoWeeks.isHidden = true
        specificDatesButton.isHidden = true
        noSpecificDatesButton.isHidden = true
        questionLabel.isHidden = true
        calendarView.isHidden = false
        dayOfWeekStackView.isHidden = false
        
        let currentDate = Date(timeIntervalSinceNow: 86400)
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if let selectedDatesValue = SavedPreferencesForTrip["selected_dates"] as? [Date] {
            if selectedDatesValue.count > 0 {
                calendarView.scrollToDate(selectedDatesValue[0], triggerScrollToDateDelegate: true, animateScroll: true, preferredScrollPosition: UICollectionViewScrollPosition.bottom)
            } else {
                calendarView.scrollToDate(currentDate, triggerScrollToDateDelegate: true, animateScroll: true, preferredScrollPosition: UICollectionViewScrollPosition.bottom)
            }
        }
        
        getLengthOfSelectedAvailabilities()
    }
    @IBAction func noSpecificDatesButtonTouchedUpInside(_ sender: Any) {
        month1.isHidden = false
        month2.isHidden = false
        month3.isHidden = false
        month4.isHidden = false
        weekend.isHidden = false
        oneWeek.isHidden = false
        twoWeeks.isHidden = false
        specificDatesButton.isHidden = true
        noSpecificDatesButton.isHidden = true
        questionLabel.isHidden = false
        calendarView.isHidden = true
        pickAMonthLabel.isHidden = false
        pickADurationLabel.isHidden = false
    }
    @IBAction func weekendTouchedUpInside(_ sender: Any) {
        if weekend.backgroundColor == UIColor.clear {
            oneWeek.isSelected = false
            oneWeek.backgroundColor = UIColor.clear
            oneWeek.titleLabel?.textColor = UIColor.white
            twoWeeks.isSelected = false
            twoWeeks.backgroundColor = UIColor.clear
            twoWeeks.titleLabel?.textColor = UIColor.white
        }
    }
    
    func updateNonSpecificDatesDictionary() {
        var nonSpecificDatesDictionary = NSMutableDictionary()
        var duration = String()
        var month = String()
        if oneWeek.backgroundColor == UIColor.white {
            duration = "oneWeek"
        } else if twoWeeks.backgroundColor == UIColor.white {
            duration = "twoWeeks"
        } else if weekend.backgroundColor == UIColor.white {
            duration = "weekend"
        }
        
        if month1.backgroundColor == UIColor.white {
            month = month1.currentTitle!
        } else if month2.backgroundColor == UIColor.white {
            month = month2.currentTitle!
        } else if month3.backgroundColor == UIColor.white {
            month = month3.currentTitle!
        } else if month4.backgroundColor == UIColor.white {
            month = month4.currentTitle!
        }
        
        nonSpecificDatesDictionary["duration"] = duration
        nonSpecificDatesDictionary["month"] = month
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["nonSpecificDates"] = nonSpecificDatesDictionary
        //Save
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    func nonSpecificDatesToWhereLogic() {
        if (oneWeek.backgroundColor == UIColor.white || weekend.backgroundColor == UIColor.white || twoWeeks.backgroundColor == UIColor.white) && (month1.backgroundColor == UIColor.white || month2.backgroundColor == UIColor.white || month3.backgroundColor == UIColor.white || month4.backgroundColor == UIColor.white) {
            
            let when = DispatchTime.now() + 0.15
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.subviewWhere()
            }
        }
    }
    
    @IBAction func oneWeekTouchedUpInside(_ sender: Any) {
        if oneWeek.backgroundColor == UIColor.clear {
            weekend.isSelected = false
            weekend.backgroundColor = UIColor.clear
            weekend.titleLabel?.textColor = UIColor.white
            twoWeeks.isSelected = false
            twoWeeks.backgroundColor = UIColor.clear
            twoWeeks.titleLabel?.textColor = UIColor.white
//            if (month1.backgroundColor == UIColor.white || month2.backgroundColor == UIColor.white || month3.backgroundColor == UIColor.white || month4.backgroundColor == UIColor.white) {
//                subviewNextButton.isHidden = false
//            } else {
//                subviewNextButton.isHidden = true
//            }
        }
    }
    @IBAction func twoWeeksTouchedUpInside(_ sender: Any) {
        if twoWeeks.backgroundColor == UIColor.clear {
            weekend.isSelected = false
            weekend.backgroundColor = UIColor.clear
            weekend.titleLabel?.textColor = UIColor.white
            oneWeek.isSelected = false
            oneWeek.backgroundColor = UIColor.clear
            oneWeek.titleLabel?.textColor = UIColor.white
//            if (month1.backgroundColor == UIColor.white || month2.backgroundColor == UIColor.white || month3.backgroundColor == UIColor.white || month4.backgroundColor == UIColor.white) {
//                subviewNextButton.isHidden = false
//            } else {
//                subviewNextButton.isHidden = true
//            }
        }
    }
    @IBAction func month1TouchedUpInside(_ sender: Any) {
        if month1.backgroundColor == UIColor.clear {
            month2.isSelected = false
            month2.backgroundColor = UIColor.clear
            month2.titleLabel?.textColor = UIColor.white
            month3.isSelected = false
            month3.backgroundColor = UIColor.clear
            month3.titleLabel?.textColor = UIColor.white
            month4.isSelected = false
            month4.backgroundColor = UIColor.clear
            month4.titleLabel?.textColor = UIColor.white
//            if (weekend.backgroundColor == UIColor.white || oneWeek.backgroundColor == UIColor.white || twoWeeks.backgroundColor == UIColor.white) {
//                subviewNextButton.isHidden = false
//            } else {
//                subviewNextButton.isHidden = true
//            }
        }
    }
    @IBAction func month2TouchedUpInside(_ sender: Any) {
        if month2.backgroundColor == UIColor.clear {
            month1.isSelected = false
            month1.backgroundColor = UIColor.clear
            month1.titleLabel?.textColor = UIColor.white
            month3.isSelected = false
            month3.backgroundColor = UIColor.clear
            month3.titleLabel?.textColor = UIColor.white
            month4.isSelected = false
            month4.backgroundColor = UIColor.clear
            month4.titleLabel?.textColor = UIColor.white
//            if (weekend.backgroundColor == UIColor.white || oneWeek.backgroundColor == UIColor.white || twoWeeks.backgroundColor == UIColor.white) {
//                subviewNextButton.isHidden = false
//            } else {
//                subviewNextButton.isHidden = true
//            }
        }
    }
    @IBAction func month3TouchedUpInside(_ sender: Any) {
        if month3.backgroundColor == UIColor.clear {
            month1.isSelected = false
            month1.backgroundColor = UIColor.clear
            month1.titleLabel?.textColor = UIColor.white
            month2.isSelected = false
            month2.backgroundColor = UIColor.clear
            month2.titleLabel?.textColor = UIColor.white
            month4.isSelected = false
            month4.backgroundColor = UIColor.clear
            month4.titleLabel?.textColor = UIColor.white
//            if (weekend.backgroundColor == UIColor.white || oneWeek.backgroundColor == UIColor.white || twoWeeks.backgroundColor == UIColor.white) {
//                subviewNextButton.isHidden = false
//            } else {
//                subviewNextButton.isHidden = true
//            }
        }
    }
    
    @IBAction func month4TouchedUpInside(_ sender: Any) {
        if month4.backgroundColor == UIColor.clear {
            month1.isSelected = false
            month1.backgroundColor = UIColor.clear
            month1.titleLabel?.textColor = UIColor.white
            month2.isSelected = false
            month2.backgroundColor = UIColor.clear
            month2.titleLabel?.textColor = UIColor.white
            month3.isSelected = false
            month3.backgroundColor = UIColor.clear
            month3.titleLabel?.textColor = UIColor.white
//            if (weekend.backgroundColor == UIColor.white || oneWeek.backgroundColor == UIColor.white || twoWeeks.backgroundColor == UIColor.white) {
//                subviewNextButton.isHidden = false
//            } else {
//                subviewNextButton.isHidden = true
//            }
        }
    }
    @IBAction func homeAirportEditingChanged(_ sender: Any) {
        DataContainerSingleton.sharedDataContainer.homeAirport = homeAirportTextField.text
        
        //Replace with logic for matching airport database
        if (homeAirportTextField.text?.characters.count)! >= 3 {
        //Enter code here for if airport code is entered
        }
    }

    @IBAction func addContact(_ sender: Any) {
        checkContactsAccess()
    }
    @IBAction func addFromContacts(_ sender: Any) {
        checkContactsAccess()
    }
    @IBAction func subviewWhereButtonTouchedUpInside(_ sender: Any) {
        subviewWhere()
    }
    
    @IBAction func subviewWhoButtonTouchedUpInside(_ sender: Any) {
        subviewWho()
    }
    @IBAction func subviewWhenButtonTouchedUpInside(_ sender: Any) {
        subviewWhen()
        UIView.animate(withDuration: 0.4) {
            self.whiteLine.layer.frame = CGRect(x: 61, y: 104, width: 55, height: 51)
        }
    }
    
    @IBAction func subviewDoneButtonTouchedUpInside(_ sender: Any) {
        updateCompletionStatus()
    }
    
    @IBAction func goingSoloButtonTouchedUpInside(_ sender: Any) {
        super.performSegue(withIdentifier: "newTripToSwiping", sender: self)
        updateCompletionStatus()
    }
    @IBAction func chatButtonIsTouchedUpInside(_ sender: Any) {
        // Make sure the device can send text messages
        if (messageComposer.canSendText()) {
            // Obtain a configured MFMessageComposeViewController
            let messageComposeVC = messageComposer.configuredMessageComposeViewController()
            
            // Present the configured MFMessageComposeViewController instance
            present(messageComposeVC, animated: true, completion: nil)
            
            chatButton.isHidden = true
            subviewDoneButton.isHidden = false
            
        } else {
            // Let the user know if his/her device isn't able to send text messages
            let errorAlert = UIAlertController(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
            }
            
            errorAlert.addAction(cancelAction)
            self.present(errorAlert, animated: true, completion: nil)
            
            chatButton.isHidden = false
            subviewDoneButton.isHidden = true
        }
    }
    
    func updateLastVC(){
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["lastVC"] = "newTrip" as NSString
        //Save
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    func updateCompletionStatus(){
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["finished_entering_preferences_status"] = "swiping" as NSString
        //Save
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    ////// ADD NEW TRIP VARS (NS ONLY) HERE ///////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    override func fetchSavedPreferencesForTrip() -> NSMutableDictionary {
        //Determine if new or added trip
        let isNewOrAddedTrip = determineIfNewOrAddedTrip()

        //Init preference vars for if new or added trip
        //Trip status
        var bookingStatus = NSNumber(value: 0)
        var finishedEnteringPreferencesStatus = NSString()
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
        finishedEnteringPreferencesStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "finished_entering_preferences_status") as? NSString ?? NSString()
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
        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus,"finished_entering_preferences_status": finishedEnteringPreferencesStatus, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips,"numberDestinations":numberDestinations,"nonSpecificDates":nonSpecificDates, "rankedPotentialTripsDictionary": rankedPotentialTripsDictionary, "tripID": tripID,"lastVC": lastVC,"firebaseChannelKey": firebaseChannelKey,"rankedPotentialTripsDictionaryArrayIndex": rankedPotentialTripsDictionaryArrayIndex, "timesViewed": timesViewed] as NSMutableDictionary
        
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

extension String {
    var length: Int {
        return self.characters.count
    }
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    func substring(from: Int) -> String {
        return self[Range(min(from, length) ..< length)]
    }
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return self[Range(start ..< end)]
    }
}



// MARK: JTCalendarView Extension
extension NewTripNameViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = Date()
        let endDate = formatter.date(from: "2017 12 31")
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
            myCustomCell?.dayLabel.textColor = NewTripNameViewController.blackColor
            myCustomCell?.selectedView.layer.backgroundColor = NewTripNameViewController.whiteColor.cgColor
            myCustomCell?.selectedView.layer.cornerRadius =  ((myCustomCell?.selectedView.frame.height)!/2)
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
        case .left:
            myCustomCell?.selectedView.isHidden = false
            myCustomCell?.dayLabel.textColor = NewTripNameViewController.blackColor
            myCustomCell?.selectedView.layer.backgroundColor = NewTripNameViewController.whiteColor.cgColor
            myCustomCell?.selectedView.layer.cornerRadius =  ((myCustomCell?.selectedView.frame.height)!/2)
            myCustomCell?.rightSideConnector.isHidden = false
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            
        case .right:
            myCustomCell?.selectedView.isHidden = false
            myCustomCell?.dayLabel.textColor = NewTripNameViewController.blackColor
            myCustomCell?.selectedView.layer.backgroundColor = NewTripNameViewController.whiteColor.cgColor
            myCustomCell?.selectedView.layer.cornerRadius =  ((myCustomCell?.selectedView.frame.height)!/2)
            myCustomCell?.leftSideConnector.isHidden = false
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            
        case .middle:
            myCustomCell?.selectedView.isHidden = true
            myCustomCell?.middleConnector.isHidden = false
            myCustomCell?.middleConnector.layer.backgroundColor = NewTripNameViewController.transparentWhiteColor
            myCustomCell?.dayLabel.textColor = NewTripNameViewController.whiteColor
            myCustomCell?.selectedView.layer.cornerRadius =  0
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.leftSideConnector.isHidden = true
        default:
            myCustomCell?.selectedView.isHidden = true
            myCustomCell?.selectedView.layer.backgroundColor = NewTripNameViewController.transparentColor
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            myCustomCell?.dayLabel.textColor = NewTripNameViewController.whiteColor
        }
        if cellState.date < Date() {
            myCustomCell?.dayLabel.textColor = NewTripNameViewController.darkGrayColor
        }
        
        if cellState.dateBelongsTo != .thisMonth  {
            myCustomCell?.dayLabel.textColor = UIColor(cgColor: NewTripNameViewController.transparentColor)
            myCustomCell?.selectedView.isHidden = true
            myCustomCell?.selectedView.layer.backgroundColor = NewTripNameViewController.transparentColor
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            return
        }

    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {

        let myCustomCell = calendarView.dequeueReusableJTAppleCell(withReuseIdentifier: "CellView", for: indexPath) as! CellView
        myCustomCell.dayLabel.text = cellState.text
        if cellState.dateBelongsTo == .previousMonthWithinBoundary || cellState.dateBelongsTo == .followingMonthWithinBoundary {
            myCustomCell.isSelected = false
        }
        
        handleSelection(cell: myCustomCell, cellState: cellState)
        
        return myCustomCell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        if leftDateTimeArrays.count >= 1 && rightDateTimeArrays.count >= 1 {
            calendarView.deselectAllDates(triggerSelectionDelegate: false)
            rightDateTimeArrays.removeAllObjects()
            leftDateTimeArrays.removeAllObjects()
            calendarView.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
        }
        
        //UNCOMMENT FOR TWO CLICK RANGE SELECTION
        let leftKeys = leftDateTimeArrays.allKeys
        let rightKeys = rightDateTimeArrays.allKeys
        if leftKeys.count == 1 && rightKeys.count == 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let leftDate = dateFormatter.date(from: leftKeys[0] as! String)
            if date > leftDate! {
                calendarView.selectDates(from: leftDate!, to: date,  triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
                let when = DispatchTime.now() + 0.15
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.subviewWhere()
                }

            } else {
            calendarView.deselectAllDates(triggerSelectionDelegate: false)
            rightDateTimeArrays.removeAllObjects()
            leftDateTimeArrays.removeAllObjects()
            calendarView.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
            }
        }
        
//        //Spawn time of day selection
//        let positionInSuperView = self.view.convert((cell?.frame)!, from:calendarView)
//        var timeOfDayTableX = CGFloat()
//        var timeOfDayTableY = CGFloat()
//
//        if cellState.selectedPosition() == .left || cellState.selectedPosition() == .full || cellState.selectedPosition() == .right {
//            if positionInSuperView.origin.y < 70 {
//                timeOfDayTableY = positionInSuperView.origin.y + 65
//            } else if positionInSuperView.origin.y < 350 {
//                timeOfDayTableY = positionInSuperView.origin.y + 30
//            } else {
//                timeOfDayTableY = positionInSuperView.origin.y - 170
//            }
//            if positionInSuperView.origin.x < 40 {
//                timeOfDayTableX = positionInSuperView.midX + 50
//            } else if positionInSuperView.origin.x < 310 {
//                timeOfDayTableX = positionInSuperView.midX - 12
//            } else {
//                timeOfDayTableX = positionInSuperView.midX - 77
//            }
//            timeOfDayTableView.center = CGPoint(x: timeOfDayTableX, y: timeOfDayTableY)
//            animateTimeOfDayTableIn()
//        }
//        
        handleSelection(cell: cell, cellState: cellState)
        
        // Create array of selected dates
        let selectedDates = calendarView.selectedDates as [NSDate]
        getLengthOfSelectedAvailabilities()
        
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["selected_dates"] = selectedDates
        SavedPreferencesForTrip["Availability_segment_lengths"] = lengthOfAvailabilitySegmentsArray as [NSNumber]
        //Save
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
        mostRecentSelectedCellDate = date as NSDate
        
        let availableTimeOfDayInCell = ["Anytime"]
        let timeOfDayToAddToArray = availableTimeOfDayInCell.joined(separator: ", ") as NSString
        
        let cell = calendarView.cellStatus(for: mostRecentSelectedCellDate as Date)
        if cell?.selectedPosition() == .full || cell?.selectedPosition() == .left {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
            leftDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
        }
        if cell?.selectedPosition() == .right {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
            rightDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
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
            calendarView.deselectAllDates(triggerSelectionDelegate: false)
            return
        }
        
        // Create array of selected dates
        calendarView.deselectDates(from: date, to: date, triggerSelectionDelegate: false)
        let selectedDates = calendarView.selectedDates as [NSDate]
        
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
            
//            //Spawn time of day selection
//            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let leftMostDateAsString = formatter.string (from: leftMostDate!)
            let rightMostDateAsString = formatter.string (from: rightMostDate!)
//            var cellRow = cellState.row()
//            var cellCol = cellState.column()
//
            if leftDateTimeArrays[leftMostDateAsString] == nil {
//
//                if cellCol != 6 {
//                    cellCol += 1
//                } else {
//                    cellCol = 0
//                    cellRow += 1
//                }
//
//                
//                //Spawn time of day selection
//                let positionInSuperView = self.view.convert((cell?.frame)!, from:calendarView)
//                var timeOfDayTableX = CGFloat()
//                var timeOfDayTableY = CGFloat()
//                    if positionInSuperView.origin.y < 70 {
//                        timeOfDayTableY = positionInSuperView.origin.y + 65
//                    } else if positionInSuperView.origin.y < 350 {
//                        timeOfDayTableY = positionInSuperView.origin.y + 30
//                    } else {
//                        timeOfDayTableY = positionInSuperView.origin.y - 170
//                    }
//                    if positionInSuperView.origin.x < 40 {
//                        timeOfDayTableX = positionInSuperView.midX + 50
//                    } else if positionInSuperView.origin.x < 310 {
//                        timeOfDayTableX = positionInSuperView.midX - 12
//                    } else {
//                        timeOfDayTableX = positionInSuperView.midX - 200
//                    }
//                
                mostRecentSelectedCellDate = leftMostDate! as NSDate
                leftDateTimeArrays.removeAllObjects()
                
                let availableTimeOfDayInCell = ["Anytime"]
                let timeOfDayToAddToArray = availableTimeOfDayInCell.joined(separator: ", ") as NSString
                
                let cell = calendarView.cellStatus(for: mostRecentSelectedCellDate as Date)
                if cell?.selectedPosition() == .full || cell?.selectedPosition() == .left {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
                    leftDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
                }
                if cell?.selectedPosition() == .right {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
                    rightDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
                }
                
                //Update trip preferences in dictionary
                let SavedPreferencesForTrip2 = fetchSavedPreferencesForTrip()
                SavedPreferencesForTrip2["origin_departure_times"] = leftDateTimeArrays as NSDictionary
                SavedPreferencesForTrip2["return_departure_times"] = rightDateTimeArrays as NSDictionary
                
                //Save
                saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip2)

//
//                timeOfDayTableView.center = CGPoint(x: timeOfDayTableX, y: timeOfDayTableY)
//                animateTimeOfDayTableIn()
            }
//
            if rightDateTimeArrays[rightMostDateAsString] == nil {
//
//                if cellCol != 0 {
//                    cellCol -= 1
//                } else {
//                    cellCol = 6
//                    cellRow -= 1
//                }
//
//                let positionInSuperView = self.view.convert((cell?.frame)!, from:calendarView)
//                var timeOfDayTableX = CGFloat()
//                var timeOfDayTableY = CGFloat()
//                if positionInSuperView.origin.y < 70 {
//                    timeOfDayTableY = positionInSuperView.origin.y + 65
//                } else if positionInSuperView.origin.y < 350 {
//                    timeOfDayTableY = positionInSuperView.origin.y + 30
//                } else {
//                    timeOfDayTableY = positionInSuperView.origin.y - 170
//                }
//                if positionInSuperView.origin.x < 40 {
//                    timeOfDayTableX = positionInSuperView.midX + 180
//                } else if positionInSuperView.origin.x < 310 {
//                    timeOfDayTableX = positionInSuperView.midX - 12
//                } else {
//                    timeOfDayTableX = positionInSuperView.midX - 77
//                }
//                
                mostRecentSelectedCellDate = rightMostDate! as NSDate
                rightDateTimeArrays.removeAllObjects()
                
                let availableTimeOfDayInCell = ["Anytime"]
                let timeOfDayToAddToArray = availableTimeOfDayInCell.joined(separator: ", ") as NSString
                
                let cell = calendarView.cellStatus(for: mostRecentSelectedCellDate as Date)
                if cell?.selectedPosition() == .full || cell?.selectedPosition() == .left {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
                    leftDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
                }
                if cell?.selectedPosition() == .right {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
                    rightDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
                }
                
                //Update trip preferences in dictionary
                let SavedPreferencesForTrip2 = fetchSavedPreferencesForTrip()
                SavedPreferencesForTrip2["origin_departure_times"] = leftDateTimeArrays as NSDictionary
                SavedPreferencesForTrip2["return_departure_times"] = rightDateTimeArrays as NSDictionary
                
                //Save
                saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip2)
//
//                timeOfDayTableView.center = CGPoint(x: timeOfDayTableX, y: timeOfDayTableY)
//                animateTimeOfDayTableIn()
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
        let selectedDates = calendarView.selectedDates as [NSDate]
        leftDates = []
        rightDates = []
        fullDates = []
        lengthOfAvailabilitySegmentsArray = []
        if selectedDates.count > 0 {
            for date in selectedDates {
                if calendarView.cellStatus(for: date as Date)?.selectedPosition() == .left {
                    leftDates.append(date as Date)
                }
            }
            for date in selectedDates {
                if calendarView.cellStatus(for: date as Date)?.selectedPosition() == .right {
                    rightDates.append(date as Date)
                }
            }
            for date in selectedDates {
                if calendarView.cellStatus(for: date as Date)?.selectedPosition() == .full {
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
        
        let headerCell = calendarView.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "monthHeaderView", for: indexPath) as! monthHeaderView
        
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
    
//    func animateTimeOfDayTableIn(){
//        timeOfDayTableView.isHidden = false
//        timeOfDayTableView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
//        timeOfDayTableView.alpha = 0
//        
//        UIView.animate(withDuration: 0.4) {
//            self.popupBackgroundView.isHidden = false
//            self.timeOfDayTableView.alpha = 1
//            self.timeOfDayTableView.transform = CGAffineTransform.identity
//        }
//    }
//    
//    func dismissTimeOfDayTableOut() {
//        UIView.animate(withDuration: 0.3, animations: {
//            self.timeOfDayTableView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
//            self.timeOfDayTableView.alpha = 0
//            let selectedRows = self.timeOfDayTableView.indexPathsForSelectedRows
//            self.popupBackgroundView.isHidden = true
//            for rowIndex in selectedRows! {
//                self.timeOfDayTableView.deselectRow(at: rowIndex, animated: false)
//            }
//            if self.leftDates.count == self.rightDates.count && (self.leftDates.count != 0 || self.rightDates.count != 0) {
//                self.subviewNextButton.isHidden = false
//            }
//        }) { (Success:Bool) in
//            self.timeOfDayTableView.isHidden = true
//        }
//    }
}

extension UIColor {
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
