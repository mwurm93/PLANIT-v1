//
//  AlreadyHaveFlightsQuestionView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 7/12/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class AlreadyHaveFlightsQuestionView: UIView, UITextFieldDelegate {
    //Class vars     
    var alreadyHaveFlightsQuestionLabel: UILabel?
    var alreadyHaveFlightsDepartureDate: UITextField?
    var alreadyHaveFlightsDepartureFlightNumber: UITextField?
    var alreadyHaveFlightsReturnDate: UITextField?
    var alreadyHaveFlightsReturnFlightNumber: UITextField?
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
        
        //        self.layer.borderColor = UIColor.green.cgColor
        //        self.layer.borderWidth = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
        
        alreadyHaveFlightsQuestionLabel?.frame = CGRect(x: 10, y: 15, width: bounds.size.width - 20, height: 75)
        
        alreadyHaveFlightsDepartureDate?.frame = CGRect(x: (bounds.size.width-300-25)/2, y: 115, width: 150, height: 30)
        alreadyHaveFlightsDepartureDate?.setBottomBorder(borderColor: UIColor.white)
        
        alreadyHaveFlightsDepartureFlightNumber?.frame = CGRect(x: (alreadyHaveFlightsDepartureDate?.frame.maxX)! + 25, y: 115, width: 150, height: 30)
        alreadyHaveFlightsDepartureFlightNumber?.setBottomBorder(borderColor: UIColor.white)
        
        alreadyHaveFlightsReturnDate?.frame = CGRect(x: (bounds.size.width-300-25)/2, y: 190, width: 150, height: 30)
        alreadyHaveFlightsReturnDate?.setBottomBorder(borderColor: UIColor.white)
        
        alreadyHaveFlightsReturnFlightNumber?.frame = CGRect(x: (alreadyHaveFlightsReturnDate?.frame.maxX)! + 25, y: 190, width: 150, height: 30)
        alreadyHaveFlightsReturnFlightNumber?.setBottomBorder(borderColor: UIColor.white)
        
        addButton?.sizeToFit()
        addButton?.frame.size.height = 30
        addButton?.frame.size.width += 20
        addButton?.frame.origin.x = (bounds.size.width - (addButton?.frame.width)!) / 2
        addButton?.frame.origin.y = 270
        addButton?.layer.cornerRadius = (addButton?.frame.height)! / 2
    }
    
    
    func addViews() {
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
        
        
        //Question label
        alreadyHaveFlightsQuestionLabel = UILabel(frame: CGRect.zero)
        alreadyHaveFlightsQuestionLabel?.translatesAutoresizingMaskIntoConstraints = false
        alreadyHaveFlightsQuestionLabel?.numberOfLines = 0
        alreadyHaveFlightsQuestionLabel?.textAlignment = .center
        alreadyHaveFlightsQuestionLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        alreadyHaveFlightsQuestionLabel?.textColor = UIColor.white
        alreadyHaveFlightsQuestionLabel?.adjustsFontSizeToFitWidth = true
        alreadyHaveFlightsQuestionLabel?.text = "Enter your flight details to share with your group"
        self.addSubview(alreadyHaveFlightsQuestionLabel!)
        
        //Button
        addButton = UIButton(type: .custom)
        addButton?.frame = CGRect.zero
        addButton?.setTitleColor(UIColor.white, for: .normal)
        addButton?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        addButton?.layer.borderWidth = 1
        addButton?.layer.borderColor = UIColor.white.cgColor
        addButton?.layer.masksToBounds = true
        addButton?.titleLabel?.textAlignment = .center
        addButton?.setTitle("Save", for: .normal)
        addButton?.translatesAutoresizingMaskIntoConstraints = false
        addButton?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(addButton!)

        
        
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        alreadyHaveFlightsReturnFlightNumber?.resignFirstResponder()
        alreadyHaveFlightsReturnDate?.resignFirstResponder()
        
        alreadyHaveFlightsDepartureDate?.resignFirstResponder()
        alreadyHaveFlightsDepartureFlightNumber?.resignFirstResponder()
        
        return true
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
}
