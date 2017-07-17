//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  UIButton+States.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

extension UIButton {
    func setSetupButtonStates(_ setupButtonStates: Bool) {
        let normalImage: UIImage? = image(for: .normal)
        let hiImage: UIImage? = setupButtonStates ? normalImage?.applying(kkJRFilterButtonHiAlpha) : nil
        let disImage: UIImage? = setupButtonStates ? normalImage?.applying(kkJRFilterButtonDisAlpha) : nil
        setImage(hiImage, for: .highlighted)
        setImage(disImage, for: .disabled)
        let selectedImage: UIImage? = image(for: .selected)
        let hiSelectedImage: UIImage? = setupButtonStates ? selectedImage?.applying(kkJRFilterButtonHiAlpha) : nil
        setImage(hiSelectedImage, for: [.highlighted, .selected])
        adjustsImageWhenDisabled = false
        adjustsImageWhenHighlighted = false
    }
}

let kkJRFilterButtonHiAlpha = 0.4
let kkJRFilterButtonDisAlpha = 0.25