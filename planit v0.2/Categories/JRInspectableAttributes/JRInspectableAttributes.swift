//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRInspectableAttributes.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

extension UILabel {
    @IBInspectable var ipadFontSize: CGFloat = 0.0
    @IBInspectable var iphone6FontSize: CGFloat = 0.0
    @IBInspectable var iphone6PlusFontSize: CGFloat = 0.0
    @IBInspectable var iphone4FontSize: CGFloat = 0.0
    @IBInspectable var jrTextColorKey: String = ""

    func ipadFontSize() -> CGFloat {
        return 0
    }

    func setIpadFontSize(_ ipadFontSize: CGFloat) {
        if iPad() {
            font = UIFont(name: font.fontName, size: ipadFontSize)
        }
    }

    func iphone6FontSize() -> CGFloat {
        return 0
    }

    func setIphone6FontSize(_ iphone6FontSize: CGFloat) {
        if iPhone47Inch() {
            font = UIFont(name: font.fontName, size: iphone6FontSize)
        }
    }

    func iphone6PlusFontSize() -> CGFloat {
        return 0
    }

    func setIphone6PlusFontSize(_ iphone6PlusFontSize: CGFloat) {
        if iPhone55Inch() {
            font = UIFont(name: font.fontName, size: iphone6PlusFontSize)
        }
    }

    func iphone4FontSize() -> CGFloat {
        return 0
    }

    func setIphone4FontSize(_ iphone4FontSize: CGFloat) {
        if iPhone35Inch() {
            font = UIFont(name: font.fontName, size: iphone4FontSize)
        }
    }

    func jrTextColorKey() -> String {
        return nil
    }

    func setJRTextColorKey(_ JRTextColorKey: String) {
        textColor = colorFromConstant(JRTextColorKey)
    }
}

extension NSLayoutConstraint {
    @IBInspectable var ipadConstant: CGFloat = 0.0
    @IBInspectable var iphone6Constant: CGFloat = 0.0
    @IBInspectable var iphone6PlusConstant: CGFloat = 0.0
    @IBInspectable var iphone4Constant: CGFloat = 0.0

    func ipadConstant() -> CGFloat {
        return 0
    }

    func setIpadConstant(_ ipadConstant: CGFloat) {
        if iPad() {
            constant = ipadConstant
        }
    }

    func iphone6Constant() -> CGFloat {
        return 0
    }

    func setIphone6Constant(_ iphone6Constant: CGFloat) {
        if iPhone47Inch() {
            constant = iphone6Constant
        }
    }

    func iphone6PlusConstant() -> CGFloat {
        return 0
    }

    func setIphone6PlusConstant(_ iphone6PlusConstant: CGFloat) {
        if iPhone55Inch() {
            constant = iphone6PlusConstant
        }
    }

    func iphone4Constant() -> CGFloat {
        return 0
    }

    func setIphone4Constant(_ iphone4Constant: CGFloat) {
        if iPhone35Inch() {
            constant = iphone4Constant
        }
    }
}

extension UIView {
    @IBInspectable var jrBackgroundColorKey: String = ""
    @IBInspectable var jrCornerRadius: CGFloat = 0.0
    @IBInspectable var isJRShouldRasterize: Bool = false
    @IBInspectable var jrShadowColor: UIColor?
    @IBInspectable var jrShadowColorKey: String = ""
    @IBInspectable var jrShadowOffset = CGSize.zero
    @IBInspectable var jrShadowOpacity: CGFloat = 0.0
    @IBInspectable var jrShadowRadius: CGFloat = 0.0

    func setJRBackgroundColorKey(_ JRSelectedColorKey: String) {
        backgroundColor = colorFromConstant(JRSelectedColorKey)
    }

    func jrBackgroundColorKey() -> String {
        return nil
    }

    func setJRCornerRadius(_ JRCornerRadius: CGFloat) {
        layer.cornerRadius = JRCornerRadius
        layer.masksToBounds = true
    }

    func jrCornerRadius() -> CGFloat {
        return layer.cornerRadius
    }

    func setJRShouldRasterize(_ JRShouldRasterize: Bool) {
        if JRShouldRasterize {
            layer.rasterizationScale = UIScreen.main.scale()
        }
        layer.shouldRasterize = JRShouldRasterize
    }

    func jrShouldRasterize() -> Bool {
        return layer.shouldRasterize
    }

    func setJRShadowColor(_ JRShadowColor: UIColor) {
        layer.shadowColor = JRShadowColor.cgColor
    }

    func jrShadowColor() -> UIColor {
        return UIColor(CGColor: layer.shadowColor)
    }

