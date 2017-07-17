//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation
import HotellookSDK

class HLNearbyCitiesDetector: NSObject, HLLocationManagerDelegate {
    private(set) var nearbyCities: [HDKCity]?
    private(set) var isBusy: Bool = false
    var currentLocationDestination: String?

    var searchInfo: HLSearchInfo?
    var citiesDetector: HLCitiesByPointDetector?

    class func shared() -> HLNearbyCitiesDetector {
        var onceToken: Int
        var sharedInstance: HLNearbyCitiesDetector?
        if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
            sharedInstance = HLNearbyCitiesDetector()
        }
        onceToken = 1
        return sharedInstance!
    }

    func detectCurrentCity(with searchInfo: HLSearchInfo) {
        if isBusy {
            return
        }
        isBusy = true
        NotificationCenter.default.post(name: HL_NEARBY_CITIES_DETECTION_STARTED_NOTIFICATION, object: nil, userInfo: nil)
        HLLocationManager.sharedManager().hasUserDeniedLocationAccess(onCompletion: {(_ accessDenied: Bool) -> Void in
            if !accessDenied {
                self.searchInfo = searchInfo
                if HLLocationManager.sharedManager().location {
                    self.detectCurrentCity()
                }
                else {
                    self.registerForLocationManagerNotifications()
                }
            }
            else {
                NotificationCenter.default.post(name: HL_NEARBY_CITIES_DETECTION_FAILED_NOTIFICATION, object: nil, userInfo: nil)
                isBusy = false
            }
        })
    }

    func dropCurrentLocationSearchDestination() {
        if currentLocationDestination == kStartCurrentLocationSearch {
            currentLocationDestination = nil
        }
    }

// MARK: - Public
    override init() {
        super.init()
        
        isBusy = false
        currentLocationDestination = nil
        citiesDetector = HLCitiesByPointDetector()
    
    }

// MARK: - Private
    func detectCurrentCity() {
        searchInfo.locationPoint = HLSearchUserLocationPoint.forCurrentLocation()
        weakify(self)
        citiesDetector?.detectNearbyCities(for: searchInfo, onCompletion: {(_ cities: [HDKCity]) -> Void in
            strongify(self)
            self.citiesDetected(cities)
        }, onError: {(_ error: Error?) -> Void in
            strongify(self)
            self.citiesDetectionFailed(error)
        })
    }

    func citiesDetected(_ cities: [HDKCity]) {
        nearbyCities = cities
        DispatchQueue.main.async(execute: {() -> Void in
            var userInfo: [AnyHashable: Any]? = nil
            if self.currentLocationDestination {
                userInfo = [kCurrentLocationDestinationKey: self.currentLocationDestination]
            }
            NotificationCenter.default.post(name: HL_NEARBY_CITIES_DETECTED_NOTIFICATION, object: self.nearbyCities, userInfo: userInfo)
        })
        isBusy = false
    }

    func citiesDetectionFailed(_ error: Error?) {
        DispatchQueue.main.async(execute: {() -> Void in
            if error?.code == NSURLErrorCancelled {
                NotificationCenter.default.post(name: HL_NEARBY_CITIES_DETECTION_CANCELLED_NOTIFICATION, object: nil, userInfo: nil)
            }
            else {
                let error = Error(code: HLManagedCityDetectionFailed)
                NotificationCenter.default.post(name: HL_NEARBY_CITIES_DETECTION_FAILED_NOTIFICATION, object: error, userInfo: nil)
            }
        })
        isBusy = false
    }

// MARK: - HLLocationManager Notifications Response Methods
    func locationUpdatedNotification(_ notification: Notification) {
        if nearbyCities?.first == nil {
            unregisterLocationNotifications()
            detectCurrentCity()
        }
    }

    func locationUpdateFailedNotification(_ notification: Notification) {
        unregisterLocationNotifications()
        isBusy = false
    }

    func locationServicesAccessFailedNotification(_ notification: Notification) {
        unregisterLocationNotifications()
        isBusy = false
    }

    func dropCurrentLocation() {
        nearbyCities = nil
    }
}