#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>

@interface UITableView (HLNibLoading)
- (void)hl_registerNibWithName:(nonnull NSString *)name;
@end

@interface UICollectionView (HLNibLoading)
- (void)hl_registerNibWithName:(nonnull NSString *)name;
@end
