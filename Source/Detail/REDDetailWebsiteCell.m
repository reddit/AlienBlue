//  REDDetailWebsiteCell.m
//  RedditApp

#import "RedditApp/Detail/REDDetailWebsiteCell.h"

#import "JMUICore/Extensions/UIKit/UIImageView+JMRemote.h"
#import "RedditApp/Detail/REDDetailViewController.h"
#import "RedditApp/Util/REDColor.h"

static const int kThumbnailHeight = 180;
static const int kImageMargin = 10;
static const int kDomainMargin = 10;
static const int kDomainHeight = 40;
static int const kDomainLabelFontSize = 12;

@interface REDDetailWebsiteCell ()

// A weak reference, downcasted from self.node, is kept for convenience.
@property(nonatomic, weak) REDDetailWebsiteNode *detailWebsiteNode;
@property(nonatomic, strong) UIImageView *thumbnailView;
@property(nonatomic, strong) UIView *domainBackground;
@property(nonatomic, strong) UILabel *domainLabel;
@property(nonatomic, strong) UIImageView *openIconView;

@end

@implementation REDDetailWebsiteCell

- (void)updateWithNode:(JMOutlineNode *)node {
  NSAssert([node isKindOfClass:[REDDetailWebsiteNode class]], @"Wrong node type.");
  self.detailWebsiteNode = (REDDetailWebsiteNode *)node;

  [self setCellBackgroundColor:[REDColor whiteColor]];
  self.selectionStyle = UITableViewCellSelectionStyleNone;

  if (!self.thumbnailView) {
    self.thumbnailView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    self.thumbnailView.clipsToBounds = YES;
    [self.contentView addSubview:self.thumbnailView];
  }
  [self.thumbnailView jm_setRemoteImageWithURL:self.detailWebsiteNode.thumbnailUrl
                                   placeholder:nil
                                     decorator:nil
                                    onProgress:nil
                                    onComplete:nil
                                     onFailure:nil];

  if (!self.domainBackground) {
    self.domainBackground = [[UIView alloc] initWithFrame:CGRectZero];
    self.domainBackground.backgroundColor = [REDColor whiteColor];
    self.domainBackground.layer.borderColor = [REDColor paleGreyColor].CGColor;
    self.domainBackground.layer.borderWidth = 1.0f;
    [self.contentView addSubview:self.domainBackground];
  }

  if (!self.domainLabel) {
    self.domainLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.domainLabel.backgroundColor = [REDColor whiteColor];
    self.domainLabel.textColor = [REDColor blueColor];
    self.domainLabel.font = [UIFont systemFontOfSize:kDomainLabelFontSize];
    [self.contentView addSubview:self.domainLabel];
  }
  self.domainLabel.text = self.detailWebsiteNode.webDomain;

  if (!self.openIconView) {
    self.openIconView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.openIconView.image = [UIImage imageNamed:@"btn_linkout"];
    [self.contentView addSubview:self.openIconView];
  }

  [self.detailWebsiteNode.viewController
      prepareWebViewControllerWithURL:self.detailWebsiteNode.URL
                                title:self.detailWebsiteNode.title];

  [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                                     action:@selector(userTappedCell)]];

  [super updateWithNode:node];
}

#pragma mark - sizing and layout

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView {
  NSAssert([node isKindOfClass:[REDDetailWebsiteNode class]], @"Wrong node type.");
  REDDetailWebsiteNode *detailWebsiteNode = (REDDetailWebsiteNode *)node;
  return (detailWebsiteNode.thumbnailUrl ? kThumbnailHeight : kDomainHeight) + 2 * kImageMargin;
}

- (void)layoutCellOverlays {
  self.thumbnailView.frame =
      CGRectMake(kImageMargin, kImageMargin, self.bounds.size.width - 2 * kImageMargin,
                 self.bounds.size.height - 2 * kImageMargin);

  CGRect domainBackgroundFrame =
      CGRectMake(kImageMargin, self.bounds.size.height - kImageMargin - kDomainHeight,
                 self.bounds.size.width - 2 * kImageMargin, kDomainHeight);
  self.domainBackground.frame = domainBackgroundFrame;

  CGSize domainTextSize = [self.domainLabel sizeThatFits:self.bounds.size];
  CGFloat textY = floorf(domainBackgroundFrame.origin.y + domainBackgroundFrame.size.height -
                         kDomainHeight / 2.0 - domainTextSize.height / 2.0);
  self.domainLabel.frame =
      CGRectMake(kImageMargin + kDomainMargin, textY, domainTextSize.width, domainTextSize.height);

  CGSize openIconSize = [self.openIconView sizeThatFits:self.bounds.size];
  CGFloat iconX = CGRectGetMaxX(domainBackgroundFrame) - openIconSize.width;
  CGFloat iconY = floorf(domainBackgroundFrame.origin.y + domainBackgroundFrame.size.height -
                         kDomainHeight / 2.0 - openIconSize.height / 2.0);
  self.openIconView.frame = CGRectMake(iconX, iconY, openIconSize.width, openIconSize.height);
}

#pragma mark - private

- (void)userTappedCell {
  [self.detailWebsiteNode.viewController presentWebViewController];
}

@end

#pragma mark - REDDetailWebsiteNode

@implementation REDDetailWebsiteNode

- (instancetype)initWithURL:(NSURL *)URL
                      title:(NSString *)title
                  webDomain:(NSString *)webDomain
               thumbnailUrl:(NSURL *)thumbnailUrl
              thumbnailSize:(CGSize)thumbnailSize
             viewController:(__weak REDDetailViewController *)viewController {
  if (self = [super init]) {
    _URL = URL;
    _title = title;
    _webDomain = webDomain;
    _thumbnailUrl = thumbnailUrl;
    _thumbnailSize = thumbnailSize;
    _viewController = viewController;
  }
  return self;
}

+ (Class)cellClass {
  return [REDDetailWebsiteCell class];
}

@end
