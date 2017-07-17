//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation

private let defaultMaxPivotsCount: Int = 10

class HLSliderCalculatorFactory: NSObject {
    class func priceSliderCalculator(with filter: HLFilter) -> HLPriceSliderCalculator {
        return self.priceSliderCalculator(with: filter, maxPivotCount: defaultMaxPivotsCount)
    }

    class func priceSliderCalculator(with filter: HLFilter, maxPivotCount: Int) -> HLPriceSliderCalculator {
        let roomPrices: [Any] = self.prices(from: filter)
        if roomPrices.arrayWithoutDuplicates().count < 2 {
            return nil
        }
        return HLPriceSliderCalculator(prices: roomPrices, maxPivotCount: maxPivotCount)
    }

    class func prices(from filter: HLFilter) -> [NSNumber] {
        return filter.searchResult.variants.flattenMap({(_ variant: HLResultVariant) -> [Any] in
            return variant.rooms.map({(_ room: HDKRoom) -> NSNumber in
                return (room.price)
            })
        })
    }
}