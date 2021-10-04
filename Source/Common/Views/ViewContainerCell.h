#import "JMOutlineCell.h"

@interface ViewContainerNode : JMOutlineNode
@property (strong) UIView *view;
@property CGSize padding;
@property CGFloat heightForViewPortrait;
@property CGFloat heightForViewLandscape;
@property BOOL resizesToFitCell;

- (id)initWithView:(UIView *)view;
@end

@interface ViewContainerCell : JMOutlineCell

@end
