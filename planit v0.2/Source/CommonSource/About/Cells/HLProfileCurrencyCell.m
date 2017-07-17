#import "HLProfileCurrencyCell.h"
#import "HLProfileCurrencyItem.h"
#import <HotellookSDK/HotellookSDK.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import "JRColorScheme.h"

@interface HLProfileCurrencyCell()
@property (nonatomic, weak) IBOutlet UILabel *currencyLabel;
@end

@implementation HLProfileCurrencyCell

- (void)setupWithItem:(HLProfileCurrencyItem *)item
{
    [super setupWithItem:item];
    self.currencyLabel.text = item.currency.code;
    self.currencyLabel.textColor = [JRColorScheme navigationBarBackgroundColor];
}

@end
