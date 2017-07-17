//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  CAAnimation+JRPopup.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

extension CAAnimation {
    class func attachPopUp() -> CAAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        let scale1: CATransform3D = CATransform3DMakeScale(0.25, 0.25, 1)
        let scale2: CATransform3D = CATransform3DMakeScale(0.75, 0.75, 1)
        let scale3: CATransform3D = CATransform3DMakeScale(1.0, 1.0, 1)
        let scale4: CATransform3D = CATransform3DMakeScale(1.2, 1.2, 1)
        let scale5: CATransform3D = CATransform3DMakeScale(1.0, 1.0, 1)
        let frameValues: [Any] = [NSValue(caTransform3D: scale1), NSValue(caTransform3D: scale2), NSValue(caTransform3D: scale3), NSValue(caTransform3D: scale4), NSValue(caTransform3D: scale5)]
        animation.values = frameValues as? [Any] ?? [Any]()
        let frameTimes: [Any] = [0.1, 0.4, 0.5, 0.6, 1.0]
        animation.keyTimes = frameTimes as? [NSNumber] ?? [NSNumber]()
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        animation.duration = 0.265
        return animation
    }

    class func detachPopUp() -> CAAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        let scale5: CATransform3D = CATransform3DMakeScale(0.0, 0.0, 1)
        let scale4: CATransform3D = CATransform3DMakeScale(0.75, 0.75, 1)
        let scale3: CATransform3D = CATransform3DMakeScale(1.0, 1.0, 1)
        let scale2: CATransform3D = CATransform3DMakeScale(1.1, 1.1, 1)
        let scale1: CATransform3D = CATransform3DMakeScale(1.0, 1.0, 1)
        let frameValues: [Any] = [NSValue(caTransform3D: scale1), NSValue(caTransform3D: scale2), NSValue(caTransform3D: scale3), NSValue(caTransform3D: scale4), NSValue(caTransform3D: scale5)]
        animation.values = frameValues as? [Any] ?? [Any]()
        let frameTimes: [Any] = [0.1, 0.4, 0.7, 0.8, 1.0]
        animation.keyTimes = frameTimes as? [NSNumber] ?? [NSNumber]()
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = true
        animation.duration = 0.225
        return animation
    }
}