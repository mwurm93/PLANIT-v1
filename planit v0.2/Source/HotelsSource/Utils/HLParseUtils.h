#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>
#import <CoreLocation/CoreLocation.h>

@interface HLParseUtils : NSObject

#pragma mark - Options

+ (NSArray <NSDictionary *> *)optionsWithValuesFromOptionsStrings:(NSArray <NSString *> *)optionsStrings;
+ (NSDictionary *)optionWithValueFromOptionString:(NSString *)optionString;


@end
