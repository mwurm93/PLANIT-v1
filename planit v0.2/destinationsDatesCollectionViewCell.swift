//
//  destinationsDatesCollectionViewCell.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/27/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class destinationsDatesCollectionViewCell: UICollectionViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var travelDateButton: UIButton!
    @IBOutlet weak var destinationButton: UIButton!
    @IBOutlet weak var placeToStaySummaryButton: UIButton!
    @IBOutlet weak var travelSummaryButton: UIButton!
    @IBOutlet weak var modeOfTransportationIcon: UIImageView!
    @IBOutlet weak var placeToStayTypeIcon: UIImageView!
    @IBOutlet weak var numberOfNightsButton: UIButton!
    @IBOutlet weak var inLabel: UILabel!
    @IBOutlet weak var departureAirport: UILabel!
    @IBOutlet weak var departureTime: UILabel!
    @IBOutlet weak var returningAirport: UILabel!
    @IBOutlet weak var returningTime: UILabel!
    
    var inBetweenDatesLine: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}
