#import "TemplateCell.h"

#define kTemplateCellHeaderHeight 40.

@interface TemplateNode()
@property (strong) Template *tPlate;
@end

@implementation TemplateNode

- (id)initWithTemplate:(Template *)tPlate;
{
  self = [super init];
  if (self)
  {
    self.tPlate = tPlate;
    self.title = tPlate.body;
    self.hidesDivider = YES;
  }
  return self;
}

+ (Class)cellClass;
{
  return UNIVERSAL(TemplateCell);
}

@end

#pragma mark - Cell Composition

@interface TemplateCell()
@property (strong) JMViewOverlay *headerOverlay;
@property (readonly) Template *tPlate;
@end;

@implementation TemplateCell

+ (CGSize)textPadding;
{
  return CGSizeMake(10., 2.);
}

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
  TemplateNode *tNode = (TemplateNode *)node;
  
  if (tNode.collapsed)
  {
    return 40.;
  }
  
  CGFloat height = 0.;
  
  UIFont *font = [UIFont skinFontWithName:kBundleFontOptionTitle];
  CGFloat titleWidth = tableView.bounds.size.width - ([[self class] textPadding].width * 2);
  CGFloat titleHeight = [tNode.title sizeWithFont:font constrainedToSize:CGSizeMake(titleWidth, MAXFLOAT)].height;
  
  height += ([[self class] textPadding].height * 2);
  height += titleHeight;
  height += kTemplateCellHeaderHeight;
  height += 5.;
  return height;
}

- (Template *)tPlate;
{
  TemplateNode *tNode = (TemplateNode *)self.node;
  return tNode.tPlate;
}

- (void)layoutCellOverlays;
{
  [super layoutCellOverlays];
  self.titleOverlay.frame = CGRectInset(self.containerView.bounds, [[self class] textPadding].width, [[self class] textPadding].height);
  self.titleOverlay.height -= kTemplateCellHeaderHeight;
  self.titleOverlay.top = kTemplateCellHeaderHeight - 10.;
  
  if (self.node.collapsed)
  {
    self.headerOverlay.top = 10.;
    self.titleOverlay.hidden = YES;
  }
}

- (void)createSubviews;
{
  [super createSubviews];
  self.cellBackgroundColor = [UIColor colorForBackground];

  self.titleOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
  BSELF(TemplateCell);
  self.headerOverlay = [JMViewOverlay overlayWithFrame:CGRectMake(0., 3., self.containerView.bounds.size.width, kTemplateCellHeaderHeight) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    UIColor *typeIconBGColor = (blockSelf.tPlate.sendPreference == TemplateSendPreferenceComment) ? [UIColor colorWithHex:0xad49e1] : [UIColor colorWithHex:0x009cff];
    
    [typeIconBGColor set];

    NSString *headerTitle = [NSString stringWithFormat:@"%@", blockSelf.tPlate.title];
    [headerTitle drawAtPoint:CGPointMake(40., 5.) withFont:[UIFont skinFontWithName:kBundleFontPostSubtitleBold]];

    UIImage *disclosureIcon = [UIImage skinImageNamed:@"icons/disclosure-arrow" withColor:[UIColor colorForAccessoryButtons]];
    if (!blockSelf.isEditing)
    {
      [disclosureIcon drawAtPoint:CGPointMake(bounds.size.width - 20., 6.)];
    }
    
    NSString *iconName = (blockSelf.tPlate.sendPreference == TemplateSendPreferenceComment) ? @"comments-icon" : @"inbox-icon";
    UIImage *icon = [UIImage skinIcon:iconName withColor:[UIColor colorForBackground]];
    CGRect iconRect = CGRectMake(10., 3., 18., 18.);
    
    [typeIconBGColor set];
    [[UIBezierPath bezierPathWithRoundedRect:iconRect cornerRadius:4.] fill];
    
    [icon drawInRect:CGRectOffset(iconRect, 0., 0.)];
  }];
  self.headerOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self.containerView addOverlay:self.headerOverlay];
}

- (void)decorateCellBackground;
{
  [super decorateCellBackground];
  CGRect bounds = self.bounds;
  CGRect dottedDividerRect = CGRectCropToBottom(bounds, 2.);
  [UIView jm_drawHorizontalDottedLineInRect:dottedDividerRect lineWidth:1. lineColor:[UIColor colorForDottedDivider]];
}

- (void)drawRect:(CGRect)rect;
{
  [super drawRect:rect];
  // this allows bevel lines to appear even when the cell
  // enters edit mode (which shrinks the width of container view)
  [self decorateCellBackground];
}

@end
