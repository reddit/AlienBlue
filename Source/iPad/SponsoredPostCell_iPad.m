#import "SponsoredPostCell_iPad.h"
#import "NPostCell_iPad.h"
#import "Resources.h"

@implementation SponsoredPostCell_iPad

+ (CGFloat)footerPadding;
{
  return 0.;
}

+ (CGFloat)minimumHeightForPost:(Post *)post;
{
  return [[NPostCell_iPad class] minimumHeightForPost:post];
}

- (CGRect)rectForTitle;
{
  CGRect titleRect = [super rectForTitle];
  CGFloat xOffset = (self.post.thumbnail != nil) ? 10. : 0.;
  titleRect = CGRectOffset(titleRect, xOffset, 4.);
  return titleRect;
}

- (void)layoutCellOverlays;
{
  [super layoutCellOverlays];
  self.sectionDivider.right = self.commentButtonOverlay.left - 4.;
}

- (void)decorateCellBackground;
{
  CGRect bounds = self.bounds;
  CGContextRef context = UIGraphicsGetCurrentContext();
  [[UIColor colorForBackground] set];
  CGContextFillRect(context, bounds);
  
  if (self.highlighted || self.node.selected)
  {
    UIColor *bgColor = [Resources isNight] ? [UIColor colorWithWhite:0. alpha:0.08] : [UIColor colorWithWhite:0. alpha:0.02];
    [bgColor set];
    CGContextFillRect(context, bounds);
  }
  
  [[UIColor colorForSoftDivider] set];
  [[UIBezierPath bezierPathWithRect:CGRectMake(15., self.containerView.height - 1., self.containerView.width - 30., 1.)] fill];
}

@end
