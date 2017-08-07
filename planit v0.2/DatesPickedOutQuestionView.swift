//
//  DatesPickedOutQuestion.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/17/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class DatesPickedOutQuestionView: UIView {
    
    //Class vars
    var questionLabel: UILabel?
    var button1: UIButton?
    var button2: UIButton?
    var noDatesPickedOutLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addViews()
//        self.layer.borderColor = UIColor.red.cgColor
//        self.layer.borderWidth = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
        
        questionLabel?.frame = CGRect(x: 10, y: 40, width: bounds.size.width - 20, height: 50)
        
        button1?.frame = CGRect(x: (bounds.size.width-175)/2, y: 130, width: 175, height: 30)
        button1?.layer.cornerRadius = (button1?.frame.height)! / 2

        button2?.frame = CGRect(x: (bounds.size.width-175)/2, y: 180, width: 175, height: 30)
        button2?.layer.cornerRadius = (button1?.frame.height)! / 2
        
//        noDatesPickedOutLabel?.frame = CGRect(x: 10, y: 240, width: bounds.size.width - 20, height: 50)
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
        questionLabel?.text = "Do you have dates picked out?"
        self.addSubview(questionLabel!)
        
        //Button1
        button1 = UIButton(type: .custom)
        button1?.frame = CGRect.zero
        button1?.setTitleColor(UIColor.white, for: .normal)
        button1?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button1?.setTitleColor(UIColor.white, for: .selected)
        button1?.setBackgroundColor(color: (UIColor()).getCustomBlueColor(), forState: .selected)
        button1?.layer.borderWidth = 1
        button1?.layer.borderColor = UIColor.white.cgColor
        button1?.layer.masksToBounds = true
        button1?.titleLabel?.textAlignment = .center
        button1?.setTitle("Yes", for: .normal)
        button1?.setTitle("Yes", for: .selected)
        button1?.translatesAutoresizingMaskIntoConstraints = false
        button1?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button1!)
        
        //Button2
        button2 = UIButton(type: .custom)
        button2?.frame = CGRect.zero
        button2?.setTitleColor(UIColor.white, for: .normal)
        button2?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button2?.setTitleColor(UIColor.white, for: .selected)
        button2?.setBackgroundColor(color: (UIColor()).getCustomBlueColor(), forState: .selected)
        button2?.layer.borderWidth = 1
        button2?.layer.borderColor = UIColor.white.cgColor
        button2?.layer.masksToBounds = true
        button2?.titleLabel?.textAlignment = .center
        button2?.setTitle("No", for: .normal)
        button2?.setTitle("No", for: .selected)
        button2?.translatesAutoresizingMaskIntoConstraints = false
        button2?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button2!)
        
        
        noDatesPickedOutLabel = UILabel(frame: CGRect.zero)
        noDatesPickedOutLabel?.translatesAutoresizingMaskIntoConstraints = false
        noDatesPickedOutLabel?.numberOfLines = 0
        noDatesPickedOutLabel?.textAlignment = .center
        noDatesPickedOutLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        noDatesPickedOutLabel?.textColor = UIColor.white
        noDatesPickedOutLabel?.adjustsFontSizeToFitWidth = true
        noDatesPickedOutLabel?.text = "No worries, we can come back to that later"
        self.addSubview(noDatesPickedOutLabel!)


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
}
