//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRPriceUtils.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

class JRPriceUtils: NSObject {
    class func formattedPrice(inUserCurrency price: JRSDKPrice) -> String {
        let minPriceValue = price.inUserCurrency()
        return AviasalesNumberUtil.formatPrice(minPriceValue)
    }
}