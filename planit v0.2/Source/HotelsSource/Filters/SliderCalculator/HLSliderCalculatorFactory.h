#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>

@class HLPriceSliderCalculator, HLFilter;

NS_ASSUME_NONNULL_BEGIN

@interface HLSliderCalculatorFactory : NSObject

+ (nullable HLPriceSliderCalculator *)priceSliderCalculatorWithFilter:(HLFilter *)filter;
+ (nullable HLPriceSliderCalculator *)priceSliderCalculatorWithFilter:(HLFilter *)filter maxPivotCount:(NSInteger)maxPivotCount;
+ (nullable NSArray<NSNumber *>*)pricesFromFilter:(HLFilter *)filter;

@end

NS_ASSUME_NONNULL_END
