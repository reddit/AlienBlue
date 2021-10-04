//  REDDetailHeaderCell.m
//  RedditApp

#import "RedditApp/Detail/REDDetailHeaderCell.h"

#import "RedditApp/Detail/REDDetailViewController.h"
#import "RedditApp/Util/REDColor.h"
#import "Sections/Posts/Post.h"

static int const kMarginX = 15;
static int const kMarginTop = 12;
static int const kTopLabelHeight = 15;
static int const kSpacingAfterTopLabel = 8;
static int const kSpacingAfterTitle = 12;
static int const kBottomLabelHeight = 17;
static int const kMarginBottom = 7;
static int const kOpenWebsiteButtonFudgeX = 10;
static int const kOpenWebsiteButtonFudgeY = -10;

static int const kLabelFontSize = 12;
static int const kTitleFontSize = 16;

@interface REDDetailHeaderCell ()
// A weak reference, downcasted from self.node, is kept for convenience.
@property(nonatomic, weak) REDDetailHeaderNode *detailHeaderNode;
@property(nonatomic, strong) UILabel *topLabel;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *bottomLabel;
@property(nonatomic, strong) UIButton *openWebsiteButton;
@end

@implementation REDDetailHeaderCell

- (void)updateWithNode:(JMOutlineNode *)node {
  NSAssert([node isKindOfClass:[REDDetailHeaderNode class]], @"Wrong node type.");
  self.detailHeaderNode = (REDDetailHeaderNode *)node;
  Post *post = self.detailHeaderNode.post;

  if (!self.topLabel) {
    self.topLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.topLabel.backgroundColor = [REDColor whiteColor];
    self.topLabel.font = [UIFont systemFontOfSize:kLabelFontSize];
    [self.contentView addSubview:self.topLabel];
  }
  NSMutableAttributedString *topLabelText = [[NSMutableAttributedString alloc]
      initWithString:[NSString stringWithFormat:@"r/%@ \u2022 %@", post.subreddit, post.domain]];
  NSDictionary *subredditColor = @{NSForegroundColorAttributeName : [REDColor blueColor]};
  [topLabelText setAttributes:subredditColor range:NSMakeRange(0, post.subreddit.length + 2)];
  NSDictionary *interpunctColor = @{NSForegroundColorAttributeName : [REDColor neutralColor]};
  [topLabelText setAttributes:interpunctColor range:NSMakeRange(post.subreddit.length + 3, 1)];
  NSDictionary *domainColor = @{NSForegroundColorAttributeName : [REDColor greyColor]};
  [topLabelText setAttributes:domainColor
                        range:NSMakeRange(post.subreddit.length + 5, post.domain.length)];
  self.topLabel.attributedText = topLabelText;

  if (!self.titleLabel) {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.backgroundColor = [REDColor whiteColor];
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont systemFontOfSize:kTitleFontSize weight:UIFontWeightLight];
    [self.contentView addSubview:self.titleLabel];
  }
  self.titleLabel.text = post.title;

  if (!self.bottomLabel) {
    self.bottomLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.bottomLabel.backgroundColor = [REDColor whiteColor];
    self.bottomLabel.textColor = [REDColor greyColor];
    self.bottomLabel.font = [UIFont systemFontOfSize:kLabelFontSize];
    [self.contentView addSubview:self.bottomLabel];
  }
  self.bottomLabel.text = [NSString stringWithFormat:@"%@ \u2022 %@", post.author, post.timeAgo];

  if (!self.openWebsiteButton && post.url.length > 0) {
    // TODO(sharkey): Make this open a website.
    self.openWebsiteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.openWebsiteButton setImage:[UIImage imageNamed:@"btn_linkout"]
                            forState:UIControlStateNormal];
    [self.openWebsiteButton addTarget:self
                               action:@selector(didPressOpenWebsiteButton)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.openWebsiteButton];
    [self.detailHeaderNode.viewController
        prepareWebViewControllerWithURL:[NSURL URLWithString:post.url]
                                  title:post.title];
  }

  [self setCellBackgroundColor:[REDColor whiteColor]];

  [super updateWithNode:node];
}

#pragma mark - sizing and layout

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView {
  NSAssert([node isKindOfClass:[REDDetailHeaderNode class]], @"Wrong node type.");
  REDDetailHeaderNode *detailHeaderNode = (REDDetailHeaderNode *)node;
  NSDictionary *attributes =
      @{NSFontAttributeName : [UIFont systemFontOfSize:kTitleFontSize weight:UIFontWeightLight]};
  CGRect titleBounds = [detailHeaderNode.post.title
      boundingRectWithSize:CGSizeMake(tableView.bounds.size.width - 2 * kMarginX, FLT_MAX)
                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                attributes:attributes
                   context:nil];
  return ceilf(kMarginTop + kTopLabelHeight + kSpacingAfterTopLabel + titleBounds.size.height +
               kSpacingAfterTitle + kBottomLabelHeight + kMarginBottom);
}

- (void)layoutCellOverlays {
  self.topLabel.frame =
      CGRectMake(kMarginX, kMarginTop, self.bounds.size.width - 2 * kMarginX, kTopLabelHeight);

  self.titleLabel.frame = CGRectMake(kMarginX, kMarginTop + kTopLabelHeight + kSpacingAfterTopLabel,
                                     self.bounds.size.width - 2 * kMarginX, 0);
  [self.titleLabel sizeToFit];

  self.bottomLabel.frame =
      CGRectMake(kMarginX, CGRectGetMaxY(self.titleLabel.frame) + kSpacingAfterTitle,
                 self.bounds.size.width - 2 * kMarginX, kBottomLabelHeight);

  [self.openWebsiteButton sizeToFit];
  CGRect buttomFrame = self.openWebsiteButton.frame;
  buttomFrame.origin = CGPointMake(
      self.bounds.size.width - kMarginX - buttomFrame.size.width + kOpenWebsiteButtonFudgeX,
      kMarginTop + kOpenWebsiteButtonFudgeY);
  self.openWebsiteButton.frame = buttomFrame;
}

#pragma mark - private

- (void)didPressOpenWebsiteButton {
  [self.detailHeaderNode.viewController presentWebViewController];
}

@end

#pragma mark - REDDetailHeaderNode

@implementation REDDetailHeaderNode

- (instancetype)initWithPost:(Post *)post
              viewController:(__weak REDDetailViewController *)viewController {
  if (self = [super init]) {
    self.post = post;
    self.viewController = viewController;
  }
  return self;
}

+ (Class)cellClass {
  return [REDDetailHeaderCell class];
}

@end
