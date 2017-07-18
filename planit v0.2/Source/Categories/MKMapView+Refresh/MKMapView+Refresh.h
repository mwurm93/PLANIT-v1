#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>
#import <MapKit/MapKit.h>

@interface MKMapView (Refresh)
- (void)hl_refreshAnnotationsAnimated:(BOOL)animated;
@end
