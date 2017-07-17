//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation

class HLAlertsFabric: NSObject {
// MARK: - System alerts

    class func showOutdatedResultsAlert(_ handler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: NSLS("HL_ALERT_OUTDATED_RESULTS_TITLE"), message: NSLS("HL_ALERT_OUTDATED_RESULTS_DESCRIPTION"), preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLS("HL_LOC_ALERT_LATER_BUTTON"), style: .default, handler: nil)
        alertController.addAction(ok)
        let newSearch = UIAlertAction(title: NSLS("HL_NEW_SEARCH_BUTTON"), style: .default, handler: handler as? ((UIAlertAction) -> Void) ?? ((UIAlertAction) -> Void)())
        alertController.addAction(newSearch)
        UIApplication.shared.keyWindow.rootViewController.present(alertController as? UIViewController ?? UIViewController(), animated: true) { _ in }
    }

    class func showSearchAlertViewWithError(_ error: Error?, handler: (() -> Void)? = nil) {
        if error?.code == NSURLErrorNotConnectedToInternet {
            HLAlertsFabric.showNoInternetConnectionAlert(handler)
        }
        else {
            HLAlertsFabric.showSearchErrorAlert(handler)
        }
    }

    class func showEmptySearchFormAlert(_ searchInfo: HLSearchInfo, in controller: UIViewController) {
        self.showAlert(withText: self.alertMessage(searchInfo), title: NSLS("HL_LOC_SEARCH_FORM_EMPTY_ALERT_TITLE"), in: controller)
    }

    class func showMailSenderUnavailableAlert(in controller: UIViewController) {
        self.showAlert(withText: NSLS("HL_LOC_EMAIL_SENDER_UNAVALIBLE_MESSAGE"), title: NSLS("HL_LOC_EMAIL_SENDER_UNAVALIBLE_TITLE"), in: controller)
    }

    class func showLocationAlert() {
        let alertController = UIAlertController(title: NSLS("HL_LOC_NO_CURRENT_CITY_SCREEN_TITLE"), message: NSLS("HL_LOC_NO_CURRENT_CITY_SCREEN_DESCRIPTION"), preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLS("HL_LOC_ALERT_LATER_BUTTON"), style: .default, handler: nil)
        alertController.addAction(ok)
        let settings = UIAlertAction(title: NSLS("HL_LOC_NO_CURRENT_CITY_SETTINGS_BUTTON"), style: .default, handler: {(_ action: UIAlertAction) -> Void in
                JRAppDelegate.openSettings()
            })
        alertController.addAction(settings)
        UIApplication.shared.keyWindow.rootViewController.present(alertController as? UIViewController ?? UIViewController(), animated: true) { _ in }
    }

    class func clipboardToast() -> HLToastView {
        let text: String = NSLS("HL_LOC_SHARE_COPIED_TO_CLIPBOARD")
        let image = UIImage.toastCheckMarkIcon()
        let toastView: HLToastView? = self.toast(withText: text, icon: image)
        toastView?.isUserInteractionEnabled = false
        return toastView!
    }

    class func datesRestrictionToast() -> HLToastView {
        let text: String = NSLS("HL_LOC_DATE_PICKER_LENGTH_RESTRICTION_TITLE")
        let image = UIImage(named: "toastCrossIcon")
        return self.toast(withText: text, icon: image)
    }

    class func showAlert(withText text: String, title: String, in parentController: UIViewController) -> UIAlertController {
        let alertController = UIAlertController(title: title as? String ?? "", message: text as? String ?? "", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(ok)
        parentController.present(alertController as? UIViewController ?? UIViewController(), animated: true) { _ in }
        return alertController
    }

    class func showSearchErrorAlert(_ handler: ((_ action: UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: NSLS("HL_ALERT_SEARCH_ERROR_TITLE"), message: NSLS("HL_ALERT_SEARCH_ERROR_DESCRIPTION"), preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLS("HL_LOC_ALERT_CLOSE_BUTTON"), style: .default, handler: handler as? ((UIAlertAction) -> Void) ?? ((UIAlertAction) -> Void)())
        alertController.addAction(ok)
        UIApplication.shared.keyWindow.rootViewController.present(alertController as? UIViewController ?? UIViewController(), animated: true) { _ in }
    }

    class func showNoInternetConnectionAlert(_ handler: ((_ action: UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: NSLS("HL_ALERT_NO_INTERNET_CONNECTION_TITLE"), message: NSLS("HL_ALERT_NO_INTERNET_CONNECTION_DESCRIPTION"), preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLS("HL_LOC_ALERT_CLOSE_BUTTON"), style: .default, handler: handler as? ((UIAlertAction) -> Void) ?? ((UIAlertAction) -> Void)())
        alertController.addAction(ok)
        UIApplication.shared.keyWindow.rootViewController.present(alertController as? UIViewController ?? UIViewController(), animated: true) { _ in }
    }

// MARK: - Toasts

// MARK: - Private
    class func toast(withText text: String, icon image: UIImage) -> HLToastView {
        let tv: HLToastView? = LOAD_VIEW_FROM_NIB_NAMED("HLToastView")
        tv?.titleLabel?.text = text
        tv?.iconView?.image = image
        tv?.hideAfterTime = 2.0
        return tv!
    }

    class func alertMessage(_ searchInfo: HLSearchInfo) -> String {
        if searchInfo.adultsCount <= 0 {
            return NSLS("HL_LOC_SEARCH_FORM_EMPTY_ADULTS_MESSAGE")
        }
        if searchInfo.checkInDate == nil || searchInfo.checkOutDate == nil {
            return NSLS("HL_LOC_SEARCH_FORM_EMPTY_DATES_MESSAGE")
        }
        if searchInfo.city == nil && searchInfo.hotel == nil {
            return NSLS("HL_LOC_SEARCH_FORM_EMPTY_CITY_MESSAGE")
        }
        return NSLS("HL_LOC_SEARCH_FORM_EMPTY_CITY_MESSAGE")
    }
}