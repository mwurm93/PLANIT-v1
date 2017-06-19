//
//  DecidedOnCityToVisitQuestionView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/18/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class DecidedOnCityToVisitQuestionView: UIView {
    
    //Class vars
    var questionLabel: UILabel?
    var textfield: UITextField?
    var button: UIButton?
    
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
        
        textfield?.frame = CGRect(x: (bounds.size.width-175)/2, y: 120, width: 175, height: 30)
        //Add underline to textfield
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0,y: (textfield?.frame.height)! - 1,width: (textfield?.frame.width)!,height: 1.0)
        bottomLine.backgroundColor = UIColor.white.cgColor
        textfield?.layer.addSublayer(bottomLine)
        
        
        button?.frame = CGRect(x: (bounds.size.width-250)/2, y: 180, width: 250, height: 60)
        button?.layer.cornerRadius = (button?.frame.height)! / 2
        
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
        questionLabel?.text = "Have you decided on a city to visit? \n If so, enter it here!"
        self.addSubview(questionLabel!)
        
        //Textfield
        textfield = UITextField(frame: CGRect.zero)
        textfield?.textColor = UIColor.white
        textfield?.borderStyle = .none
        textfield?.layer.masksToBounds = true
        textfield?.textAlignment = .center
        let userNameQuestionTextfieldPlaceholder = textfield!.value(forKey: "placeholderLabel") as? UILabel
        userNameQuestionTextfieldPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        userNameQuestionTextfieldPlaceholder?.text = "Name"
        textfield?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textfield!)
        
        //Button
        button = UIButton(type: .custom)
        button?.frame = CGRect.zero
        button?.setTitleColor(UIColor.white, for: .normal)
        button?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button?.setTitleColor(UIColor.white, for: .selected)
        button?.setBackgroundColor(color: UIColor.blue, forState: .selected)
        button?.layer.borderWidth = 1
        button?.layer.borderColor = UIColor.white.cgColor
        button?.layer.masksToBounds = true
        button?.titleLabel?.numberOfLines = 0
        button?.titleLabel?.textAlignment = .center
        button?.setTitle("Nothing set in stone,\n give me some ideas!", for: .normal)
        button?.setTitle("Nothing set in stone,\n give me some ideas!", for: .selected)
        button?.translatesAutoresizingMaskIntoConstraints = false
        button?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button!)
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
