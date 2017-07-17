//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFilterOneThumbSliderItem.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

class JRFilterOneThumbSliderItem: NSObject, JRFilterItemProtocol {
    private(set) var minValue: CGFloat = 0.0
    private(set) var maxValue: CGFloat = 0.0
    var currentValue: CGFloat = 0.0
    var filterAction: (() -> Void)? = nil

    init(minValue: CGFloat, maxValue: CGFloat, currentValue: CGFloat) {
        super.init()
        
        self.minValue = minValue
        self.maxValue = maxValue
        self.currentValue = currentValue
    
    }

//- mark JRFilterItemProtocol
    func tilte() -> String {
        return ""
    }

    func attributedStringValue() -> NSAttributedString {
        return NSAttributedString(string: "")
    }
}

class JRFilterPriceItem: JRFilterOneThumbSliderItem {
//- mark JRFilterItemProtocol

    func tilte() -> String {
        return NSLS("JR_FILTER_PRICE_FILTER")
    }

    func attributedStringValue() -> NSAttributedString {
        let userCurrency: JRSDKCurrency = AviasalesSDK.sharedInstance.currencyCode
        let priceInUserCurrency = AviasalesNumberUtil.convertPrice((currentValue), fromCurrency: "usd", to: userCurrency)
        let priceString: String = AviasalesNumberUtil.formatPrice(priceInUserCurrency)
        let text: String = "\(NSLS("JR_FILTER_TOTAL_DURATION_PRIOR_UP_TO")) \(priceString)"
        var attributedText = NSMutableAttributedString(string: text, attributes: nil)
        return attributedText
    }
}

class JRFilterTotalDurationItem: JRFilterOneThumbSliderItem {
//- mark JRFilterItemProtocol

    func tilte() -> String {
        return NSLS("JR_FILTER_TOTAL_DURATION")
    }

    func attributedStringValue() -> NSAttributedString {
        let timeString: String = DateUtil.duration(currentValue, durationStyle: JRDateUtilDurationLongStyle)
        let text: String = "\(NSLS("JR_FILTER_TOTAL_DURATION_PRIOR_UP_TO")) \(timeString)"
        var attributedText = NSMutableAttributedString(string: text, attributes: nil)
        return attributedText
    }
}