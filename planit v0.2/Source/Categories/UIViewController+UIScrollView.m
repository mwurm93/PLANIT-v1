#import "planit_v0_2-Swift.h"
#import "UIViewController+UIScrollView.h"
#import "UIScrollView+ScrollableArea.h"

@implementation UIViewController (UIScrollView)

- (void) setScrollViewTouchableArea:(UIScrollView *)scrollView
{
    [scrollView hl_setScrollableAreaToView:self.view];
}

@end
