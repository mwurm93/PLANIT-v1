//
//  HowDoYouWantToGetThereQuestionView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/21/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class HowDoYouWantToGetThereQuestionView: UIView {
    //Class vars
    var questionLabel: UILabel?
    var button1: UIButton?
    var button2: UIButton?
    var button3: UIButton?
    var button4: UIButton?
    var button5: UIButton?
    var button6: UIButton?
    
    
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
        
        questionLabel?.frame = CGRect(x: 10, y: 40, width: bounds.size.width - 20, height: 60)
        
        button1?.sizeToFit()
        button1?.frame.size.height = 30
        button1?.frame.size.width += 20
        button1?.frame.origin.x = (bounds.size.width - (button1?.frame.width)!) / 2
        button1?.frame.origin.y = 165
        button1?.layer.cornerRadius = (button1?.frame.height)! / 2
        
        button2?.sizeToFit()
        button2?.frame.size.height = 30
        button2?.frame.size.width += 20
        button2?.frame.origin.x = (bounds.size.width - (button2?.frame.width)!) / 2
        button2?.frame.origin.y = 215
        button2?.layer.cornerRadius = (button2?.frame.height)! / 2
        
        button3?.sizeToFit()
        button3?.frame.size.height = 30
        button3?.frame.size.width += 20
        button3?.frame.origin.x = (bounds.size.width - (button3?.frame.width)!) / 2
        button3?.frame.origin.y = 265
        button3?.layer.cornerRadius = (button3?.frame.height)! / 2
        
        button4?.sizeToFit()
        button4?.frame.size.height = 30
        button4?.frame.size.width += 20
        button4?.frame.origin.x = (bounds.size.width - (button4?.frame.width)!) / 2
        button4?.frame.origin.y = 365
        button4?.layer.cornerRadius = (button4?.frame.height)! / 2
        
        button5?.sizeToFit()
        button5?.frame.size.height = 30
        button5?.frame.size.width += 20
        button5?.frame.origin.x = (bounds.size.width - (button5?.frame.width)!) / 2
        button5?.frame.origin.y = 315
        button5?.layer.cornerRadius = (button5?.frame.height)! / 2

        button6?.sizeToFit()
        button6?.frame.size.height = 30
        button6?.frame.size.width += 20
        button6?.frame.origin.x = (bounds.size.width - (button6?.frame.width)!) / 2
        button6?.frame.origin.y = 435
        button6?.layer.cornerRadius = (button6?.frame.height)! / 2
        button6?.isHidden = true
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
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        var destinationsForTrip = (SavedPreferencesForTrip["destinationsForTrip"] as! [String])
        let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
        if destinationsForTrip.count != 0 {
            if indexOfDestinationBeingPlanned < destinationsForTrip.count {
                questionLabel?.text = "How do you want to get to\n\(destinationsForTrip[indexOfDestinationBeingPlanned])?"
            }
        }
        self.addSubview(questionLabel!)
        
        //Button2
        button1 = UIButton(type: .custom)
        button1?.frame = CGRect.zero
        button1?.setTitleColor(UIColor.white, for: .normal)
        button1?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button1?.layer.borderWidth = 1
        button1?.layer.borderColor = UIColor.white.cgColor
        button1?.layer.masksToBounds = true
        button1?.titleLabel?.numberOfLines = 0
        button1?.titleLabel?.textAlignment = .center
        button1?.setTitle("Fly", for: .normal)
        button1?.translatesAutoresizingMaskIntoConstraints = false
        button1?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button1!)
        
        
        //Button2
        button2 = UIButton(type: .custom)
        button2?.frame = CGRect.zero
        button2?.setTitleColor(UIColor.white, for: .normal)
        button2?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button2?.layer.borderWidth = 1
        button2?.layer.borderColor = UIColor.white.cgColor
        button2?.layer.masksToBounds = true
        button2?.titleLabel?.numberOfLines = 0
        button2?.titleLabel?.textAlignment = .center
        button2?.setTitle("Drive", for: .normal)
        button2?.translatesAutoresizingMaskIntoConstraints = false
        button2?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button2!)
        
        //Button3
        button3 = UIButton(type: .custom)
        button3?.frame = CGRect.zero
        button3?.setTitleColor(UIColor.white, for: .normal)
        button3?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button3?.layer.borderWidth = 1
        button3?.layer.borderColor = UIColor.white.cgColor
        button3?.layer.masksToBounds = true
        button3?.titleLabel?.numberOfLines = 0
        button3?.titleLabel?.textAlignment = .center
        button3?.setTitle("Train, Bus, other", for: .normal)
        button3?.translatesAutoresizingMaskIntoConstraints = false
        button3?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button3!)
        
        //Button4
        button4 = UIButton(type: .custom)
        button4?.frame = CGRect.zero
        button4?.setTitleColor(UIColor.white, for: .normal)
        button4?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button4?.layer.borderWidth = 1
        button4?.layer.borderColor = UIColor.white.cgColor
        button4?.layer.masksToBounds = true
        button4?.titleLabel?.numberOfLines = 0
        button4?.titleLabel?.textAlignment = .center
        button4?.setTitle("I don't know, help me!", for: .normal)
        button4?.translatesAutoresizingMaskIntoConstraints = false
        button4?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button4!)
        
        //Button5
        button5 = UIButton(type: .custom)
        button5?.frame = CGRect.zero
        button5?.setTitleColor(UIColor.white, for: .normal)
        button5?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button5?.layer.borderWidth = 1
        button5?.layer.borderColor = UIColor.white.cgColor
        button5?.layer.masksToBounds = true
        button5?.titleLabel?.numberOfLines = 0
        button5?.titleLabel?.textAlignment = .center
        button5?.setTitle("I'll already be there", for: .normal)
        button5?.translatesAutoresizingMaskIntoConstraints = false
        button5?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button5!)
        
        //Button6
        button6 = UIButton(type: .custom)
        button6?.frame = CGRect.zero
        button6?.setTitleColor(UIColor.white, for: .normal)
        button6?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button6?.layer.borderWidth = 1
        button6?.layer.borderColor = UIColor.white.cgColor
        button6?.layer.masksToBounds = true
        button6?.titleLabel?.numberOfLines = 0
        button6?.titleLabel?.textAlignment = .center
        button6?.setTitle("Skip this, I planned roundtrip travel", for: .normal)
        button6?.translatesAutoresizingMaskIntoConstraints = false
        button6?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button6!)
        
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
