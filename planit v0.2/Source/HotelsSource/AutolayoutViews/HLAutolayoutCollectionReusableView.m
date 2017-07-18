#import "HLAutolayoutCollectionReusableView.h"
#import "planit_v0_2-Swift.h"

@interface HLAutolayoutCollectionReusableView()
@property(nonatomic) BOOL didSetupConstraints;
@end

@implementation HLAutolayoutCollectionReusableView

- (void)updateConstraints
{
    [super updateConstraints];

    if (!self.didSetupConstraints) {
        [self setupConstraints];
        self.didSetupConstraints = YES;
    }
}

- (void)setupConstraints
{
    // Implement in subclass
}

@end
