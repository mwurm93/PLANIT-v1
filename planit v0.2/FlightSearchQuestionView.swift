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
    var searchMode = "roundtrip"
    var questionLabel: UILabel?
    var searchButton: UIButton?
    var departureOrigin: UITextField?
    var departureDestination: UITextField?
    var departureDate: UITextField?
    var returnDate: UITextField?
    var returnOrigin: UITextField?
    var returnDestination: UITextField?
    var addButton: UIButton?
    
    var formatter = DateFormatter()
    
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
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])
        if destinationsForTrip.count == 1 {
            saveIsRoundTrip(isRoundtrip:true)
        } else if destinationsForTrip.count > 1 {
            saveIsRoundTrip(isRoundtrip:false)
        }
        
        //        self.layer.borderColor = UIColor.green.cgColor
        //        self.layer.borderWidth = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
//
        questionLabel?.frame = CGRect(x: 10, y: 40, width: bounds.size.width - 20, height: 50)
        
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
        
        addButton?.sizeToFit()
        addButton?.frame.size.height = 30
        addButton?.frame.size.width += 20
        addButton?.frame.origin.x = (bounds.size.width - (addButton?.frame.width)!) / 2
        addButton?.frame.origin.y = 380
        addButton?.layer.cornerRadius = (addButton?.frame.height)! / 2
        
        
        //UPDATE DATES
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var datesDestinationsDictionary = SavedPreferencesForTrip["datesDestinationsDictionary"] as! [String:[Date]]
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])

        var leftDatesDestinations = [String:Date]()
        var rightDatesDestinations = [String:Date]()
        
        if indexOfDestinationBeingPlanned < destinationsForTrip.count {
            if datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned]] != nil {
                leftDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned]] = datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned]]?[0]
                rightDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned]] = datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned]]?[(datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned]]?.count)! - 1]
                formatter.dateFormat = "MM/dd/YYYY"
                let leftDateAsString = formatter.string(from: leftDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned]]!)
                let rightDateAsString = formatter.string(from: rightDatesDestinations[destinationsForTrip[indexOfDestinationBeingPlanned]]!)
                departureDate?.text = leftDateAsString
                returnDate?.text = rightDateAsString
            }
        }
        
        //UPDATE DESTINATIONS
        var departureOriginValue = String()
        if indexOfDestinationBeingPlanned == 0 {
            departureOriginValue = DataContainerSingleton.sharedDataContainer.homeAirport!
        } else {
            departureOriginValue = ((SavedPreferencesForTrip["destinationsForTrip"] as? [String])?[indexOfDestinationBeingPlanned - 1])!
        }
        if departureOriginValue != "" {
            departureOrigin?.text = departureOriginValue
        }
        if indexOfDestinationBeingPlanned < destinationsForTrip.count {
            let returnOriginValue = (SavedPreferencesForTrip["destinationsForTrip"] as? [String])?[indexOfDestinationBeingPlanned]
            if returnOriginValue != nil && returnOriginValue != "" {
                returnOrigin?.text = returnOriginValue
            }
            
            let departureDestinationValue = (SavedPreferencesForTrip["destinationsForTrip"] as? [String])?[indexOfDestinationBeingPlanned]
            if departureDestinationValue != nil && departureDestinationValue != "" {
                departureDestination?.text = departureDestinationValue
            }
        }
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
        
        //Button
        addButton = UIButton(type: .custom)
        addButton?.frame = CGRect.zero
        addButton?.setTitleColor(UIColor.lightGray, for: .normal)
        addButton?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        addButton?.layer.borderWidth = 1
        addButton?.layer.borderColor = UIColor.lightGray.cgColor
        addButton?.layer.masksToBounds = true
        addButton?.titleLabel?.textAlignment = .center
        addButton?.setTitle("Already have flights", for: .normal)
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
        returnDestination?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(returnDestination!)        
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
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var datesDestinationsDictionary = SavedPreferencesForTrip["datesDestinationsDictionary"] as! [String:[Date]]
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])
        
        if textField == departureOrigin {
            //UPDATE DESTINATIONS
            if indexOfDestinationBeingPlanned == 0 {
                DataContainerSingleton.sharedDataContainer.homeAirport = textField.text
            } else {
                let datesOfDestinationForUpdate = datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned - 1]]
                datesDestinationsDictionary.removeValue(forKey: destinationsForTrip[indexOfDestinationBeingPlanned - 1])
                datesDestinationsDictionary[textField.text!] = datesOfDestinationForUpdate
                
                destinationsForTrip[indexOfDestinationBeingPlanned - 1] = textField.text!
                SavedPreferencesForTrip["destinationsForTrip"] = destinationsForTrip
                SavedPreferencesForTrip["datesDestinationsDictionary"] = datesDestinationsDictionary
                saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
            }
        }
        if textField == departureDestination {
            if indexOfDestinationBeingPlanned < destinationsForTrip.count {
                let datesOfDestinationForUpdate = datesDestinationsDictionary[destinationsForTrip[indexOfDestinationBeingPlanned]]
                datesDestinationsDictionary.removeValue(forKey: destinationsForTrip[indexOfDestinationBeingPlanned])
                datesDestinationsDictionary[textField.text!] = datesOfDestinationForUpdate
                
                destinationsForTrip[indexOfDestinationBeingPlanned] = textField.text!
                SavedPreferencesForTrip["destinationsForTrip"] = destinationsForTrip
                SavedPreferencesForTrip["datesDestinationsDictionary"] = datesDestinationsDictionary
                saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
            }
        }
        
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == departureDate || textField == returnDate{
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
            self.searchModeControl.frame.origin.y = 185
            self.searchButton?.frame.origin.y = 260
            self.addButton?.frame.origin.y = 310
        } else if searchMode == "roundtrip" {
            self.returnOrigin?.isHidden = true
            self.returnDestination?.isHidden = true
            self.returnDate?.isHidden = false
            self.searchModeControl.frame.origin.y = 255
            self.searchButton?.frame.origin.y = 330
            self.addButton?.frame.origin.y = 380
        } else if searchMode == "multiCity" {
            self.returnOrigin?.isHidden = false
            self.returnDestination?.isHidden = false
            self.returnDate?.isHidden = false
            self.searchModeControl.frame.origin.y = 255
            self.searchButton?.frame.origin.y = 330
            self.addButton?.frame.origin.y = 380
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
    func saveIsRoundTrip(isRoundtrip:Bool)  {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        
        var travelDictionaryArray = SavedPreferencesForTrip["travelDictionaryArray"] as! [[String:Any]]
        travelDictionaryArray[indexOfDestinationBeingPlanned]["isRoundtrip"] = isRoundtrip
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
    }
}
