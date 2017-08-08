//
//  CarRentalSearchQuestionView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/23/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class CarRentalSearchQuestionView: UIView, UITextFieldDelegate {
    //Class vars
    var rankedPotentialTripsDictionary = [Dictionary<String, Any>]()
    var rankedPotentialTripsDictionaryArrayIndex = 0
    var searchMode = "Same drop-off"
    var rentalMode = "At destination"

    var questionLabel: UILabel?
    var origin: UITextField?
    var differentDropOff: UITextField?
    var pickUpDate: UITextField?
    var dropOffDate: UITextField?
    var searchButton: UIButton?
    
    var formatter = DateFormatter()

    
    
    //MARK: Outlets
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
        saveIsRoundTrip(isRoundtrip: true)
        
        //        self.layer.borderColor = UIColor.green.cgColor
        //        self.layer.borderWidth = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
        
        questionLabel?.frame = CGRect(x: 10, y: 20, width: bounds.size.width - 20, height: 35)
        
        pickUpDate?.frame = CGRect(x: (bounds.size.width-300-25)/2, y: 95, width: 150, height: 30)
        pickUpDate?.setBottomBorder(borderColor: UIColor.white)
        
        origin?.frame = CGRect(x: (pickUpDate?.frame.maxX)! + 25, y: 95, width: 150, height: 30)
        origin?.setBottomBorder(borderColor: UIColor.white)

        dropOffDate?.frame = CGRect(x: (bounds.size.width-300-25)/2, y: 170, width: 150, height: 30)
        dropOffDate?.setBottomBorder(borderColor: UIColor.white)
        
        differentDropOff?.frame = CGRect(x: (dropOffDate?.frame.maxX)! + 25, y: 170, width: 150, height: 30)
        differentDropOff?.setBottomBorder(borderColor: UIColor.white)
        
        searchButton?.sizeToFit()
        searchButton?.frame.size.height = 30
        searchButton?.frame.size.width += 20
        searchButton?.frame.origin.x = (bounds.size.width - (searchButton?.frame.width)!) / 2
        searchButton?.frame.origin.y = 330
        searchButton?.layer.cornerRadius = (searchButton?.frame.height)! / 2
        
        //UPDATE DATES
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var datesDestinationsDictionary = SavedPreferencesForTrip["datesDestinationsDictionary"] as! [String:[Date]]
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])
        
        var leftDatesDestinations = [String:Date]()
        var rightDatesDestinations = [String:Date]()
        
        if datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned]] != nil {
            leftDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned]] = datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned]]?[0]
            rightDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned]] = datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned]]?[(datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned]]?.count)! - 1]
            formatter.dateFormat = "MM/dd/YYYY"
            let leftDateAsString = formatter.string(from: leftDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned]]!)
            let rightDateAsString = formatter.string(from: rightDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned]]!)
            pickUpDate?.text = leftDateAsString
            dropOffDate?.text = rightDateAsString
        }
        
    }
    
    
    func addViews() {
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

        
        //Question label
        questionLabel = UILabel(frame: CGRect.zero)
        questionLabel?.translatesAutoresizingMaskIntoConstraints = false
        questionLabel?.numberOfLines = 0
        questionLabel?.textAlignment = .center
        questionLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        questionLabel?.textColor = UIColor.white
        questionLabel?.adjustsFontSizeToFitWidth = true
        questionLabel?.text = "Search for rental cars"
        self.addSubview(questionLabel!)
        
        //Textfield
        origin = UITextField(frame: CGRect.zero)
        origin?.delegate = self
        origin?.textColor = UIColor.white
        origin?.borderStyle = .none
        origin?.layer.masksToBounds = true
        origin?.textAlignment = .center
        origin?.returnKeyType = .next
        let originPlaceholder = NSAttributedString(string: "Pick-up where?", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6)])
        origin?.attributedPlaceholder = originPlaceholder
        if rentalMode == "At destination" {
            let departureDestinationValue = (SavedPreferencesForTrip["destinationsForTrip"] as? [String])?[0]
            if departureDestinationValue != nil && departureDestinationValue != "" {
                origin?.text = departureDestinationValue
            }
        } else {
            let departureOriginValue = DataContainerSingleton.sharedDataContainer.homeAirport
            if departureOriginValue != nil && departureOriginValue != "" {
                origin?.text = departureOriginValue
            }
        }
        origin?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(origin!)
        
        //Textfield
        pickUpDate = UITextField(frame: CGRect.zero)
        pickUpDate?.delegate = self
        pickUpDate?.textColor = UIColor.white
        pickUpDate?.borderStyle = .none
        pickUpDate?.layer.masksToBounds = true
        pickUpDate?.textAlignment = .center
        pickUpDate?.returnKeyType = .next
        let pickUpDatePlaceholder = NSAttributedString(string: "Pick-up when?", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6)])
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
        let differentDropOffPlaceholder = NSAttributedString(string: "Drop-off where?", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6)])
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
        let dropOffDatePlaceholder = NSAttributedString(string: "Drop-off when?", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6)])
        dropOffDate?.attributedPlaceholder = dropOffDatePlaceholder
        dropOffDate?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(dropOffDate!)
        
        //Button
        searchButton = UIButton(type: .custom)
        searchButton?.frame = CGRect.zero
        searchButton?.setTitleColor(UIColor.white, for: .normal)
        searchButton?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        searchButton?.layer.borderWidth = 1
        searchButton?.layer.borderColor = UIColor.white.cgColor
        searchButton?.layer.masksToBounds = true
        searchButton?.titleLabel?.textAlignment = .center
        searchButton?.setTitle("Search", for: .normal)
        searchButton?.translatesAutoresizingMaskIntoConstraints = false
        searchButton?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(searchButton!)
        
        if searchMode == "Same drop-off" {
            differentDropOff?.isHidden = true
        } else {
            differentDropOff?.isHidden = false
        }
    }
    
    func buttonClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.setButtonWithTransparentText(button: sender, title: sender.currentTitle as! NSString, color: UIColor.white)
        } else {
            sender.removeMask(button:sender, color: UIColor.white)
        }
        for subview in self.subviews {
            if subview.isKind(of: UIButton.self) && subview != sender {
                (subview as! UIButton).isSelected = false
                (subview as! UIButton).removeMask(button: subview as! UIButton, color: UIColor.white)
            }
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        origin?.resignFirstResponder()
        differentDropOff?.resignFirstResponder()
        
        dropOffDate?.resignFirstResponder()
        pickUpDate?.resignFirstResponder()
        
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == pickUpDate || textField == dropOffDate {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "animateInDatePickingSubview_Departure"), object: nil)
            return false
        }
        return true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == origin || textField == differentDropOff {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "animateOutDatePickingSubview"), object: nil)
        }
    }

    func handleSearchMode() {
        if searchModeControl.selectedSegmentIndex == 0 {
            searchMode = "Same drop-off"
            differentDropOff?.isHidden = true
        } else {
            searchMode = "Different drop-off"
            differentDropOff?.isHidden = false
        }
    }
    func saveIsRoundTrip(isRoundtrip:Bool)  {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        
        var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
        travelDictionaryArray[indexOfDestinationBeingPlanned]["isRoundtrip"] = isRoundtrip
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
    }
    
    @IBAction func searchModeControlValueChanged(_ sender: Any) {
        handleSearchMode()
        if searchModeControl.selectedSegmentIndex == 0 {
            saveIsRoundTrip(isRoundtrip: true)
        } else {
            saveIsRoundTrip(isRoundtrip: false)
        }
    }
    
}
