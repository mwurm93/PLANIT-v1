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
    var button1: UIButton?
    
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
        
        questionLabel?.frame = CGRect(x: 10, y: 10, width: bounds.size.width - 20, height: 80)
        questionLabel2?.frame = CGRect(x: 60, y: 83, width: bounds.size.width - 90, height: 130)
        questionLabel3?.frame = CGRect(x: 10, y: 100, width: bounds.size.width - 20, height: 60)
        
        tripNameQuestionTextfield?.frame = CGRect(x: (bounds.size.width-175)/2, y: 155, width: 175, height: 30)
        tripNameQuestionTextfield?.setBottomBorder(borderColor: UIColor.white)
        
        tripNameQuestionButton?.sizeToFit()
        tripNameQuestionButton?.frame.size.height = 30
        tripNameQuestionButton?.frame.size.width += 20
        tripNameQuestionButton?.frame.origin.x = (bounds.size.width - (tripNameQuestionButton?.frame.width)!) / 2
        tripNameQuestionButton?.frame.origin.y = 210
        tripNameQuestionButton?.layer.cornerRadius = (tripNameQuestionButton?.frame.height)! / 2
        
        button1?.sizeToFit()
        button1?.frame.size.height = 30
        button1?.frame.size.width += 20
        button1?.frame.origin.x = (bounds.size.width - (button1?.frame.width)!) / 2
        button1?.frame.origin.y = 240
        button1?.layer.cornerRadius = (button1?.frame.height)! / 2
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
        questionLabel2?.text = " •  Select dates\n •  Choose your destination(s)\n •  Plan travel\n •  Find a place to stay\n •  Invite friends!"
        self.addSubview(questionLabel2!)
        
        questionLabel3 = UILabel(frame: CGRect.zero)
        questionLabel3?.translatesAutoresizingMaskIntoConstraints = false
        questionLabel3?.numberOfLines = 0
        questionLabel3?.textAlignment = .center
        questionLabel3?.font = UIFont.boldSystemFont(ofSize: 25)
        questionLabel3?.textColor = UIColor.white
        questionLabel3?.adjustsFontSizeToFitWidth = true
        questionLabel3?.text = "Give this trip a name?"
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
        tripNameQuestionButton?.layer.borderWidth = 1
        tripNameQuestionButton?.layer.borderColor = UIColor.white.cgColor        
        tripNameQuestionButton?.layer.masksToBounds = true
        tripNameQuestionButton?.titleLabel?.textAlignment = .center
        tripNameQuestionButton?.setTitle("Not right now", for: .normal)
        tripNameQuestionButton?.translatesAutoresizingMaskIntoConstraints = false
        tripNameQuestionButton?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(tripNameQuestionButton!)
        
        //Button1
        button1 = UIButton(type: .custom)
        button1?.frame = CGRect.zero
        button1?.setTitleColor(UIColor.white, for: .normal)
        button1?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button1?.layer.borderWidth = 1
        button1?.layer.borderColor = UIColor.white.cgColor
        button1?.layer.masksToBounds = true
        button1?.titleLabel?.numberOfLines = 0
        button1?.titleLabel?.textAlignment = .center
        button1?.setTitle("Got it", for: .normal)
        button1?.translatesAutoresizingMaskIntoConstraints = false
        button1?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button1!)
    }
    
    func buttonClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.setButtonWithTransparentText(button: sender, title: sender.currentTitle as! NSString, color: UIColor.white)
            if sender == button1 {
                tripNameQuestionButton?.isHidden = false
                tripNameQuestionTextfield?.isHidden = false
                tripNameQuestionTextfield?.becomeFirstResponder()
                questionLabel3?.isHidden = false
                button1?.isHidden = true
                questionLabel?.isHidden = true
                questionLabel2?.isHidden = true
            }
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
