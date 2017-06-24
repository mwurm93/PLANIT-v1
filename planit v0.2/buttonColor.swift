//
//  buttonColor.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/23/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

extension UIButton {
    
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: forState)
    }

}

extension UIColor {
    func getCustomBlueColor() -> UIColor {
        return UIColor(red: 0/255, green:8/255 ,blue:108/255 , alpha:0.82)
    }
}
