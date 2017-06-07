//
//  flightSearchViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/15/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import JTAppleCalendar

class flightSearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    //Vars passed from segue
    var rankedPotentialTripsDictionaryArrayIndex: Int?
    
    //MARK: Outlets
    @IBOutlet weak var underline: UIImageView!
    @IBOutlet weak var departureOrigin: UITextField!
    @IBOutlet weak var departureDestination: UITextField!
    @IBOutlet weak var departureDate: UITextField!
    @IBOutlet weak var returnOrigin: UITextField!
    @IBOutlet weak var returnDestination: UITextField!
    @IBOutlet weak var returnDate: UITextField!
    @IBOutlet weak var returnOriginLabel: UILabel!
    @IBOutlet weak var returnDestinationLabel: UILabel!
    @IBOutlet weak var returnDateLabel: UILabel!
    @IBOutlet weak var popupBackgroundView: UIView!
    @IBOutlet weak var subviewDoneButton: UIButton!
    @IBOutlet weak var timeOfDayTableView: UITableView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet var popupSubview: UIView!
    @IBOutlet weak var dayOfWeekStackView: UIStackView!
    
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
    var rankedPotentialTripsDictionary = [Dictionary<String, Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                rankedPotentialTripsDictionary = rankedPotentialTripsDictionaryFromSingleton as! [Dictionary<String, AnyObject>]
            }
        }
    
        underline.layer.frame = CGRect(x: 139, y: 49, width: 98, height: 51)
        returnOrigin.isHidden = true
        returnOriginLabel.isHidden = true
        returnDestination.isHidden = true
        returnDestinationLabel.isHidden = true
        returnDate.isHidden = false
        returnDateLabel.isHidden = false
        
        if let leftDateTimeArrays = SavedPreferencesForTrip["origin_departure_times"]  as? NSMutableDictionary {
            if let rightDateTimeArrays = SavedPreferencesForTrip["return_departure_times"] as? NSMutableDictionary {
                    let departureDictionary = leftDateTimeArrays as Dictionary
                    let returnDictionary = rightDateTimeArrays as Dictionary
                    let departureKeys = Array(departureDictionary.keys)
                    let returnKeys = Array(returnDictionary.keys)
                    if returnKeys.count != 0 {
                        let returnDateValue = returnKeys[0]
                        returnDate.text =  "\(returnDateValue)"
                    }
                    if departureKeys.count != 0 {
                        let departureDateValue = departureKeys[0]
                        departureDate.text =  "\(departureDateValue)"
                    }
            }
        }

        
        //Textfield setup
        self.departureDate.delegate = self
        departureDate.layer.borderWidth = 1
        departureDate.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        departureDate.layer.masksToBounds = true
        departureDate.layer.cornerRadius = 5
        let departureDateLabelPlaceholder = departureDate!.value(forKey: "placeholderLabel") as? UILabel
        departureDateLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)

        self.departureOrigin.delegate = self
        departureOrigin.layer.borderWidth = 1
        departureOrigin.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        departureOrigin.layer.masksToBounds = true
        departureOrigin.layer.cornerRadius = 5
        let departureOriginValue = DataContainerSingleton.sharedDataContainer.homeAirport ?? ""
        departureOrigin.text =  "\(departureOriginValue)"
        let departureOriginLabelPlaceholder = departureOrigin!.value(forKey: "placeholderLabel") as? UILabel
        departureOriginLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)

        self.departureDestination.delegate = self
        departureDestination.layer.borderWidth = 1
        departureDestination.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        departureDestination.layer.masksToBounds = true
        departureDestination.layer.cornerRadius = 5
        
        
        let departureDestinationValue = rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex!]["destination"] as! String
        departureDestination.text =  "\(departureDestinationValue)"
        let departureDestinationLabelPlaceholder = departureDestination!.value(forKey: "placeholderLabel") as? UILabel
        departureDestinationLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)

        self.returnDate.delegate = self
        returnDate.layer.borderWidth = 1
        returnDate.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        returnDate.layer.masksToBounds = true
        returnDate.layer.cornerRadius = 5
        let returnDateLabelPlaceholder = returnDate!.value(forKey: "placeholderLabel") as? UILabel
        returnDateLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        self.returnOrigin.delegate = self
        returnOrigin.layer.borderWidth = 1
        returnOrigin.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        returnOrigin.layer.masksToBounds = true
        returnOrigin.layer.cornerRadius = 5
        let returnOriginValue = rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex!]["destination"] as! String
        returnOrigin.text =  "\(returnOriginValue)"
        let returnOriginLabelPlaceholder = returnOrigin!.value(forKey: "placeholderLabel") as? UILabel
        returnOriginLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        self.returnDestination.delegate = self
        returnDestination.layer.borderWidth = 1
        returnDestination.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        returnDestination.layer.masksToBounds = true
        returnDestination.layer.cornerRadius = 5
        let returnDestinationValue = DataContainerSingleton.sharedDataContainer.homeAirport ?? ""
        returnDestination.text =  "\(returnDestinationValue)"
        let returnDestinationLabelPlaceholder = returnDestination!.value(forKey: "placeholderLabel") as? UILabel
        returnDestinationLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)        
        
        
        //Calendar Setup
        popupSubview.layer.cornerRadius = 10
        subviewDoneButton.isHidden = true
        
        //Calendar subview
        // Set up tap outside time of day table
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissPopup(touch:)))
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        popupBackgroundView.isHidden = true
        popupBackgroundView.layer.cornerRadius = 10
        self.popupBackgroundView.addGestureRecognizer(tap)
        
        //Time of Day
        timeOfDayTableView.delegate = self
        timeOfDayTableView.dataSource = self
        timeOfDayTableView.layer.cornerRadius = 5
        timeOfDayTableView.layer.isHidden = true
        timeOfDayTableView.allowsMultipleSelection = true
        
        
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
                calendarView.scrollToDate(selectedDatesValue[0], animateScroll: false)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchFlightsToFlightResults" {
            let destination = segue.destination as? flightResultsViewController
            destination?.rankedPotentialTripsDictionaryArrayIndex = rankedPotentialTripsDictionaryArrayIndex
            destination?.searchMode = self.searchMode
        }
    }

    func updateCompletionStatus() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["finished_entering_preferences_status"] = "flightSearch" as NSString
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        departureDestination.resignFirstResponder()
        departureOrigin.resignFirstResponder()

        returnDestination.resignFirstResponder()
        returnOrigin.resignFirstResponder()
        
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == departureDate || textField == returnDate {
            return false
        }
        return true
    }
    
    // MARK: UITableviewdelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        
        if tableView == timeOfDayTableView {
            numberOfRows = 7
        }
        return numberOfRows
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeOfDayPrototypeCell", for: indexPath) as! timeOfDayTableViewCell
            cell.timeOfDayTableLabel.text = timesOfDayArray[indexPath.row]
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == timeOfDayTableView {
            let topRows = [IndexPath(row:0, section: 0),IndexPath(row:1, section: 0),IndexPath(row:2, section: 0),IndexPath(row:3, section: 0),IndexPath(row:4, section: 0),IndexPath(row:5, section: 0)]
            if indexPath == IndexPath(row:6, section: 0) {
                for rowIndex in topRows {
                    self.timeOfDayTableView.deselectRow(at: rowIndex, animated: false)
                }
            }
            if topRows.contains(indexPath) {
                self.timeOfDayTableView.deselectRow(at: IndexPath(row:6, section:0), animated: false)
            }
            
            let selectedTimesOfDay = timeOfDayTableView.indexPathsForSelectedRows
            var availableTimeOfDayInCell = [String]()
            for indexPath in selectedTimesOfDay! {
                let cell = timeOfDayTableView.cellForRow(at: indexPath) as! timeOfDayTableViewCell
                availableTimeOfDayInCell.append(cell.timeOfDayTableLabel.text!)
            }
            let timeOfDayToAddToArray = availableTimeOfDayInCell.joined(separator: ", ") as NSString
            
            let cell = calendarView.cellStatus(for: mostRecentSelectedCellDate as Date)
            if cell?.selectedPosition() == .full || cell?.selectedPosition() == .left {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
                leftDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
                departureDate.text =  "\(mostRecentSelectedCellDateAsNSString)"
            }
            if cell?.selectedPosition() == .right {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
                rightDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
                returnDate.text =  "\(mostRecentSelectedCellDateAsNSString)"
            }
            
            //Update trip preferences in dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["origin_departure_times"] = leftDateTimeArrays as NSDictionary
            SavedPreferencesForTrip["return_departure_times"] = rightDateTimeArrays as NSDictionary
            
            //Save
            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        }
    }
    
    //MARK: Custom functions
    func dismissPopup(touch: UITapGestureRecognizer) {
        if timeOfDayTableView.indexPathsForSelectedRows != nil {
            dismissTimeOfDayTableOut()
            popupBackgroundView.isHidden = true
            
            let when = DispatchTime.now() + 0.6
            DispatchQueue.main.asyncAfter(deadline: when) {
                if self.leftDateTimeArrays.count == self.rightDateTimeArrays.count {
                }
            }
        }
    }
    
    func fetchSavedPreferencesForTrip() -> NSMutableDictionary {
        //Update preference vars if an existing trip
        //Trip status
        let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? 0 as NSNumber
        let finishedEnteringPreferencesStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "finished_entering_preferences_status") as? NSString ?? NSString()
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
        
        //SavedPreferences
        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus,"finished_entering_preferences_status": finishedEnteringPreferencesStatus, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips,"numberDestinations":numberDestinations,"nonSpecificDates":nonSpecificDates, "rankedPotentialTripsDictionary": rankedPotentialTripsDictionary, "tripID": tripID] as NSMutableDictionary
        
        return fetchedSavedPreferencesForTrip
    }
    func saveUpdatedExistingTrip(SavedPreferencesForTrip: NSMutableDictionary) {
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
    }

    func animateInSubview(){
        //Animate In Subview
        self.view.addSubview(popupSubview)
        
        if dateEditing == "departureDate" {
            popupSubview.center = CGPoint(x: 188, y: 385)
        } else if dateEditing == "returnDate" {
            popupSubview.center = CGPoint(x: 188, y: 460)
        }
        popupSubview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        popupSubview.alpha = 0
        UIView.animate(withDuration: 0.2) {
            self.popupSubview.alpha = 1
            self.popupSubview.transform = CGAffineTransform.identity
        }
        
        getLengthOfSelectedAvailabilities()
        if self.leftDates.count == self.rightDates.count && (self.leftDates.count != 0 || self.rightDates.count != 0) {
            self.subviewDoneButton.isHidden = false
        }
    }
    
    func animateOutSubview() {
        UIView.animate(withDuration: 0.3, animations: {
            self.popupSubview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.popupSubview.alpha = 0
            self.popupSubview.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }) { (Success:Bool) in
            self.popupSubview.removeFromSuperview()
        }
    }
    
    //MARK: Actions
    @IBAction func departureOriginEditingChanged(_ sender: Any) {
        DataContainerSingleton.sharedDataContainer.homeAirport = departureOrigin.text
    }
    @IBAction func multiCityButtonTouchedUpInside(_ sender: Any) {
        UIView.animate(withDuration: 0.4) {
            self.underline.layer.frame = CGRect(x: 247, y: 49, width: 98, height: 51)
            self.returnOrigin.isHidden = false
            self.returnOriginLabel.isHidden = false
            self.returnDestination.isHidden = false
            self.returnDestinationLabel.isHidden = false
            self.returnDate.isHidden = false
            self.returnDateLabel.isHidden = false
        }
        searchMode = "multiCity"
    }
    @IBAction func roundtripButtonTouchedUpInside(_ sender: Any) {
        UIView.animate(withDuration: 0.4) {
            self.underline.layer.frame = CGRect(x: 139, y: 49, width: 98, height: 51)
            self.returnOrigin.isHidden = true
            self.returnOriginLabel.isHidden = true
            self.returnDestination.isHidden = true
            self.returnDestinationLabel.isHidden = true
            self.returnDate.isHidden = false
            self.returnDateLabel.isHidden = false        }
        searchMode = "roundtrip"
    }
    @IBAction func oneWayButtonTouchedUpInside(_ sender: Any) {
        UIView.animate(withDuration: 0.4) {
            self.underline.layer.frame = CGRect(x: 30, y: 49, width: 98, height: 51)
            self.returnOrigin.isHidden = true
            self.returnOriginLabel.isHidden = true
            self.returnDestination.isHidden = true
            self.returnDestinationLabel.isHidden = true
            self.returnDate.isHidden = true
            self.returnDateLabel.isHidden = true
        }
        searchMode = "oneWay"
    }
    
    @IBAction func departureDateTextFieldTouchedDown(_ sender: Any) {
        dateEditing = "departureDate"
        animateInSubview()
    }
    @IBAction func returnDateTextFieldTouchedDown(_ sender: Any) {
        dateEditing = "returnDate"
        animateInSubview()
        UIView.animate(withDuration: 0.2) {
        }
    }
    @IBAction func subviewDoneButtonTouchedUpInside(_ sender: Any) {
        animateOutSubview()
    }
    @IBAction func searchFlightsButtonTouchedUpInside(_ sender: Any) {
        updateCompletionStatus()
        super.performSegue(withIdentifier: "searchFlightsToFlightResults", sender: self)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == departureOrigin || textField == returnOrigin || textField == departureDestination || textField == returnDestination {
            animateOutSubview()
        }
    }
    
}

