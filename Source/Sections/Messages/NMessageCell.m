#import "NMessageCell.h"
#import "MessageOptionsDrawerView.h"
#import "MessageHeaderBarOverlay.h"

@interface MessageNode()
@property (strong) Message *message;
@end

@implementation MessageNode

- (id)initWithMessage:(Message *)message;
{
  JM_SUPER_INIT(initWithComment:message level:0);
  self.message = message;
  return self;
}

+ (Class)cellClass;
{
  return UNIVERSAL(NMessageCell);
}

@end

@interface NMessageCell()
@property (strong) MessageHeaderBarOverlay *messageHeaderBarOverlay;
@property (readonly) MessageNode *messageNode;
@property (readonly) Message *message;
@end

@implementation NMessageCell

+ (BOOL)shouldExpandTextToFullWidthWhenSelected;
{
  return NO;
}

+ (CGFloat)minimumHeightForCellTextForNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
{
  return [NBaseStyledTextCell minimumHeightForCellTextForNode:node bounds:bounds];
}

+ (CGFloat)indentForCellTextForNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
{
  return 30.;
}

+ (CGFloat)heightForCellHeaderForNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
{
  MessageNode *messageNode = JMCastOrNil(node, MessageNode);
  return [MessageHeaderBarOverlay recommendedHeaderBarHeightForMessageNode:messageNode];
}

+ (CGFloat)heightForCellFooterForNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
{
  CGFloat height = [[NCommentCell class] heightForCellFooterForNode:node bounds:bounds];
  height += 5.;
  return height;
}

- (MessageNode *)messageNode;
{
  return (MessageNode *)self.node;
}

- (Message *)message;
{
  return self.messageNode.message;
}

- (void)createSubviews;
{
  [super createSubviews];

  [self.voteOverlay removeFromParentView];
  [self.headerBar removeFromParentView];
  [self.dottedLineSeparatorOverlay removeFromParentView];
  
  BSELF(NMessageCell);
  self.messageHeaderBarOverlay = [[MessageHeaderBarOverlay alloc] initWithFrame:CGRectMake(0, 0, self.containerView.width, 0.)];
  self.messageHeaderBarOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  self.messageHeaderBarOverlay.onTap = ^(CGPoint touchPoint) {
    [blockSelf didTapHeaderBar];
  };
  [self.containerView addOverlay:self.messageHeaderBarOverlay];
}

- (void)updateWithNode:(JMOutlineNode *)node;
{
  [super updateWithNode:node];
  [self.messageHeaderBarOverlay updateForMessageNode:(MessageNode *)self.node];
  self.messageHeaderBarOverlay.height = [MessageHeaderBarOverlay recommendedHeaderBarHeightForMessageNode:self.messageNode];
}

- (void)attachOptionsDrawerIfNecessary;
{
  [self.drawerView removeFromSuperview];
  if (self.node.selected)
  {
    self.drawerView = [[MessageOptionsDrawerView alloc] initWithNode:self.node];
    self.drawerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.drawerView.top = self.containerView.height - kABTableCellDrawerHeight;
    self.drawerView.width = self.containerView.width;
    self.drawerView.delegate = self.node.delegate;
    [self.containerView addSubview:self.drawerView];
  }
  else
  {
    self.drawerView = nil;
  }
  
  [self layoutCellOverlays];
}

- (void)didTapHeaderBar;
{
  if (self.messageNode.onHeaderBarTap)
  {
    self.messageNode.onHeaderBarTap();
  }
}

- (void)didTapContents;
{
  if (self.messageNode.onContentsTap)
  {
    self.messageNode.onContentsTap();
  }
}

- (void)decorateCellBackground;
{
  CGPoint lineStartPoint = CGPointMake(20, 0.);
  CGRect lineRect = CGRectMake(lineStartPoint.x, lineStartPoint.y, 1., self.containerView.height - lineStartPoint.y);
  
  [[UIColor colorForSoftDivider] setFill];
  
  UIBezierPath *threadLinePath = [UIBezierPath bezierPathWithRect:lineRect];
  [threadLinePath fill];
  
  CGRect dottedLineRect = CGRectCropToRight(self.bounds, self.bounds.size.width - 38.);
  dottedLineRect = CGRectCropToBottom(dottedLineRect, 1.);
  dottedLineRect.size.width -= 20.;
  [UIView jm_drawHorizontalDottedLineInRect:dottedLineRect lineWidth:1. lineColor:[UIColor colorForDivider]];
}

@end
