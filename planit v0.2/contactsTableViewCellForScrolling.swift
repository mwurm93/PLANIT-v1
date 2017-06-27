//
//  contactsTableViewCellForScrolling.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/27/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class contactsTableViewCellForScrolling: UITableViewCell {
    
    // MARK: Outlets
    
    // MARK: Class vars
    var nameLabel: UILabel!
    var thumbnailImage: UIImageView!
    var initialsLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //Question label
        nameLabel = UILabel(frame: CGRect(x: 79, y: 0, width: 228, height: 55))
        nameLabel?.translatesAutoresizingMaskIntoConstraints = true
        nameLabel?.numberOfLines = 0
        nameLabel?.textAlignment = .left
        nameLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        nameLabel?.textColor = UIColor.white
        nameLabel?.adjustsFontSizeToFitWidth = true
        self.addSubview(nameLabel!)
        
        //Question label
        thumbnailImage = UIImageView(frame: CGRect(x: 16, y: 0, width: 55, height: 55))
        thumbnailImage?.translatesAutoresizingMaskIntoConstraints = true
        self.addSubview(thumbnailImage!)
        
        //Question label
        initialsLabel = UILabel(frame: CGRect(x: 16, y: 0, width: 55, height: 55))
        initialsLabel?.translatesAutoresizingMaskIntoConstraints = true
        initialsLabel?.numberOfLines = 0
        initialsLabel?.textAlignment = .center
        initialsLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        initialsLabel?.textColor = UIColor.white
        initialsLabel?.adjustsFontSizeToFitWidth = true
        self.addSubview(initialsLabel!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

