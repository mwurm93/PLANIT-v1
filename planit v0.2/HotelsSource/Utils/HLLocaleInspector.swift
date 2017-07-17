//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation

class HLLocaleInspector: NSObject {
    class func shared() -> HLLocaleInspector {
        var sharedInspector: HLLocaleInspector?
        var onceToken: Int
        if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
            sharedInspector = HLLocaleInspector()
        }
        onceToken = 1
        return sharedInspector!
    }

    class func shouldUseMetricSystem() -> Bool {
        return NSLocale.currentLocale.object(forKey: NSLocaleUsesMetricSystem)?
    }

    class func localizedUserReviewLangName(forLang lang: String) -> String {
        let locKey: String = "HL_HOTEL_DETAIL_LANGUAGE_" + (lang.uppercased())
        let localizedString: String = NSLS(locKey)
        let localizationNotFound: Bool = (localizedString == locKey)
        if localizationNotFound {
            return ""
        }
        else {
            return localizedString
        }
    }

    class func userReviewLangName() -> String {
        let language: String = HLLocaleInspector.shared().uiLanguage
        let locale: String? = NSLocale.currentLocale.object(forKey: NSLocaleCountryCode)?.lowercased()
        if !(language == "en") {
            return language
        }
        if !(locale == "en") {
            return locale!
        }
        return nil
    }

    func localeString() -> String {
        let locale = NSLocale.currentLocale
        let lang: String? = locale.object(forKey: NSLocaleLanguageCode)
        let scriptCode: String? = locale.object(forKey: NSLocaleScriptCode)
        let region: String? = locale.object(forKey: NSLocaleCountryCode)
        var result: String? = lang?
        if (scriptCode?.characters.count ?? 0) > 0 {
            result! += "-\(scriptCode)"
        }
        if (region?.characters.count ?? 0) > 0 {
            result! += "_\(region)"
        }
        return result!
    }

    func isLanguageRussian(_ lang: String) -> Bool {
        return (lang == "ru")
    }

    func isLanguageEnglish(_ lang: String) -> Bool {
        return (lang == "en")
    }

    func isCurrentLanguageRussian() -> Bool {
        return isLanguageRussian(uiLanguage)
    }

    func isCurrentLanguageEnglish() -> Bool {
        return isLanguageEnglish(uiLanguage)
    }

    func countryCode() -> String {
        return NSLocale.currentLocale.object(forKey: NSLocaleCountryCode) ?? "US"!
    }

    func uiLanguage() -> String {
        let localeLang: String = (NSLocale.preferredLanguages[0] as? String ?? "" as? NSString)?.substring(to: 2)
        return localeLang
    }
}