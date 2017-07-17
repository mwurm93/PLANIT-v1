//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation
import HotellookSDK

class HLFilter: NSObject, NSCopying, HLFilteringOperationDelegate {
    var filterQueue: OperationQueue?
    var keyString: String = ""
    var amenities = [String]()
    private var _searchResult: SearchResult?
    var searchResult: SearchResult? {
        get {
            return _searchResult
        }
        set(searchResult) {
            let oldVariant: HLResultVariant? = self.searchResult.variants.last
            _searchResult = searchResult
            filteredVariants = self.searchResult.variants
            filteredRoomsWithoutPriceFilter =   
            filteredVariants
            var: [HDKRoom]
            variant
            do {
                return variant.rooms
            }
            if searchResult.variants.count > 0 {
                calculateBounds(withVariants: searchResult.variants)
                graphSliderMinValue = 0
                graphSliderMaxValue = 1
            }
            let newVariant: HLResultVariant? = self.searchResult.variants.last
            if !oldVariant?.hotel?.city?.isEqual(newVariant?.hotel?.city) {
                currentMaxDistance = maxDistance
            }
        }
    }
    private(set) var filteredVariants = [HLResultVariant]()
    var allVariants: [HLResultVariant] {
        return searchResult.variants ?? []
    }
    private(set) var filteredRoomsWithoutPriceFilter = [HDKRoom]()
    weak var delegate: HLFilterDelegate?
    var minPrice: Float = 0.0
    var maxPrice: Float = 0.0
    private var _currentMinPrice: Float = 0.0
    var currentMinPrice: Float {
        get {
            return _currentMinPrice
        }
        set(currentMinPrice) {
            _currentMinPrice = currentMinPrice
            graphSliderMinValue = priceSliderCalculator.sliderValue(currentMinPrice)
        }
    }
    private var _currentMaxPrice: Float = 0.0
    var currentMaxPrice: Float {
        get {
            return _currentMaxPrice
        }
        set(currentMaxPrice) {
            _currentMaxPrice = currentMaxPrice
            graphSliderMaxValue = priceSliderCalculator.sliderValue(currentMaxPrice)
        }
    }
    private var _graphSliderMinValue: CGFloat = 0.0
    var graphSliderMinValue: CGFloat {
        get {
            return _graphSliderMinValue
        }
        set(graphSliderMinValue) {
            currentMinPrice = priceSliderCalculator ? priceSliderCalculator.priceValue(graphSliderMinValue, roundingRule: HLSliderCalculatorRoundingRuleFloor) : minPrice
            _graphSliderMinValue = graphSliderMinValue
        }
    }
    private var _graphSliderMaxValue: CGFloat = 0.0
    var graphSliderMaxValue: CGFloat {
        get {
            return _graphSliderMaxValue
        }
        set(graphSliderMaxValue) {
            currentMaxPrice = priceSliderCalculator ? priceSliderCalculator.priceValue(graphSliderMaxValue, roundingRule: HLSliderCalculatorRoundingRuleCeil) : maxPrice
            _graphSliderMaxValue = graphSliderMaxValue
        }
    }
    var priceSliderCalculator: HLPriceSliderCalculator?
    var minRating: Int = 0
    var maxRating: Int = 0
    var currentMinRating: Int = 0
    var minDistance: CGFloat = 0.0
    var maxDistance: CGFloat = 0.0
    var currentMaxDistance: CGFloat = 0.0
    var isHideHotelsWithNoRooms: Bool = false
    var isHideDormitory: Bool = false
    var isHideSharedBathroom: Bool = false
    var isCanFilterByOptions: Bool = false
    var sortType = SortType()
    var options = [String]()
    var gatesToFilter = [String]()
    var districtsToFilter = [String]()
    private var _distanceLocationPoint: HDKLocationPoint?
    var distanceLocationPoint: HDKLocationPoint? {
        get {
            return _distanceLocationPoint
        }
        set(distanceLocationPoint) {
            if !_distanceLocationPoint.isEqual(distanceLocationPoint) {
                _distanceLocationPoint = distanceLocationPoint
                calculateDistanceBounds(searchResult.variants, locationPoint: self.distanceLocationPoint)
            }
        }
    }
    var roomAmenities: [Any] {
        let allRoomAmenities: [Any] = ["4", "6", "13", "14"]
            return amenities.filter { NSPredicate.predicate({0:@escaping (Any?, [String : Any]?).evaluate(with: $0) }
    }
    var hotelAmenities: [Any] {
        let allHotelAmenities: [Any] = ["0", "1", "3", "5", "7", "8", "9"]
            return amenities.filter { NSPredicate.predicate({0:@escaping (Any?, [String : Any]?).evaluate(with: $0) }
    }
    var searchInfo: HLSearchInfo?

    var filteredVariants = [HLResultVariant]()
    var filteredRoomsWithoutPriceFilter = [HDKRoom]()

    func setDefaultLocationPointWith(_ searchInfo: HLSearchInfo) {
        switch searchInfo.searchInfoType {
            case HLSearchInfoTypeCity:
                distanceLocationPoint = HLCityLocationPoint(city: searchInfo.city)
            case HLSearchInfoTypeCustomLocation, HLSearchInfoTypeUserLocation:
                distanceLocationPoint = HDKLocationPoint(name: NSLS("HL_LOC_SEARCH_POINT_TEXT"), location: searchInfo.locationPoint.location)
            case HLSearchInfoTypeAirport:
                distanceLocationPoint = HDKLocationPoint(name: searchInfo.locationPoint.title, location: searchInfo.locationPoint.location)
            case HLSearchInfoTypeCityCenterLocation:
                distanceLocationPoint = HLCityLocationPoint(city: searchInfo.locationPoint.city)
            default:
                break
        }

    }

    func refreshPriceBounds() {
        graphSliderMinValue = graphSliderMinValue
        graphSliderMaxValue = graphSliderMaxValue
    }

    func calculateBounds(withVariants variants: [Any]) {
        calculateDistanceBounds(searchResult.variants, locationPoint: distanceLocationPoint)
        calculatePriceAndOptionsBounds(variants)
        priceSliderCalculator = HLSliderCalculatorFactory.priceSliderCalculator(with: self)
    }

    func applyParams(_ filter: HLFilter) {
        amenities = filter.amenities
        keyString = filter.keyString
        options = filter.options?
        minPrice = filter.minPrice
        maxPrice = filter.maxPrice
        priceSliderCalculator = filter.priceSliderCalculator
        graphSliderMinValue = filter.graphSliderMinValue
        graphSliderMaxValue = filter.graphSliderMaxValue
        minDistance = filter.minDistance
        maxDistance = filter.maxDistance
        currentMaxDistance = filter.currentMaxDistance
        minRating = filter.minRating
        maxRating = filter.maxRating
        currentMinRating = filter.currentMinRating
        isHideHotelsWithNoRooms = filter.isHideHotelsWithNoRooms
        isHideDormitory = filter.isHideDormitory
    }

    func dropFilters() {
        dropCommonValues()
        isHideSharedBathroom = false
        isHideDormitory = false
        isHideHotelsWithNoRooms = false
        currentMinPrice = minPrice
        currentMaxPrice = maxPrice
        graphSliderMinValue = 0
        graphSliderMaxValue = 1
        currentMaxDistance = maxDistance
        currentMinRating = minRating
        filteredVariants = searchResult.variants
        filteredRoomsWithoutPriceFilter =   
        filteredVariants
        var: [HDKRoom]
        variant
        do {
            return variant.rooms
        }
        weakify(self)
        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            strongify(self)
            for variant: HLResultVariant in self.filteredVariants {
                variant.dropRoomsFiltering()
            }
            self.filteredVariants = self.sortVariants(self.filteredVariants)
            weakify(self)
            hl_dispatch_main_async_safe({() -> Void in
                strongify(self)
                self.delegate?.didFilterVariants()
            })
        })
    }

    func dropCommonValues() {
        amenities = [Any]()
        options = [Any]()
        gatesToFilter = [Any]()
        districtsToFilter = [Any]()
        keyString = nil
    }

    func allVariantsHaveSamePrice() -> Bool {
        return minPrice == maxPrice
    }

    func canDropFilters() -> Bool {
        if isHideHotelsWithNoRooms {
            return true
        }
        if isHideDormitory {
            return true
        }
        if isHideSharedBathroom {
            return true
        }
        if currentMaxPrice != maxPrice {
            return true
        }
        if currentMinPrice != minPrice {
            return true
        }
        if currentMaxDistance != maxDistance {
            return true
        }
        if isRatingFilterActive() {
            return true
        }
        if (keyString.characters.count ?? 0) > 0 {
            return true
        }
        if options.count > 0 {
            return true
        }
        if amenities.count > 0 {
            return true
        }
        if gatesToFilter.count > 0 {
            return true
        }
        if districtsToFilter.count > 0 {
            return true
        }
        return false
    }

    func isRatingFilterActive() -> Bool {
        return currentMinRating != minRating
    }

    func allDistrictNames() -> [String] {
        return searchResult.counters.hotelsCountAccordingToGates.keys
    }

    func discountVariants() -> [Any] {
        let predicate = NSPredicate.predicate({0:@escaping (Any?, [String : Any]?)
        return searchResult.variants.filter { predicate.evaluate(with: $0) }
    }

    func privatePriceVariants() -> [Any] {
        let predicate = NSPredicate.predicate({0:@escaping (Any?, [String : Any]?)
        return searchResult.variants.filter { predicate.evaluate(with: $0) }
    }

    override init() {
        super.init()
        
        dropCommonValues()
        minPrice = 0
        maxPrice = DBL_MAX
        minDistance = MAXFLOAT
        maxDistance = 0.0
        currentMaxDistance = 0.0
        minRating = 0
        maxRating = 100
        filterQueue = OperationQueue()
        filterQueue?.maxConcurrentOperationCount = 1
    
    }

    func copy(with zone: NSZone) -> Any {
        let copy = HLFilter()
        if copy {
            copy.amenities = amenities
            copy.keyString = keyString
            copy.options = options?
            copy.minPrice = minPrice
            copy.maxPrice = maxPrice
            copy.currentMinPrice = currentMinPrice
            copy.currentMaxPrice = currentMaxPrice
            copy.priceSliderCalculator = priceSliderCalculator
            copy.graphSliderMinValue = graphSliderMinValue
            copy.graphSliderMaxValue = graphSliderMaxValue
            copy.minDistance = minDistance
            copy.maxDistance = maxDistance
            copy.currentMaxDistance = currentMaxDistance
            copy.distanceLocationPoint = distanceLocationPoint
            copy.minRating = minRating
            copy.maxRating = maxRating
            copy.currentMinRating = currentMinRating
            copy.isHideHotelsWithNoRooms = isHideHotelsWithNoRooms
            copy.isHideDormitory = isHideDormitory
        }
        return copy
    }

    func isEqual(_ object: Any) -> Bool {
        if !(object is HLFilter) {
            return false
        }
        let filterObject: HLFilter? = (object as? HLFilter)
        let filterAreEqual: Bool? = amenities == filterObject?.amenities && keyString == filterObject?.keyString && options == filterObject?.options && minPrice == filterObject?.minPrice && maxPrice == filterObject?.maxPrice && currentMinPrice == filterObject?.currentMinPrice && currentMaxPrice == filterObject?.currentMaxPrice && minDistance == filterObject?.minDistance && maxDistance == filterObject?.maxDistance && currentMaxDistance == filterObject?.currentMaxDistance && minRating == filterObject?.minRating && maxRating == filterObject?.maxRating && currentMinRating == filterObject?.currentMinRating && isHideHotelsWithNoRooms == filterObject?.isHideHotelsWithNoRooms && isHideDormitory == filterObject?.isHideDormitory
        return filterAreEqual!
    }

    func hash() -> Int {
        return keyString._hash ^ (NSInteger)
        minPrice ^ (NSInteger)
        maxPrice ^ (NSInteger)
        currentMaxPrice ^ (NSInteger)
        currentMinPrice ^ maxRating ^ minRating ^ options.count
    }

// MARK: - Private
    func calculateDistanceBounds(_ variants: [Any], locationPoint point: HDKLocationPoint) {
        if variants.count == 0 {
            return
        }
        minDistance = CGFLOAT_MAX
        maxDistance = -1
        for variant: HLResultVariant in variants {
            var distance: CGFloat = CGFLOAT_MAX
            distance = HLDistanceCalculator.getDistanceFrom(distanceLocationPoint, toHotel: variant.hotel)
            if distance != CGFLOAT_MAX {
                variant.distanceToCurrentLocationPoint = distance
                maxDistance = max(maxDistance, distance)
                minDistance = min(minDistance, distance)
            }
        }
        minDistance += 0.01
        maxDistance += 0.01
        currentMaxDistance = maxDistance
    }

    func calculatePriceAndOptionsBounds(_ variants: [Any]) {
        maxPrice = UNKNOWN_MAX_PRICE
        minPrice = UNKNOWN_MIN_PRICE
        isCanFilterByOptions = false
        var shouldCheckOptions: Bool = true
        for variant: HLResultVariant in variants {
            for room: HDKRoom in variant.rooms {
                maxPrice = max(maxPrice, room.price)
                minPrice = min(minPrice, room.price)
            }
            if shouldCheckOptions {
                for room: HDKRoom in variant.rooms {
                    if room.hasBreakfast || room.refundable {
                        isCanFilterByOptions = true
                        shouldCheckOptions = false
                    }
                }
            }
        }
        if maxPrice == UNKNOWN_MAX_PRICE {
            maxPrice = UNKNOWN_MIN_PRICE
        }
    }

// MARK: - Public

    func sortVariants(_ variants: [Any]) -> [Any] {
        return VariantsSorter.sortVariants(variants, with: sortType, searchInfo: searchInfo)
    }

// MARK: - HLFilteringOperation delegate
    func variantsFiltered(_ filteredVariants: [HLResultVariant], withoutPriceFilter filteredRoomsWithoutPriceFilter: [HDKRoom]) {
        self.filteredVariants = sortVariants(filteredVariants)
        self.filteredRoomsWithoutPriceFilter = filteredRoomsWithoutPriceFilter
        weak var weakSelf: HLFilter? = self
        hl_dispatch_main_async_safe({() -> Void in
            weakSelf?.self.delegate?.didFilterVariants()
        })
    }
}

let UNKNOWN_MAX_PRICE = (-1)