// MARK: JTCalendarView Extension
extension flightSearchViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
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
        
        if searchMode == "oneWay" || ((searchMode == "roundtrip" || searchMode == "multiCity") && leftDateTimeArrays.count >= 1 && rightDateTimeArrays.count >= 1) {
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
            } else {
                calendarView.deselectAllDates(triggerSelectionDelegate: false)
                rightDateTimeArrays.removeAllObjects()
                leftDateTimeArrays.removeAllObjects()
                calendarView.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
            }
        }
        
        //Spawn time of day selection
        let positionInSuperView = self.view.convert((cell?.frame)!, from:calendarView)
        var timeOfDayTableX = CGFloat()
        var timeOfDayTableY = CGFloat()
        
        var adjustmentY = CGFloat(0)
        if dateEditing == "departureDate" {
            adjustmentY = CGFloat(26.5 + 73)
        } else if dateEditing == "returnDate" {
            adjustmentY = CGFloat(101.5 + 73)
        }
        
        if cellState.selectedPosition() == .left || cellState.selectedPosition() == .full || cellState.selectedPosition() == .right {
            if positionInSuperView.origin.y - adjustmentY < 70 {
                timeOfDayTableY = positionInSuperView.origin.y + 65 - adjustmentY
            } else if positionInSuperView.origin.y - adjustmentY < 300 {
                timeOfDayTableY = positionInSuperView.origin.y + 30 - adjustmentY
            } else {
                timeOfDayTableY = positionInSuperView.origin.y - 170 - adjustmentY
            }
            if positionInSuperView.origin.x < 40 {
                timeOfDayTableX = positionInSuperView.midX + 50
            } else if positionInSuperView.origin.x < 310 {
                timeOfDayTableX = positionInSuperView.midX - 12
            } else {
                timeOfDayTableX = positionInSuperView.midX - 77
            }
            timeOfDayTableView.center = CGPoint(x: timeOfDayTableX, y: timeOfDayTableY)
            animateTimeOfDayTableIn()
        }
        
        handleSelection(cell: cell, cellState: cellState)
        
        // Create array of selected dates
        let selectedDates = calendarView.selectedDates as [NSDate]
        getLengthOfSelectedAvailabilities()
        
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["selected_dates"] = selectedDates
        SavedPreferencesForTrip["Availability_segment_lengths"] = lengthOfAvailabilitySegmentsArray as [NSNumber]
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        mostRecentSelectedCellDate = date as NSDate
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
            
            //Spawn time of day selection
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let leftMostDateAsString = formatter.string (from: leftMostDate!)
            let rightMostDateAsString = formatter.string (from: rightMostDate!)
            var cellRow = cellState.row()
            var cellCol = cellState.column()
            
            if leftDateTimeArrays[leftMostDateAsString] == nil {
                
                if cellCol != 6 {
                    cellCol += 1
                } else {
                    cellCol = 0
                    cellRow += 1
                }
                
                
                //Spawn time of day selection
                let positionInSuperView = self.view.convert((cell?.frame)!, from:calendarView)
                
                var adjustmentY = CGFloat(0)
                if dateEditing == "departureDate" {
                    adjustmentY = CGFloat(26.5 + 73)
                } else if dateEditing == "returnDate" {
                    adjustmentY = CGFloat(101.5 + 73)
                }
                
                var timeOfDayTableX = CGFloat()
                var timeOfDayTableY = CGFloat()
                if positionInSuperView.origin.y - adjustmentY < 70 {
                    timeOfDayTableY = positionInSuperView.origin.y + 65 - adjustmentY
                } else if positionInSuperView.origin.y - adjustmentY < 300 {
                    timeOfDayTableY = positionInSuperView.origin.y + 30 - adjustmentY
                } else {
                    timeOfDayTableY = positionInSuperView.origin.y - 170 - adjustmentY
                }
                if positionInSuperView.origin.x < 40 {
                    timeOfDayTableX = positionInSuperView.midX + 50
                } else if positionInSuperView.origin.x < 310 {
                    timeOfDayTableX = positionInSuperView.midX - 12
                } else {
                    timeOfDayTableX = positionInSuperView.midX - 200
                }
                
                mostRecentSelectedCellDate = leftMostDate! as NSDate
                leftDateTimeArrays.removeAllObjects()
                
                timeOfDayTableView.center = CGPoint(x: timeOfDayTableX, y: timeOfDayTableY)
                animateTimeOfDayTableIn()
            }
            
            if rightDateTimeArrays[rightMostDateAsString] == nil {
                
                if cellCol != 0 {
                    cellCol -= 1
                } else {
                    cellCol = 6
                    cellRow -= 1
                }
                
                let positionInSuperView = self.view.convert((cell?.frame)!, from:calendarView)
                
                var adjustmentY = CGFloat(0)
                if dateEditing == "departureDate" {
                    adjustmentY = CGFloat(26.5 + 73)
                } else if dateEditing == "returnDate" {
                    adjustmentY = CGFloat(101.5 + 73)
                }
                
                var timeOfDayTableX = CGFloat()
                var timeOfDayTableY = CGFloat()
                if positionInSuperView.origin.y - adjustmentY < 70 {
                    timeOfDayTableY = positionInSuperView.origin.y + 65 - adjustmentY
                } else if positionInSuperView.origin.y - adjustmentY < 300 {
                    timeOfDayTableY = positionInSuperView.origin.y + 30 - adjustmentY
                } else {
                    timeOfDayTableY = positionInSuperView.origin.y - 170 - adjustmentY
                }
                if positionInSuperView.origin.x < 40 {
                    timeOfDayTableX = positionInSuperView.midX + 180
                } else if positionInSuperView.origin.x < 310 {
                    timeOfDayTableX = positionInSuperView.midX - 12
                } else {
                    timeOfDayTableX = positionInSuperView.midX - 77
                }
                
                mostRecentSelectedCellDate = rightMostDate! as NSDate
                rightDateTimeArrays.removeAllObjects()
                
                timeOfDayTableView.center = CGPoint(x: timeOfDayTableX, y: timeOfDayTableY)
                animateTimeOfDayTableIn()
            }
            
        }
        
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["selected_dates"] = selectedDates as [NSDate]
        SavedPreferencesForTrip["Availability_segment_lengths"] = lengthOfAvailabilitySegmentsArray as [NSNumber]
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
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
    
    func animateTimeOfDayTableIn(){
        timeOfDayTableView.isHidden = false
        timeOfDayTableView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        timeOfDayTableView.alpha = 0
        
        if self.leftDates.count == self.rightDates.count && (self.leftDates.count != 0 || self.rightDates.count != 0) {
            self.subviewDoneButton.isHidden = false
        }
        
        UIView.animate(withDuration: 0.4) {
            self.popupBackgroundView.isHidden = false
            self.timeOfDayTableView.alpha = 1
            self.timeOfDayTableView.transform = CGAffineTransform.identity
        }
    }
    
    func dismissTimeOfDayTableOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.timeOfDayTableView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.timeOfDayTableView.alpha = 0
            let selectedRows = self.timeOfDayTableView.indexPathsForSelectedRows
            self.popupBackgroundView.isHidden = true
            for rowIndex in selectedRows! {
                self.timeOfDayTableView.deselectRow(at: rowIndex, animated: false)
            }
            if self.leftDates.count == self.rightDates.count && (self.leftDates.count != 0 || self.rightDates.count != 0) {
                self.subviewDoneButton.isHidden = false
            }
        }) { (Success:Bool) in
            self.timeOfDayTableView.isHidden = true
            self.dateEditing = "returnDate"
                UIView.animate(withDuration: 0.2) {
                    self.popupSubview.center = CGPoint(x: 188, y: 460)
                }
        }
    }
}
