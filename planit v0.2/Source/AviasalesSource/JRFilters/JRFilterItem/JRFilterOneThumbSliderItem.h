//
//  JRFilterOneThumbSliderItem.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRFilterItemProtocol.h"


@interface JRFilterOneThumbSliderItem : NSObject <JRFilterItemProtocol>

@property (nonatomic, assign, readonly) float minValue;
@property (nonatomic, assign, readonly) float maxValue;

@property (nonatomic, assign) float currentValue;

@property (nonatomic, copy) void (^filterAction)();

- (instancetype)initWithMinValue:(float)minValue maxValue:(float)maxValue currentValue:(float)currentValue;

@end


@interface JRFilterPriceItem : JRFilterOneThumbSliderItem

@end


@interface JRFilterTotalDurationItem : JRFilterOneThumbSliderItem

@end
