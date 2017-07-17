//
//  JRAppLauncher.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "JRDefines.h"

@interface JRAppLauncher : NSObject

+ (void)startServicesWithAPIToken:(NSString *)APIToken
                    partnerMarker:(NSString *)partnerMarker
                   appodealAPIKey:(NSString *)appodealAPIKey;

@end
