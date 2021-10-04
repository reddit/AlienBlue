#import "ImgurUploadCell.h"
#import "ThumbOverlay.h"
#import "UIImage+JMActionMenuAssets.h"

@interface ImgurUploadNode()
@property (strong) ImgurUploadRecord *uploadRecord;
@end

@implementation ImgurUploadNode

- (id)initWithUploadRecord:(ImgurUploadRecord *)uploadRecord;
{
  JM_SUPER_INIT(init);
  self.uploadRecord = uploadRecord;
  return self;
}

+ (Class)cellClass;
{
  return UNIVERSAL(ImgurUploadCell);
}

@end


@interface ImgurUploadCell()
@property (readonly) ImgurUploadRecord *uploadRecord;
@property (strong) ThumbOverlay *thumbOverlay;
@property (strong) JMViewOverlay *titleOverlay;
@property (strong) JMViewOverlay *gearButtonOverlay;
@end

@implementation ImgurUploadCell

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
  return 60.;
}

- (ImgurUploadRecord *)uploadRecord;
{
  return [(ImgurUploadNode *)self.node uploadRecord];
}

- (void)createSubviews;
{
  [super createSubviews];
  
  self.thumbOverlay = [[ThumbOverlay alloc] initWithFrame:CGRectMake(13., 5., 50., 50.)];
  [self.containerView addOverlay:self.thumbOverlay];
  
  CGRect titleRect = CGRectCropToRight(self.containerView.bounds, self.containerView.bounds.size.width - 75.);
  BSELF(ImgurUploadCell);
  self.titleOverlay = [JMViewOverlay overlayWithFrame:titleRect drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    [@"Uploaded Image" jm_drawAtPoint:CGPointMake(0., 10.) withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.] color:[UIColor colorForHighlightedOptions]];
    [blockSelf.uploadRecord.originalImageUrl jm_drawAtPoint:CGPointMake(0., 32.) withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.] color:[UIColor colorForText]];
  }];
  self.titleOverlay.autoresizingMask = JMFlexibleSizeMask;
  [self.containerView addOverlay:self.titleOverlay];
  
  self.gearButtonOverlay = [JMViewOverlay overlayWithFrame:CGRectMake(0., 0., 60., self.containerView.bounds.size.height) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    CGRect dottedLineRect = CGRectInset(CGRectCropToLeft(bounds, 1.), 0., 10.);
    [UIView jm_drawVerticalDottedLineInRect:dottedLineRect lineWidth:0.5 lineColor:[UIColor colorForDottedDivider]];
    UIColor *iconColor = highlighted ? [UIColor colorForHighlightedOptions] : [UIColor colorWithWhite:0.5 alpha:0.5];
    UIImage *gearIcon = [UIImage actionMenuIconWithName:@"am-icon-global-settings" fillColor:iconColor];
    CGRect gearRect = CGRectOffset(bounds, -2, 0.);
    [gearIcon jm_drawCenteredInRect:gearRect];
  } onTap:^(CGPoint touchPoint) {
    [blockSelf didTapGearIcon];
  }];
  self.gearButtonOverlay.right = self.containerView.bounds.size.width;
  self.gearButtonOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
  [self.containerView addOverlay:self.gearButtonOverlay];
}

- (void)didTapGearIcon;
{
  ImgurUploadNode *uploadNode = JMCastOrNil(self.node, ImgurUploadNode);
  if (uploadNode.onGearIconTapAction)
  {
    uploadNode.onGearIconTapAction();
  }
}

- (void)updateWithNode:(JMOutlineNode *)node;
{
  [super updateWithNode:node];
  [self.thumbOverlay updateWithUrl:self.uploadRecord.originalImageUrl fallbackUrl:nil showRetinaVersion:YES];
}

- (void)decorateCellBackground;
{
  [[UIColor colorForBackground] setFill];
  [[UIBezierPath bezierPathWithRect:self.bounds] fill];
}

@end
