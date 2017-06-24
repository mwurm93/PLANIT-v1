//
//  flightSearchQuestionView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/21/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class FlightSearchQuestionView: UIView, UITextFieldDelegate {
    //Class vars
    var rankedPotentialTripsDictionary = [Dictionary<String, Any>]()
    var rankedPotentialTripsDictionaryArrayIndex = 0
    var searchMode = "roundtrip"
    var questionLabel: UILabel?
    var searchButton: UIButton?
    var departureOrigin: UITextField?
    var departureDestination: UITextField?
    var departureDate: UITextField?
    var returnDate: UITextField?
    var returnOrigin: UITextField?
    var returnDestination: UITextField?
    var alreadyHaveFlightsQuestionLabel: UILabel?
    var alreadyHaveFlightsDepartureDate: UITextField?
    var alreadyHaveFlightsDepartureFlightNumber: UITextField?
    var alreadyHaveFlightsReturnDate: UITextField?
    var alreadyHaveFlightsReturnFlightNumber: UITextField?
    var addButton: UIButton?
    
    // MARK: Outlets
    @IBOutlet weak var searchModeControl: UISegmentedControl!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addViews()
        
        //        self.layer.borderColor = UIColor.green.cgColor
        //        self.layer.borderWidth = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
//
        questionLabel?.frame = CGRect(x: 10, y: 20, width: bounds.size.width - 20, height: 50)
        
        departureDate?.frame = CGRect(x: (bounds.size.width-303-18*2)/2, y: 95, width: 101, height: 30)
        departureDate?.setBottomBorder(borderColor: UIColor.white)
        
        departureOrigin?.frame = CGRect(x: (departureDate?.frame.maxX)! + 18, y: 95, width: 101, height: 30)
        departureOrigin?.setBottomBorder(borderColor: UIColor.white)

        departureDestination?.frame = CGRect(x: (departureOrigin?.frame.maxX)! + 18, y: 95, width: 101, height: 30)
        departureDestination?.setBottomBorder(borderColor: UIColor.white)
        
        returnDate?.frame = CGRect(x: (bounds.size.width-303-18*2)/2, y: 170, width: 101, height: 30)
        returnDate?.setBottomBorder(borderColor: UIColor.white)
        
        returnOrigin?.frame = CGRect(x: (returnDate?.frame.maxX)! + 18, y: 170, width: 101, height: 30)
        returnOrigin?.setBottomBorder(borderColor: UIColor.white)

        returnDestination?.frame = CGRect(x: (returnOrigin?.frame.maxX)! + 18, y: 170, width: 101, height: 30)
        returnDestination?.setBottomBorder(borderColor: UIColor.white)
        
        searchButton?.sizeToFit()
        searchButton?.frame.size.height = 30
        searchButton?.frame.size.width += 20
        searchButton?.frame.origin.x = (bounds.size.width - (searchButton?.frame.width)!) / 2
        searchButton?.frame.origin.y = 330
        searchButton?.layer.cornerRadius = (searchButton?.frame.height)! / 2
        
        alreadyHaveFlightsQuestionLabel?.frame = CGRect(x: 10, y: 380, width: bounds.size.width - 20, height: 75)

        alreadyHaveFlightsDepartureDate?.frame = CGRect(x: (bounds.size.width-300-25)/2, y: 460, width: 150, height: 30)
        alreadyHaveFlightsDepartureDate?.setBottomBorder(borderColor: UIColor.white)
        
        alreadyHaveFlightsDepartureFlightNumber?.frame = CGRect(x: (alreadyHaveFlightsDepartureDate?.frame.maxX)! + 25, y: 460, width: 150, height: 30)
        alreadyHaveFlightsDepartureFlightNumber?.setBottomBorder(borderColor: UIColor.white)
        
        alreadyHaveFlightsReturnDate?.frame = CGRect(x: (bounds.size.width-300-25)/2, y: 515, width: 150, height: 30)
        alreadyHaveFlightsReturnDate?.setBottomBorder(borderColor: UIColor.white)
        
        alreadyHaveFlightsReturnFlightNumber?.frame = CGRect(x: (alreadyHaveFlightsReturnDate?.frame.maxX)! + 25, y: 515, width: 150, height: 30)
        alreadyHaveFlightsReturnFlightNumber?.setBottomBorder(borderColor: UIColor.white)
        
        addButton?.sizeToFit()
        addButton?.frame.size.height = 30
        addButton?.frame.size.width += 20
        addButton?.frame.origin.x = (bounds.size.width - (addButton?.frame.width)!) / 2
        addButton?.frame.origin.y = 560
        addButton?.layer.cornerRadius = (addButton?.frame.height)! / 2
        
    }
    
    
    func addViews() {
        //Question label
        questionLabel = UILabel(frame: CGRect.zero)
        questionLabel?.translatesAutoresizingMaskIntoConstraints = false
        questionLabel?.numberOfLines = 0
        questionLabel?.textAlignment = .center
        questionLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        questionLabel?.textColor = UIColor.white
        questionLabel?.adjustsFontSizeToFitWidth = true
        questionLabel?.text = "Search for flights"
        self.addSubview(questionLabel!)

        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                rankedPotentialTripsDictionary = rankedPotentialTripsDictionaryFromSingleton as! [Dictionary<String, AnyObject>]
                for i in 0 ... rankedPotentialTripsDictionary.count - 1 {
                    if rankedPotentialTripsDictionary[i]["destination"] as! String == (SavedPreferencesForTrip["destinationsForTrip"] as! [String])[0] {
                        rankedPotentialTripsDictionaryArrayIndex = i
                    }
                }
            }
        }
                
        if let leftDateTimeArrays = SavedPreferencesForTrip["origin_departure_times"]  as? NSMutableDictionary {
            if let rightDateTimeArrays = SavedPreferencesForTrip["return_departure_times"] as? NSMutableDictionary {
                let departureDictionary = leftDateTimeArrays as Dictionary
                let returnDictionary = rightDateTimeArrays as Dictionary
                let departureKeys = Array(departureDictionary.keys)
                let returnKeys = Array(returnDictionary.keys)
                if returnKeys.count != 0 {
                    let returnDateValue = returnKeys[0]
                    returnDate?.text =  "\(returnDateValue)"
                }
                if departureKeys.count != 0 {
                    let departureDateValue = departureKeys[0]
                    departureDate?.text =  "\(departureDateValue)"
                }
            }
        }
        
        //Button
        searchButton = UIButton(type: .custom)
        searchButton?.frame = CGRect.zero
        searchButton?.setTitleColor(UIColor.white, for: .normal)
        searchButton?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        searchButton?.setTitleColor(UIColor.white, for: .selected)
        searchButton?.setBackgroundColor(color: (UIColor()).getCustomBlueColor(), forState: .selected)
        searchButton?.layer.borderWidth = 1
        searchButton?.layer.borderColor = UIColor.white.cgColor
        searchButton?.layer.masksToBounds = true
        searchButton?.titleLabel?.textAlignment = .center
        searchButton?.setTitle("Search", for: .normal)
        searchButton?.setTitle("Search", for: .selected)
        searchButton?.translatesAutoresizingMaskIntoConstraints = false
        searchButton?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(searchButton!)
        
        //Button
        addButton = UIButton(type: .custom)
        addButton?.frame = CGRect.zero
        addButton?.setTitleColor(UIColor.white, for: .normal)
        addButton?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        addButton?.setTitleColor(UIColor.white, for: .selected)
        addButton?.setBackgroundColor(color: (UIColor()).getCustomBlueColor(), forState: .selected)
        addButton?.layer.borderWidth = 1
        addButton?.layer.borderColor = UIColor.white.cgColor
        addButton?.layer.masksToBounds = true
        addButton?.titleLabel?.textAlignment = .center
        addButton?.setTitle("Save", for: .normal)
        addButton?.setTitle("Save", for: .selected)
        addButton?.translatesAutoresizingMaskIntoConstraints = false
        addButton?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(addButton!)

        
        
        //Textfield
        departureDate = UITextField(frame: CGRect.zero)
        departureDate?.delegate = self
        departureDate?.textColor = UIColor.white
        departureDate?.borderStyle = .none
        departureDate?.layer.masksToBounds = true
        departureDate?.textAlignment = .center
        departureDate?.returnKeyType = .next
        let departureDatePlaceholder = NSAttributedString(string: "Leave when?", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6),NSFontAttributeName: UIFont.systemFont(ofSize: 16)])
        departureDate?.attributedPlaceholder = departureDatePlaceholder
        departureDate?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(departureDate!)
        
        //Textfield
        departureOrigin = UITextField(frame: CGRect.zero)
        departureOrigin?.delegate = self
        departureOrigin?.textColor = UIColor.white
        departureOrigin?.borderStyle = .none
        departureOrigin?.layer.masksToBounds = true
        departureOrigin?.textAlignment = .center
        departureOrigin?.returnKeyType = .next
        let departureOriginPlaceholder = NSAttributedString(string: "From where?", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6),NSFontAttributeName: UIFont.systemFont(ofSize: 16)])
        departureOrigin?.attributedPlaceholder = departureOriginPlaceholder
        let departureOriginValue = DataContainerSingleton.sharedDataContainer.homeAirport
        if departureOriginValue != nil && departureOriginValue != "" {
            departureOrigin?.text = departureOriginValue
        }
        departureOrigin?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(departureOrigin!)
        
        //Textfield
        departureDestination = UITextField(frame: CGRect.zero)
        departureDestination?.delegate = self
        departureDestination?.textColor = UIColor.white
        departureDestination?.borderStyle = .none
        departureDestination?.layer.masksToBounds = true
        departureDestination?.textAlignment = .center
        departureDestination?.returnKeyType = .next
        let departureDestinationPlaceholder = NSAttributedString(string: "To where?", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6),NSFontAttributeName: UIFont.systemFont(ofSize: 16)])
        departureDestination?.attributedPlaceholder = departureDestinationPlaceholder
        let departureDestinationValue = (SavedPreferencesForTrip["destinationsForTrip"] as? [String])?[0]
        if departureDestinationValue != nil && departureDestinationValue != "" {
            departureDestination?.text = departureDestinationValue
        }
        departureDestination?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(departureDestination!)
        
        //Textfield
        returnDate = UITextField(frame: CGRect.zero)
        returnDate?.delegate = self
        returnDate?.textColor = UIColor.white
        returnDate?.borderStyle = .none
        returnDate?.layer.masksToBounds = true
        returnDate?.textAlignment = .center
        returnDate?.returnKeyType = .next
        let returnDatePlaceholder = NSAttributedString(string: "Return when?", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6),NSFontAttributeName: UIFont.systemFont(ofSize: 16)])
        returnDate?.attributedPlaceholder = returnDatePlaceholder
        returnDate?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(returnDate!)
        
        //Textfield
        returnOrigin = UITextField(frame: CGRect.zero)
        returnOrigin?.delegate = self
        returnOrigin?.textColor = UIColor.white
        returnOrigin?.borderStyle = .none
        returnOrigin?.layer.masksToBounds = true
        returnOrigin?.textAlignment = .center
        returnOrigin?.returnKeyType = .next
        let returnOriginPlaceholder = NSAttributedString(string: "From where?", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6),NSFontAttributeName: UIFont.systemFont(ofSize: 16)])
        returnOrigin?.attributedPlaceholder = returnOriginPlaceholder
        let returnOriginValue = (SavedPreferencesForTrip["destinationsForTrip"] as? [String])?[0]
        if returnOriginValue != nil && returnOriginValue != "" {
            returnOrigin?.text = returnOriginValue
        }

        returnOrigin?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(returnOrigin!)

        //Textfield
        returnDestination = UITextField(frame: CGRect.zero)
        returnDestination?.delegate = self
        returnDestination?.textColor = UIColor.white
        returnDestination?.borderStyle = .none
        returnDestination?.layer.masksToBounds = true
        returnDestination?.textAlignment = .center
        returnDestination?.returnKeyType = .next
        let returnDestinationPlaceholder = NSAttributedString(string: "To where?", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6),NSFontAttributeName: UIFont.systemFont(ofSize: 16)])
        returnDestination?.attributedPlaceholder = returnDestinationPlaceholder
