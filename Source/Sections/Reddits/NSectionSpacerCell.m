#import "NSectionSpacerCell.h"

@interface SectionSpacerNode()
@property CGFloat spacingHeight;
@end

@implementation SectionSpacerNode

- (id)initWithSpacingHeight:(CGFloat)spacingHeight spacerDecoration:(SectionSpacerDecoration)spacerDecoration;
{
  JM_SUPER_INIT(init)
  self.spacingHeight = spacingHeight;
  self.spacerDecoration = spacerDecoration;
  return self;
}

+ (SectionSpacerNode *)spacerNode;
{
  return [[SectionSpacerNode alloc] initWithSpacingHeight:10. spacerDecoration:SectionSpacerDecorationNone];
}

+ (SectionSpacerNode *)spacerNodeWithCustomHeight:(CGFloat)height decoration:(SectionSpacerDecoration)decoration;
{
  return [[SectionSpacerNode alloc] initWithSpacingHeight:height spacerDecoration:decoration];
}

+ (Class)cellClass;
{
    return NSClassFromString(@"NSectionSpacerCell");
}

@end

@implementation NSectionSpacerCell

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
    if (node.hidden) return 0.;
    SectionSpacerNode *spacerNode = JMCastOrNil(node, SectionSpacerNode);
    return spacerNode.spacingHeight;
}

- (void)createSubviews;
{
  [super createSubviews];
  [self setCellBackgroundColor:[UIColor colorForBackground]];
}

- (void)decorateCellBackground;
{
  SectionSpacerNode *node = (SectionSpacerNode *)self.node;
  UIColor *bgColor = (node.backgroundColor != nil) ? node.backgroundColor : [UIColor colorForBackground];
  [bgColor set];
  [[UIBezierPath bezierPathWithRect:self.bounds] fill];
  
  if (node.spacerDecoration == SectionSpacerDecorationDot)
  {
    UIBezierPath *dotPath = [UIBezierPath bezierPathWithOvalInRect:CGRectCenterWithSize(self.bounds, CGSizeMake(6., 6.))];
    [[UIColor colorForDivider] setFill];
    [dotPath fill];
  }
  
  if (node.spacerDecoration == SectionSpacerDecorationLine)
  {
    [UIView jm_drawHorizontalDottedLineInRect:self.bounds lineWidth:0.5 lineColor:[UIColor colorForDottedDivider]];
  }
  
}

@end
