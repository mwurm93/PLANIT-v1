#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>
#import <CoreLocation/CoreLocation.h>

@class HLApiCoordinate;
@class HDKHotel;
@class HDKLocationPoint;
@class HDKCity;

@interface HLDistanceCalculator : NSObject

+ (double)getDistanceFromHotel:(HDKHotel *)hotel toLocation:(CLLocation *)location;
+ (double)getDistanceFromLocationPoint:(HDKLocationPoint *)point toHotel:(HDKHotel *)hotel;
+ (double)getDistanceFromUserToHotel:(HDKHotel *)hotel;
+ (double)getDistanceFromCity:(HDKCity *)city toHotel:(HDKHotel *)hotel;
+ (CGFloat)getDistanceFromHotel:(HDKHotel *)hotel toPointsOfCategory:(NSString *)category undefinedDistance:(CGFloat)undefinedDistance;
+ (double)convertKilometersToMiles:(double)kilometers;
+ (double)convertMetersToKilometers:(double)meters;

+ (void)calculateDistancesFromVariants:(NSArray *)variants toLocationPoint:(HDKLocationPoint *)point;

@end
