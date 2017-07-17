//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation

let kMaxVariantsToShowNearbyCitiesSearchCard: Int = 25

protocol HLActionCellDelegate: NSObjectProtocol {
    func actionCardItemClosed(_ item: HLCollectionItem)

    func distanceItemClosed(_ item: HLDistanceFilterCardItem)

    func distanceItemApplied(_ item: HLDistanceFilterCardItem)

    func nearbyCitiesSearchItemApplied(_ item: HLCollectionItem)

    func filterUpdated(_ filter: Filter)

    func searchTickets()
}

class HLActionCardsManager: NSObject {
    var excludedCardClasses = [Any]()
    var distanceItem: HLDistanceFilterCardItem?
    var priceItem: HLPriceFilterCardItem?

    func registerCardNibs(for collectionView: UICollectionView) {
        collectionView.hl_registerNib(withName: HLDistanceFilterCardCell.hl_reuseIdentifier())
        collectionView.hl_registerNib(withName: HLPriceFilterCardCell.hl_reuseIdentifier())
        collectionView.hl_registerNib(withName: HLRatingCardCell.hl_reuseIdentifier())
        collectionView.hl_registerNib(withName: HLPlaceholderCell.hl_reuseIdentifier())
        collectionView.hl_registerNib(withName: HLNearbyCitiesSearchCardCell.hl_reuseIdentifier())
        collectionView.hl_registerNib(withName: HLSearchTicketsCardCell.hl_reuseIdentifier())
    }

    func excludeItemClass(_ item: HLActionCardItem) {
        excludedCardClasses.append(item.self)
    }

    func shouldAdd(_ item: HLActionCardItem) -> Bool {
        return !excludedCardClasses.contains(item.self)
    }

    func addActionCards(to items: [HLCollectionItem], configuration: ActionCardsConfiguration) -> [HLCollectionItem] {
        var result: [Any] = items
        result = self.items(byAddingFilterCard: result, configuration: configuration)
        result = self.items(byAddingSearchTicketsCard: result, configuration: configuration)
        result = self.items(byAddingPlaceholderCard: result, configuration: configuration)
        result = self.items(byAddingNearbyCitiesSearchCard: result, configuration: configuration)
        return result
    }

    override init() {
        super.init()
        
        excludedCardClasses = [Any]()
    
    }

    func items(byAddingFilterCard items: [HLCollectionItem], configuration config: ActionCardsConfiguration) -> [HLCollectionItem] {
        var result: [Any] = items
        if !iPhone() {
            return result
        }
        switch config.searchInfo.searchInfoType {
            case HLSearchInfoTypeCityCenterLocation, HLSearchInfoTypeCustomLocation, HLSearchInfoTypeUserLocation, HLSearchInfoTypeAirport:
                let distanceItem: HLDistanceFilterCardItem? = createDistanceItem(withTopItem: true, configuration: config)
                if shouldAdd(distanceItem) {
                    result = HLActionCardsArrayHelper.add(distanceItem, toArray: result, atIndex: 0, minVariantsCount: 0)
                }
            case HLSearchInfoTypeCity:
                switch config.filter.sortType {
                    case SortTypePrice:
                        result = self.items(byAddingRatingFilterItem: items, configuration: config)
                    default:
                        priceItem = createPriceItem(with: config)
                        if shouldAddPriceItem(priceItem, filter: config.filter) {
                            result = HLActionCardsArrayHelper.add(priceItem, toArray: result, atIndex: 0, minVariantsCount: 0)
                        }
                }

                let distanceItem: HLDistanceFilterCardItem? = createDistanceItem(withTopItem: false, configuration: config)
                if shouldAdd(distanceItem) {
                    result = HLActionCardsArrayHelper.add(distanceItem, toArray: result, atIndex: 5, minVariantsCount: 10)
                }
            default:
                break
        }

        return result
    }

    func shouldAddSearchTicketsCard(with config: ActionCardsConfiguration) -> Bool {
        if iPad() {
            return false
        }
        if !ticketsEnabled() {
            return false
        }
        let type: HLSearchInfoType = config.searchInfo.searchInfoType
        if type == HLSearchInfoTypeCustomLocation || type == HLSearchInfoTypeUserLocation {
            return false
        }
        return true
    }

    func items(byAddingSearchTicketsCard items: [HLCollectionItem], configuration config: ActionCardsConfiguration) -> [HLCollectionItem] {
        if !shouldAddSearchTicketsCard(with: config) {
            return items
        }
        let item = HLSearchTicketsCardItem(topItem: false, cellReuseIdentifier: HLSearchTicketsCardCell.hl_reuseIdentifier(), filter: config.filter, delegate: config.delegate)
        if shouldAdd(item) {
            return HLActionCardsArrayHelper.add(item, toArray: items, atIndex: 3, minVariantsCount: 0, canAppend: false)
        }
        return items
    }

