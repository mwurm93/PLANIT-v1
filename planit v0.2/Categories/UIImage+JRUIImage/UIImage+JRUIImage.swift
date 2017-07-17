//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  UIImage+JRUIImage.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

extension UIImage {
    convenience init(color: UIColor) {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext? = UIGraphicsGetCurrentContext()
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    func imageTinted(with color: UIColor) -> UIImage {
        return imageTinted(with: color, fraction: 0.0)
    }

    func imageTinted(with color: UIColor, fraction: CGFloat) -> UIImage {
        if color {
            var image: UIImage?
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            var rect = CGRect.zero
            rect.size = size
            color.set()
            UIRectFill(rect)
            draw(in: rect, blendMode: kCGBlendModeDestinationIn, alpha: 1.0)
            if fraction > 0.0 {
                draw(in: rect, blendMode: kCGBlendModeSourceAtop, alpha: fraction)
            }
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image!
        }
    }

    func applyingAlpha(_ alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let ctx: CGContext? = UIGraphicsGetCurrentContext()
        let area = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        ctx.scaleBy(x: 1, y: -1)
        ctx.translateBy(x: 0, y: -area.size.height)
        CGContextSetBlendMode(ctx, kCGBlendModeMultiply)
        ctx.setAlpha(alpha)
        ctx.draw(in: cgImage, image: area)
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}