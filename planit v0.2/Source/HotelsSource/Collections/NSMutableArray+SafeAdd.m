#import "planit_v0_2-Swift.h"
#import "NSMutableArray+SafeAdd.h"

@implementation NSMutableArray (SafeAdd)

- (void)addIfNotNil:(id)object
{
    if (object != nil) {
        [self addObject: object];
    }
}

@end
