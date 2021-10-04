#import "ABActionMenuWatchedPostEditPanel.h"
#import "ABActionMenuThemeConfiguration.h"
#import "ABActionMenuWatchedPostStatistics.h"
#import "OverlayViewContainer.h"

@interface ABActionMenuWatchedPostEditPanel()
@property (strong) UILabel *watchingPostTitleLabel;
@property (readonly) ABActionMenuPostRecord *currentlyWatchedPost;
@property (strong) ABActionMenuPostRecord *selectedWatchedPost;
@property (strong) JMViewOverlay *postListOverlay;
@property (readonly) BOOL hasNoRecentVisitedPosts;
@property NSInteger pressingOnIndex;
@end

@implementation ABActionMenuWatchedPostEditPanel

- (void)createSubviews;
{
  [super createSubviews];
  
  self.pressingOnIndex = -1;
  
  UILabel *panelTitleLabel = [UILabel new];
  panelTitleLabel.text = @"Which recently visited post would you like to watch?";
  if (self.hasNoRecentVisitedPosts)
  {
    panelTitleLabel.text = @"Please visit a thread that you'd like to monitor before returning.";
  }
  panelTitleLabel.numberOfLines = 2;
  panelTitleLabel.size = CGSizeMake(240., 40.);
  panelTitleLabel.font = self.themeConfiguration.fontForCustomEditPanelText;
  panelTitleLabel.textAlignment = NSTextAlignmentCenter;
  panelTitleLabel.autoresizingMask = JMFlexibleHorizontalMarginMask;
  panelTitleLabel.textColor = self.themeConfiguration.titleColorForEditingLabel;
  [self addSubview:panelTitleLabel];
  [panelTitleLabel centerHorizontallyInSuperView];
  
  #define kWatchPostPanelRowHeight 50.
  OverlayViewContainer *overlayContainer = [[OverlayViewContainer alloc] initWithSize:CGSizeMake(self.bounds.size.width - 40., kWatchPostPanelRowHeight * 3)];
  overlayContainer.backgroundColor = [UIColor clearColor];
  overlayContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self addSubview:overlayContainer];
  [overlayContainer centerHorizontallyInSuperView];
  overlayContainer.top = panelTitleLabel.bottom + 5.;
  
  BSELF(ABActionMenuWatchedPostEditPanel);
  self.postListOverlay = [JMViewOverlay overlayWithFrame:overlayContainer.bounds drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    
//    if ([ABActionMenuPostRecord recentlyVisitedPostRecords].count == 0.)
//    {
//      NSString *title;
//      if (blockSelf.currentlyWatchedPost != nil)
//      {
//        title = [NSString stringWithFormat:@"Watching : %@", blockSelf.currentlyWatchedPost.postTitle];
//      }
//      else
//      {
//        title = @"Not currently watching any posts";
//      }
//      title = [title stringByAppendingString:@"\n\nVisit a thread that you'd like to monitor before returning here."];
//      [UIView jm_drawHorizontalDottedLineInRect:CGRectCropToTop(bounds, 1.) lineWidth:0.5 lineColor:[UIColor colorForDottedDivider]];
//      [title jm_drawVerticallyCenteredInRect:bounds withFont:blockSelf.themeConfiguration.fontForCustomEditPanelText color:blockSelf.themeConfiguration.titleColorForEditingLabel horizontalAlignment:NSTextAlignmentCenter];
//      return;
//    }
    
    for (NSUInteger i = 0; i < [ABActionMenuPostRecord recentlyVisitedPostRecords].count; i++)
    {
      ABActionMenuPostRecord *record = [[ABActionMenuPostRecord recentlyVisitedPostRecords] jm_safeObjectAtIndex:i];
      CGFloat yOffset = i * kWatchPostPanelRowHeight;
      CGRect listItemRect = CGRectMake(0., yOffset, bounds.size.width, kWatchPostPanelRowHeight);
      CGRect selectionIndicatorRect = CGRectCenterWithSize(CGRectCropToLeft(listItemRect, 50.), CGSizeMake(30., 30.));
      BOOL highlightRow = highlighted && blockSelf.pressingOnIndex == i;
      
      UIBezierPath *selectionPath = [UIBezierPath bezierPathWithOvalInRect:selectionIndicatorRect];
      
      [blockSelf.themeConfiguration.colorForDisabledIcon setStroke];
      [selectionPath stroke];
      
      if ([record.votableElementIdent jm_matches:blockSelf.currentlyWatchedPost.votableElementIdent] || highlightRow)
      {
        [blockSelf.themeConfiguration.buttonBackgroundColor setFill];
        [[UIBezierPath bezierPathWithOvalInRect:CGRectInset(selectionIndicatorRect, 5., 5.)] fill];
      }
      
      CGRect titleRect = CGRectInset(CGRectCropToRight(listItemRect, bounds.size.width - 50.), 0., 5.);
      [record.postTitle jm_drawVerticallyCenteredInRect:titleRect withFont:blockSelf.themeConfiguration.fontForCustomEditPanelSmallText color:blockSelf.themeConfiguration.titleColorForEditingLabel horizontalAlignment:NSTextAlignmentLeft];
      
    }
  } onTap:^(CGPoint touchPoint) {
    NSUInteger selectedIndex = floor(touchPoint.y / kWatchPostPanelRowHeight);
    ABActionMenuPostRecord *recordAtLocation = [[ABActionMenuPostRecord recentlyVisitedPostRecords] jm_safeObjectAtIndex:selectedIndex];
    if (recordAtLocation)
    {
      blockSelf.selectedWatchedPost = recordAtLocation;
    }
  }];
  self.postListOverlay.onPress = ^(CGPoint pressLocation){
    blockSelf.pressingOnIndex = floor(pressLocation.y / kWatchPostPanelRowHeight);
  };
  self.postListOverlay.redrawsOnTouch = YES;
  self.postListOverlay.autoresizingMask = JMFlexibleSizeMask;
  [overlayContainer addOverlay:self.postListOverlay];
}

- (BOOL)hasNoRecentVisitedPosts;
{
  return [ABActionMenuPostRecord recentlyVisitedPostRecords].count == 0;
}

- (ABActionMenuPostRecord *)currentlyWatchedPost;
{
  return self.selectedWatchedPost ?: (ABActionMenuPostRecord *)self.userInfo;
}

- (CGFloat)recommendedHeight;
{
  return self.hasNoRecentVisitedPosts ? 65. : [ABActionMenuPostRecord recentlyVisitedPostRecords].count * kWatchPostPanelRowHeight + 65.;
}

- (NSObject<NSCoding> *)generateUpdatedUserInfo;
{
  return self.currentlyWatchedPost;
}

@end
