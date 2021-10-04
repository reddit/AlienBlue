//  REDDetailVideoCell.m
//  RedditApp

#import "RedditApp/Detail/REDDetailVideoCell.h"

#import "JMUICore/Extensions/UIKit/UIImageView+JMRemote.h"
#import "RedditApp/REDWebViewController.h"

@interface REDDetailVideoCell ()<UIWebViewDelegate>

// A weak reference, downcasted from self.node, is kept for convenience.
@property(nonatomic, weak) REDDetailVideoNode *detailVideoNode;

// These are used for inline videos.
@property(nonatomic, assign) bool useInlineWebView;
@property(nonatomic, strong) UIWebView *videoWebView;

// These are used for everything else.
@property(nonatomic, strong) UIImageView *thumbnailView;
@property(nonatomic, strong) UIImageView *playIconView;

@end

@implementation REDDetailVideoCell

- (void)updateWithNode:(JMOutlineNode *)node {
  NSAssert([node isKindOfClass:[REDDetailVideoNode class]], @"Wrong node type.");
  self.detailVideoNode = (REDDetailVideoNode *)node;

  self.useInlineWebView = NO;

  NSString *youTubeId = [self _extractYouTubeIdFromURL:self.detailVideoNode.URL];
  if (youTubeId) {
    NSString *newURL = [NSString stringWithFormat:@"https://www.youtube.com/embed/%@", youTubeId];
    self.detailVideoNode.URL = newURL;
    self.useInlineWebView = YES;
  } else if ([self.detailVideoNode.URL rangeOfString:@"imgur.com"].location != NSNotFound &&
             [self.detailVideoNode.URL hasSuffix:@".gifv"]) {
    self.useInlineWebView = YES;
  }

  // Non-YouTube videos get the thumbnail with a Play icon over it. Tapping launches a webview.
  if (!self.useInlineWebView) {
    [self.videoWebView removeFromSuperview];
    self.videoWebView = nil;

    self.backgroundColor = [UIColor blackColor];

    self.thumbnailView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.thumbnailView];

    self.playIconView = [[UIImageView alloc] init];
    self.playIconView.image = [UIImage imageNamed:@"icon_play"];
    [self.contentView addSubview:self.playIconView];

    [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                               initWithTarget:self
                                                       action:@selector(_userTappedThumbnail)]];
  } else {
    [self.thumbnailView removeFromSuperview];
    [self.playIconView removeFromSuperview];

    if (!self.videoWebView) {
      self.videoWebView = [[UIWebView alloc] initWithFrame:self.bounds];
      self.videoWebView.scrollView.scrollEnabled = NO;
      self.videoWebView.scalesPageToFit = YES;
      self.videoWebView.delegate = self;
    }
    NSURL *URL = [NSURL URLWithString:self.detailVideoNode.URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [self.videoWebView loadRequest:request];
    [self.contentView addSubview:self.videoWebView];
  }

  [super updateWithNode:node];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  // Center the webview.
  webView.scrollView.contentOffset =
      CGPointMake(floorf((webView.scrollView.contentSize.width - webView.frame.size.width) / 2),
                  floorf((webView.scrollView.contentSize.height - webView.frame.size.height) / 2));
}

#pragma mark - sizing and layout

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView {
  return 300;
}

- (void)layoutCellOverlays {
  if (!self.useInlineWebView) {
    self.thumbnailView.frame = self.bounds;

    CGRect playIconFrame;
    playIconFrame.size = [self.playIconView sizeThatFits:self.bounds.size];
    playIconFrame.origin =
        CGPointMake(floorf(self.bounds.size.width - playIconFrame.size.width) / 2,
                    floorf(self.bounds.size.height - playIconFrame.size.height) / 2);
    self.playIconView.frame = playIconFrame;
  }
}

#pragma mark - private

- (void)_userTappedThumbnail {
  REDWebViewController *webViewController =
      [[REDWebViewController alloc] initWithURL:[NSURL URLWithString:self.detailVideoNode.URL]
                                          title:nil];
  UINavigationController *navigationController =
      [[UINavigationController alloc] initWithRootViewController:webViewController];
  [self.detailVideoNode.viewController presentViewController:navigationController
                                                    animated:YES
                                                  completion:nil];
}

- (NSString *)_extractYouTubeIdFromURL:(NSString *)URL {
  if ([URL hasPrefix:@"http://www.youtube.com"] || [URL hasPrefix:@"https://www.youtube.com"] ||
      [URL hasPrefix:@"http://youtu.be"] || [URL hasPrefix:@"https://youtu.be"]) {
    NSString *youTubeIdRegex = @"(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)";
    NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:youTubeIdRegex options:0 error:nil];
    NSRange rangeOfFirstMatch =
        [regex rangeOfFirstMatchInString:URL options:0 range:NSMakeRange(0, [URL length])];
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
      return [URL substringWithRange:rangeOfFirstMatch];
    }
  }
  return nil;
}

@end

#pragma mark - view model

@implementation REDDetailVideoNode

- (instancetype)initWithURL:(NSString *)URL
               thumbnailUrl:(NSURL *)thumbnailUrl
              thumbnailSize:(CGSize)thumbnailSize

             viewController:(__weak UIViewController *)viewController {
  if (self = [super init]) {
    _URL = [URL copy];
    _thumbnailUrl = thumbnailUrl;
    _thumbnailSize = thumbnailSize;
    _viewController = viewController;
  }

  return self;
}

+ (Class)cellClass {
  return [REDDetailVideoCell class];
}

@end
