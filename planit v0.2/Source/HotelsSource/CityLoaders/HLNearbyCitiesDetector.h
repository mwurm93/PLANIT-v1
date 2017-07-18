#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>

@class HLSearchInfo;
@class HDKCity;

@interface HLNearbyCitiesDetector : NSObject

+ (instancetype _Nonnull)shared;
- (void)detectCurrentCityWithSearchInfo:(HLSearchInfo * _Nonnull)searchInfo;
- (void)dropCurrentLocationSearchDestination;

@property (nullable, nonatomic, readonly) NSArray <HDKCity *> *nearbyCities;

@property (nonatomic, assign, readonly) BOOL busy;
@property (nullable, nonatomic, strong) NSString *currentLocationDestination;

@end
