//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRSDKAirport+LocalizedName.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//
//
//  JRSDKAirport+LocalizedName.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
///

extension JRSDKAirport {
    func localizedName() -> String {
        if isCity {
            return NSLS("JR_ANY_AIRPORT")
        }
        else {
            return airportName
        }
    }
}