//        let returnDestinationValue = DataContainerSingleton.sharedDataContainer.homeAirport
//        if returnDestinationValue != nil && returnDestinationValue != "" {
//            returnDestination?.text = returnDestinationValue
//        }
        returnDestination?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(returnDestination!)
        
        //Textfield
        alreadyHaveFlightsDepartureDate = UITextField(frame: CGRect.zero)
        alreadyHaveFlightsDepartureDate?.delegate = self
        alreadyHaveFlightsDepartureDate?.textColor = UIColor.white
        alreadyHaveFlightsDepartureDate?.borderStyle = .none
        alreadyHaveFlightsDepartureDate?.layer.masksToBounds = true
        alreadyHaveFlightsDepartureDate?.textAlignment = .center
        alreadyHaveFlightsDepartureDate?.returnKeyType = .next
        let alreadyHaveFlightsDepartureDatePlaceholder = NSAttributedString(string: "MM/DD/YYYY", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6),NSFontAttributeName: UIFont.systemFont(ofSize: 16)])
        alreadyHaveFlightsDepartureDate?.attributedPlaceholder = alreadyHaveFlightsDepartureDatePlaceholder
        alreadyHaveFlightsDepartureDate?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(alreadyHaveFlightsDepartureDate!)

        alreadyHaveFlightsDepartureFlightNumber = UITextField(frame: CGRect.zero)
        alreadyHaveFlightsDepartureFlightNumber?.delegate = self
        alreadyHaveFlightsDepartureFlightNumber?.textColor = UIColor.white
        alreadyHaveFlightsDepartureFlightNumber?.borderStyle = .none
        alreadyHaveFlightsDepartureFlightNumber?.layer.masksToBounds = true
        alreadyHaveFlightsDepartureFlightNumber?.textAlignment = .center
        alreadyHaveFlightsDepartureFlightNumber?.returnKeyType = .next
        let alreadyHaveFlightsDepartureFlightNumberPlaceholder = NSAttributedString(string: "Flight #", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6),NSFontAttributeName: UIFont.systemFont(ofSize: 16)])
        alreadyHaveFlightsDepartureFlightNumber?.attributedPlaceholder = alreadyHaveFlightsDepartureFlightNumberPlaceholder
        alreadyHaveFlightsDepartureFlightNumber?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(alreadyHaveFlightsDepartureFlightNumber!)

        //Textfield
        alreadyHaveFlightsReturnDate = UITextField(frame: CGRect.zero)
        alreadyHaveFlightsReturnDate?.delegate = self
        alreadyHaveFlightsReturnDate?.textColor = UIColor.white
        alreadyHaveFlightsReturnDate?.borderStyle = .none
        alreadyHaveFlightsReturnDate?.layer.masksToBounds = true
        alreadyHaveFlightsReturnDate?.textAlignment = .center
        alreadyHaveFlightsReturnDate?.returnKeyType = .next
        let alreadyHaveFlightsReturnDatePlaceholder = NSAttributedString(string: "MM/DD/YYYY", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6),NSFontAttributeName: UIFont.systemFont(ofSize: 16)])
        alreadyHaveFlightsReturnDate?.attributedPlaceholder = alreadyHaveFlightsReturnDatePlaceholder
        alreadyHaveFlightsReturnDate?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(alreadyHaveFlightsReturnDate!)
        
        alreadyHaveFlightsReturnFlightNumber = UITextField(frame: CGRect.zero)
        alreadyHaveFlightsReturnFlightNumber?.delegate = self
        alreadyHaveFlightsReturnFlightNumber?.textColor = UIColor.white
        alreadyHaveFlightsReturnFlightNumber?.borderStyle = .none
        alreadyHaveFlightsReturnFlightNumber?.layer.masksToBounds = true
        alreadyHaveFlightsReturnFlightNumber?.textAlignment = .center
        alreadyHaveFlightsReturnFlightNumber?.returnKeyType = .next
        let alreadyHaveFlightsReturnFlightNumberPlaceholder = NSAttributedString(string: "Flight #", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6),NSFontAttributeName: UIFont.systemFont(ofSize: 16)])
        alreadyHaveFlightsReturnFlightNumber?.attributedPlaceholder = alreadyHaveFlightsReturnFlightNumberPlaceholder
        alreadyHaveFlightsReturnFlightNumber?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(alreadyHaveFlightsReturnFlightNumber!)
        
        handleSearchMode()
        
        //Question label
        alreadyHaveFlightsQuestionLabel = UILabel(frame: CGRect.zero)
        alreadyHaveFlightsQuestionLabel?.translatesAutoresizingMaskIntoConstraints = false
        alreadyHaveFlightsQuestionLabel?.numberOfLines = 0
        alreadyHaveFlightsQuestionLabel?.textAlignment = .center
        alreadyHaveFlightsQuestionLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        alreadyHaveFlightsQuestionLabel?.textColor = UIColor.white
        alreadyHaveFlightsQuestionLabel?.adjustsFontSizeToFitWidth = true
        alreadyHaveFlightsQuestionLabel?.text = "If you already have flights, enter them here to share with your group."
        self.addSubview(alreadyHaveFlightsQuestionLabel!)


    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        departureDestination?.resignFirstResponder()
        departureOrigin?.resignFirstResponder()
        
        returnDestination?.resignFirstResponder()
        returnOrigin?.resignFirstResponder()
        
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == departureDate {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "animateInDatePickingSubview_Departure"), object: nil)
            return false
        } else if textField == returnDate {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "animateInDatePickingSubview_Departure"), object: nil)
            return false
        }

        return true
    }
    func handleSearchMode() {
        if searchMode == "oneWay" {
            self.returnOrigin?.isHidden = true
            self.returnDestination?.isHidden = true
            self.returnDate?.isHidden = true
        } else if searchMode == "roundtrip" {
            self.returnOrigin?.isHidden = true
            self.returnDestination?.isHidden = true
            self.returnDate?.isHidden = false
        } else if searchMode == "multiCity" {
            self.returnOrigin?.isHidden = false
            self.returnDestination?.isHidden = false
            self.returnDate?.isHidden = false
        }
    }
    
    func buttonClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true {
            sender.layer.borderWidth = 0
        } else {
            sender.layer.borderWidth = 1
        }
    }
    
    
    // MARK: Actions
    @IBAction func searchModeControlValueChanged(_ sender: Any) {
        if searchModeControl.selectedSegmentIndex == 0 {
            searchMode = "oneWay"
        } else if searchModeControl.selectedSegmentIndex == 1 {
            searchMode = "roundtrip"
        } else {
            searchMode = "multiCity"
        }
        handleSearchMode()
    }
    @IBAction func multiCityButtonTouchedUpInside(_ sender: Any) {
    }
    @IBAction func roundtripButtonTouchedUpInside(_ sender: Any) {
    }
    @IBAction func oneWayButtonTouchedUpInside(_ sender: Any) {
    }
    
//    @IBAction func subviewDoneButtonTouchedUpInside(_ sender: Any) {
//        animateOutSubview()
//    }
    @IBAction func searchFlightsButtonTouchedUpInside(_ sender: Any) {
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == departureOrigin || textField == returnOrigin || textField == departureDestination || textField == returnDestination {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "animateOutDatePickingSubview"), object: nil)
        }
    }

}
