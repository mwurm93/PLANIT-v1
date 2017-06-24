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
        searchButton?.frame.origin.y = 310
        searchButton?.layer.cornerRadius = (searchButton?.frame.height)! / 2
        
        if searchMode == "Same drop-off" {
            differentDropOff?.isHidden = true
        } else {
            differentDropOff?.isHidden = false
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
        let originPlaceholder = NSAttributedString(string: "Pick-up location", attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6)])        
        origin?.attributedPlaceholder = originPlaceholder
        if rentalMode == "At destination" {
            let departureDestinationValue = rankedPotentialTripsDictionary[rankedPotentialTripsDictionaryArrayIndex]["destination"] as! String
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
    }
    
    func buttonClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true {
            sender.layer.borderWidth = 0
        } else {
            sender.layer.borderWidth = 1
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

    
    @IBAction func searchModeControlValueChanged(_ sender: Any) {
        if searchModeControl.selectedSegmentIndex == 0 {
            searchMode = "Same drop-off"
            differentDropOff?.isHidden = true
        } else {
            searchMode = "Different drop-off"
            differentDropOff?.isHidden = false
        }
    }
    
}