    func items(byAddingRatingFilterItem items: [HLCollectionItem], configuration config: ActionCardsConfiguration) -> [HLCollectionItem] {
        var result: [Any] = items
        let ratingItem = HLRatingFilterCardItem(topItem: true, cellReuseIdentifier: HLRatingCardCell.hl_reuseIdentifier(), filter: config.filter, delegate: config.delegate)
        if shouldAdd(ratingItem) {
            result = HLActionCardsArrayHelper.add(ratingItem, toArray: result, atIndex: 0, minVariantsCount: 0)
        }
        return result
    }

    func items(byAddingPlaceholderCard items: [HLCollectionItem], configuration config: ActionCardsConfiguration) -> [HLCollectionItem] {
        if !iPhone() || items.count > 0 {
            return items
        }
        let placeholderItem = HLPlaceholderCardItem(topItem: false, cellReuseIdentifier: HLPlaceholderCell.hl_reuseIdentifier(), filter: config.filter, delegate: config.delegate)
        return HLActionCardsArrayHelper.add(placeholderItem, toArray: items, atIndex: 0, minVariantsCount: 0)
    }

    func items(byAddingNearbyCitiesSearchCard items: [HLCollectionItem], configuration config: ActionCardsConfiguration) -> [HLCollectionItem] {
        let indexToInsertNearbyCitiesSearchItem: Int = self.indexToInsertNearbyCitiesSearchItem(toArray: items, configuration: config)
        if indexToInsertNearbyCitiesSearchItem != NSNotFound {
            let item = HLNearbyCitiesSearchCardItem(topItem: false, cellReuseIdentifier: HLNearbyCitiesSearchCardCell.hl_reuseIdentifier(), filter: config.filter, delegate: config.delegate)
            var mutableResult: [Any] = items
            mutableResult.insert(item, at: indexToInsertNearbyCitiesSearchItem)
            return mutableResult
        }
        else {
            return items
        }
    }

// MARK: - Private

    func indexToInsertNearbyCitiesSearchItem(toArray items: [HLCollectionItem], configuration config: ActionCardsConfiguration) -> Int {
        let originalRoomsWithPrices: IndexSet? = (config.filter.searchResult?.variants? as NSArray).indexesOfObjects(passingTest: {(_ obj: HLResultVariant, _ idx: Int, _ stop: Bool) -> Bool in
                return obj.rooms.atLeastOneConfirms({(_ room: HDKRoom) -> Bool in
                    return room.price > 0
                })
            })
        if config.searchInfo.searchInfoType != HLSearchInfoTypeCity || originalRoomsWithPrices?.count > kMaxVariantsToShowNearbyCitiesSearchCard || config.filter.searchResult?.nearbyCities?.count <= 1 {
            return NSNotFound
        }
        let lastPriceVariantOrTopCardIndex: Int? = items.lastIndexOfObject(passingTest: {(_ item: Any, _ index: Int) -> Bool in
                if (item is HLActionCardItem) {
                    return (item as? HLActionCardItem)?.topItem!
                }
                let roomWithPrice: HDKRoom? = (item as? HLVariantItem)?.variant?.roomWithMinPrice
                return roomWithPrice != nil
            })
        return lastPriceVariantOrTopCardIndex != NSNotFound ? (lastPriceVariantOrTopCardIndex + 1) : 0
    }

    func createDistanceItem(withTopItem topItem: Bool, configuration config: ActionCardsConfiguration) -> HLDistanceFilterCardItem {
        if distanceItem == nil {
            distanceItem = HLDistanceFilterCardItem(topItem: topItem, cellReuseIdentifier: HLDistanceFilterCardCell.hl_reuseIdentifier(), filter: config.filter, delegate: config.delegate, search: config.searchInfo)
        }
        else {
            distanceItem?.update(config.filter)
        }
        return distanceItem!
    }

    func createPriceItem(with config: ActionCardsConfiguration) -> HLPriceFilterCardItem {
        if priceItem == nil {
            priceItem = HLPriceFilterCardItem(topItem: true, cellReuseIdentifier: HLPriceFilterCardCell.hl_reuseIdentifier(), filter: config.filter, delegate: config.delegate, currency: config.searchInfo.currency)
        }
        return priceItem!
    }

    func shouldAddPriceItem(_ item: HLPriceFilterCardItem, filter: Filter) -> Bool {
        return shouldAdd(item) && !filter.allVariantsHaveSamePrice() && filter.searchResult.variants.count >= 3
    }
}