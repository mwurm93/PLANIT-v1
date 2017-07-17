//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation
import HotellookSDK

let UNKNOWN_MIN_PRICE = MAXFLOAT
enum HLVariantState : Int {
    case hlVariantLoadingState = 0
    case hlVariantRefreshState
    case hlVariantNoContentState
    case hlVariantNormalState
    case hlVariantOutdatedState
}

enum HLRoomsAvailability : Int {
    case hasRooms = 0
    case noRooms
    case sold
}


class HLResultVariant: NSObject, NSCoding, NSCopying {
    private var _rooms = [HDKRoom]()
    var rooms: [HDKRoom]? {
        get {
            return _rooms
        }
        set(rooms) {
            _rooms = rooms
            dropRoomsFiltering()
        }
    }
    var badges: [Any] {
        return popularBadges
    }
    var popularBadges: [HLPopularHotelBadge]?
    var lastUpdate: Date?
    var hotel: HDKHotel?
    private var _searchInfo: HLSearchInfo?
    var searchInfo: HLSearchInfo? {
        get {
            return _searchInfo
        }
        set(searchInfo) {
            _searchInfo = searchInfo
            duration = DateUtil.hl_daysBetweenDate(searchInfo.checkInDate, andOtherDate: searchInfo.checkOutDate)
        }
    }
    var searchId: String = ""
    var gatesSortOrder = [String]()
    var gatesCount: Int {
        let gatesIds: [Any] = filteredRooms.map({(_ room: HDKRoom) -> Void in
                    return room.gate.gateId
                })
            return Set<AnyHashable>(gatesIds).count
    }
    var roomsByType: [[HDKRoom]] {
        let plainRooms: [Any] = RoomsSorter.sortRooms(byPrice: filteredRooms, gatesSortOrder: gatesSortOrder)
            let groups: [AnyHashable: Any] = collectedRooms(byType: plainRooms)
            return RoomsSorter.sortRoomsGroups(byPrice: groups.allValues)
    }
    var sortedRooms: [HDKRoom] {
        return RoomsSorter.sortRooms(byPrice: filteredRooms, gatesSortOrder: gatesSortOrder)
    }
    private(set) var filteredRooms = [HDKRoom]()
    private var _roomWithMinPrice: HDKRoom?
    var roomWithMinPrice: HDKRoom? {
        calculateRoomWithMinPriceIfNeeded()
            return _roomWithMinPrice
    }
    var distanceToCurrentLocationPoint: CGFloat = 0.0
    var minPrice: Float {
        return roomWithMinPrice?.price!
    }
    private(set) var duration: Int = 0
    private var _discount: Int = 0
    var discount: Int {
        return roomWithMinPrice?._discount!
    }
    var oldMinPrice: Float {
        return roomWithMinPrice?.oldPrice!
    }
    private var _highlightType = HDKHighlightType()
    var highlightType: HDKHighlightType {
        return roomWithMinPrice?._highlightType!
    }
    var isHasDiscount: Bool {
        return roomWithMinPrice?.hasDiscountHighlight!
    }
    var isHasPrivatePrice: Bool {
        return roomWithMinPrice?.hasPrivatePriceHighlight!
    }

    private var _filteredRooms = [HDKRoom]()
    var filteredRooms: [HDKRoom] {
        get {
            return _filteredRooms
        }
        set(filteredRooms) {
            _filteredRooms = filteredRooms
            roomWithMinPrice = nil
        }
    }

    class func createEmpty(_ searchInfo: HLSearchInfo, hotel: HDKHotel) -> HLResultVariant {
        let variant: HLResultVariant? = self.init()
        variant?.lastUpdate = Date()
        variant?.searchInfo = searchInfo
        variant?.hotel = hotel
        return variant!
    }

    func outdate() {
        lastUpdate = nil
        popularBadges = [Any]()
        rooms = [Any]()
        filteredRooms = [Any]()
        distanceToCurrentLocationPoint = 0.0
        roomWithMinPrice = nil
        duration = 1
    }

    func atLeastOnePriceOutdated() -> Bool {
        if lastUpdate == nil {
            return true
        }
        let intervalSinceLastUpdate: TimeInterval = Date().timeIntervalSince(lastUpdate)
        let resultsTTL: Int = ServiceLocator.shared.resultsTTLManager.minResultsTTL()
        return intervalSinceLastUpdate >= resultsTTL
    }

    func isGateOutdated(_ gate: HDKGate) -> Bool {
        if lastUpdate == nil {
            return true
        }
        let interval: TimeInterval = Date().timeIntervalSince(lastUpdate)
        let gateTTL: Int = ServiceLocator.shared.resultsTTLManager.resultsTTL(forGate: gate.gateId)
        return interval >= gateTTL
    }

    func addRooms(_ newRooms: [Any]) {
        if rooms.isEmpty {
            rooms = [Any]()
        }
        rooms += newRooms
        dropRoomsFiltering()
    }

    func dropRoomsFiltering() {
        filteredRooms = rooms
    }

