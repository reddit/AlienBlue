//  REDDetailViewController.m
//  RedditApp

#import "RedditApp/Detail/REDDetailViewController.h"

#import "Helpers/RedditAPI+Account.h"
#import "JMOutlineView/JMOutlineCell.h"
#import "RedditApp/Detail/Comments/REDCommentsController.h"
#import "RedditApp/Detail/Comments/REDCommentsController+PopoverOptions.h"
#import "RedditApp/Detail/Comments/REDCommentsController+ReplyInteraction.h"
#import "RedditApp/Detail/REDDetailHeaderCell.h"
#import "RedditApp/Detail/REDDetailPhotoCell.h"
#import "RedditApp/Detail/REDDetailSelfTextCell.h"
#import "RedditApp/Detail/REDDetailVideoCell.h"
#import "RedditApp/Detail/REDDetailWebsiteCell.h"
#import "RedditApp/Posts/REDPostCommentsBar.h"
#import "RedditApp/REDNavigationBar.h"
#import "RedditApp/REDWebViewController.h"
#import "RedditApp/Util/REDColor.h"
#import "RedditApp/Util/REDTodoPrompt.h"
#import "Sections/Browser/LinkShareCoordinator.h"
#import "Sections/Comments/CommentNode.h"
#import "Sections/Posts/Post.h"
#import "Sections/Posts/Post+API.h"

#pragma mark - ScrollForwarder

// We can't implement UIScrollViewDelegate in REDDetailViewController because a super class
// (JMOutlineViewController) implements this. So instead, we forward to this helper class, which
// then informs REDDetailViewController of a scroll.
// We care about the scroll so we can move the REDPostCommentsBar. The REDPostCommentsBar is not
// a normal cell, because we want it to stick to the top and bottom of the screen instead of
// scrolling off.

@protocol ScrollForwarderDelegate
- (void)didScroll:(CGFloat)contentOffsetY;
@end

@interface ScrollForwarder : NSObject<UIScrollViewDelegate>
@property(nonatomic, weak) id<ScrollForwarderDelegate> delegate;
@end

@implementation ScrollForwarder

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self.delegate didScroll:scrollView.contentOffset.y];
}

@end

#pragma mark - REDPostCommentsBarSpacerCell

// This is a simple cell that is the size of the REDPostCommentsBar. The REDPostCommentsBar floats
// above the table, and resides in the spot of this cell except when it's stuck to the top or
// bottom of the view.

@interface REDPostCommentsBarSpacerCell : JMOutlineCell
@end

@interface REDPostCommentsBarSpacerNode : JMOutlineNode
@end


@implementation REDPostCommentsBarSpacerCell

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView {
  return [REDPostCommentsBar height];
}

@end

@implementation REDPostCommentsBarSpacerNode

+ (Class)cellClass {
  return [REDPostCommentsBarSpacerCell class];
}

@end

#pragma mark - REDDetailViewController

@interface REDDetailViewController ()<REDCommentsControllerDelegate, ScrollForwarderDelegate>

@property(nonatomic, strong) Post *post;
@property(nonatomic, strong) NSArray *contentNodes;
@property(nonatomic, strong) REDCommentsController *commentsViewController;
@property(nonatomic, strong) UIButton *bookmarkButton;
@property(nonatomic, strong) REDPostCommentsBar *commentsBar;
@property(nonatomic, strong) ScrollForwarder *scrollForwarder;
@property(nonatomic, strong) REDWebViewController *webViewController;
@end

@implementation REDDetailViewController

