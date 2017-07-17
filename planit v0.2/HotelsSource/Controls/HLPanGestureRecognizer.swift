//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  HLPanGestureRecognizer.swift
//  HotelLook
//
//  Created by Oleg on 27/05/14.
//  Copyright (c) 2014 Anton Chebotov. All rights reserved.
//

import Foundation
import UIKit

enum HLPanGestureRecognizerDirection : Int {
    case vertical
    case horizontal
}

private let kDirectionPanThreshold: Int = 5

class HLPanGestureRecognizer: UIPanGestureRecognizer {
    var direction = HLPanGestureRecognizerDirection(rawValue: 0)!

    private var drag: Bool = false
    private var moveX: Int = 0
    private var moveY: Int = 0

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches as? Set<UITouch> ?? Set<UITouch>(), with: event)
        if state == .failed {
            return
        }
        let nowPoint: CGPoint? = touches.first?.location(in: view)
        let prevPoint: CGPoint? = touches.first?.previousLocation(in: view)
        moveX += (prevPoint?.x - nowPoint?.x)
        moveY += (prevPoint?.y - nowPoint?.y)
        if !drag {
            if abs(moveX) > kDirectionPanThreshold {
                if direction == .vertical {
                    //                self.state = UIGestureRecognizerStateFailed;
                }
                else {
                    drag = true
                }
            }
            else if abs(moveY) > kDirectionPanThreshold {
                if direction == .horizontal {
                    //                self.state = UIGestureRecognizerStateFailed;
                }
                else {
                    drag = true
                }
            }
        }
    }

    override func reset() {
        super.reset()
        drag = false
        moveX = 0
        moveY = 0
    }
}