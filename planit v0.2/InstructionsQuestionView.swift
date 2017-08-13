//
//  InstructionsQuestionView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 7/12/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class InstructionsQuestionView: UIView {
    
    //Class vars
    var questionLabel1: UILabel?
    var questionLabel2: UILabel?
    var button1: UIButton?
    
    //MARK: Outlets
    @IBOutlet weak var exampleItineraryImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addViews()
//                self.layer.borderColor = UIColor.green.cgColor
//                self.layer.borderWidth = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
        
        questionLabel1?.frame = CGRect(x: 10, y: 15, width: bounds.size.width - 20, height: 80)
        questionLabel2?.frame = CGRect(x: 60, y: 90, width: bounds.size.width - 90, height: 130)
        
        button1?.sizeToFit()
        button1?.frame.size.height = 30
        button1?.frame.size.width += 20
        button1?.frame.origin.x = (bounds.size.width - (button1?.frame.width)!) / 2
        button1?.frame.origin.y = 555
        button1?.layer.cornerRadius = (button1?.frame.height)! / 2
        
        exampleItineraryImageView.layer.cornerRadius = 5
        
        exampleItineraryImageView.layer.borderColor = UIColor.white.cgColor
        
        exampleItineraryImageView.layer.borderWidth = 2
    }
    
    func addViews() {
        //Question label
        questionLabel1 = UILabel(frame: CGRect.zero)
        questionLabel1?.translatesAutoresizingMaskIntoConstraints = false
        questionLabel1?.numberOfLines = 0
        questionLabel1?.textAlignment = .center
        questionLabel1?.font = UIFont.boldSystemFont(ofSize: 25)
        questionLabel1?.textColor = UIColor.white
        questionLabel1?.adjustsFontSizeToFitWidth = true
        self.addSubview(questionLabel1!)
        
        questionLabel2 = UILabel(frame: CGRect.zero)
        questionLabel2?.translatesAutoresizingMaskIntoConstraints = false
        questionLabel2?.numberOfLines = 0
        questionLabel2?.textAlignment = .left
        questionLabel2?.font = UIFont.boldSystemFont(ofSize: 19)
        questionLabel2?.textColor = UIColor.white
        questionLabel2?.adjustsFontSizeToFitWidth = true
        questionLabel2?.text = " •  Select dates\n •  Choose your destination(s)\n •  Plan travel\n •  Find a place to stay\n •  Invite friends!"
//        self.addSubview(questionLabel2!)
        
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
        button1?.setTitle("Let's do it!", for: .normal)
        button1?.translatesAutoresizingMaskIntoConstraints = false
        button1?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button1!)
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
