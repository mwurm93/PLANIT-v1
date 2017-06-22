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
//    var questionLabel: UILabel?
    
    // MARK: Outlets
    @IBOutlet weak var underline: UIImageView!
    @IBOutlet weak var departureOrigin: UITextField!
    @IBOutlet weak var departureDestination: UITextField!
    @IBOutlet weak var departureDate: UITextField!
    @IBOutlet weak var returnDate: UITextField!
    @IBOutlet weak var returnOrigin: UITextField!
    @IBOutlet weak var returnDestination: UITextField!
    @IBOutlet weak var returnDateLabel: UILabel!
    @IBOutlet weak var returnOriginLabel: UILabel!
    @IBOutlet weak var returnDestinationLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    
    
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
//        let bounds = UIScreen.main.bounds
//        
//        questionLabel?.frame = CGRect(x: 10, y: 40, width: bounds.size.width - 20, height: 50)
        
    }
    
    
    func addViews() {
//        //Question label
//        questionLabel = UILabel(frame: CGRect.zero)
//        questionLabel?.translatesAutoresizingMaskIntoConstraints = false
//        questionLabel?.numberOfLines = 0
//        questionLabel?.textAlignment = .center
//        questionLabel?.font = UIFont.boldSystemFont(ofSize: 25)
//        questionLabel?.textColor = UIColor.white
//        questionLabel?.adjustsFontSizeToFitWidth = true
//        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//        var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])
//        if destinationsForTrip.count != 0 {
//            questionLabel?.text = "How do you want to get to \(destinationsForTrip[0])?"
//        }
//        self.addSubview(questionLabel!)
//        
//   
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
        
        self.underline.layer.frame = CGRect(x: 132, y: 33, width: 98, height: 51)
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
        
        
        let departureDestinationValue = rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex]["destination"] as! String
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
        let returnOriginValue = rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex]["destination"] as! String
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
    
    // MARK: Actions
    @IBAction func multiCityButtonTouchedUpInside(_ sender: Any) {
        UIView.animate(withDuration: 0.4) {
            self.underline.layer.frame = CGRect(x: 239, y: 33, width: 98, height: 51)
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
            self.underline.layer.frame = CGRect(x: 132, y: 33, width: 98, height: 51)
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
            self.underline.layer.frame = CGRect(x: 24, y: 33, width: 98, height: 51)
            self.returnOrigin.isHidden = true
            self.returnOriginLabel.isHidden = true
            self.returnDestination.isHidden = true
            self.returnDestinationLabel.isHidden = true
            self.returnDate.isHidden = true
            self.returnDateLabel.isHidden = true
        }
        searchMode = "oneWay"
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
