//
//  destinationDaysTableViewCell.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 7/10/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class destinationDaysTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    
    // MARK: Class vars
    var destinationLabel: UILabel!
    var cellTextField: UITextField!
    var daysLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        destinationLabel = UILabel(frame: CGRect(x: 123, y: 5, width: 180, height: 30))
        destinationLabel?.textColor = UIColor.white
        destinationLabel?.textAlignment = .left
        destinationLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        addSubview(destinationLabel)
        
        cellTextField = UITextField(frame: CGRect(x: 10, y: 5, width: 35, height: 30))
        cellTextField.borderStyle = .none
        cellTextField.textAlignment = .center
        cellTextField.textColor = UIColor.white
        cellTextField.setBottomBorder(borderColor: UIColor.white)
        addSubview(cellTextField)
        
        daysLabel = UILabel(frame: CGRect(x: 53, y: 5, width: 70, height: 30))
        daysLabel.textColor = UIColor.white
        daysLabel.text = "nights in"
        addSubview(daysLabel)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
