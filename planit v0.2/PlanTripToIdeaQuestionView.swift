//
//  PlanTripToIdeaQuestionView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/18/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class PlanTripToIdeaQuestionView: UIView {
    
    //Class vars
    var questionLabel: UILabel?
    var button1: UIButton?
    var button2: UIButton?
    
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
        
        button1?.frame = CGRect(x: (bounds.size.width-100)/2, y: 120, width: 100, height: 30)
        button1?.layer.cornerRadius = (button1?.frame.height)! / 2
        
        button2?.frame = CGRect(x: (bounds.size.width-250)/2, y: 180, width: 250, height: 60)
        button2?.layer.cornerRadius = (button2?.frame.height)! / 2
        
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
        questionLabel?.text = "Do you want to plan your trip to this destination?"
        self.addSubview(questionLabel!)
        
        //Button2
        button1 = UIButton(type: .custom)
        button1?.frame = CGRect.zero
        button1?.setTitleColor(UIColor.white, for: .normal)
        button1?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button1?.setTitleColor(UIColor.white, for: .selected)
        button1?.setBackgroundColor(color: UIColor.blue, forState: .selected)
        button1?.layer.borderWidth = 1
        button1?.layer.borderColor = UIColor.white.cgColor
        button1?.layer.masksToBounds = true
        button1?.titleLabel?.numberOfLines = 0
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
        button2?.setBackgroundColor(color: UIColor.blue, forState: .selected)
        button2?.layer.borderWidth = 1
        button2?.layer.borderColor = UIColor.white.cgColor
        button2?.layer.masksToBounds = true
        button2?.titleLabel?.numberOfLines = 0
        button2?.titleLabel?.textAlignment = .center
        button2?.setTitle("Not yet, let's explore\nother options as well!", for: .normal)
        button2?.setTitle("Not yet, let's explore\nother options as well!", for: .selected)
        button2?.translatesAutoresizingMaskIntoConstraints = false
        button2?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button2!)
    }
    
    func buttonClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender == button2 && sender.isSelected == true {
            button1?.isSelected = false
            button1?.layer.borderWidth = 1
        } else if sender == button1 && sender.isSelected == true  {
            button2?.isSelected = false
            button2?.layer.borderWidth = 1
        }
        if sender.isSelected == true {
            sender.layer.borderWidth = 0
        } else {
            sender.layer.borderWidth = 1
        }
    }
}
