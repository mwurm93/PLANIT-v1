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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func addLine(fromPoint start: CGPoint, toPoint end:CGPoint, color: UIColor) {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.strokeColor = color.cgColor
        line.lineWidth = 1
        line.lineJoin = kCALineJoinRound
        self.layer.addSublayer(line)
    }
}
