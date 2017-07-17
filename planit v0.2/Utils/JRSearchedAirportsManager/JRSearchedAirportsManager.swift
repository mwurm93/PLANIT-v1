//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRSearchedAirportsManager.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

private let kJRSearchedAirportsStorageKey: String = "kJRSearchedAirportsStorageKey"
private let kJRSearchedAirportsMaxCount: Int = 20

class JRSearchedAirportsManager: NSObject {
    class func markSearchedAirport(_ searchedAirport: JRSDKAirport) {
        let airportData: [AnyHashable: Any] = ["iata": searchedAirport.iata(), "isCity": (searchedAirport.isCity())]
        var searchedAirports: [Any] = JRSearchedAirportsManager.rawSearchedAirports()
        for airportData: [AnyHashable: Any] in searchedAirports {
            if (airportData["iata"] == searchedAirport.iata()) && airportData["isCity"] == searchedAirport.isCity() {
                searchedAirports.remove(at: searchedAirports.index(of: airportData)!)
                break
            }
        }
        searchedAirports.insert(airportData, at: 0)
        if searchedAirports.count > kJRSearchedAirportsMaxCount {
            searchedAirports.removeObjects(in: NSRange(location: kJRSearchedAirportsMaxCount, length: searchedAirports.count - kJRSearchedAirportsMaxCount))
        }
        UserDefaults.standard.setValue(searchedAirports, forKey: kJRSearchedAirportsStorageKey)
        UserDefaults.standard.synchronize()
    }

    class func searchedAirports() -> [JRSDKAirport] {
        var airports = [Any]()
        for airportData: [AnyHashable: Any] in JRSearchedAirportsManager.rawSearchedAirports() {
            let airport: JRSDKAirport? = AviasalesSDK.sharedInstance.airportsStorage().findAirport(byIATA: airportData["iata"], city: airportData["isCity"])
            if airport != nil {
                airports.append(airport)
            }
        }
        return airports
    }

    class func rawSearchedAirports() -> [Any] {
        let airportsData: Any? = UserDefaults.standard.value(forKey: kJRSearchedAirportsStorageKey)
        var searchedAirports = [Any]()
        if (airportsData? is [Any]) {
            searchedAirports = (airportsData as? [Any])
        }
        return searchedAirports
    }
}