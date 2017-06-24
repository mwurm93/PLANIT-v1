//
//  TripNameQuestionView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/16/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class TripNameQuestionView: UIView {
    
    //Class vars
    var questionLabel: UILabel?
    var questionLabel2: UILabel?
    var questionLabel3: UILabel?
    var tripNameQuestionTextfield: UITextField?
    var tripNameQuestionButton: UIButton?
    
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
        
        questionLabel?.frame = CGRect(x: 10, y: 40, width: bounds.size.width - 20, height: 80)
        questionLabel2?.frame = CGRect(x: 50, y: 125, width: bounds.size.width - 100, height: 100)
        questionLabel3?.frame = CGRect(x: 10, y: 220, width: bounds.size.width - 20, height: 60)
        
        tripNameQuestionTextfield?.frame = CGRect(x: (bounds.size.width-175)/2, y: 270, width: 175, height: 30)
        tripNameQuestionTextfield?.setBottomBorder(borderColor: UIColor.white)
        
        tripNameQuestionButton?.sizeToFit()
        tripNameQuestionButton?.frame.size.height = 30
        tripNameQuestionButton?.frame.size.width += 20
        tripNameQuestionButton?.frame.origin.x = (bounds.size.width - (tripNameQuestionButton?.frame.width)!) / 2
        tripNameQuestionButton?.frame.origin.y = 330
        tripNameQuestionButton?.layer.cornerRadius = (tripNameQuestionButton?.frame.height)! / 2
    
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
        questionLabel?.text = "Hi, I'm Planny, your personal trip planning guru! I'm here to help you:"
        self.addSubview(questionLabel!)

        questionLabel2 = UILabel(frame: CGRect.zero)
        questionLabel2?.translatesAutoresizingMaskIntoConstraints = false
        questionLabel2?.numberOfLines = 0
        questionLabel2?.textAlignment = .left
        questionLabel2?.font = UIFont.boldSystemFont(ofSize: 19)
        questionLabel2?.textColor = UIColor.white
        questionLabel2?.adjustsFontSizeToFitWidth = true
        questionLabel2?.text = " ☐  Select dates\n ☐  Choose your destination\n ☐  Plan your travel\n ☐  Find a place to stay\n ☐  Send to your friends!"
        self.addSubview(questionLabel2!)
        
        questionLabel3 = UILabel(frame: CGRect.zero)
        questionLabel3?.translatesAutoresizingMaskIntoConstraints = false
        questionLabel3?.numberOfLines = 0
        questionLabel3?.textAlignment = .center
        questionLabel3?.font = UIFont.boldSystemFont(ofSize: 25)
        questionLabel3?.textColor = UIColor.white
        questionLabel3?.adjustsFontSizeToFitWidth = true
        questionLabel3?.text = "Do you want to name this trip?"
        self.addSubview(questionLabel3!)
        
        //Textfield
        tripNameQuestionTextfield = UITextField(frame: CGRect.zero)
        tripNameQuestionTextfield?.textColor = UIColor.white
        tripNameQuestionTextfield?.borderStyle = .none
        tripNameQuestionTextfield?.layer.masksToBounds = true
        tripNameQuestionTextfield?.textAlignment = .center
        tripNameQuestionTextfield?.returnKeyType = .next
        let userNameQuestionTextfieldPlaceholder = tripNameQuestionTextfield!.value(forKey: "placeholderLabel") as? UILabel
        userNameQuestionTextfieldPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        userNameQuestionTextfieldPlaceholder?.text = "Name"
        tripNameQuestionTextfield?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tripNameQuestionTextfield!)

        //Button
        tripNameQuestionButton = UIButton(type: .custom)
        tripNameQuestionButton?.frame = CGRect.zero
        tripNameQuestionButton?.setTitleColor(UIColor.white, for: .normal)
        tripNameQuestionButton?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        tripNameQuestionButton?.setTitleColor(UIColor.white, for: .selected)
        tripNameQuestionButton?.setBackgroundColor(color: (UIColor()).getCustomBlueColor(), forState: .selected)
        tripNameQuestionButton?.layer.borderWidth = 1
        tripNameQuestionButton?.layer.borderColor = UIColor.white.cgColor        
        tripNameQuestionButton?.layer.masksToBounds = true
        tripNameQuestionButton?.titleLabel?.textAlignment = .center
        tripNameQuestionButton?.setTitle("Not right now", for: .normal)
        tripNameQuestionButton?.setTitle("Not right now", for: .selected)
        tripNameQuestionButton?.translatesAutoresizingMaskIntoConstraints = false
        tripNameQuestionButton?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(tripNameQuestionButton!)
    }
    
    func buttonClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true {
            sender.layer.borderWidth = 0
        } else {
            sender.layer.borderWidth = 1
        }
    }
}
