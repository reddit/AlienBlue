//  REDPostCommentsBar.m
//  RedditApp

#import "RedditApp/Posts/REDPostCommentsBar.h"

#import "RedditApp/Util/REDColor.h"
#import "Sections/Posts/Post.h"

static const int kHeight = 50;
static const int kLeftMargin = 15;
static const int kSpacingX = 2;
static const int kFontSize = 11;
static const int kSeperatorDistanceFromRight = 110;
static const int kSeperatorWidth = 1;
static const int kSeperatorVerticalMargin = 12;

@interface REDPostCommentsBar ()

@property(nonatomic, strong) Post *post;
@property(nonatomic, strong) UIImageView *commentsIcon;
@property(nonatomic, strong) UILabel *commentCountLabel;
@property(nonatomic, strong) UIImageView *arrowIcon;
@property(nonatomic, strong) UIView *separator;
@property(nonatomic, strong) UILabel *scoreLabel;
@property(nonatomic, strong) UIImage *voteUpButtonUnselectedImage;
@property(nonatomic, strong) UIImage *voteUpButtonSelectedImage;
@property(nonatomic, strong) UIImage *voteDownButtonUnselectedImage;
@property(nonatomic, strong) UIImage *voteDownButtonSelectedImage;
@property(nonatomic, strong) UIButton *voteUpButton;
@property(nonatomic, strong) UIButton *voteDownButton;

@end

@implementation REDPostCommentsBar

+ (CGFloat)height {
  return kHeight;
}

- (instancetype)initWithPost:(Post *)post {
  self = [super initWithFrame:CGRectZero];
  if (self) {
    self.post = post;

    self.backgroundColor = [REDColor whiteColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    self.commentsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_comment"]];
    [self.commentsIcon sizeToFit];
    [self addSubview:self.commentsIcon];

    self.commentCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.commentCountLabel.font = [UIFont systemFontOfSize:kFontSize];
    self.commentCountLabel.textColor = [REDColor greyColor];
    NSString *formatString = post.numComments == 1 ? @"%ld comment" : @"%ld comments";
    self.commentCountLabel.text = [NSString stringWithFormat:formatString, post.numComments];
    [self.commentCountLabel sizeToFit];
    [self addSubview:self.commentCountLabel];

    self.arrowIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ind_expandarrow"]];
    [self.arrowIcon sizeToFit];
    [self addSubview:self.arrowIcon];

    self.separator = [[UIView alloc] initWithFrame:CGRectZero];
    self.separator.backgroundColor = [REDColor paleGreyColor];
    [self addSubview:self.separator];

    self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.scoreLabel.font = [UIFont systemFontOfSize:kFontSize];
    self.scoreLabel.textColor = [REDColor greyColor];
    [self addSubview:self.scoreLabel];

    self.voteUpButtonUnselectedImage = [UIImage imageNamed:@"btn_upvote"];
    self.voteUpButtonSelectedImage = [UIImage imageNamed:@"btn_upvote_dn"];
    self.voteDownButtonUnselectedImage = [UIImage imageNamed:@"btn_downvote"];
    self.voteDownButtonSelectedImage = [UIImage imageNamed:@"btn_downvote_dn"];

    self.voteUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.voteUpButton addTarget:self
                          action:@selector(didPressVoteUpButton)
                forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.voteUpButton];

    self.voteDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.voteDownButton addTarget:self
                            action:@selector(didPressVoteDownButton)
                  forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.voteDownButton];

    [self updateView];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [self initWithPost:nil];
  NSAssert(NO, @"Invalid initializer.");
  return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [self initWithPost:nil];
  NSAssert(NO, @"Invalid initializer.");
  return nil;
}

#pragma mark - UIView

- (CGSize)sizeThatFits:(CGSize)size {
  return CGSizeMake(size.width, kHeight);
}

- (void)layoutSubviews {
  // Layout the left side, left to right.
  CGRect commentsIconFrame = self.commentsIcon.frame;
  commentsIconFrame.origin =
      CGPointMake(kLeftMargin, floorf((kHeight - commentsIconFrame.size.height) / 2));
  self.commentsIcon.frame = commentsIconFrame;

  CGRect commentCountLabelFrame = self.commentCountLabel.frame;
  commentCountLabelFrame.origin =
      CGPointMake(CGRectGetMaxX(commentsIconFrame) + kSpacingX,
                  floorf((kHeight - commentCountLabelFrame.size.height) / 2));
  self.commentCountLabel.frame = commentCountLabelFrame;

  CGRect arrowIconFrame = self.arrowIcon.frame;
  arrowIconFrame.origin = CGPointMake(CGRectGetMaxX(commentCountLabelFrame) + kSpacingX,
                                      floorf((kHeight - arrowIconFrame.size.height) / 2));
  self.arrowIcon.frame = arrowIconFrame;

  // Layout the right side, right to left.
  CGRect voteDownFrame = self.voteDownButton.frame;
  voteDownFrame.origin = CGPointMake(self.frame.size.width - voteDownFrame.size.width,
                                     floorf((kHeight - voteDownFrame.size.height) / 2));
  self.voteDownButton.frame = voteDownFrame;

  CGRect voteUpFrame = self.voteUpButton.frame;
  voteUpFrame.origin = CGPointMake(CGRectGetMinX(voteDownFrame) - voteUpFrame.size.width,
                                   floorf((kHeight - voteUpFrame.size.height) / 2));
  self.voteUpButton.frame = voteUpFrame;

  CGRect scoreLabelFrame = self.scoreLabel.frame;
  scoreLabelFrame.origin = CGPointMake(CGRectGetMinX(voteUpFrame) - scoreLabelFrame.size.width,
                                       floorf((kHeight - scoreLabelFrame.size.height) / 2));
  self.scoreLabel.frame = scoreLabelFrame;

  self.separator.frame =
      CGRectMake(self.frame.size.width - kSeperatorDistanceFromRight, kSeperatorVerticalMargin,
                 kSeperatorWidth, self.frame.size.height - 2 * kSeperatorVerticalMargin);
}

// Pass through hit detection so that you can scroll the detail view that this lies on top of.
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  UIView *hitView = [super hitTest:point withEvent:event];
  if (hitView == self) return nil;
  return hitView;
}

#pragma mark - private

- (void)updateView {
  self.scoreLabel.text = [NSString stringWithFormat:@"%ld", self.post.score];
  [self.scoreLabel sizeToFit];

  UIImage *voteUpImage =
      (self.post.voteState == VoteStateUpvoted ? self.voteUpButtonSelectedImage
                                               : self.voteUpButtonUnselectedImage);
  [self.voteUpButton setImage:voteUpImage forState:UIControlStateNormal];
  [self.voteUpButton sizeToFit];

  UIImage *voteDownImage =
      (self.post.voteState == VoteStateDownvoted ? self.voteDownButtonSelectedImage
                                                 : self.voteDownButtonUnselectedImage);
  [self.voteDownButton setImage:voteDownImage forState:UIControlStateNormal];
  [self.voteDownButton sizeToFit];
}

- (void)didPressVoteUpButton {
  [self.post upvote];
  [self updateView];
}

- (void)didPressVoteDownButton {
  [self.post downvote];
  [self updateView];
}

@end
