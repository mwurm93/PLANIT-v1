#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLLocaleInspector : NSObject

+ (HLLocaleInspector *)sharedInspector;
+ (BOOL)shouldUseMetricSystem;

- (NSString *)localeString;
- (BOOL)isLanguageRussian:(NSString *)lang;
- (BOOL)isLanguageEnglish:(NSString *)lang;

- (BOOL)isCurrentLanguageRussian;
- (BOOL)isCurrentLanguageEnglish;

+ (NSString *)localizedUserReviewLangNameForLang:(NSString *)lang;
+ (NSString * _Nullable)userReviewLangName;

- (NSString *)countryCode;

NS_ASSUME_NONNULL_END

@end
