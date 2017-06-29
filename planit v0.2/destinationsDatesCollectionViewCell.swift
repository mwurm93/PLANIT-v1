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
    @IBOutlet weak var datesButton: UIButton!
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var destinationButton: UIButton!
    @IBOutlet weak var destinationLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }    
}