- (instancetype)initWithPost:(Post *)post {
  if (self = [super init]) {
    self.post = post;

    REDNavigationBar *navigationBar = [REDNavigationBar new];
    [navigationBar setBackgroundColor:self.keyColor];
    [self attachCustomNavigationBarView:navigationBar];

    UIButton *overflowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [overflowButton addTarget:self
                       action:@selector(didPressOverflowButton)
             forControlEvents:UIControlEventTouchUpInside];
    [overflowButton setImage:[UIImage imageNamed:@"btn_overflow_nav_white"]
                    forState:UIControlStateNormal];
    [overflowButton sizeToFit];
    [navigationBar addRightButton:overflowButton];

    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton addTarget:self
                    action:@selector(didPressShareButton)
          forControlEvents:UIControlEventTouchUpInside];
    [shareButton setImage:[UIImage imageNamed:@"btn_share_nav_white"]
                 forState:UIControlStateNormal];
    [shareButton sizeToFit];
    [navigationBar addRightButton:shareButton];

    self.bookmarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bookmarkButton addTarget:self
                            action:@selector(didPressBookmarkButton)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.bookmarkButton setImage:[UIImage imageNamed:@"btn_bookmark_nav_white"]
                         forState:UIControlStateNormal];
    [self.bookmarkButton sizeToFit];
    [navigationBar addRightButton:self.bookmarkButton];
    [self setBookmarkAlpha];

    self.commentsViewController =
        [[REDCommentsController alloc] initWithPost:post contextId:nil detailViewController:self];
    self.commentsViewController.delegate = self;
    [self.commentsViewController fetchComments];

    self.commentsBar = [[REDPostCommentsBar alloc] initWithPost:post];

    [self buildContentNodes];
    [self setNodes];

    self.scrollForwarder = [[ScrollForwarder alloc] init];
    self.scrollForwarder.delegate = self;
    self.scrollObserver = self.scrollForwarder;
  }
  return self;
}

- (void)prepareWebViewControllerWithURL:(NSURL *)url title:(NSString *)title {
  self.webViewController = [[REDWebViewController alloc] initWithURL:url title:title];
}

- (void)presentWebViewController {
  UINavigationController *navigationController =
      [[UINavigationController alloc] initWithRootViewController:self.webViewController];
  [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)buildContentNodes {
  NSMutableArray *contentNodes = [NSMutableArray array];

  [contentNodes addObject:[[REDDetailHeaderNode alloc] initWithPost:self.post viewController:self]];

  if (self.post.selftext.length > 0) {
    [contentNodes addObject:[[REDDetailSelfTextNode alloc] initWithMarkdown:self.post.selftext
                                                             viewController:self]];
  }

  NSURL *url;
  CGSize size;
  [self getThumbnailURL:&url andSize:&size forPost:self.post];
  if (!url || CGSizeEqualToSize(size, CGSizeZero)) {
    [self getSourceURL:&url andSize:&size forPost:self.post];
  }

  switch (self.post.linkType) {
    case LinkTypeArticle: {
      REDDetailWebsiteNode *detailWebsiteNode =
          [[REDDetailWebsiteNode alloc] initWithURL:[NSURL URLWithString:self.post.url]
                                              title:self.post.title
                                          webDomain:self.post.domain
                                       thumbnailUrl:url
                                      thumbnailSize:size
                                     viewController:self];
      [contentNodes addObject:detailWebsiteNode];
      break;
    }
    case LinkTypePhoto: {
      if (url && !CGSizeEqualToSize(size, CGSizeZero)) {
        REDDetailPhotoNode *detailPhotoNode =
            [[REDDetailPhotoNode alloc] initWithMediaURL:url
                                                  height:size.height
                                                   width:size.width
                                            fromSelfText:NO
                                          viewController:self];
        [contentNodes addObject:detailPhotoNode];
      }
      break;
    }
    case LinkTypeVideo: {
      REDDetailVideoNode *detailVideoNode = [[REDDetailVideoNode alloc] initWithURL:self.post.url
                                                                       thumbnailUrl:url
                                                                      thumbnailSize:size
                                                                     viewController:self];
      [contentNodes addObject:detailVideoNode];
      break;
    }
    case LinkTypeSelf:
      break;
    default:
      NSAssert(NO, @"Bad link type.");
  }

  [contentNodes addObject:[[REDPostCommentsBarSpacerNode alloc] init]];

  self.contentNodes = [contentNodes copy];
}

- (void)setNodes {
  [self deselectNodes];
  [self removeAllNodes];
  for (JMOutlineNode *node in self.contentNodes) {
    [self addNode:node];
  }
  for (JMOutlineNode *node in self.commentsViewController.nodes) {
    [self addNode:node];
  }
  [self reload];
}

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.view addSubview:self.commentsBar];
  self.commentsBar.frame = self.view.bounds;
  [self.commentsBar sizeToFit];
  [self didScroll:self.tableView.contentOffset.y];
}

