//
//  JRAviasalesAdLoader.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>
#import "planit_v0_2-Swift.h"


@interface JRAviasalesAdLoader : NSObject

- (instancetype)initWithSearchInfo:(JRSDKSearchInfo *)searchInfo;

/**
 * callback - returns nil if error occured
 */
- (void)loadAdWithCallback:(void (^)(UIView *adView))callback;

@end
