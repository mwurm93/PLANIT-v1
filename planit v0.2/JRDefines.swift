//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRDefines.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//
//
//  Defines.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

enum DeviceSizeType : Int {
    case iPhone55Inch
    // iPhone 6+
    case iPhone47Inch
    // iPhone 6
    case iPhone4Inch
    // iPhone 5, 5c, 5s,
    case iPhone35Inch
    // iPhone 4s
    case iPad
}

let kHotelsStringsTable: String = "HotelsLocalizable"

#if !AviasalesSDKTemplate_Defines_h
//#define AviasalesSDKTemplate_Defines_h
#if APPSTORE
//#define MLOG(fmt, ...)
#else
//#define MLOG(fmt, ...)  NSLog((@"%s %d: " fmt), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__)
#endif
let AVIASALES_BUNDLE = (Bundle.main.url(forResource: "AviasalesSDKTemplateBundle", withExtension: "bundle") ? Bundle(url: Bundle.main.url(forResource: "AviasalesSDKTemplateBundle", withExtension: "bundle")) : Bundle.main)
func AVIASALES_(v: Any) -> Any {
    return AVIASALES_BUNDLE.localizedString(forKey: (v), value: "", table: ("AviasalesTemplateLocalizable"))
}
func AVIASALES__(k: Any, v: Any) -> Any {
    return AVIASALES_BUNDLE.localizedString(forKey: (k), value: (v), table: ("AviasalesTemplateLocalizable"))
}
let AVIASALES_VC_GRANDPA_IS_TABBAR = parentViewController.parentViewController?.responds(to: #selector(self.tabBar))
let AVIASALES_CURRENCIES = ["eur", "usd", "gbp", "aud", "cad", "nzd", "thb", "pln", "brl", "cny", "hkd", "twd", "sgd", "krw", "myr", "vnd", "jpy", "try", "rub", "idr", "dkk", "nok", "sek", "mop", "php"]
//------------------------
// MACRO
//------------------------
let JR_ANY_AIRPORT = "ANY"
let JR_OTHER_ALLIANCES = "OTHER_ALLIANCES"
let AS_MARKER = JRUserSettings.sharedManager().marker()
func LOAD_VIEW_FROM_NIB_NAMED(X: Any) -> Any {
    return AVIASALES_BUNDLE.loadNibNamed(X, owner: self, options: nil)?[0]
}
func LANDSCAPE_NAME(X: Any) -> Any {
    return "\(X)_landscape"
}
func dispatch_main_sync_safe(block: Any) -> Any {
    return if Thread.isMainThread {
    block()
}
else {
    DispatchQueue.main.sync(execute: block)
}
}
func IS_NON_EMPTY_STRING(object: Any) -> Any {
    return object && (object is String) && (object.characters.count ?? 0) > 0
}
let HL_URL_SHORTENER_USERNAME = "sapato"
let HL_URL_SHORTENER_PASSWORD = "EPhliOk7"
//------------------------
// DEFINES
//------------------------
func JRUserDefaults() -> UserDefaults {
    return UserDefaults.standard
}

func JRPixel() -> CGFloat {
    return 1.0 / UIScreen.main.scale()
}

let HL_DEFAULTS_SEARCH_INFO_KEY = "hotelsSearchInfoKey"
//------------------------
// TARGETS & CONFIGURATIONS
//------------------------
func Simulator() -> Bool {
    return (UIDevice.currentDevice.model == "iPhone Simulator")
}

func iPhone() -> Bool {
    return (UI_USER_INTERFACE_IDIOM() == .phone)
}

func iPhone4Inch() -> Bool {
    return iPhoneWithHeight(568)
}

func iPhone35Inch() -> Bool {
    return iPhoneWithHeight(480)
}

func iPhone47Inch() -> Bool {
    return iPhoneWithHeight(667)
}

func iPhone55Inch() -> Bool {
    return iPhoneWithHeight(736)
}

func iPad() -> Bool {
    return (UI_USER_INTERFACE_IDIOM() == .pad)
}

func CurrentDeviceSizeType() -> DeviceSizeType {
    var wasTypeDefined: Bool = false
    var res: DeviceSizeType
    if wasTypeDefined {
        return res
    }
    else {
        res = iPad() ? .iPad : iPhone55Inch() ? .iPhone55Inch : iPhone47Inch() ? .iPhone47Inch : iPhone4Inch() ? .iPhone4Inch :         /* otherwise */
.iPhone35Inch
        wasTypeDefined = true
        return res
    }
}

func iOSVersionEqualTo(version: String) -> Bool {
    return (UIDevice.currentDevice.systemVersion.compare(version, options: .numeric) == .orderedSame)
}

func iOSVersionGreaterThan(version: String) -> Bool {
    return (UIDevice.currentDevice.systemVersion.compare(version, options: .numeric) == .orderedDescending)
}

func iOSVersionGreaterThanOrEqualTo(version: String) -> Bool {
    return (UIDevice.currentDevice.systemVersion.compare(version, options: .numeric) != .orderedAscending)
}

func iOSVersionLessThan(version: String) -> Bool {
    return (UIDevice.currentDevice.systemVersion.compare(version, options: .numeric) == .orderedAscending)
}

func iOSVersionLessThanOrEqualTo(version: String) -> Bool {
    return (UIDevice.currentDevice.systemVersion.compare(version, options: .numeric) != .orderedDescending)
}

func iPhoneSizeValue(defaultValue: CGFloat, iPhone6Value: CGFloat, iPhone6PlusValue: CGFloat) -> CGFloat {
    switch CurrentDeviceSizeType() {
        case .iPad, .iPhone55Inch:
            return iPhone6PlusValue
        case .iPhone47Inch:
            return iPhone6Value
        default:
            return defaultValue
    }

}

func deviceSizeTypeValue(deviceSizeTypeIPhone35Inch: CGFloat, deviceSizeTypeIPhone4Inch: CGFloat, deviceSizeTypeIPhone47Inch: CGFloat, deviceSizeTypeIPhone55Inch: CGFloat, deviceSizeTypeIPad: CGFloat) -> CGFloat {
    switch CurrentDeviceSizeType() {
        case .iPhone35Inch:
            return deviceSizeTypeIPhone35Inch
        case .iPhone4Inch:
            return deviceSizeTypeIPhone4Inch
        case .iPhone47Inch:
            return deviceSizeTypeIPhone47Inch
        case .iPhone55Inch:
            return deviceSizeTypeIPhone55Inch
        case .iPad:
            return deviceSizeTypeIPad
    }

}

func minScreenDimension() -> CGFloat {
    let screenSize: CGSize = UIScreen.main.bounds.size
    return min(screenSize.width, screenSize.height)
}

func maxScreenDimension() -> CGFloat {
    let screenSize: CGSize = UIScreen.main.bounds.size
    return max(screenSize.width, screenSize.height)
}

func Debug() -> Bool {
#if DEBUG
    return true
#else
    return false
#endif
}

func AppStore() -> Bool {
#if APPSTORE
    return true
#else
    return false
#endif
}

func ticketsEnabled() -> Bool {
#if TICKETS_ENABLED
    return true
#else
    return false
#endif
}

func hotelsEnabled() -> Bool {
#if HOTELS_ENABLED
    return true
#else
    return false
#endif
}

func loadViewFromNibNamed(nibNamed: String) -> UIView? {
    return Bundle.main.loadNibNamed(nibNamed, owner: nil, options: nil)?[0]
}

func loadViewFromNib(nibNamed: String, owner: Any) -> UIView? {
    return Bundle.main.loadNibNamed(nibNamed, owner: owner, options: nil)?[0]
}

func platformName() -> String {
    return iPhone() ? "iphone" : "ipad"
}

//------------------------
// LOCALIZATION
//------------------------
func NSLS(key: String) -> String {
    let result = AVIASALES_BUNDLE.localizedString(forKey: key, value: "", table: "AviasalesTemplateLocalizable")
    if !(result == key) {
        return result
    }
    else {
        return NSLocalizedString(key, tableName: kHotelsStringsTable, bundle: Bundle.main, value: "", comment: "")
    }
}

func NSLSP(key: String, pluralValue: Float) -> String {
    let result = AVIASALES_BUNDLE.pluralizedString(withKey: key, defaultValue: "", table: "AviasalesTemplateLocalizable", pluralValue: SL_FLOATVALUE(pluralValue))
    if !(result == key) {
        return result
    }
    else {
        return Bundle.main.pluralizedString(withKey: key, defaultValue: "", table: kHotelsStringsTable, pluralValue: SL_FLOATVALUE(pluralValue))
    }
}

//------------------------
// DISPATCH
//------------------------
func hl_dispatch_main_sync_safe(block: () -> ()) {
    if Thread.isMainThread {
        block()
    }
    else {
        DispatchQueue.main.sync(execute: block)
    }
}

func hl_dispatch_main_async_safe(block: () -> ()) {
    if Thread.isMainThread {
        block()
    }
    else {
        DispatchQueue.main.async(execute: block)
    }
}

//------------------------
// Float comparison
//------------------------
let FLOAT_COMPARISON_EPSILON = 0.00001
func IS_FLOAT_EQUALS_WITH_ACCURACY(A: Any, B: Any, EPSILON: Any) -> Any {
    return abs(A - B) < EPSILON
}
func IS_FLOAT_EQUALS(A: Any, B: Any) -> Any {
    return IS_FLOAT_EQUALS_WITH_ACCURACY(A, B, FLOAT_COMPARISON_EPSILON)
}
let ZERO_HEADER_HEIGHT = 0.00001
#endif
//------------------------
// CONFIG
//------------------------
func ShowAppodealAds() -> Bool {
    return kShowAppodealAds
}

func ShowAviasalesAds() -> Bool {
    return kShowAviasalesAds
}

//------------------------
// DEFINES
//------------------------

//------------------------
// TARGETS & CONFIGURATIONS
//------------------------

func iPhoneWithHeight(height: CGFloat) -> Bool {
    let screneSize: CGSize = UIScreen.main.bounds.size
    return iPhone() && (fabs(Double(max(screneSize.width, screneSize.height)) - Double(height)) < DBL_EPSILON)
}

//------------------------
// LOCALIZATION
//------------------------

//------------------------
// DISPATCH
//------------------------

//------------------------
// CONFIG
//------------------------