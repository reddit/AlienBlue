#import "CreatePostMoreOptionsCell.h"
#import "UIImage+Skin.h"

@implementation MoreOptionsNode

+ (Class)cellClass;
{
    return NSClassFromString(@"CreatePostMoreOptionsCell");
}

//+ (SEL)selectedAction;
//{
//    return @selector(moreNodeSelected:);
//}

@end

@implementation CreatePostMoreOptionsCell

- (void)decorateCell;
{
    UIColor *bgColor = self.highlighted ? [UIColor colorForBackgroundAlt] : [UIColor colorForBackground];
    [bgColor set];
    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
  
    [[UIColor grayColor] set];
    UIFont *moreOptionsFont = [UIFont boldSystemFontOfSize:24.];
    NSString *ellipsis = @"⋯";
  
    [ellipsis jm_drawVerticallyCenteredInRect:self.bounds withFont:moreOptionsFont color:[UIColor grayColor] horizontalAlignment:NSTextAlignmentCenter];
  
//    CGRect textRect = CGRectInset(self.bounds, 20., 5.);
//    textRect = CGRectOffset(textRect, 0., 5.);
//  
//    CGPoint triangleCenter = CGPointCenterOfRect(self.bounds);
//    triangleCenter.x += 60.;

//    [@"⋯"
//    [@"⋯" drawInRect:textRect withFont:moreOptionsFont lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
//    [[UIBezierPath bezierPathWithTriangleCenter:triangleCenter sideLength:9. angle:180.] fill];
  
    [UIView jm_drawHorizontalDottedLineInRect:CGRectCropToTop(self.bounds, 1.) lineWidth:1. lineColor:[UIColor colorForDottedDivider]];
}

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
  return 40.;
}

@end
