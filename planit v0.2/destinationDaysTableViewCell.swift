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
    var cellButton: UIButton!
    var cellTextField: UITextField!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        cellButton = UIButton(frame: CGRect(x: 5, y: 5, width: 60, height: 30))
        cellButton?.isEnabled = false
        cellButton.setTitle("title", for: UIControlState.normal)
        cellButton?.setTitleColor(UIColor.white, for: .normal)
        cellButton?.setBackgroundColor(color: UIColor.clear, forState: .normal)
//        cellButton?.layer.borderWidth = 1
//        cellButton?.layer.borderColor = UIColor.white.cgColor
        cellButton?.layer.masksToBounds = true
        cellButton?.titleLabel?.numberOfLines = 0
        cellButton?.titleLabel?.textAlignment = .left
        cellButton?.translatesAutoresizingMaskIntoConstraints = false
//        cellButton?.addTarget(self, action: #selector(self.chooseDestinationButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
        addSubview(cellButton)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
