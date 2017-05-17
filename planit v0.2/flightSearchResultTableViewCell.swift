//
//  flightSearchResultTableViewCell.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/17/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class flightSearchResultTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var departureDepartureTime: UILabel!
    @IBOutlet weak var departureOrigin: UILabel!
    @IBOutlet weak var departureArrivalTime: UILabel!
    @IBOutlet weak var departureDestination: UILabel!
    @IBOutlet weak var returnDepartureTime: UILabel!
    @IBOutlet weak var returnOrigin: UILabel!
    @IBOutlet weak var returnArrivalTime: UILabel!
    @IBOutlet weak var returnDestination: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
