//
//  HLUrlShortener.h
//  HotelLook
//
//  Created by Anton Chebotov on 19/08/15.
//  Copyright (c) 2015 Anton Chebotov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>

#import "HLResultVariant.h"

@interface HLUrlShortener : NSObject

@property (nonatomic, readonly) NSString *longUrlString;
@property (nonatomic, readonly) NSString *shortenedUrlString;

- (void)shortenUrlForVariant:(HLResultVariant *)variant completion:(void (^)(void))completion;
- (NSString *)shortenedUrl;

@end
