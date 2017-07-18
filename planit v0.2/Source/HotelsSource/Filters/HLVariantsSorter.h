#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>

typedef NS_ENUM(NSUInteger, SortType) {
    SortTypePopularity = 0,
    SortTypePrice,
    SortTypeDistance,
    SortTypeRating,
    SortTypeDiscount,
    SortTypeBookingsCount,
};
