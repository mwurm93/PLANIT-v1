//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  NSError+HLCustomErrors.swift
//  HotelLook
//
//  Created by Anton Chebotov on 06/02/14.
//  Copyright (c) 2014 Anton Chebotov. All rights reserved.
//

import Foundation

enum HLErrorCode : Int {
    case hlServerUnavailableError = 10000
    case hlNoSearchInfoError
    case hlNoNearbyCitiesError
    case hlSearchMaxDurationExceed
    case hlManagedCityDetectionFailed
    case hlHotelsContentLoadingWithEmptyParamsError
    case hlHotelDetailsLoadingEmptyHotelIdError
    case hlHotelDetailsLoadingEmptyCityIdError
    case hlHotelsContentLoadinNoContentError
    case hlRoomsLoaderNoContentError
    case hlNoContentInCitiesAutocompletionError
    case hlWrongResponseJSONFormatError
    case hlWrongDeeplinkResponseFormateError
    case hlWrongHotelDetailsResponseFormateError
    case hlEmptyAutocompleteNonCriticalError
    case hlDatePickerLimitNonCriticalError
    case hlEmptyResultsNonCriticalError
    case hlOutdatedResultsNonCriticalError
    case hlToughFiltersNonCriticalError
    case hlNoMinPriceNonCriticalError
    case hlInvalidArgument
    case hlMigrationError
}

let kHLServerErrorDomain: String = "HLServerErrorDomain"
let kHLURLResponseErrorDomain: String = "HLURLResponseErrorDomain"
let kHLNetworkErrorDomain: String = "HLNetworErrorDomain"
let kHLErrorDomain: String = "HLErrorDomain"
let kHLNonCriticalErrorDomain: String = "HLNonCriticalErrorDomain"
let kHLMigrationErrorDomain: String = "kHLMigrationErrorDomain"

extension NSError {
    convenience init(code: HLErrorCode) {
        return Error(domain: Error.hlErrorDomain(), code: code, userInfo: nil)
    }

    class func errorServer(with code: HLErrorCode) -> Error? {
        return Error(domain: Error.hlServerErrorDomain(), code: code, userInfo: nil)
    }

    class func errorURLResponse(with code: HLErrorCode) -> Error? {
        return Error(domain: Error.hlURLResponseErrorDomain(), code: code, userInfo: nil)
    }

    class func errorNonCritical(with code: HLErrorCode) -> Error? {
        return Error(domain: Error.hlNonCriticalErrorDomain(), code: code, userInfo: nil)
    }

    class func errorMigration(with code: HLErrorCode, description: String) -> Error? {
        let userInfo: [AnyHashable: Any] = description ? [NSLocalizedDescriptionKey: description] : nil
        return Error(domain: Error.hlMigrationErrorDomain(), code: code, userInfo: userInfo)
    }

    class func hlErrorDomain() -> String {
        return kHLErrorDomain
    }

    class func hlServerErrorDomain() -> String {
        return kHLServerErrorDomain
    }

    class func hlNetworkErrorDomain() -> String {
        return kHLNetworkErrorDomain
    }

    class func hlMigrationErrorDomain() -> String {
        return kHLMigrationErrorDomain
    }

    class func hlURLResponseErrorDomain() -> String {
        return kHLURLResponseErrorDomain
    }

    class func hlNonCriticalErrorDomain() -> String {
        return kHLNonCriticalErrorDomain
    }
}