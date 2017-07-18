#import "HLVariantScrollablePhotoCell.h"
#import "HLCommonVC.h"

@class HLMapGroupDetailsVC;

@interface HLMapGroupDetailsVC : HLCommonVC <HLShowHotelProtocol>

@property (nonatomic, strong) NSArray *variants;
@property (nonatomic, weak) id <HLShowHotelProtocol> delegate;

@end