    func setJRShadowColorKey(_ JRShadowColorKey: String) {
        setJRShadowColor(colorFromConstant(JRShadowColorKey))
    }

    func jrShadowColorKey() -> String {
        return nil
    }

    func setJRShadowOffset(_ JRShadowOffset: CGSize) {
        layer.shadowOffset = JRShadowOffset
    }

    func jrShadowOffset() -> CGSize {
        return layer.shadowOffset
    }

    func setJRShadowOpacity(_ JRShadowOpacity: CGFloat) {
        layer.shadowOpacity = JRShadowOpacity
    }

    func jrShadowOpacity() -> CGFloat {
        return layer.shadowOpacity
    }

    func setJRShadowRadius(_ JRShadowRadius: CGFloat) {
        layer.shadowRadius = JRShadowRadius
    }

    func jrShadowRadius() -> CGFloat {
        return layer.shadowRadius
    }
}

extension UIButton {
    @IBInspectable var jrNormalColor: UIColor?
    @IBInspectable var jrNormalColorKey: String = ""
    @IBInspectable var jrHighlightedColor: UIColor?
    @IBInspectable var jrHighlightedColorKey: String = ""
    @IBInspectable var jrSelectedColor: UIColor?
    @IBInspectable var jrSelectedColorKey: String = ""
    @IBInspectable var jrDisabledColor: UIColor?
    @IBInspectable var jrDisabledColorKey: String = ""
    @IBInspectable var jrTextNormalColorKey: String = ""
    @IBInspectable var jrTextHighlightedColorKey: String = ""
    @IBInspectable var jrTextSelectedColorKey: String = ""
    @IBInspectable var jrTextDisabledColorKey: String = ""

    func setJRNormalColor(_ JRNormalColor: UIColor) {
        setBackgroundImage(UIImage(color: JRNormalColor), for: .normal)
    }

    func jrNormalColor() -> UIColor {
        return nil
    }

    func setJRNormalColorKey(_ JRNormalColorKey: String) {
        setJRNormalColor(colorFromConstant(JRNormalColorKey))
    }

    func jrNormalColorKey() -> String {
        return nil
    }

    func setJRHighlightedColor(_ JRHighlightedColor: UIColor) {
        setBackgroundImage(UIImage(color: JRHighlightedColor), for: .highlighted)
    }

    func jrHighlightedColor() -> UIColor {
        return nil
    }

    func setJRHighlightedColorKey(_ JRHighlightedColorKey: String) {
        setJRHighlightedColor(colorFromConstant(JRHighlightedColorKey))
    }

    func jrHighlightedColorKey() -> String {
        return nil
    }

    func setJRSelectedColor(_ JRSelectedColor: UIColor) {
        setBackgroundImage(UIImage(color: JRSelectedColor), for: .selected)
    }

    func jrSelectedColor() -> UIColor {
        return nil
    }

    func setJRSelectedColorKey(_ JRSelectedColorKey: String) {
        setJRSelectedColor(colorFromConstant(JRSelectedColorKey))
    }

    func jrSelectedColorKey() -> String {
        return nil
    }

    func setJRDisabledColor(_ JRDisabledColor: UIColor) {
        setBackgroundImage(UIImage(color: JRDisabledColor), for: .disabled)
    }

    func jrDisabledColor() -> UIColor {
        return nil
    }

    func setJRDisabledColorKey(_ JRDisabledColorKey: String) {
        setJRDisabledColor(colorFromConstant(JRDisabledColorKey))
    }

    func jrDisabledColorKey() -> String {
        return nil
    }

    func setJRTextNormalColorKey(_ JRTextNormalColorKey: String) {
        setTitleColor(colorFromConstant(JRTextNormalColorKey), for: .normal)
    }

    func jrTextNormalColorKey() -> String {
        return nil
    }

    func setJRTextHighlightedColorKey(_ JRTextHighlightedColorKey: String) {
        setTitleColor(colorFromConstant(JRTextHighlightedColorKey), for: .highlighted)
    }

    func jrTextHighlightedColorKey() -> String {
        return nil
    }

    func setJRTextSelectedColorKey(_ JRTextSelectedColorKey: String) {
        setTitleColor(colorFromConstant(JRTextSelectedColorKey), for: .selected)
    }

    func jrTextSelectedColorKey() -> String {
        return nil
    }

    func setJRTextDisabledColorKey(_ JRTextDisabledColorKey: String) {
        setTitleColor(colorFromConstant(JRTextDisabledColorKey), for: .disabled)
    }

    func jrTextDisabledColorKey() -> String {
        return nil
    }
}

@inline(__always) private func colorFromConstant(constant: String) -> UIColor {
    return JRColorScheme.color(fromConstant: constant)
}