//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation
import HotellookSDK

protocol HLFilteringOperationDelegate: NSObjectProtocol {
    func variantsFiltered(_ filteredVariants: [Any], withoutPriceFilter filteredVariantsWithoutPriceFilter: [Any])
}

class HLFilteringOperation: NSOperation {
    var variants = [Any]()
    weak var filter: Filter?
    weak var delegate: HLFilteringOperationDelegate?

    func main() {
        autoreleasepool {
            let amenities = [Any](arrayLiteral: filter?.amenities)
            var resultArray = [Any](arrayLiteral: variants)
            for variant: HLResultVariant in resultArray {
                variant.dropRoomsFiltering()
            }
            weakify(self)
            let indexesToBeRemoved: IndexSet? = (resultArray as NSArray).indexesOfObjects(passingTest: {(_ variant: HLResultVariant, _ idx: Int, _ stop: Bool) -> Bool in
                    strongify(self)
                    if !self || isCancelled {
                        stop = true
                        return false
                    }
                    if !FilterLogic.doesVariantConformPropertyType(variant, filter: self.filter) {
                        return true
                    }
                    if filter?.hideHotelsWithNoRooms && variant.rooms.count == 0 {
                        return true
                    }
                    if !FilterLogic.doesVariantConformNameFilter(variant, filterString: filter?.keyString) {
                        return true
                    }
                    if filter?.currentMaxDistance != filter?.maxDistance {
                        if variant.distanceToCurrentLocationPoint > filter?.currentMaxDistance {
                            return true
                        }
                    }
                    let rating: Int? = variant.hotel.rating
                    if rating < filter?.currentMinRating {
                        return true
                    }
                    if !FilterLogic.doesVariantConformStarsFilter(variant, filter: self.filter) {
                        return true
                    }
                    for amenity: String in amenities {
                        variant.filterRooms(by: amenity)
                        if !variant.shouldIncludeToFilteredResults(by: amenity) {
                            return true
                        }
                    }
                    if filter?.districtsToFilter?.count > 0 {
                        if !filter?.districtsToFilter?.contains(variant.hotel.firstDistrictName) {
                            return true
                        }
                    }
                    if filter?.gatesToFilter?.count > 0 {
                        variant.filterRooms(byGates: filter?.gatesToFilter, hotelWebsiteString: FilterLogic.hotelWebsiteAgencyName())
                        if variant.filteredRooms.count == 0 {
                            return true
                        }
                    }
                    if filter?.options?.count > 0 {
                        variant.filterRooms(withOptions: filter?.options)
                        if variant.filteredRooms.count == 0 {
                            return true
                        }
                    }
                    if filter?.hideDormitory {
                        variant.filterRooms(withOptions: [RoomOptionConsts.kRoomDormitoryOptionKey])
                        if variant.filteredRooms.count == 0 {
                            return true
                        }
                    }
                    if filter?.hideSharedBathroom {
                        variant.filterRoomsBySharedBathroom()
                        if variant.filteredRooms.count == 0 {
                            return true
                        }
                    }
                    return false
                })
            if !isCancelled {
                resultArray.removeObjects(atIndexes: indexesToBeRemoved)
                let filteredRoomsWithoutPriceFilter: [HDKRoom]
                resultArray
                var: [HDKRoom]
                variant
                do {
                    return variant.filteredRooms
                }
                weakify(self)
                let indexesToBeRemoved: IndexSet? = (resultArray as NSArray).indexesOfObjects(passingTest: {(_ variant: HLResultVariant, _ idx: Int, _ stop: Bool) -> Bool in
                        strongify(self)
                        if !self || isCancelled {
                            stop = true
                            return false
                        }
                        if (filter?.maxPrice > filter?.currentMaxPrice) || (filter?.minPrice < filter?.currentMinPrice) {
                            variant.filterRooms(with: filter?.currentMinPrice, maxPrice: filter?.currentMaxPrice)
                            if variant.filteredRooms.count == 0 {
                                return true
                            }
                        }
                        return false
                    })
                if !isCancelled {
                    resultArray.removeObjects(atIndexes: indexesToBeRemoved)
                    for variant: HLResultVariant in resultArray {
                        variant.calculateRoomWithMinPriceIfNeeded()
                    }
                    if delegate && delegate?.responds(to: Selector("variantsFiltered:withoutPriceFilter:")) {
                        delegate?.variantsFiltered(resultArray, withoutPriceFilter: filteredRoomsWithoutPriceFilter)
                    }
                }
            }
        }
    }

    func isConcurrent() -> Bool {
        return true
    }
}