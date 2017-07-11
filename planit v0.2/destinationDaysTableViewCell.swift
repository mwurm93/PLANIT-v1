//
//  destinationDaysTableViewCell.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 7/10/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class destinationDaysTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    // MARK: Outlets
    
    // MARK: Class vars
    var cellButton: UIButton!
    var cellTextField: UITextField!
    var daysLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        cellButton = UIButton(frame: CGRect(x: 115, y: 5, width: 180, height: 30))
        cellButton?.isEnabled = false
        cellButton.setTitle("title", for: UIControlState.normal)
        cellButton?.setTitleColor(UIColor.white, for: .normal)
        cellButton?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        cellButton?.titleLabel?.numberOfLines = 0
        cellButton?.titleLabel?.textAlignment = .left
        cellButton?.titleLabel?.adjustsFontSizeToFitWidth = true
//        cellButton?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellButton)
        
        cellTextField = UITextField(frame: CGRect(x: 10, y: 5, width: 35, height: 30))
        cellTextField.borderStyle = .none
        cellTextField.textAlignment = .center
        cellTextField.textColor = UIColor.white
        cellTextField.setBottomBorder(borderColor: UIColor.white)
        addSubview(cellTextField)
        
        daysLabel = UILabel(frame: CGRect(x: 53, y: 5, width: 60, height: 30))
        daysLabel.textColor = UIColor.white
        daysLabel.text = "nights"
        addSubview(daysLabel)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    //UITextfield delegate
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        return true
    }
}
