//
//  textfieldUnderline.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/23/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

extension UITextField {
    func setBottomBorder(borderColor: UIColor) {
        
        self.borderStyle = UITextBorderStyle.none
        self.backgroundColor = UIColor.clear
        let width = 1.0
        
        let borderLine = UIView()
        borderLine.frame = CGRect(x: 0, y: Double(self.frame.height) - width, width: Double(self.frame.width), height: width)
        
        borderLine.backgroundColor = borderColor
        self.addSubview(borderLine)
    }
}

extension UITextView {
    func setBottomBorder(borderColor: UIColor) {
        
        self.backgroundColor = UIColor.clear
        let width = 1.0
        
        let borderLine = UIView()
        borderLine.frame = CGRect(x: 0, y: Double(self.frame.height) - width, width: Double(self.frame.width), height: width)
        
        borderLine.backgroundColor = borderColor
        self.addSubview(borderLine)
    }
}

