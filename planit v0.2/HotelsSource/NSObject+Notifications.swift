//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation

protocol HLNearbyCitiesDetectionDelegate: NSObjectProtocol {
    func nearbyCitiesDetectionStarted(_ notification: Notification)

    func nearbyCitiesDetected(_ notification: Notification)

    func nearbyCitiesDetectionFailed(_ notification: Notification)

    func nearbyCitiesDetectionCancelled(_ notification: Notification)

    func locationServicesAccessFailed(_ notification: Notification)

    func locationDetectionFailed(_ notification: Notification)
}

protocol HLSearchInfoChangeDelegate: NSObjectProtocol {
    func searchInfoChangedNotification(_ notification: Notification)
}

protocol HLLocationManagerDelegate: NSObjectProtocol {
    func locationUpdatedNotification(_ notification: Notification)

    func locationUpdateFailedNotification(_ notification: Notification)

    func locationServicesAccessFailedNotification(_ notification: Notification)
}

protocol HLCityInfoLoadingProtocol: NSObjectProtocol {
    func cityInfoDidLoad(_ notification: Notification)

    func cityInfoLoadingFailed(_ notification: Notification)

    func cityInfoLoadingCancelled(_ notification: Notification)
}

extension NSObject {
    func registerForSearchInfoChangesNotifications() {
        assert(self is HLSearchInfoChangeDelegate, "Cannot register for notifications. Doesn't conform HLSearchInfoChangeDelegate protocol")
        subscribe(toNotification: HL_SEARCHINFO_CHANGED, withSelector: #selector(self.searchInfoChangedNotification))
    }

    func registerForCurrentCityNotifications() {
        assert(self is HLNearbyCitiesDetectionDelegate, "Cannot register for notifications. Doesn't conform HLNearbyCitiesDetectionDelegate protocol")
        subscribe(to: HL_NEARBY_CITIES_DETECTION_STARTED_NOTIFICATION, withSelector: #selector(self.nearbyCitiesDetectionStarted))
        subscribe(to: HL_NEARBY_CITIES_DETECTED_NOTIFICATION, withSelector: #selector(self.nearbyCitiesDetected))
        subscribe(to: HL_NEARBY_CITIES_DETECTION_FAILED_NOTIFICATION, withSelector: #selector(self.nearbyCitiesDetectionFailed))
        subscribe(to: HL_NEARBY_CITIES_DETECTION_CANCELLED_NOTIFICATION, withSelector: #selector(self.nearbyCitiesDetectionCancelled))
        subscribe(to: HL_LOCATION_SERVICES_ACCESS_FAILED_NOTIFICATION, withSelector: #selector(self.locationServicesAccessFailed))
        subscribe(to: HL_LOCATION_DETECTION_FAILED_NOTIFICATION, withSelector: #selector(self.locationDetectionFailed))
    }

    func registerForLocationManagerNotifications() {
        assert(self is HLLocationManagerDelegate, "Cannot register for notifications. Doesn't conform HLLocationManagerDelegate protocol")
        subscribe(to: HL_LOCATION_UPDATED_NOTIFICATION, withSelector: #selector(self.locationUpdatedNotification))
        subscribe(to: HL_LOCATION_DETECTION_FAILED_NOTIFICATION, withSelector: #selector(self.locationUpdateFailedNotification))
        subscribe(to: HL_LOCATION_SERVICES_ACCESS_FAILED_NOTIFICATION, withSelector: #selector(self.locationServicesAccessFailedNotification))
    }

    func registerCityInfoLoadingNotifications() {
        let message: String = "Cannot register \(description) for notifications. Doesn't conform HLCityInfoLoadingDelegate protocol"
        assert(self is HLCityInfoLoadingProtocol, message)
        subscribe(to: HL_CITY_INFO_LOADING_FINISHED_NOTIFICATION, withSelector: #selector(self.cityInfoDidLoad))
        subscribe(to: HL_CITY_INFO_LOADING_FAILED_NOTIFICATION, withSelector: #selector(self.cityInfoLoadingFailed))
        subscribe(to: HL_CITY_INFO_LOADING_CANCELLED_NOTIFICATION, withSelector: #selector(self.cityInfoLoadingCancelled))
    }

    func unregisterLocationNotifications() {
        NotificationCenter.default.removeObserver(self, name: HL_LOCATION_UPDATED_NOTIFICATION, object: nil)
        NotificationCenter.default.removeObserver(self, name: HL_LOCATION_DETECTION_FAILED_NOTIFICATION, object: nil)
        NotificationCenter.default.removeObserver(self, name: HL_LOCATION_SERVICES_ACCESS_FAILED_NOTIFICATION, object: nil)
    }

    func unregisterNotificationResponse() {
        NotificationCenter.default.removeObserver(self)
    }

    func subscribe(toNotification notification: String, with selector: Selector) {
        if responds(to: selector) {
            NotificationCenter.default.addObserver(self, selector: selector, name: notification as? NSNotification.Name ?? NSNotification.Name(), object: nil)
        }
    }
}