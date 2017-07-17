//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation
import HotellookSDK
import PromiseKit

let HL_VARIANTS_MANAGER_DID_LOAD_HOTELS: String = "hl_variantsManagerDidLoadHotels"
let HL_VARIANTS_MANAGER_DID_LOAD_PRICES: String = "hl_variantsManagerDidLoadPrices"

protocol HLVariantsManagerDelegate: NSObjectProtocol {
    func variantsManagerFinished(_ searchResult: SearchResult)

    func variantsManagerFailedWithError(_ error: Error?)

    func variantsManagerCancelled()
    func variantsManagerSearchRoomsStarted(withGates gates: [HDKGate])

    func variantsManagerSearchRoomsDidReceiveData(fromGatesIds gateIds: [String])
}

class HLVariantsManager: NSObject, HDKSearchLoaderDelegate, HLHotelsManagerDelegate {
    var searchInfo: HLSearchInfo?
    weak var delegate: HLVariantsManagerDelegate?
    private(set) var isSearchInProgress: Bool = false
    private(set) var hotels = [Any]()

    var roomsLoader: HDKRoomsLoader?
    var citiesByPointDetector: HLCitiesByPointDetector?
    var hotelsManager: HLHotelsManager?
    var searchResult: SearchResult?
    var searchId: String = ""
    var rooms = [AnyHashable: Any]()
    var hotels = [Any]()
    var startDate: Date?
    var nearbyCities = [Any]()
    var isSearchInProgress: Bool = false
    var backgroundTask = UIBackgroundTaskIdentifier()

    func startCitySearch() {
        if searchInfo != nil {
            hotels = nil
            nearbyCities = nil
            prepareForStartSearch()
            startHotelsLoader()
            startSearchRoomLoader()
            startNearbyCitiesSearch(for: searchInfo)
        }
        else {
            try? collectingVariantsFailed()
        }
    }

    func startHotelSearch(_ hotel: HDKHotel) {
        if searchInfo != nil {
            hotels = [hotel]
            nearbyCities = []
            prepareForStartSearch()
            startHotelRoomLoader(hotel)
        }
        else {
            try? collectingVariantsFailed()
        }
    }

    func stopSearch() {
        searchEnded()
        if delegate && delegate?.responds(to: #selector(self.variantsManagerCancelled)) {
            delegate?.variantsManagerCancelled()
        }
        roomsLoader?.cancel()
        stopBackgroundTask()
    }

    deinit {
        roomsLoader?.cancel()
    }

// MARK: - Public

// MARK: - Private
    func searchEnded() {
        hotelsManager?.stopLoading()
        hotelsManager = nil
        isSearchInProgress = false
    }

    func startNearbyCitiesSearch(for searchInfo: HLSearchInfo) {
        nearbyCities = nil
        citiesByPointDetector = HLCitiesByPointDetector()
        weakify(self)
        citiesByPointDetector?.detectNearbyCities(for: searchInfo, onCompletion: {(_ cities: [HDKCity]) -> Void in
            strongify(self)
            self.nearbyCities = cities
            self.tryCollectingVariants()
        }, onError: {(_ error: Error?) -> Void in
            strongify(self)
            self.nearbyCities = []
            self.tryCollectingVariants()
        })
    }

    func prepareForStartSearch() {
        weak var weakSelf: HLVariantsManager? = self
        backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {0:(()
        searchResult = SearchResult(searchInfo: searchInfo)
        rooms = nil
        isSearchInProgress = true
        startDate = Date()
    }

    func collectingVariantsFailedWithError(_ error: Error?) {
        searchEnded()
        if delegate && delegate?.responds(to: #selector(self.variantsManagerFailedWithError)) {
            try? delegate?.variantsManagerFailed()
        }
        stopBackgroundTask()
    }

    func collectingVariantsCancelled() {
        if delegate?.responds(to: #selector(self.variantsManagerCancelled)) {
            delegate?.variantsManagerCancelled()
        }
        stopBackgroundTask()
    }

    func langParam() -> String {
        return HLLocaleInspector.sharedInspector.localeString()
    }

    func marker() -> String {
        return kJRPartnerMarker
    }

    func startHotelRoomLoader(_ hotel: HDKHotel) {
        roomsLoader = ServiceLocator.shared.sdkFacade.roomsLoader()
        roomsLoader?.delegate = self
        roomsLoader?.startSearchForHotel(with: searchInfo, marker: marker(), marketing: nil, hotelId: hotel.hotelId)
    }

    func startSearchRoomLoader() {
        roomsLoader = ServiceLocator.shared.sdkFacade.roomsLoader()
        roomsLoader?.delegate = self
        roomsLoader?.startSearchForCity(with: searchInfo, marker: marker(), marketing: nil)
    }

    func startHotelsLoader() {
        hotelsManager = HLHotelsManager()
        hotelsManager?.delegate = self
        var cities: [Any]
        if searchInfo.city {
            cities = [searchInfo.city]
        }
        else if searchInfo.locationPoint.nearbyCities {
            cities = searchInfo.locationPoint.nearbyCities
        }

        hotelsManager?.loadHotelsContent(forCities: cities)
    }

    func tryCollectingVariants() {
        if !rooms || !hotels || nearbyCities == nil {
            return
        }
        saveResultsTTL()
        weakify(self)
        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            strongify(self)
            let variantsDict: [AnyHashable: Any]? = self.createEmptyVariants(byHotels: self.hotels, gatesSortOrder: roomsLoader?.gatesSortOrder)
            self.updateRooms(self.rooms, withRoomTypes: roomsLoader?.roomTypes)
            self.fillVariants(variantsDict, withRooms: self.rooms)
            var variantsArray: [Any]? = variantsDict?.allValues()
            let badgeParser = HLBadgeParser()
            badgeParser.fillBadges(for: variantsArray, badgesDictionary: roomsLoader?.badges, hotelsBadges: roomsLoader?.hotelsBadges, hotelsRank: roomsLoader?.hotelsRank)
            variantsArray = VariantsSorter.sortVariants(byPopularity: variantsArray, searchInfo: self.searchInfo)
            self.searchResult = SearchResult(searchInfo: self.searchInfo, variants: variantsArray, nearbyCities: self.nearbyCities)
            searchResult?.self.searchId = self.searchId
            self.searchEnded()
            weakify(self)
            DispatchQueue.main.async(execute: {() -> Void in
                strongify(self)
                self.notifyDelegateSearchFinished()
            })
        })
    }

