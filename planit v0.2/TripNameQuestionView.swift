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
    }
    
    
    func addViews() {
        questionLabel = UILabel(frame: CGRect.zero)
        questionLabel?.translatesAutoresizingMaskIntoConstraints = false
        questionLabel?.numberOfLines = 0
        questionLabel?.textAlignment = .center
        questionLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        questionLabel?.textColor = UIColor.white
        questionLabel?.adjustsFontSizeToFitWidth = true
        questionLabel?.text = "Hi [name], would you like to name your trip?"
        self.addSubview(questionLabel!)
        
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
    }
    
    
}
