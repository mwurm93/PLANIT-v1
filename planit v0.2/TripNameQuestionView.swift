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
        self.layer.borderColor = UIColor.green.cgColor
        self.layer.borderWidth = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
        
        questionLabel?.frame = CGRect(x: 10, y: 40, width: bounds.size.width - 20, height: 50)
        
        tripNameQuestionTextfield?.frame = CGRect(x: (bounds.size.width-175)/2, y: 120, width: 175, height: 30)
        //Add underline to textfield
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0,y: (tripNameQuestionTextfield?.frame.height)! - 1,width: (tripNameQuestionTextfield?.frame.width)!,height: 1.0)
        bottomLine.backgroundColor = UIColor.white.cgColor
        tripNameQuestionTextfield?.layer.addSublayer(bottomLine)
        
        
        tripNameQuestionButton?.frame = CGRect(x: (bounds.size.width-175)/2, y: 180, width: 175, height: 30)
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
        self.addSubview(questionLabel!)
        
        //Textfield
        tripNameQuestionTextfield = UITextField(frame: CGRect.zero)
        tripNameQuestionTextfield?.textColor = UIColor.white
        tripNameQuestionTextfield?.borderStyle = .none
        tripNameQuestionTextfield?.layer.masksToBounds = true
        tripNameQuestionTextfield?.textAlignment = .center
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
        tripNameQuestionButton?.setBackgroundColor(color: UIColor.blue, forState: .selected)
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

extension UIButton {
    
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: forState)
    }
}
