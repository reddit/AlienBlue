#import "MessageHeaderBarOverlay.h"
#import "NMessageCell.h"
#import "Message.h"

@interface MessageHeaderBarOverlay ()
@property (ab_weak) MessageNode *messageNode;
@property (readonly) BOOL collapsed;
@end

@implementation MessageHeaderBarOverlay

- (id)initWithFrame:(CGRect)frame;
{
  JM_SUPER_INIT(initWithFrame:frame);
  self.allowTouchPassthrough = NO;
  return self;
}

- (void)updateForMessageNode:(MessageNode *)messageNode;
{
  self.messageNode = messageNode;
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect;
{
  CGRect secondaryLevelBoundaryRect = CGRectCropToBottom(self.bounds, [[self class] sectionHeightForSecondaryLevelContentForMessageNode:self.messageNode]);
  secondaryLevelBoundaryRect = CGRectCropToRight(secondaryLevelBoundaryRect, secondaryLevelBoundaryRect.size.width - 40.);
  
  Message *m = self.messageNode.message;
  
  CGPoint tinyIndicatorTriangleCenter = CGPointCenterOfRect(secondaryLevelBoundaryRect);
  tinyIndicatorTriangleCenter.x = secondaryLevelBoundaryRect.origin.x;
  tinyIndicatorTriangleCenter.y += 2.;
  CGFloat triangleAngle = (self.messageNode.collapsed) ? 90. : 180.;
  UIBezierPath *tinyIndicatorPath = [UIBezierPath bezierPathWithTriangleCenter:tinyIndicatorTriangleCenter sideLength:6. angle:triangleAngle];
  
  UIColor *indicatorFillColor = [UIColor grayColor];
  if (m.isUnread)
  {
    indicatorFillColor = m.i_isModMail ? [UIColor colorForModeratorMailAlert] : [UIColor colorForInboxAlert];
  }
  [indicatorFillColor setFill];
  [tinyIndicatorPath fill];
  
  UIColor *subtitleColor = self.messageNode.collapsed ? [UIColor skinColorForDisabledText] : [UIColor grayColor];
  
  if (m.isMine)
  {
    subtitleColor = [UIColor colorForHighlightedOptions];
  }
  else if (m.isUnread)
  {
    subtitleColor = indicatorFillColor;
  }
  
  NSString *subtitleText = m.author;
  
  if (m.isMine && !JMIsEmpty(m.destinationUser) && !m.i_isModMail)
  {
    subtitleText = [NSString stringWithFormat:@"to %@", m.destinationUser];
  }
  
  CGRect subtitleRect = CGRectInset(secondaryLevelBoundaryRect, 10., 0.);
  subtitleRect.size.width -= 10.;
  
  UIFont *subtitleFont = [[ABBundleManager sharedManager] fontForKey:kBundleFontMessageSubtitle];

  [subtitleText jm_drawVerticallyCenteredInRect:subtitleRect withFont:subtitleFont color:subtitleColor horizontalAlignment:NSTextAlignmentLeft];
  
  NSString *rightHandText = m.metadataForPresentation;
  [rightHandText jm_drawVerticallyCenteredInRect:subtitleRect withFont:subtitleFont color:subtitleColor horizontalAlignment:NSTextAlignmentRight];
}

+ (CGFloat)sectionHeightForSecondaryLevelContentForMessageNode:(MessageNode *)messageNode;
{
  return 30.;
}

+ (CGFloat)recommendedHeaderBarHeightForMessageNode:(MessageNode *)messageNode;
{
  CGFloat secondaryLevelSectionHeight = [self sectionHeightForSecondaryLevelContentForMessageNode:messageNode];
  return secondaryLevelSectionHeight;
}

@end
