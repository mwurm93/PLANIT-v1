//
//  ExistingTripTableViewCell.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 11/28/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit

class ExistingTripTableViewCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var existingTripTableViewLabel: UILabel!
    @IBOutlet weak var existingTripTableViewImage: UIImageView!
    @IBOutlet weak var destinationsLabel: UILabel!
    @IBOutlet weak var tripStartDateLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var tripEndDateLabel: UILabel!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripBackgroundView: UIView!
    @IBOutlet weak var menuItemImageView: UIImageView!
    @IBOutlet weak var menuItemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
    }

}
