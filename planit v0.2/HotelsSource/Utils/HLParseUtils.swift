//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import CoreLocation
import Foundation
import HotellookSDK

let kNegationPrefix: String = "!"

class HLParseUtils: NSObject {
// MARK: - Options

// MARK: - Options

    class func optionsWithValues(fromOptionsStrings optionsStrings: [String]) -> [[AnyHashable: Any]] {
        var optionsAndValues = [Any]()
        for option: String in optionsStrings {
            var shouldAddOption: Bool = true
            if option.hasPrefix(kNegationPrefix) {
                let optionStringWithoutPrefix: String = (option as? NSString)?.substring(from: (kNegationPrefix.characters.count ?? 0))
                shouldAddOption = !optionsStrings.contains(optionStringWithoutPrefix)
            }
            else {
                shouldAddOption = !optionsStrings.contains(kNegationPrefix + (option))
            }
            if shouldAddOption {
                optionsAndValues.append(self.optionWithValue(fromOptionString: option))
            }
        }
        return optionsAndValues
    }

    class func optionWithValue(fromOptionString optionString: String) -> [AnyHashable: Any] {
        var dictionaryToReturn: [AnyHashable: Any]
        if optionString.hasPrefix(kNegationPrefix) {
            let optionStringWithoutPrefix: String = (optionString as? NSString)?.substring(from: (kNegationPrefix.characters.count ?? 0))
            dictionaryToReturn = [optionStringWithoutPrefix: false]
        }
        else {
            dictionaryToReturn = [optionString: true]
        }
        return dictionaryToReturn
    }
}