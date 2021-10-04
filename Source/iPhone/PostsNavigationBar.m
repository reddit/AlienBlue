#import "PostsNavigationBar.h"
#import "Announcement.h"
#import "AnnouncementViewController.h"

@interface PostsNavigationBar()
@property (strong) UIView *searchHeaderBarContainerView;
@property (strong) UIView *searchHeaderBarView;
@property (readonly) BOOL shouldDecorateForAnnouncementBanner;
@property (strong) UIButton *announcementButton;
@end

@implementation PostsNavigationBar

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kAnnouncementReceivedNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kAnnouncementMarkedReadNotification object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
  JM_SUPER_INIT(initWithFrame:frame);
  
  self.searchHeaderBarContainerView = [UIView new];
  [self addSubview:self.searchHeaderBarContainerView];
  [self.searchHeaderBarContainerView jm_sendToBack];
  
  self.announcementButton = [UIButton new];
  UIImage *announcementButtonImage = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    CGRect buttonRect = CGRectInset(bounds, 0., 4.);
    [[UIColor skinColorForConstructive] setFill];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:buttonRect cornerRadius:(buttonRect.size.height / 2.)];
    [path fill];
    [@"Announcement" jm_drawVerticallyCenteredInRect:buttonRect withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.] color:[UIColor whiteColor] horizontalAlignment:NSTextAlignmentCenter];
  } withSize:CGSizeMake(120., 30.)];
  self.announcementButton.size = announcementButtonImage.size;
  [self.announcementButton setImage:announcementButtonImage forState:UIControlStateNormal];
  [self addSubview:self.announcementButton];
  [self.announcementButton centerInSuperView];
  self.announcementButton.alpha = 0.;
  [self.announcementButton addTarget:self action:@selector(userDidTapAnnouncementButton) forControlEvents:UIControlEventTouchUpInside];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(announcementReceived) name:kAnnouncementReceivedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(announcementMarkedAsRead) name:kAnnouncementMarkedReadNotification object:nil];

  return self;
}

- (void)layoutSubviews;
{
  [super layoutSubviews];
  
  CGFloat searchOpacity = (self.height - self.searchHeaderBarContainerView.top)/(self.maximumBarHeight - self.height);
  self.searchHeaderBarContainerView.alpha = searchOpacity;
  
  [self.announcementButton centerHorizontallyInSuperView];
  self.announcementButton.centerY = self.recommendedVerticalCenterForBarItems;
  [self.announcementButton jm_adjustToPixelBoundaries];
}

- (void)setSearchHeaderBar:(UIView *)searchHeaderBarView;
{
  [self.searchHeaderBarView removeFromSuperview];
  self.searchHeaderBarView = searchHeaderBarView;
  self.searchHeaderBarView.autoresizingMask = JMFlexibleSizeMask;
  
  self.searchHeaderBarContainerView.size = self.searchHeaderBarView.size;
  [self.searchHeaderBarContainerView addSubview:self.searchHeaderBarView];
  self.searchHeaderBarContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  self.searchHeaderBarContainerView.top = self.defaultBarHeight - 5.;
}

- (CGFloat)maximumBarHeight;
{
  return self.defaultBarHeight + 50.;
}

- (BOOL)shouldDecorateForAnnouncementBanner;
{
  Announcement *latestAnnouncement = [Announcement latestAnnouncement];
  return latestAnnouncement && latestAnnouncement.shouldShow && latestAnnouncement.showsBanner;
}

- (void)updateAnnouncementButtonAnimated:(BOOL)animated;
{
  BOOL showAnnouncementBanner = self.shouldDecorateForAnnouncementBanner;

  BSELF(PostsNavigationBar);
  [UIView jm_transition:self animations:^{
    blockSelf.titleLabel.alpha = showAnnouncementBanner ? 0. : 1.;
    blockSelf.announcementButton.alpha = showAnnouncementBanner ? 1. : 0.;
  } completion:nil animated:animated];
}

- (void)announcementReceived;
{
  [self updateAnnouncementButtonAnimated:YES];
}

- (void)announcementMarkedAsRead
{
  [self updateAnnouncementButtonAnimated:YES];
}

- (void)userDidTapAnnouncementButton;
{
  [AnnouncementViewController showLatest];
}

@end
