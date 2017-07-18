#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>

@interface NSMutableArray<ObjectType> (SafeAdd)

- (void)addIfNotNil:(ObjectType)object;

@end
