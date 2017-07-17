//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import CoreLocation
import Foundation

//#import "HLDevSettingsVC.h"
let kCurrentLocationDestinationKey: String = "currentLocationDestination"
let kForceCurrentLocationToSearchForm: String = "kForceCurrentLocationToSearchForm"
let kStartCurrentLocationSearch: String = "startCurrentCitySearch"
let kShowCurrentLocationOnMap: String = "showCurrentLocationOnMap"
let kLocationManagerDistanceFilter: CLLocationDistance = 10.0
private var kAuthorizationStatusKey: String = "authorizationStatus"

class HLLocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?

    static var sharedManager: HLLocationManager?

    class func sharedManager() -> HLLocationManager {
        if sharedManager == nil {
            var onceToken: Int
            if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
                self.sharedManager = HLLocationManager()
            }
        onceToken = 1
        }
        return sharedManager!
    }

    func location() -> CLLocation {
        return locationManager?._location!
    }

    func requestUserLocation(withLocationDestination destination: String?) {
        let currentStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        switch currentStatus {
            case kCLAuthorizationStatusNotDetermined:
                locationManager?.requestWhenInUseAuthorization()
                let cityDetector = HLNearbyCitiesDetector.shared
                if !cityDetector.currentLocationDestination {
                    cityDetector.currentLocationDestination = destination
                }
            case kCLAuthorizationStatusDenied:
                HLAlertsFabric.showLocationAlert()
            default:
                startUpdatingLocation()
        }

    }

    func locationAuthorizationRequested() -> Bool {
        let currentStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        return (currentStatus != kCLAuthorizationStatusNotDetermined)
    }

    func startUpdatingLocationIfAllowed() {
        let currentStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if currentStatus == kCLAuthorizationStatusAuthorizedAlways || currentStatus == kCLAuthorizationStatusAuthorizedWhenInUse {
            startUpdatingLocation()
        }
    }

    func stopUpdatingLocation() {
        locationManager?.stopUpdatingLocation()
    }

    func hasUserDeniedLocationAccess(onCompletion completion: @escaping (_ accessDenied: Bool) -> Void) {
        getAuthorizationStatus(onCompletion: {(_ status: CLAuthorizationStatus) -> Void in
            completion(status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
        })
    }

    func hasUserGrantedLocationAccess(onCompletion completion: @escaping (_ accessGranted: Bool) -> Void) {
        getAuthorizationStatus(onCompletion: {(_ status: CLAuthorizationStatus) -> Void in
            completion(status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse)
        })
    }

    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.distanceFilter = kLocationManagerDistanceFilter
        locationManager?.delegate = self
    
    }

    func getAuthorizationStatus(onCompletion completion: @escaping (_ status: CLAuthorizationStatus) -> Void) {
        var localCompletion: ((_ status: CLAuthorizationStatus) -> Void)? = completion
        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
            DispatchQueue.main.async(execute: {() -> Void in
                if localCompletion != nil {
                    localCompletion(status)
                    localCompletion = nil
                }
            })
        })
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((int64_t)(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            if localCompletion != nil {
                localCompletion(kCLAuthorizationStatusNotDetermined)
                localCompletion = nil
            }
        })
    }

// MARK: - Private
    func startUpdatingLocation() {
        locationManager?.startUpdatingLocation()
        if !HLNearbyCitiesDetector.shared.nearbyCities {
            let searchInfo = HLSearchInfo.default()
            HLNearbyCitiesDetector.shared.detectCurrentCity(with: searchInfo)
        }
    }

    func accessGranted(with status: CLAuthorizationStatus) -> Bool {
        if status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse {
            return true
        }
        else {
            return false
        }
    }
}

class HLDebugLocationManager: HLLocationManager {
// MARK: - Override methods

    override func location() -> CLLocation {
        return super.location()
    }

    override func getAuthorizationStatus(onCompletion completion: @escaping (_ status: CLAuthorizationStatus) -> Void) {
        super.getAuthorizationStatus(onCompletion: completion)
    }

    override func locationAuthorizationRequested() -> Bool {
        return super.locationAuthorizationRequested()
    }

    func requestUserLocation() {
        super.requestUserLocation(withLocationDestination: nil)
    }

    override func startUpdatingLocation() {
        super.startUpdatingLocation()
    }
}

extension HLLocationManager {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [Any]) {
        let location: CLLocation? = locations.last
        let notification = Notification(name: HL_LOCATION_UPDATED_NOTIFICATION, object: location)
        NotificationCenter.default.post(notification)
        locationManager?.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error?) {
        if error?.code != kCLErrorLocationUnknown {
            sendMainThreadNotification(withName: HL_LOCATION_DETECTION_FAILED_NOTIFICATION)
            locationManager?.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case kCLAuthorizationStatusDenied:
                sendMainThreadNotification(withName: HL_LOCATION_SERVICES_ACCESS_FAILED_NOTIFICATION)
            case kCLAuthorizationStatusAuthorizedWhenInUse, kCLAuthorizationStatusAuthorizedAlways:
                startUpdatingLocation()
            default:
                break
        }

    }

    func sendMainThreadNotification(withName name: String) {
        DispatchQueue.main.async(execute: {() -> Void in
            NotificationCenter.default.post(name: name, object: nil, userInfo: nil)
        })
    }
}