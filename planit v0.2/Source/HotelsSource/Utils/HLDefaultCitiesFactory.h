#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>

@class HDKCity;

@interface HLDefaultCitiesFactory : NSObject

+ (HDKCity *)defaultCity;

@end
