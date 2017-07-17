//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  UIView+JRFadeAnimation.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

let kJRFadeAnimationFastTransitionDuration = 0.2
let kJRFadeAnimationMediumTransitionDuration = 0.4
let kJRFadeAnimationLondTransitionDuration = 0.6
extension UIView {
    class func addTransitionFade(to view: UIView, duration: TimeInterval) {
        let animation = CATransition.animation
        animation.type = kCATransitionFade
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        animation.fillMode = kCAFillModeForwards
        animation.duration = duration as? CMTime ?? CMTime()
        view.layer.add(animation as? CAAnimation ?? CAAnimation(), forKey: "kCATransitionFade")
    }
}