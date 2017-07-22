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
        
        questionLabel3?.frame = CGRect(x: 10, y: 15, width: bounds.size.width - 20, height: 60)
        
        tripNameQuestionTextfield?.frame = CGRect(x: (bounds.size.width-175)/2, y: 70, width: 175, height: 30)
        tripNameQuestionTextfield?.setBottomBorder(borderColor: UIColor.white)
        
        tripNameQuestionButton?.sizeToFit()
        tripNameQuestionButton?.frame.size.height = 30
        tripNameQuestionButton?.frame.size.width += 20
        tripNameQuestionButton?.frame.origin.x = (bounds.size.width - (tripNameQuestionButton?.frame.width)!) / 2
        tripNameQuestionButton?.frame.origin.y = 125
        tripNameQuestionButton?.layer.cornerRadius = (tripNameQuestionButton?.frame.height)! / 2
        
    }
    
    func addViews() {
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
