//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  ASTSimpleSearchFormSeparatorView.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

enum ASTSearchFormSeparatorViewStyle : Int {
    case top
    case bottom
}


class ASTSimpleSearchFormSeparatorView: UIView {
    var separatorColor: UIColor?
    var leftInset: CGFloat = 0.0
    var rightInset: CGFloat = 0.0
    var style = ASTSearchFormSeparatorViewStyle(rawValue: 0)!

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        separatorColor?.set()
        let y: CGFloat = style == .top ? bounds.minY : bounds.maxY
        let currentContext: CGContext? = UIGraphicsGetCurrentContext()
        currentContext.setLineWidth(1.0 * UIScreen.main.scale())
        currentContext.move(to: CGPoint(x: leftInset, y: y))
        currentContext.addLine(to: CGPoint(x: bounds.width - rightInset, y: y))
        currentContext.strokePath()
    }
}