#import "HLAboutFooterView.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>
#import "planit_v0_2-Swift.h"


@interface  HLAboutFooterView()
@property (nonatomic, weak) IBOutlet UILabel * versionLabel;
@end


@implementation HLAboutFooterView

- (void) awakeFromNib
{
    [super awakeFromNib];
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"%@ %@", NSLS(@"HL_LOC_ABOUT_VERSION_TITLE"), version];
}
@end
