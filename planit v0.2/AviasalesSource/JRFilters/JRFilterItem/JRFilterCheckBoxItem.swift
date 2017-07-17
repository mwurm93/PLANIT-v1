//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFilterCheckBoxItem.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

class JRFilterCheckBoxItem: NSObject, JRFilterItemProtocol {
    var filterAction: (() -> Void)? = nil
    var isSelected: Bool = false
    var isShowAverageRate: Bool {
        return false
    }
    var rating: Int {
        return 0
    }

    func tilte() -> String {
        return ""
    }

    func attributedStringValue() -> NSAttributedString {
        return NSAttributedString(string: "")
    }
}

class JRFilterStopoverItem: JRFilterCheckBoxItem {
    private var stopoverCount: Int = 0
    private var minPrice: CGFloat = 0.0

    init(stopoverCount: Int, minPrice: CGFloat) {
        super.init()
        
        self.stopoverCount = stopoverCount
        self.minPrice = minPrice
    
    }

    func tilte() -> String {
        if stopoverCount == 0 {
            return NSLS("JR_SEARCH_RESULTS_TRANSFERS##{zero}")
        }
        let format: String = NSLSP("JR_SEARCH_RESULTS_TRANSFERS", stopoverCount)
        return String(format: format, stopoverCount)
    }

    func attributedStringValue() -> NSAttributedString {
        let userCurrency: JRSDKCurrency = AviasalesSDK.sharedInstance.currencyCode
        let priceInUserCurrency = AviasalesNumberUtil.convertPrice((minPrice), fromCurrency: "usd", to: userCurrency)
        let priceString: String = AviasalesNumberUtil.formatPrice(priceInUserCurrency)
        let text: String = "\(NSLS("JR_FILTER_TOTAL_DURATION_FROM")) \(priceString)"
        var attributedText = NSMutableAttributedString(string: text, attributes: nil)
        return attributedText
    }
}

class JRFilterGateItem: JRFilterCheckBoxItem {
    private var gate: JRSDKGate?

    init(gate: JRSDKGate) {
        super.init()
        
        self.gate = gate
    
    }

    func tilte() -> String {
        return gate.label!
    }
}

class JRFilterPaymentMethodItem: JRFilterCheckBoxItem {
    private var paymentMethod: JRSDKPaymentMethod?

    init(paymentMethod: JRSDKPaymentMethod) {
        super.init()
        
        self.paymentMethod = paymentMethod
    
    }

    func tilte() -> String {
        return paymentMethod.localizedName
    }
}

class JRFilterAirlineItem: JRFilterCheckBoxItem {
    private var airline: JRSDKAirline?

    init(airline: JRSDKAirline) {
        super.init()
        
        self.airline = airline
    
    }

    func showAverageRate() -> Bool {
        return true
    }

    func rating() -> Int {
        return CInt(airline.averageRate)
    }

    func tilte() -> String {
        return airline.name!
    }
}

class JRFilterAllianceItem: JRFilterCheckBoxItem {
    private var alliance: JRSDKAlliance?

    init(alliance: JRSDKAlliance) {
        super.init()
        
        self.alliance = alliance
    
    }

    func tilte() -> String {
        return (alliance.name == JR_OTHER_ALLIANCES) ? NSLS("JR_FILTER_OTHER_ALLIANCES") : alliance.name
    }
}

class JRFilterAirportItem: JRFilterCheckBoxItem {
    private var airport: JRSDKAirport?

    init(airport: JRSDKAirport) {
        super.init()
        
        self.airport = airport
    
    }

    func tilte() -> String {
        return airport.airportName
    }
}