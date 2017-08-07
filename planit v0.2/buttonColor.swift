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
    func setButtonWithTransparentText(button: UIButton, title: NSString, color: UIColor) {
        button.backgroundColor = color
        button.titleLabel?.backgroundColor = UIColor.clear
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(UIColor.clear, for: .normal)
        button.setTitle(title as String, for: [])
        let buttonSize: CGSize = button.bounds.size
        let font: UIFont = button.titleLabel!.font
        let centeredStyle = NSMutableParagraphStyle()
        centeredStyle.alignment = .center
        let attribs: [String : AnyObject] = [NSFontAttributeName: button.titleLabel!.font, NSParagraphStyleAttributeName: centeredStyle]
        let textSize: CGSize = title.size(attributes: attribs)
        UIGraphicsBeginImageContextWithOptions(buttonSize, false, UIScreen.main.scale)
        let ctx: CGContext = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(UIColor.white.cgColor)
        let center: CGPoint = CGPoint(x: buttonSize.width / 2 - textSize.width / 2, y: buttonSize.height / 2 - textSize.height / 2)
        let path: UIBezierPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: buttonSize.width, height: buttonSize.height))
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        ctx.setBlendMode(.destinationOut)
        title.draw(at: center, withAttributes: [NSFontAttributeName: font])
        let viewImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let maskLayer: CALayer = CALayer()
        maskLayer.contents = ((viewImage.cgImage) as AnyObject)
        maskLayer.frame = button.bounds
        button.layer.mask = maskLayer
        button.layer.borderWidth = 0
        
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.removeMask(button: button, color: color)
        }
    }
    
    func removeMask(button:UIButton, color: UIColor) {
        button.backgroundColor = UIColor.clear
        button.layer.mask = nil
        button.layer.borderWidth = 1
        button.layer.borderColor = color.cgColor
        button.setTitleColor(color, for: .normal)

    }
    
    func buttonClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.setButtonWithTransparentText(button: sender, title: sender.currentTitle as! NSString, color: (sender.titleLabel?.textColor)!)
        } else {
            sender.removeMask(button:sender, color: (sender.titleLabel?.textColor)!)
        }
        for subview in self.subviews {
            if subview.isKind(of: UIButton.self) && subview != sender {
                (subview as! UIButton).isSelected = false
                (subview as! UIButton).layer.borderWidth = 1
            }
        }
    }
}

extension UIColor {
    func getCustomBlueColor() -> UIColor {
        return UIColor(red: 0/255, green:8/255 ,blue:108/255 , alpha:0.82)
    }
}
