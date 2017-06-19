//
//  DestinationOptionsCardView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/19/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import UIColor_FlatColors

class DestinationOptionsCardView: UIView {
    
    //Class vars
    var questionLabel: UILabel?
    var button1: UIButton?
    var button2: UIButton?    
        //ZLSwipeableView vars
    var colors = ["Turquoise", "Green Sea", "Emerald", "Nephritis", "Peter River", "Belize Hole", "Amethyst", "Wisteria", "Wet Asphalt", "Midnight Blue", "Sun Flower", "Orange", "Carrot", "Pumpkin", "Alizarin", "Pomegranate", "Silver", "Concrete", "Asbestos"]
    var colorIndex = 0
    var cardToLoadIndex = 0
    var loadCardsFromXib = true
    var isTrackingPanLocation = false
    var panGestureRecognizer = UIPanGestureRecognizer()
    var countSwipes = 0
    var totalDailySwipeAllotment = 6

    
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
        
        questionLabel?.frame = CGRect(x: 10, y: 40, width: bounds.size.width - 20, height: 100)
        
        button1?.frame = CGRect(x: (bounds.size.width-200)/2, y: 400, width: 80, height: 80)
        button1?.layer.cornerRadius = (button1?.frame.height)! / 2
        
        button2?.frame = CGRect(x: (bounds.size.width-200)/2+120, y: 400, width: 80, height: 80)
        button2?.layer.cornerRadius = (button2?.frame.height)! / 2
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        swipeableView.nextView = {
            return self.nextCardView()
        }
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
        questionLabel?.text = "Cool, we’ve come up with a few options that you might like."
        self.addSubview(questionLabel!)
        
        //Button1
        button1 = UIButton(type: .custom)
        button1?.frame = CGRect.zero
        button1?.layer.masksToBounds = true
        button1?.setImage(#imageLiteral(resourceName: "emptyX"), for: .normal)
        button1?.setImage(#imageLiteral(resourceName: "fullX"), for: .selected)
        button1?.translatesAutoresizingMaskIntoConstraints = false
        button1?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button1!)
        
        
        //Button2
        button2 = UIButton(type: .custom)
        button2?.frame = CGRect.zero
        button2?.layer.masksToBounds = true
        button2?.setImage(#imageLiteral(resourceName: "emptyHeart"), for: .normal)
        button2?.setImage(#imageLiteral(resourceName: "fullHeart"), for: .selected)
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
