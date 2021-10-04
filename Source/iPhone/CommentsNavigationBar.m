#import "CommentsNavigationBar.h"

@interface CommentsNavigationBar()
@property (strong) UIView *headerBarContainerView;
@property (strong) UIView *headerBarView;
@end

@implementation CommentsNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
  JM_SUPER_INIT(initWithFrame:frame);
  self.headerBarContainerView = [UIView new];
  [self addSubview:self.headerBarContainerView];
  [self.headerBarContainerView jm_sendToBack];
  return self;
}

- (void)layoutSubviews;
{
  [super layoutSubviews];

  self.headerBarContainerView.top = self.defaultBarHeight - 10.;
//  CGFloat headerBarOpacity = (self.height - self.headerBarContainerView.top)/(self.maximumBarHeight - self.height);
//  self.headerBarContainerView.alpha = headerBarOpacity;
}

- (void)setLegacyCommentHeaderBar:(UIView *)legacyCommentHeaderBar;
{
  [self.headerBarView removeFromSuperview];
  self.headerBarView = legacyCommentHeaderBar;
  self.headerBarView.autoresizingMask = JMFlexibleSizeMask;
  self.headerBarView.height = 40.;
  
  self.headerBarContainerView.size = self.headerBarView.size;
  [self.headerBarContainerView addSubview:self.headerBarView];
  self.headerBarContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self setNeedsLayout];
}

- (CGFloat)maximumBarHeight;
{
  return self.defaultBarHeight + 30.;
}

@end
