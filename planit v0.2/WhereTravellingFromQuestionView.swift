//
//  WhereTravellingFromQuestionView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/17/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class WhereTravellingFromQuestionView: UIView {
    
    //Class vars
    var questionLabel: UILabel?
    var textfield: UITextField?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addViews()
        self.layer.borderColor = UIColor.blue.cgColor
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
        questionLabel?.text = "Where will you be coming from?"
        self.addSubview(questionLabel!)
        
        //Textfield
        textfield = UITextField(frame: CGRect.zero)
        textfield?.textColor = UIColor.white
        textfield?.borderStyle = .none
        textfield?.layer.masksToBounds = true
        textfield?.textAlignment = .center
        textfield?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textfield!)
    }
    
}
