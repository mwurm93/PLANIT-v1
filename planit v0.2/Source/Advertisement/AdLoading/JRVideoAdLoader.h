//
//  JRVideoAdLoader.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//
#import "planit_v0_2-Swift.h"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>

@class APDMediaView, APDNativeAd;

@interface JRVideoAdLoader : NSObject

@property (weak, nonatomic) UIViewController *rootViewController;
- (void)loadVideoAd:(void(^)(APDMediaView *, APDNativeAd *))callback;

@end
