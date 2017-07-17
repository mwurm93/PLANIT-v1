//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation
import HotellookSDK
import PromiseKit

var HLSeasonsMapByCityId = [HDKSeason]()
var HLPointsMapByCityId = [HDKLocationPoint]()

protocol HLHotelsManagerDelegate: NSObjectProtocol {
    func hotelsManagerDidLoadHotelsContent(_ hotels: [Any], cities: [HDKCity])

    func hotelsManagerDidLoadHotelDetails(_ hotel: HDKHotel)

    func hotelsManagerFailedWithError(_ error: Error?)

    func hotelsManagerCancelled()
}

class HLHotelsManager: NSObject, HLCityInfoLoadingProtocol {
    weak var delegate: HLHotelsManagerDelegate?
    private(set) var isLoading: Bool = false

    weak var loadHotelDetailsTask: Cancellable?
    weak var loadHotelsTask: Cancellable?

    func stopLoading() {
        loadHotelsTask?.cancel()
        loadHotelsTask = nil
        loadHotelDetailsTask?.cancel()
        loadHotelDetailsTask = nil
    }

    func loadHotelsContent(forCities cities: [HDKCity]) {
        var loadedHotels: [HDKHotel] = [Any]()
        var loadedCities: [HDKCity] = [Any]()
        weakify(self)
        hl_dispatch_main_sync_safe({() -> Void in
            strongify(self)
            weakify(self)
            let completionBlock: ((_: HDKLocationListResponse, _: Error) -> Void)?? = {(_ hotelsDump: HDKLocationListResponse, _ error: Error?) -> Void in
                    strongify(self)
                    self.loadHotelsTask = nil
                    if error != nil {
                        try? self.notifyDelegate()
                        return
                    }
                    for dump: HDKLocationInfoResponse in hotelsDump.cities.allValues {
                        loadedCities.append(dump.city)
                        for hotel: HDKHotel in dump.hotels {
                            hotel.city = dump.city
                            loadedHotels.append(hotel)
                        }
                    }
                    self.notifyDelegate(withHotels: loadedHotels, cities: loadedCities)
                }
            let priceless: Bool? = (cities.count == 1) && (cities.first?.hotelsCount < 100)
            let citiesIds: [String] = cities.map({(_ city: HDKCity) -> String in
                    return city.cityId
                })
            self.loadHotelsTask = ServiceLocator.shared.sdkFacade.loadHotels(withCitiesIds: citiesIds, priceless: priceless, apartments: false, completion: completionBlock)
        })
    }

    func loadHotelDetails(for hotel: HDKHotel) {
        if hotel.hotelId == nil {
            hotelDetailsLoadingFailed(Error(code: HLHotelDetailsLoadingEmptyHotelIdError))
            return
        }
        loadHotelDetailsTask?.cancel()
        loadHotelDetailsTask = nil
        hl_dispatch_main_sync_safe({() -> Void in
            self.loadHotelDetailsTask = ServiceLocator.shared.sdkFacade.loadHotelDetails(withHotelId: hotel.hotelId, completion: {(_ newHotel: HDKHotel, _ error: Error?) -> Void in
                self.loadHotelDetailsTask = nil
                if error != nil {
                    if error?.isCancelled {
                        self.hotelDetailsLoadingCancelled()
                    }
                    else {
                        self.hotelDetailsLoadingFailed(error)
                    }
                    return
                }
                hotel.update(byHotelDetailsHotel: newHotel)
                self.hotelDetailsDidLoad(hotel)
            })
        })
    }

    func isLoading() -> Bool {
        return (loadHotelsTask != nil || loadHotelDetailsTask != nil)
    }

// MARK: - HotelContent methods

    func updateCity(for hotel: HDKHotel, with city: HDKCity) {
        if (hotel.city.cityId == city.cityId) {
            hotel.city = city
        }
        else {
            print("bad city id for hotel")
        }
    }

// MARK: - HLHotelDetailsLoaderDelegate Methods
    func hotelDetailsDidLoad(_ hotel: HDKHotel) {
        hl_dispatch_main_sync_safe({() -> Void in
            if self.delegate?.responds(to: #selector(self.hotelsManagerDidLoadHotelDetails)) {
                self.delegate?.hotelsManagerDidLoadHotelDetails(hotel)
            }
        })
    }

    func hotelDetailsLoadingFailed(_ error: Error?) {
        if delegate?.responds(to: #selector(self.hotelsManagerFailedWithError)) {
            try? delegate?.hotelsManagerFailed()
        }
    }

    func hotelDetailsLoadingCancelled() {
        if delegate?.responds(to: #selector(self.hotelsManagerCancelled)) {
            delegate?.hotelsManagerCancelled()
        }
    }

// MARK: - HotelDetails methods
}

extension HLHotelsManager {
    func notifyDelegateWithError(_ error: Error?) {
        if error?.code == NSURLErrorCancelled {
            if delegate?.responds(to: #selector(self.hotelsManagerCancelled)) {
                delegate?.hotelsManagerCancelled()
            }
        }
        else {
            if delegate?.responds(to: #selector(self.hotelsManagerFailedWithError)) {
                try? delegate?.hotelsManagerFailed()
            }
        }
    }

    func notifyDelegate(withHotels hotels: [HDKHotel], cities: [HDKCity]) {
        hl_dispatch_main_sync_safe({() -> Void in
            if delegate?.responds(to: Selector("hotelsManagerDidLoadHotelsContent:cities:")) {
                delegate?.hotelsManagerDidLoadHotelsContent(hotels, cities: cities)
            }
        })
    }
}