//
//  Icomation.swift
//  Icomations
//
//  Created by Paolo Boschini on 28/04/15.
//  Copyright (c) 2015 Paolo Boschini. All rights reserved.
//

import UIKit

extension CAAnimation {
    func setUp(_ duration: Double) {
        self.fillMode = kCAFillModeForwards
        self.isRemovedOnCompletion = false
        self.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.duration = CFTimeInterval(duration)
    }
}

enum IconType {
    case arrowUp, arrowLeft, arrowDown, arrowRight, smallArrowUp, smallArrowLeft, smallArrowDown, smallArrowRight, close, smallClose
}

class Icomation: UIButton {
    
    fileprivate enum IconState {
        case hamburger, arrow, close
    }
    
    fileprivate var toggleState = true
    fileprivate var topAnimation, middleAnimation, bottomAnimation: CAAnimation!
    fileprivate var halfSideOfTriangle: CGFloat!
    fileprivate var w, h, lineWidth: CGFloat!
    
    var topShape, middleShape, bottomShape: CAShapeLayer!
    var animationDuration = 1.0
    var numberOfRotations: Double = 0
    var type: IconType!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        create()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        create()
    }
    
    fileprivate func create() {
        type = IconType.self.smallArrowLeft
        
        titleLabel?.text = ""
        backgroundColor = UIColor.clear
        let strokeColor = UIColor.white
        
        w = bounds.width
        h = bounds.height
        lineWidth = 3
        
        let hypotenuse = w/2
        halfSideOfTriangle = (hypotenuse / sqrt(2)) / 2
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: w, y: 0))
        
        topShape = shapeLayer(path.cgPath, position: CGPoint(x: w/2, y: h/4), color: strokeColor)
        topShape.bounds = (topShape.path?.boundingBox)!
        
        middleShape = shapeLayer(path.cgPath, position: CGPoint(x: w/2, y: h/2), color: strokeColor)
        middleShape.bounds = (middleShape.path?.boundingBox)!
        
        bottomShape = shapeLayer(path.cgPath, position: CGPoint(x: w/2, y: h-h/4), color: strokeColor)
        bottomShape.bounds = (bottomShape.path?.boundingBox)!
        
        layer.addSublayer(topShape)
        layer.addSublayer(middleShape)
        layer.addSublayer(bottomShape)
    }
    
    // MARK: - Shapes
    
    fileprivate func shapeLayer(_ path: CGPath, position: CGPoint, color: UIColor) -> CAShapeLayer{
        let s = CAShapeLayer()
        s.lineWidth = lineWidth
        s.lineCap = kCALineCapRound
        s.strokeColor = color.cgColor
        s.path = path
        s.position = position
        return s
    }
    
    // MARK: - Animations
    
    fileprivate func basicAnimation(_ keyPath: String, from: CGFloat = -1, to: CGFloat = -1, byValue: CGFloat = -1) -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: keyPath)
        if from != -1 { a.fromValue = from }
        if to != -1 { a.toValue = to }
        if byValue != -1 { a.byValue = byValue }
        return a
    }
    
    fileprivate func groupAnimation(_ type: IconState, x: CGFloat = 0, y: CGFloat = 0, r: CGFloat = 0, s: CGFloat = 0.5) -> CAAnimation {
        
        var xa, ya, ra, sa: CABasicAnimation!
        
        if type == IconState.arrow || type == IconState.close {
            xa = basicAnimation("transform.translation.x", from: 0, to: x)
            ya = basicAnimation("transform.translation.y", from: 0, to: y)
            ra = basicAnimation("transform.rotation.z", from: 0, to: r)
            sa = basicAnimation("transform.scale.x", byValue: -s)
        }
        
        if type == IconState.hamburger {
            xa = basicAnimation("transform.translation.x", from: x, to: 0)
            ya = basicAnimation("transform.translation.y", from: y, to: 0)
            ra = basicAnimation("transform.rotation.z", from: r, to: 0)
            sa = basicAnimation("transform.scale.x", byValue: s)
        }
        
        let group = CAAnimationGroup()
        group.setUp(animationDuration)
        group.animations = [xa, ya, ra, sa]
        return group
    }
    
    fileprivate func rotate(_ type: IconState, to: CGFloat) -> CAAnimation {
        var r: CABasicAnimation!
        if type == IconState.arrow {
            r = basicAnimation("transform.rotation.z", from: 0, to: to)
        }
        if type == IconState.hamburger {
            r = basicAnimation("transform.rotation.z", from: to, to: 0)
        }
        r.setUp(animationDuration)
        return r
    }
    
    fileprivate func shrinkToDisappear(_ type: IconState) -> CAAnimation {
        let value: CGFloat = type == IconState.close ? -0.999 : 1.0
        let s = basicAnimation("transform.scale.x", byValue: value)
        s.setUp(animationDuration)
        return s
    }
    
    fileprivate func addAnimations() {
        topShape.add(topAnimation, forKey:"")
        middleShape.add(middleAnimation, forKey:"")
        bottomShape.add(bottomAnimation, forKey:"")
    }
    
    // MARK: - Toggles
    
    fileprivate func arrowLeft() {
        let buttonType = toggleState ? IconState.arrow : IconState.hamburger
        
        let topRotation = CGFloat(-M_PI * (3/4 + numberOfRotations))
        topAnimation = groupAnimation(buttonType, x: halfSideOfTriangle - w/2, y: halfSideOfTriangle + h/4, r: topRotation)
        
        let middleRotation = CGFloat(-M_PI * (numberOfRotations + 1))
        middleAnimation = rotate(buttonType, to: middleRotation)
        
        let bottomRotation = CGFloat(-M_PI * (5/4 + numberOfRotations))
        bottomAnimation = groupAnimation(buttonType, x: halfSideOfTriangle - w/2, y: -h/4 - halfSideOfTriangle, r: bottomRotation)
        
        addAnimations()
        toggleState = !toggleState
    }
    
    fileprivate func smallArrowLeft() {
        let buttonType = toggleState ? IconState.arrow : IconState.hamburger
        
        let topRotation = CGFloat(-M_PI * (3/4 + numberOfRotations))
        topAnimation = groupAnimation(buttonType, x: -halfSideOfTriangle + 1, y: (halfSideOfTriangle/2) + h/4, r: topRotation, s: 3/4)
        
        let middleRotation = CGFloat(-M_PI * (numberOfRotations + 1))
        middleAnimation = groupAnimation(buttonType, r: middleRotation)
        
        let bottomRotation = CGFloat(-M_PI * (5/4 + numberOfRotations))
        bottomAnimation = groupAnimation(buttonType, x: -halfSideOfTriangle + 1, y: -h/4 - (halfSideOfTriangle/2), r: bottomRotation, s: 3/4)
        
        addAnimations()
        toggleState = !toggleState
    }
    
    fileprivate func arrowUp() {
        let buttonType = toggleState ? IconState.arrow : IconState.hamburger
        
        let topRotation = CGFloat(-M_PI * (3/4 + numberOfRotations))
        topAnimation = groupAnimation(buttonType, x: halfSideOfTriangle, y: 0 - halfSideOfTriangle/2, r: topRotation)
        
        var add: CGFloat!
        if numberOfRotations == 0 {
            add = 0
        } else if numberOfRotations.truncatingRemainder(dividingBy: 2) == 0 {
            add = CGFloat(-M_PI)
        } else {
            add = CGFloat(-M_PI/2)
        }
        let middleRotation = CGFloat(add - CGFloat(M_PI/2) * CGFloat(numberOfRotations + 1))
        middleAnimation = rotate(buttonType, to: middleRotation)
        
        let bottomRotation = CGFloat(-M_PI * (1/4 + numberOfRotations))
        bottomAnimation = groupAnimation(buttonType, x: -halfSideOfTriangle, y: -h/2 - halfSideOfTriangle/2, r: bottomRotation)
        
        addAnimations()
        toggleState = !toggleState
    }
    
    fileprivate func smallArrowUp() {
        let buttonType = toggleState ? IconState.arrow : IconState.hamburger
        
        let topRotation = CGFloat(-M_PI * (3/4 + numberOfRotations))
        topAnimation = groupAnimation(buttonType, x: halfSideOfTriangle/2, y: halfSideOfTriangle/2 - 1, r: topRotation, s: 3/4)
        
        var add: CGFloat!
        if numberOfRotations == 0 {
            add = 0
        } else if numberOfRotations.truncatingRemainder(dividingBy: 2) == 0 {
            add = CGFloat(-M_PI)
        } else {
            add = CGFloat(-M_PI/2)
        }
        let middleRotation = CGFloat(add - CGFloat(M_PI/2) * CGFloat(numberOfRotations + 1))
        middleAnimation = groupAnimation(buttonType, r: middleRotation)
        
        let bottomRotation = CGFloat(-M_PI * (1/4 + numberOfRotations))
        bottomAnimation = groupAnimation(buttonType, x: -halfSideOfTriangle/2, y: -w/2 + halfSideOfTriangle/2 - 1, r: bottomRotation, s: 3/4)
        
        addAnimations()
        toggleState = !toggleState
    }
    
    fileprivate func arrowDown() {
        let buttonType = toggleState ? IconState.arrow : IconState.hamburger
        
        let topRotation = CGFloat(M_PI * (3/4 + numberOfRotations))
        topAnimation = groupAnimation(buttonType, x: halfSideOfTriangle, y: h/2 + halfSideOfTriangle/2 - 1, r: topRotation)
        
        var add: CGFloat!
        if numberOfRotations == 0 {
            add = 0
        } else if numberOfRotations.truncatingRemainder(dividingBy: 2) == 0 {
            add = CGFloat(M_PI)
        } else {
            add = CGFloat(M_PI/2)
        }
        let middleRotation = CGFloat(add + CGFloat(M_PI/2) * CGFloat(numberOfRotations + 1))
        middleAnimation = rotate(buttonType, to: middleRotation)
        
        let bottomRotation = CGFloat(M_PI * (1/4 + numberOfRotations))
        bottomAnimation = groupAnimation(buttonType, x: -halfSideOfTriangle, y: halfSideOfTriangle/2 - 1, r: bottomRotation)
        
        addAnimations()
        toggleState = !toggleState
    }
    
    fileprivate func smallArrowDown() {
        let buttonType = toggleState ? IconState.arrow : IconState.hamburger
        
        let topRotation = CGFloat(M_PI * (1/4 + numberOfRotations))
        topAnimation = groupAnimation(buttonType, x: -halfSideOfTriangle/2, y: w/2 - halfSideOfTriangle/2, r: topRotation, s: 3/4)
        
        var add: CGFloat!
        if numberOfRotations == 0 {
            add = 0
        } else if numberOfRotations.truncatingRemainder(dividingBy: 2) == 0 {
            add = CGFloat(M_PI)
        } else {
            add = CGFloat(M_PI/2)
        }
        let middleRotation = CGFloat(add + CGFloat(M_PI/2) * CGFloat(numberOfRotations + 1))
        middleAnimation = groupAnimation(buttonType, r: middleRotation)
        
        let bottomRotation = CGFloat(M_PI * (3/4 + numberOfRotations))
        bottomAnimation = groupAnimation(buttonType, x: halfSideOfTriangle/2, y: -halfSideOfTriangle/2, r: bottomRotation, s: 3/4)
        
        addAnimations()
        toggleState = !toggleState
    }
    
    fileprivate func arrowRight() {
        let buttonType = toggleState ? IconState.arrow : IconState.hamburger
        
        let topRotation = CGFloat(M_PI * (3/4 + numberOfRotations))
        topAnimation = groupAnimation(buttonType, x: w/2 - halfSideOfTriangle, y: halfSideOfTriangle + h/4, r: topRotation)
        
        let middleRotation = CGFloat(M_PI * (numberOfRotations + 1))
        middleAnimation = rotate(buttonType, to: middleRotation)
        
        let bottomRotation = CGFloat(M_PI * (5/4 + numberOfRotations))
        bottomAnimation = groupAnimation(buttonType, x: w/2 - halfSideOfTriangle, y: -h/4 - halfSideOfTriangle, r: bottomRotation)
        
        addAnimations()
        toggleState = !toggleState
    }
    
    fileprivate func smallArrowRight() {
        let buttonType = toggleState ? IconState.arrow : IconState.hamburger
        
        let topRotation = CGFloat(M_PI * (3/4 + numberOfRotations))
        topAnimation = groupAnimation(buttonType, x: halfSideOfTriangle - 1, y: (halfSideOfTriangle/2) + h/4, r: topRotation, s: 3/4)
        
        let middleRotation = CGFloat(M_PI * (numberOfRotations + 1))
        middleAnimation = groupAnimation(buttonType, r: middleRotation)
        
        let bottomRotation = CGFloat(M_PI * (5/4 + numberOfRotations))
        bottomAnimation = groupAnimation(buttonType, x: halfSideOfTriangle - 1, y: (-halfSideOfTriangle/2) - h/4, r: bottomRotation, s: 3/4)
        
        addAnimations()
        toggleState = !toggleState
    }
    
    fileprivate func close() {
        let buttonType = toggleState ? IconState.close : IconState.hamburger
        
        topAnimation = groupAnimation(buttonType, y: h/4, r: CGFloat(M_PI * (3/4 + numberOfRotations)), s: 0)
        middleAnimation = shrinkToDisappear(buttonType)
        bottomAnimation = groupAnimation(buttonType, y: -h/4, r: CGFloat(M_PI * (5/4 + numberOfRotations)), s: 0)
        
        addAnimations()
        toggleState = !toggleState
    }
    
    fileprivate func smallClose() {
        let buttonType = toggleState ? IconState.close : IconState.hamburger
        
        topAnimation = groupAnimation(buttonType, y: h/4, r: CGFloat(M_PI * (3/4 + numberOfRotations)))
        middleAnimation = shrinkToDisappear(buttonType)
        bottomAnimation = groupAnimation(buttonType, y: -h/4, r: CGFloat(M_PI * (5/4 + numberOfRotations)))
        
        addAnimations()
        toggleState = !toggleState
    }
    
    // MARK: - Touch Gestures
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches as! Set<UITouch>, with: event)
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
    }
//    override func touchesBegan(_ touches: Set<NSObject>, with event: UIEvent) {
//        super.touchesBegan(touches as! Set<UITouch>, with: event)
//        UIView.animate(withDuration: 0.1, animations: { () -> Void in
//            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//        })
//    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches as! Set<UITouch>, with: event)
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            switch self.type {
            case IconType.self.arrowUp: self.arrowUp()
            case IconType.self.arrowLeft: self.arrowLeft()
            case IconType.self.arrowDown: self.arrowDown()
            case IconType.self.arrowRight: self.arrowRight()
            case IconType.self.close: self.close()
            case IconType.self.smallArrowUp: self.smallArrowUp()
            case IconType.self.smallArrowLeft: self.smallArrowLeft()
            case IconType.self.smallArrowDown: self.smallArrowDown()
            case IconType.self.smallArrowRight: self.smallArrowRight()
            case IconType.self.smallClose: self.smallClose()
            default: self.close()
            }
        })
    }
}
