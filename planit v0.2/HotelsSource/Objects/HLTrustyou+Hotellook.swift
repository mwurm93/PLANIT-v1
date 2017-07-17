//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation
import HotellookSDK

extension HDKTrustyou {
// MARK: - Target Language Visitors Percent

    func userReviewLanguageVisitorsPercent() -> Int {
        var result: Int = -1
        let userReviewLangName: String = HLLocaleInspector.userReviewLangName()
        for dict: [AnyHashable: Any] in languageDistribution {
            let langName: String = dict["name"]
            if (userReviewLangName == langName) {
                let percentage: Int = dict.integer(forKey: "percentage", defaultValue: -1)
                if percentage >= 0 {
                    result = percentage
                    break
                }
            }
        }
        return result
    }
}

//#import "HLLocaleInspector.h"