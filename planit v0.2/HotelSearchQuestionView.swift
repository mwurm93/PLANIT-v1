//
//  HotelSearchQuestionView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/26/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class HotelSearchQuestionView: UIView, UITextFieldDelegate {
//UIPickerViewDelegate, UIPickerViewDataSource {
    //Class vars
    var rankedPotentialTripsDictionary = [Dictionary<String, Any>]()
    var rankedPotentialTripsDictionaryArrayIndex = 0
    
    var questionLabel: UILabel?
    var destination: UITextField?
    var checkInDate: UITextField?
    var checkOutDate: UITextField?
    var searchButton: UIButton?
    
    var formatter = DateFormatter()
    
    //MARK: Outlets
    @IBOutlet weak var numberOfRoomsPickerView: UIPickerView!
    
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
        
        questionLabel?.frame = CGRect(x: 10, y: 20, width: bounds.size.width - 20, height: 35)
        
        checkInDate?.frame = CGRect(x: (bounds.size.width-300-25)/2, y: 95, width: 150, height: 30)
        checkInDate?.setBottomBorder(borderColor: UIColor.white)
        
        destination?.frame = CGRect(x: (checkInDate?.frame.maxX)! + 25, y: 95, width: 150, height: 30)
        destination?.setBottomBorder(borderColor: UIColor.white)
        
        checkOutDate?.frame = CGRect(x: (bounds.size.width-300-25)/2, y: 170, width: 150, height: 30)
        checkOutDate?.setBottomBorder(borderColor: UIColor.white)
        
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
            checkInDate?.text = leftDateAsString
            checkOutDate?.text = rightDateAsString
        }
        
        
//        numberOfRoomsPickerView.frame = CGRect(x: (checkOutDate?.frame.maxX)! + 25, y: 160, width: 150, height: 50)
//        numberOfRoomsPickerView.setValue(UIColor.white, forKey: "textColor")
//        numberOfRoomsPickerView.subviews[0].subviews[1].backgroundColor = UIColor.white
//        numberOfRoomsPickerView.subviews[0].subviews[2].backgroundColor = UIColor.white

        
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
        questionLabel?.text = "Search for hotels"
        self.addSubview(questionLabel!)
        
        //Textfield
        destination = UITextField(frame: CGRect.zero)
        destination?.delegate = self
        destination?.textColor = UIColor.white
        destination?.borderStyle = .none
        destination?.layer.masksToBounds = true
        destination?.textAlignment = .center
        destination?.returnKeyType = .next
        let destinationPlaceholder = NSAttributedString(string: "Destination", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6)])
        destination?.attributedPlaceholder = destinationPlaceholder
            let departureDestinationValue = (SavedPreferencesForTrip["destinationsForTrip"] as? [String])?[0]
            if departureDestinationValue != nil && departureDestinationValue != "" {
                destination?.text = departureDestinationValue
            }
        destination?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(destination!)
        
        //Textfield
        checkInDate = UITextField(frame: CGRect.zero)
        checkInDate?.delegate = self
        checkInDate?.textColor = UIColor.white
        checkInDate?.borderStyle = .none
        checkInDate?.layer.masksToBounds = true
        checkInDate?.textAlignment = .center
        checkInDate?.returnKeyType = .next
        let checkInDatePlaceholder = NSAttributedString(string: "Check-in when?", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6)])
        checkInDate?.attributedPlaceholder = checkInDatePlaceholder
        checkInDate?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(checkInDate!)
        
        //Textfield
        checkOutDate = UITextField(frame: CGRect.zero)
        checkOutDate?.delegate = self
        checkOutDate?.textColor = UIColor.white
        checkOutDate?.borderStyle = .none
        checkOutDate?.layer.masksToBounds = true
        checkOutDate?.textAlignment = .center
        checkOutDate?.returnKeyType = .next
        let checkOutDatePlaceholder = NSAttributedString(string: "Check-out when?", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6)])
        checkOutDate?.attributedPlaceholder = checkOutDatePlaceholder
        checkOutDate?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(checkOutDate!)
        
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
        
//        self.numberOfRoomsPickerView.delegate = self
//        self.numberOfRoomsPickerView.dataSource = self        
    }
    
    func buttonClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.setButtonWithTransparentText(button: sender, title: sender.currentTitle as! NSString, color: UIColor.white)
        } else {
            sender.removeMask(button:sender)
        }
        for subview in self.subviews {
            if subview.isKind(of: UIButton.self) && subview != sender {
                (subview as! UIButton).isSelected = false
                (subview as! UIButton).removeMask(button: subview as! UIButton)
            }
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        destination?.resignFirstResponder()
        
        checkOutDate?.resignFirstResponder()
        checkInDate?.resignFirstResponder()
        
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == checkInDate || textField == checkOutDate {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "animateInDatePickingSubview_Departure"), object: nil)
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == destination {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "animateOutDatePickingSubview"), object: nil)
        }
    }
    
//    // MARK: UIPickerViewDelegate and Datasource
//    
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        if component == 0 {
//            return 4
//        }        
//        return 4
//    }
//    
////    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
////        var pickerData = ["1","2","3","4"]
////        return "1"
////    }
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//    }


}
