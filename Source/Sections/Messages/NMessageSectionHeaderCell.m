#import "NMessageSectionHeaderCell.h"
#import "Message.h"

@interface MessageSectionHeaderNode()
@property (strong) Message *message;
@end

@implementation MessageSectionHeaderNode

- (id)initWithTopLevelMessage:(Message *)message;
{
  JM_SUPER_INIT(init);
  self.message = message;
  return self;
}

+ (Class)cellClass;
{
  return UNIVERSAL(NMessageSectionHeaderCell);
}

@end

@interface NMessageSectionHeaderCell()
@property (readonly) MessageSectionHeaderNode *messageSectionHeaderNode;
@property (readonly) Message *message;
@end

@implementation NMessageSectionHeaderCell

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
  return 42.;
}

- (MessageSectionHeaderNode *)messageSectionHeaderNode;
{
  return (MessageSectionHeaderNode *)self.node;
}

- (Message *)message;
{
  return self.messageSectionHeaderNode.message;
}

- (void)decorateCellBackground;
{
  [[UIColor colorForBackground] setFill];
  [[UIBezierPath bezierPathWithRect:self.bounds] fill];
  
  if (!self.messageSectionHeaderNode.collapsed)
  {
    CGRect dottedLineRect = CGRectCropToRight(self.bounds, self.bounds.size.width - 38.);
    dottedLineRect = CGRectCropToBottom(dottedLineRect, 1.);
    dottedLineRect.size.width -= 20.;
    [UIView jm_drawHorizontalDottedLineInRect:dottedLineRect lineWidth:1. lineColor:[UIColor colorForDivider]];
  }
  
  [self drawThreadLineIfNecessary];
}

- (void)drawThreadLineIfNecessary;
{
  if (self.messageSectionHeaderNode.collapsed)
    return;
  
  CGPoint centerPoint = CGPointCenterOfRect(self.containerView.bounds);
  CGPoint lineStartPoint = CGPointMake(20, centerPoint.y + 14.);
  
  CGRect lineRect = CGRectMake(lineStartPoint.x, lineStartPoint.y, 1., self.containerView.height - lineStartPoint.y);

  [[UIColor colorForSoftDivider] setFill];
  
  UIBezierPath *threadLinePath = [UIBezierPath bezierPathWithRect:lineRect];
  [threadLinePath fill];
}

- (void)decorateCell;
{
  Message *m = self.message;
  
  CGFloat topLevelContentHeight = self.bounds.size.height;
  CGRect topLevelBounds = CGRectCropToTop(self.bounds, topLevelContentHeight);
  
  CGRect leftSectionRect = CGRectCropToLeft(topLevelBounds, 40.);
  
  CGPoint largeIndicatorTriangleCenter = CGPointCenterOfRect(leftSectionRect);
  largeIndicatorTriangleCenter.x += 2.;
  largeIndicatorTriangleCenter.y += 1.;
  CGFloat triangleAngle = (self.messageSectionHeaderNode.collapsed) ? 90. : 180.;
  UIBezierPath *largeUnreadIndicatorPath = [UIBezierPath bezierPathWithTriangleCenter:largeIndicatorTriangleCenter sideLength:10. angle:triangleAngle];

  UIColor *indicatorFillColor = [UIColor grayColor];
  if (m.isUnread || self.messageSectionHeaderNode.numberOfUnreadChildren > 0)
  {
    indicatorFillColor = m.i_isModMail ? [UIColor colorForModeratorMailAlert] : [UIColor colorForInboxAlert];
  }
  [indicatorFillColor setFill];
  [largeUnreadIndicatorPath fill];
//  }
  
//  [[UIColor grayColor] setStroke];
//  largeUnreadIndicatorPath.lineWidth = 0.5;
//  [largeUnreadIndicatorPath stroke];
  
  CGRect titleBoundaryRect = CGRectCropToRight(topLevelBounds, topLevelBounds.size.width - 40.);
  titleBoundaryRect.size.width -= 40.;
  
  UIColor *titleColor = self.messageSectionHeaderNode.collapsed ? [UIColor skinColorForDisabledText] : [UIColor colorForSectionTitle];
  UIFont *titleFont = [[ABBundleManager sharedManager] fontForKey:kBundleFontCommentSubdetailsBold];
  
  [m.titleForPresentation jm_drawVerticallyCenteredInRect:titleBoundaryRect withFont:titleFont color:titleColor horizontalAlignment:NSTextAlignmentLeft];
}

@end