#pragma mark - REDCommentsControllerDelegate

- (void)commentsDidFinishLoading:(REDCommentsController *)commentsController {
  [self setNodes];
}

#pragma mark - Comment Interaction

- (void)showMoreOptionsForCommentNode:(CommentNode *)commentNode {
  [self.commentsViewController showOptionsForComment:commentNode.comment];
}

- (void)addCommentToCommentNode:(CommentNode *)commentNode {
  REQUIRES_REDDIT_AUTHENTICATION;
  [self.commentsViewController replyToCommentNode:commentNode];
}

- (void)voteUpCommentNode:(CommentNode *)commentNode {
  REQUIRES_REDDIT_AUTHENTICATION;

  [commentNode.comment upvote];
  [self reloadRowForNode:commentNode];
}

- (void)voteDownCommentNode:(CommentNode *)commentNode {
  REQUIRES_REDDIT_AUTHENTICATION;

  [commentNode.comment downvote];
  [self reloadRowForNode:commentNode];
}

#pragma mark - ScrollForwarderDelegate

// Stick the REDPostCommentsBar to the top or bottom of the screen.
- (void)didScroll:(CGFloat)contentOffsetY {
  CGRect spacingCellRect = [self rectForNode:self.contentNodes.lastObject];
  CGFloat spacingCellRectY = CGRectGetMinY(spacingCellRect);
  CGRect commentsbarFrame = self.commentsBar.frame;
  CGFloat newY = spacingCellRectY - contentOffsetY + self.tableView.frame.origin.y;
  newY = MAX(newY, CGRectGetMinY(self.tableView.frame));
  newY = MIN(newY, CGRectGetMaxY(self.tableView.frame) - commentsbarFrame.size.height);
  commentsbarFrame.origin.y = newY;
  self.commentsBar.frame = commentsbarFrame;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

#pragma mark - accessors

- (UIColor *)keyColor {
  NSString *colorHex = self.post.subredditDetail[@"key_color"];
  if (colorHex.length > 1) {
    // The format will be "#7cd344". Skip the #.
    int colorInt = strtol(colorHex.UTF8String + 1, NULL, 16);
    return [UIColor colorWithHex:colorInt];
  }
  return [REDColor blueColor];
}

#pragma mark - private

- (void)getSourceURL:(NSURL **)urlOut andSize:(CGSize *)sizeOut forPost:(Post *)post {
  NSDictionary *source = post.preview[@"images"][0][@"source"];
  if (source) {
    *urlOut = [NSURL URLWithString:source[@"url"]];
    *sizeOut = CGSizeMake([source[@"width"] floatValue], [source[@"height"] floatValue]);
  } else {
    *urlOut = nil;
    *sizeOut = CGSizeZero;
  }
}

- (void)getThumbnailURL:(NSURL **)urlOut andSize:(CGSize *)sizeOut forPost:(Post *)post {
  NSArray *resolutions = post.preview[@"images"][0][@"resolutions"];
  if (resolutions) {
    NSDictionary *previewImageDescriptor = [resolutions lastObject];
    *urlOut = [NSURL URLWithString:previewImageDescriptor[@"url"]];
    *sizeOut = CGSizeMake([previewImageDescriptor[@"width"] floatValue],
                          [previewImageDescriptor[@"height"] floatValue]);
  } else {
    *urlOut = nil;
    *sizeOut = CGSizeZero;
  }
}

- (void)setBookmarkAlpha {
  self.bookmarkButton.alpha = self.post.saved ? 1.0 : 0.5;
}

- (void)didPressOverflowButton {
  [REDTodoPrompt show];
}

- (void)didPressShareButton {
  [LinkShareCoordinator presentLinkShareSheetFromViewController:self
                                             barButtonItemOrNil:nil
                                                    withAddress:self.post.url
                                                          title:self.post.title];
}

- (void)didPressBookmarkButton {
  [self.post toggleSaved];
  [self setBookmarkAlpha];
}

@end
