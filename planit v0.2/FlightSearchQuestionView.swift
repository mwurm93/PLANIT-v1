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
    var departureOrigin: UITextField
    var departureDestination: UITextField
    var departureDate: UITextField
    var returnDate: UITextField
    var returnOrigin: UITextField
    var returnDestination: UITextFi
    
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
        
        searchButton?.sizeToFit()
        searchButton?.frame.size.height = 30
        searchButton?.frame.size.width += 20
        searchButton?.frame.origin.x = (bounds.size.width - (searchButton?.frame.width)!) / 2
        searchButton?.frame.origin.y = 270
        searchButton?.layer.cornerRadius = (searchButton?.frame.height)! / 2
        
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
        
        handleSearchMode()
        
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
        
        //Button
        searchButton = UIButton(type: .custom)
        searchButton?.frame = CGRect.zero
        searchButton?.setTitleColor(UIColor.white, for: .normal)
        searchButton?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        searchButton?.setTitleColor(UIColor.white, for: .selected)
        searchButton?.setBackgroundColor(color: UIColor.blue, forState: .selected)
        searchButton?.layer.borderWidth = 1
        searchButton?.layer.borderColor = UIColor.white.cgColor
        searchButton?.layer.masksToBounds = true
        searchButton?.titleLabel?.textAlignment = .center
        searchButton?.setTitle("Search", for: .normal)
        searchButton?.setTitle("Search", for: .selected)
        searchButton?.translatesAutoresizingMaskIntoConstraints = false
        searchButton?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(searchButton!)
        
        
        //Textfield
        departureDate = UITextField(frame: CGRect.zero)
        departureDate?.delegate = self
        departureDate?.textColor = UIColor.white
        departureDate?.borderStyle = .none
        departureDate?.layer.masksToBounds = true
        departureDate?.textAlignment = .center
        departureDate?.returnKeyType = .next
        let departureDatePlaceholder = NSAttributedString(string: "Departure date", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6)])
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
        let pickUpDatePlaceholder = NSAttributedString(string: "Pick-up date", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6)])
        pickUpDate?.attributedPlaceholder = pickUpDatePlaceholder
        pickUpDate?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(pickUpDate!)
        
        //Textfield
        differentDropOff = UITextField(frame: CGRect.zero)
        differentDropOff?.delegate = self
        differentDropOff?.textColor = UIColor.white
        differentDropOff?.borderStyle = .none
        differentDropOff?.layer.masksToBounds = true
        differentDropOff?.textAlignment = .center
        differentDropOff?.returnKeyType = .next
        let differentDropOffPlaceholder = NSAttributedString(string: "Drop-off location", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6)])
        differentDropOff?.attributedPlaceholder = differentDropOffPlaceholder
        differentDropOff?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(differentDropOff!)
        
        //Textfield
        dropOffDate = UITextField(frame: CGRect.zero)
        dropOffDate?.delegate = self
        dropOffDate?.textColor = UIColor.white
        dropOffDate?.borderStyle = .none
        dropOffDate?.layer.masksToBounds = true
        dropOffDate?.textAlignment = .center
        dropOffDate?.returnKeyType = .next
        let dropOffDatePlaceholder = NSAttributedString(string: "Drop-off date", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6)])
        dropOffDate?.attributedPlaceholder = dropOffDatePlaceholder
        dropOffDate?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(dropOffDate!)
        

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
            self.returnOrigin.isHidden = true
            self.returnDestination.isHidden = true
            self.returnDate.isHidden = true
        } else if searchMode == "roundtrip" {
            self.returnOrigin.isHidden = true
            self.returnDestination.isHidden = true
            self.returnDate.isHidden = false
        } else if searchMode == "multiCity" {
            self.returnOrigin.isHidden = false
            self.returnDestination.isHidden = false
            self.returnDate.isHidden = false
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