    func filterRooms(withOptions options: [String]) {
        let optionsAndValues: [[AnyHashable: Any]] = HLParseUtils.optionsWithValues(fromOptionsStrings: options)
        for optionAndValue: [AnyHashable: Any] in optionsAndValues {
            let optionKey: String? = optionAndValue.keys.first
            let expectedOptionValue: Bool = optionAndValue[optionKey]
            filteredRooms = filteredRooms(filteredRooms, withOption: optionKey, expectedValue: expectedOptionValue)
        }
    }

    func filterRooms(withMinPrice minPrice: Float, maxPrice: Float) {
        let indexesToBeRemoved: IndexSet? = (filteredRooms as NSArray).indexesOfObjects(passingTest: {(_ room: HDKRoom, _ idx: Int, _ stop: Bool) -> Bool in
                let price: Float = room.price
                return (price < minPrice || price > maxPrice)
            })
        var mutableFilteredRooms: [Any] = filteredRooms
        mutableFilteredRooms.removeObjects(atIndexes: indexesToBeRemoved)
        filteredRooms = mutableFilteredRooms
    }

    func filterRooms(byGates gateNames: [String], hotelWebsiteString: String) {
        filteredRooms = FilterLogic.filterVariantRooms(byGates: filteredRooms, gates: gateNames, hotelWebsiteString: hotelWebsiteString)
    }

    func filterRooms(byAmenity amenity: String) {
        if hotel.amenitiesShort[amenity].slug.isEqual(RoomOptionConsts.kHotelAirConditioningOptionKey) {
            filterRoomsWithAirConditioning()
        }
    }

    func filterRoomsBySharedBathroom() {
        filteredRooms = FilterLogic.filterRooms(bySharedBathroom: self)
    }

    func shouldIncludeToFilteredResults(byAmenity amenity: String) -> Bool {
        if hotel.amenitiesShort[amenity].slug.isEqual(RoomOptionConsts.kHotelAirConditioningOptionKey) {
            return filteredRooms.count > 0
        }
        for amenityPiece: String in amenity.components(separatedBy: "|") {
            if hotel.amenitiesShort.keys.contains(amenityPiece) {
                return true
            }
        }
        return false
    }

    func calculateRoomWithMinPriceIfNeeded() {
        if roomWithMinPrice == nil && filteredRooms.count > 0 {
            calculateRoomWithMinPrice()
        }
    }

    func hasRooms(withOption option: String) -> Bool {
        let optionAndValue: [AnyHashable: Any] = HLParseUtils.optionWithValue(fromOptionString: option)
        let expectedOption: String? = optionAndValue.keys.first
        let expectedValue: Bool = optionAndValue[expectedOption]
        let filteredByOption: [Any] = filteredRooms(rooms, withOption: expectedOption, expectedValue: expectedValue)
        return filteredByOption.count > 0
    }

    func roomsAvailability() -> HLRoomsAvailability {
        if rooms.count > 0 {
            return .hasRooms
        }
        for guests: HDKKnownGuestsRoom in hotel.knownGuests.rooms {
            let adultsMatch: Bool = guests.adults == searchInfo.adultsCount
            let childrensMatch: Bool = guests.children == searchInfo.kidsCount
            if adultsMatch && childrensMatch {
                return .sold
            }
        }
        return .noRooms
    }

    func roomsCopy() -> [Any] {
        return rooms
    }

    class func highlightType(by highlightString: String) -> HDKHighlightType {
        var highlightMapDictionary: [AnyHashable: Any]? = nil
        var onceToken: Int
        if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
            highlightMapDictionary = ["mobile": (HDKHighlightTypeMobile), "private": (HDKHighlightTypePrivate), "discount": (HDKHighlightTypeDiscount)]
        }
        onceToken = 1
        return highlightString ? CInt(highlightMapDictionary[highlightString]) : HDKHighlightTypeNone
    }

    override init() {
        super.init()
        
        outdate()
    
    }

    func isEqual(_ object: Any) -> Bool {
        let otherVariant: HLResultVariant? = (object as? HLResultVariant)
        if otherVariant == nil {
            return false
        }
        if !(otherVariant? is HLResultVariant) {
            return false
        }
        if !hotel.isEqual(otherVariant?.hotel) {
            return false
        }
        if !searchInfo.isEqual(otherVariant?.searchInfo) {
            return false
        }
        return true
    }

    func hash() -> Int {
        return hotel._hash ^ searchInfo._hash
    }

    func collectedRooms(byType plainRoomsArray: [Any]) -> [AnyHashable: Any] {
        var roomsByTypeDict = [AnyHashable: Any]()
        for room: HDKRoom in plainRoomsArray {
            let roomType: String = room.localizedType
            var roomsOfSameType: [Any] = roomsByTypeDict[roomType]
            if roomsOfSameType.isEmpty {
                roomsOfSameType = [Any]()
                roomsByTypeDict[roomType] = roomsOfSameType
            }
            roomsOfSameType.append(room)
        }
        return roomsByTypeDict
    }

