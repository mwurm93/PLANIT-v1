//
//  buttonDashedBorder.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 7/31/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

extension UIButton {
    func addDashedBorder(lineWidth: Int, lineColor: UIColor, height: CGFloat) {
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = CGFloat(lineWidth)
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [18,10]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: height / 2).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
}

