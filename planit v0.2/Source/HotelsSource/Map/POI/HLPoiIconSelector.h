#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>
#import <UIKit/UIKit.h>

@class HLPoiIconSelector;
@class HDKCity;
@class PoiAnnotation;
@class MKAnnotationView;
@class MKMapView;
@class HDKLocationPoint;

@interface HLPoiIconSelector : NSObject

+ (UIImage *)listPoiIcon:(HDKLocationPoint *)poi city:(HDKCity *)city;
+ (UIImage *)mapPoiIcon:(HDKLocationPoint *)poi city:(HDKCity *)city;
+ (MKAnnotationView *)annotationView:(PoiAnnotation *)annotation mapView:(MKMapView *)mapView city:(HDKCity *)city;

@end
