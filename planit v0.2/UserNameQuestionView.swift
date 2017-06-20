//
//  UserNameQuestionView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/16/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class UserNameQuestionView: UIView {
    
    //Class vars
    var questionLabel: UILabel?
    var userNameQuestionTextfield: UITextField?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        addViews()
//        self.layer.borderColor = UIColor.white.cgColor
//        self.layer.borderWidth = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
        
        questionLabel?.frame = CGRect(x: 10, y: 40, width: bounds.size.width - 20, height: 50)
        userNameQuestionTextfield?.frame = CGRect(x: (bounds.size.width-175)/2, y: 120, width: 175, height: 30)
        //Add underline to textfield
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0,y: (userNameQuestionTextfield?.frame.height)! - 1,width: (userNameQuestionTextfield?.frame.width)!,height: 1.0)
        bottomLine.backgroundColor = UIColor.white.cgColor
        userNameQuestionTextfield?.layer.addSublayer(bottomLine)
    }

    
    func addViews() {
        questionLabel = UILabel(frame: CGRect.zero)
        questionLabel?.translatesAutoresizingMaskIntoConstraints = false
        questionLabel?.numberOfLines = 0
        questionLabel?.textAlignment = .center
        questionLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        questionLabel?.textColor = UIColor.white
        questionLabel?.adjustsFontSizeToFitWidth = true
        questionLabel?.text = "Hey there, what's your name?"
        self.addSubview(questionLabel!)
        
        userNameQuestionTextfield = UITextField(frame: CGRect.zero)
        userNameQuestionTextfield?.textColor = UIColor.white
        userNameQuestionTextfield?.borderStyle = .none
        userNameQuestionTextfield?.layer.masksToBounds = true
        userNameQuestionTextfield?.textAlignment = .center
        let userNameQuestionTextfieldPlaceholder = userNameQuestionTextfield!.value(forKey: "placeholderLabel") as? UILabel
        userNameQuestionTextfieldPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        userNameQuestionTextfieldPlaceholder?.text = "Name"
        userNameQuestionTextfield?.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(userNameQuestionTextfield!)
    }

    
}
