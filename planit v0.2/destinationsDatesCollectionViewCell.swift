//
//  destinationsDatesCollectionViewCell.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/27/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import MIBadgeButton_Swift

class destinationsDatesCollectionViewCell: UICollectionViewCell {
    
    var shakeEnabled = false
    
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
    @IBOutlet weak var inBetweenDatesLine: UIView!
    @IBOutlet weak var travelButton: UIButton!
    @IBOutlet weak var placeToStayButton: UIButton!
    @IBOutlet weak var popupBackgroundViewEditItineraryWithinCell: UIVisualEffectView!
    
    @IBOutlet weak var destinationButton_badge: MIBadgeButton!
    @IBOutlet weak var placeToStayButton_badge: MIBadgeButton!
    @IBOutlet weak var travelDateButton_badge: MIBadgeButton!
    @IBOutlet weak var travelButton_badge: MIBadgeButton!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    
    func shakeIcons() {
        let shakeAnim = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnim.duration = 0.05
        shakeAnim.repeatCount = 2
        shakeAnim.autoreverses = true
        let startAngle: Float = (-2) * 3.14159/180
        var stopAngle = -startAngle
        shakeAnim.fromValue = NSNumber(value: startAngle)
        shakeAnim.toValue = NSNumber(value: 3 * stopAngle)
        shakeAnim.autoreverses = true
        shakeAnim.duration = 0.2
        shakeAnim.repeatCount = 10000
        shakeAnim.timeOffset = 290 * drand48()
        
        //Create layer, then add animation to the element's layer
        let layer: CALayer = self.layer
        layer.add(shakeAnim, forKey:"shaking")
        shakeEnabled = true
    }
    
    // This function stop shaking the collection view cells
    func stopShakingIcons() {
        let layer: CALayer = self.layer
        layer.removeAnimation(forKey: "shaking")
        shakeEnabled = false
    }

}
