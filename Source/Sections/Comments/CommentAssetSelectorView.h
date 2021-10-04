#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface CommentAssetSelectorView : UIView <iCarouselDataSource, iCarouselDelegate>
- (id)initWithFrame:(CGRect)frame assetFolder:(NSString *)assetFolder;
@end