// MARK: - Getters and Setters

// MARK: - Public

    func filteredRooms(_ rooms: [Any], withOption option: String, expectedValue: Bool) -> [Any] {
        if (option == RoomOptionConsts.kRoomWifiOptionKey) {
            return FilterLogic.filterRooms(byWifi: self)
        }
        if (option == RoomOptionConsts.kRoomDormitoryOptionKey) {
            return FilterLogic.filterRooms(byDormitory: self)
        }
        if (option == RoomOptionConsts.kBreakfastOptionKey) {
            return FilterLogic.filterRooms(byBreakfast: self)
        }
        var result: [Any] = rooms
        let indexesToBeRemoved: IndexSet? = (result as NSArray).indexesOfObjects(passingTest: {(_ room: HDKRoom, _ idx: Int, _ stop: Bool) -> Bool in
                return !room.hasOption(option, withValue: expectedValue)
            })
        result.removeObjects(atIndexes: indexesToBeRemoved)
        return result
    }

    func filterRoomsWithAirConditioning() {
        filteredRooms = FilterLogic.filterRooms(byAirConditioning: self)
    }

    func calculateRoomWithMinPrice() {
        let lockQueue = DispatchQueue(label: "filteredRooms")
        lockQueue.sync {
            for i in 0..<filteredRooms.count {
                let room: HDKRoom? = filteredRooms[i]
                let currentRoomOrder: Int? = (gatesSortOrder as NSArray).index(of: room?.gate?.gateId)
                let minPriceRoomOrder: Int? = (gatesSortOrder as NSArray).index(of: roomWithMinPrice?.gate?.gateId)
                let firstRoom: Bool = i == 0
                let lowerPrice: Bool? = room?.price < roomWithMinPrice?.price
                let samePrice: Bool? = room?.price == roomWithMinPrice?.price
                let highGateOrder: Bool = currentRoomOrder < minPriceRoomOrder
                if firstRoom || lowerPrice || (samePrice && highGateOrder) {
                    roomWithMinPrice = room
                }
            }
        }
    }

// MARK: - NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(lastUpdate, forKey: "lastUpdate")
        aCoder.encode(searchInfo, forKey: "searchInfo")
        aCoder.encode(rooms, forKey: "rooms")
        aCoder.encode(hotel, forKey: "hotel")
        aCoder.encode(searchId, forKey: "searchId")
        aCoder.encode(gatesSortOrder, forKey: "gatesSortOrder")
    }

    init(coder aDecoder: NSCoder) {
        super.init()
        
        lastUpdate = aDecoder.decodeObject(forKey: "lastUpdate") as? Date ?? Date()
        searchInfo = aDecoder.decodeObject(forKey: "searchInfo") as? HLSearchInfo ?? HLSearchInfo()
        rooms = aDecoder.decodeObject(forKey: "rooms") as? [Any] ?? [Any]()
        hotel = aDecoder.decodeObject(forKey: "hotel") as? HDKHotel ?? HDKHotel()
        searchId = aDecoder.decodeObject(forKey: "searchId") as? String ?? ""
        gatesSortOrder = aDecoder.decodeObject(forKey: "gatesSortOrder") as? [String] ?? [String]()
    
    }

// MARK: - NSCopying
    func copy(with zone: NSZone) -> Any {
        let variantCopy = HLResultVariant()
        variantCopy.rooms = rooms
        variantCopy.popularBadges = popularBadges
        variantCopy.lastUpdate = lastUpdate
        variantCopy.hotel = hotel
        variantCopy.searchInfo = searchInfo
        variantCopy.searchId = searchId
        variantCopy.gatesSortOrder = gatesSortOrder
        variantCopy.dropRoomsFiltering()
        return variantCopy
    }
}

extension HLResultVariant {
    class func selectFav(_ favVariants: [Any], fromAll allVariants: [Any]) -> [Any] {
        var favIds = [Any]()
        for variant: HLResultVariant in favVariants {
            if variant?.hotel?.hotelId {
                favIds.append(variant?.hotel?.hotelId)
            }
        }
        var selected = [Any]()
        for variant: HLResultVariant in allVariants {
            autoreleasepool {
                var favFound: String? = nil
                for favId: String in favIds {
                    if (favId == variant?.hotel?.hotelId) {
                        selected.append(variant?)
                        favFound = favId
                    }
                }
                if favFound != nil {
                    favIds.remove(at: favIds.index(of: favFound)!)
                }
            }
        }
        return selected
    }

    class func hasDiscounts(_ variants: [Any]) -> Bool {
        for variant: HLResultVariant in variants {
            if variant?.hasDiscount() {
                return true
            }
        }
        return false
    }

    class func highlightedCount(_ variants: [Any]) -> Int {
        var result: Int = 0
        for variant: HLResultVariant in variants {
            if variant?.highlightType() != HDKHighlightTypeNone {
                result += 1
            }
        }
        return result
    }
}