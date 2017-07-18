#import "planit_v0_2-Swift.h"
#import "UIScrollView+ScrollableArea.h"

@implementation UIScrollView (ScrollableArea)

- (void)hl_setScrollableAreaToView:(UIView *)view
{
    UIPanGestureRecognizer * panRec = self.panGestureRecognizer;
    [view addGestureRecognizer:panRec];
}

@end
