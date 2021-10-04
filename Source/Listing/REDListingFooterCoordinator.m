//  REDListingFooterCoordinator.m
//  RedditApp

#import "RedditApp/Listing/REDListingFooterCoordinator.h"

#import "Helpers/Resources.h"
#import "MKStoreKit/MKStoreManager.h"
#import "Sections/Posts/LoadMoreSliderTrack.h"
#import "Sections/Posts/PostsShowMoreButton.h"
#import "useful-bits/UsefulBits/Source/DecoratedView.h"

#define kPrefKeySliderTrainingComplete @"kPrefKeySliderTrainingComplete"

#define kDragOffsetLoadMoreMinThreshold 30.
#define kDragOffsetLoadMoreMaxThreshold 80.
#define kDragOffsetLoadMoreTrigger 70.

@interface REDListingFooterCoordinator ()
@property(nonatomic, strong) UIView *view;
@property CGFloat lastDragOffset;
@property BOOL dragTriggeredLoadMore;
- (BOOL)needsSliderTraining;
- (void)setSliderTrainingComplete;
@end

@implementation REDListingFooterCoordinator

@synthesize view = view_;

- (id)initWithDelegate:(id<REDPostsFooterDelegate>)delegate;
{
  if ((self = [super init])) {
    self.delegate = delegate;
  }
  return self;
}

- (CGFloat)heightForFooter {
  float height = 96;

  if ([self needsSliderTraining]) height += 14.;

  return height;
}

- (void)loadView {
  self.view = [[DecoratedView alloc]
      initWithFrame:CGRectMake(0, 0, self.delegate.tableView.bounds.size.width,
                               [self heightForFooter])];
  self.view.backgroundColor = [UIColor clearColor];
  //    self.view.decorator = ^(UIView *view, CGRect dirtyRect, CGContextRef context) {
  //        [view drawCGNoise];
  //    };

  NSString *leftTitle = [MKStoreManager isProUpgraded] ? @"hide read" : @"hide read (pro)";
  NSString *rightTitle = [MKStoreManager isProUpgraded] ? @"hide all" : @"hide all (pro)";

  self.sliderView = [JMSlider sliderWithFrame:CGRectMake(0, 0, 300., 90.)
                                  centerTitle:@"more"
                                    leftTitle:leftTitle
                                   rightTitle:rightTitle
                                     delegate:self];
  self.sliderView.autoresizingMask =
      UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
      UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  [self.view addSubview:self.sliderView];
  [self.sliderView centerInSuperView];

  if ([self needsSliderTraining] && self.delegate.nodeCount > 0) {
    UIImageView *trainingImageView =
        [[UIImageView alloc] initWithImage:[UIImage skinImageNamed:@"instructions/hide-slide.png"]];
    [self.view addSubview:trainingImageView];
    self.sliderView.top -= 18.;
    [trainingImageView centerHorizontallyBelow:self.sliderView padding:-10.];
    trainingImageView.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  }

  self.pullLabel = [[UILabel alloc] initWithFrame:self.sliderView.frame];
  self.pullLabel.alpha = 0.;
  self.pullLabel.height = 20.;
  self.pullLabel.autoresizingMask = self.sliderView.autoresizingMask;
  self.pullLabel.center = self.sliderView.center;
  self.pullLabel.top += 40.;
  self.pullLabel.textAlignment = UITextAlignmentCenter;
  self.pullLabel.backgroundColor = [UIColor clearColor];
  self.pullLabel.font = [UIFont boldSystemFontOfSize:12.];
  self.pullLabel.textColor = [UIColor darkGrayColor];
  [self.view addSubview:self.pullLabel];
}

- (UIView *)view;
{
  if (!view_) {
    [self loadView];
  }
  return view_;
}

#pragma mark -
#pragma mark - Slider training

- (BOOL)needsSliderTraining;
{
  if (![[NSUserDefaults standardUserDefaults] objectForKey:kPrefKeySliderTrainingComplete])
    return YES;
  else
    return NO;
}

- (void)setSliderTrainingComplete;
{
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:YES]
                                            forKey:kPrefKeySliderTrainingComplete];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark - JMSlider Delegate

- (void)slider:(JMSlider *)slider didHighlight:(BOOL)highlighted;
{ self.delegate.tableView.canCancelContentTouches = !highlighted; }

- (void)slider:(JMSlider *)slider didSelect:(JMSliderSelection)selection;
{
  [self setSliderTrainingComplete];
  switch (selection) {
    case JMSliderSelectionLeft:
      [self.delegate hideRead];
      break;

    case JMSliderSelectionCenter:
      [self.delegate loadMore];
      break;

    case JMSliderSelectionRight:
      [self.delegate hideAll];
      break;

    default:
      break;
  }
}

- (JMCenterView *)sliderCenterViewForSlider:(JMSlider *)slider;
{
  PostsShowMoreButton *centerView =
      [[PostsShowMoreButton alloc] initForSlider:slider withTitle:@"more"];
  centerView.showGrips = YES;
  return centerView;
}

- (JMSliderTrack *)sliderTrackViewForSlider:(JMSlider *)slider;
{
  LoadMoreSliderTrack *sliderTrack =
      [[LoadMoreSliderTrack alloc] initWithFrame:slider.bounds forSlider:slider];
  return sliderTrack;
}

- (void)setShowLoadingIndicator:(BOOL)loading;
{
  self.isShowingLoadingIndicator = loading;
  [self.sliderView setLoading:loading];
}

- (void)handleDragRelease;
{
  if (self.lastDragOffset > kDragOffsetLoadMoreTrigger) {
    self.pullLabel.alpha = 0.;
    self.sliderView.alpha = 1.;
    [self.delegate loadMore];
  }
}

- (void)handleScrolling;
{
  if (self.delegate.tableView.contentSize.height < 400.) return;

  CGFloat dragPastTable = self.delegate.tableView.contentOffset.y + self.delegate.tableView.height -
                          self.delegate.tableView.contentSize.height;
  CGFloat dragOffset = JM_LIMIT(0., kDragOffsetLoadMoreMaxThreshold, dragPastTable);

  // bail early for unnecessary processing
  if (self.lastDragOffset == dragOffset) return;

  if (dragOffset > self.lastDragOffset && dragOffset < kDragOffsetLoadMoreMinThreshold) return;

  self.lastDragOffset = dragOffset;

  CGFloat moreButtonOpacity =
      JM_RANGE(1., 0., (dragOffset - kDragOffsetLoadMoreMinThreshold) /
                           (kDragOffsetLoadMoreMaxThreshold - kDragOffsetLoadMoreMinThreshold));
  self.sliderView.alpha = moreButtonOpacity;
  self.pullLabel.alpha = 1. - moreButtonOpacity;

  if (dragOffset > kDragOffsetLoadMoreTrigger)
    self.pullLabel.text = @"Release to Load More";
  else
    self.pullLabel.text = @"Pull to Load More";
}

- (void)disallowHorizontalSliderDragging;
{
  PostsShowMoreButton *showMoreButton =
      (PostsShowMoreButton *)[self.sliderView jm_firstSubviewOfClass:[PostsShowMoreButton class]];
  showMoreButton.showGrips = NO;
  [showMoreButton setLoading:YES];
  [showMoreButton setNeedsDisplay];
  self.sliderView.shouldDisallowSliding = YES;
}

@end
