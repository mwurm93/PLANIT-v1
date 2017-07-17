//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRTicketUtils.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

class JRTicketUtils: NSObject {
    class func formattedTicketMinPrice(inUserCurrency ticket: JRSDKTicket) -> String {
        let minProposal: JRSDKProposal? = JRSDKModelUtils.ticketMinimalPriceProposal(ticket)
        let minPriceValue = minProposal?.price?.priceInUserCurrency()
        return AviasalesNumberUtil.formatPrice(minPriceValue)
    }
}