    func saveResultsTTL() {
        ServiceLocator.shared.searchConfigStore.saveResultsTTL(roomsLoader?.resultsTTLByGate, ttlDefault: roomsLoader?.resultsTTL)
    }

    func updateRooms(_ rooms: [AnyHashable: Any], withRoomTypes roomTypes: [String: HDKRoomType]) {
        for hotelId: String in rooms {
            let hotelRooms: [Any] = rooms[hotelId]
            for room: HDKRoom in hotelRooms {
                let internalTypeString: String = room.internalTypeId
                var roomTypeName: String? = roomTypes[internalTypeString].name
                if roomTypeName == nil {
                    roomTypeName = NSLS("HL_LOC_DEFAULT_ROOM_TYPE")
                }
                room.localizedType = roomTypeName
            }
        }
    }

    func fillVariants(_ variants: [AnyHashable: Any], withRooms rooms: [AnyHashable: Any]) {
        for hotelId: String in rooms {
            let hotelRooms: [Any] = rooms[hotelId]
            if hotelRooms && hotelRooms.count {
                let variant: HLResultVariant? = variants[hotelId]
                if variant != nil {
                    variant?.addRooms(hotelRooms)
                }
            }
        }
    }

    func createEmptyVariants(byHotels hotels: [Any], gatesSortOrder: [String]) -> [AnyHashable: Any] {
        var emptyVariants = [AnyHashable: Any]()
        let copySearchInfo: HLSearchInfo? = searchInfo
        for hotel: HDKHotel in hotels {
            autoreleasepool {
                let variant = HLResultVariant.createEmpty(copySearchInfo, hotel: hotel)
                variant.searchId = searchId
                variant.gatesSortOrder = gatesSortOrder
                emptyVariants[variant.hotel.hotelId] = variant
            }
        }
        return emptyVariants
    }

    func notifyDelegateSearchFinished() {
        stopBackgroundTask()
        if delegate?.responds(to: #selector(self.variantsManagerFinished)) {
            delegate?.variantsManagerFinished(searchResult)
        }
        InteractionManager.shared.hotelsSearchFinished(searchInfo)
    }

    func currentSearchDuration() -> TimeInterval {
        return Date().timeIntervalSince(startDate)
    }

    func stopBackgroundTask() {
        if backgroundTask != UIBackgroundTaskInvalid {
            UIApplication.shared.endBackgroundTask(UInt(backgroundTask))
            backgroundTask = UIBackgroundTaskInvalid
        }
    }

// MARK: - HLHotelsManagerDelegate
    func hotelsManagerDidLoadHotelsContent(_ hotels: [Any], cities: [HDKCity]) {
        var citiesIdsAreCorrect: Bool = false
        switch searchInfo.searchInfoType {
            case HLSearchInfoTypeCity:
                let loadedCity: HDKCity? = cities.first
                citiesIdsAreCorrect = (searchInfo.city.cityId == loadedCity?.cityId)
                if citiesIdsAreCorrect {
                    searchInfo.city = loadedCity
                    self.hotels = hotels
                    tryCollectingVariants()
                }
            case HLSearchInfoTypeUserLocation, HLSearchInfoTypeCustomLocation, HLSearchInfoTypeCityCenterLocation, HLSearchInfoTypeAirport:
                citiesIdsAreCorrect = HDKCity.citiesIds(fromCities: cities).hl_isContentEqual(toArray: HDKCity.citiesIds(from: searchInfo.locationPoint.nearbyCities))
                if citiesIdsAreCorrect {
                    searchInfo.locationPoint.nearbyCities = cities
                    self.hotels = hotels
                    tryCollectingVariants()
                }
            default:
                break
        }

        NotificationCenter.default.post(name: HL_VARIANTS_MANAGER_DID_LOAD_HOTELS, object: nil)
    }

    func hotelsManagerFailedWithError(_ error: Error?) {
        try? collectingVariantsFailed()
    }

    func hotelsManagerCancelled() {
        stopSearch()
    }

// MARK: - HLSearchLoaderDelegate
    func searchStarted(withGates gates: [HDKGate], searchId: String) {
        self.searchId = searchId
        if delegate?.responds(to: #selector(self.variantsManagerSearchRoomsStartedWithGates)) {
            delegate?.variantsManagerSearchRoomsStarted(withGates: gates)
        }
    }

    func searchLoaderDidReceiveData(fromGateIds gateIds: [Any]) {
        if delegate?.responds(to: #selector(self.variantsManagerSearchRoomsDidReceiveDataFromGatesIds)) {
            delegate?.variantsManagerSearchRoomsDidReceiveData(fromGatesIds: gateIds)
        }
    }

    func searchLoaderFinished(withRooms rooms: [AnyHashable: Any], searchId: String) {
        self.rooms = rooms
        self.searchId = searchId
        tryCollectingVariants()
    }

    func searchLoaderFailedWithError(_ error: Error?) {
        try? collectingVariantsFailed()
    }

    func searchLoaderCancelled() {
        collectingVariantsCancelled()
    }
}