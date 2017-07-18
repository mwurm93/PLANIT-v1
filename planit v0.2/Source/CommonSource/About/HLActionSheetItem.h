#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>

@interface HLActionSheetItem : NSObject

@property (nonatomic, strong) NSString * title;
@property (nonatomic, copy) void(^selectionBlock)(void);

- (id)initWithTitle:(NSString *)title selectionBlock:(void(^)(void))selectionBlock;

@end
