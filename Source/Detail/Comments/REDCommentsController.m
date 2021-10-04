//  REDCommentsController.m
//  RedditApp

#import "RedditApp/Detail/Comments/REDCommentsController.h"

#import "Common/AppDelegate/AlienBlueAppDelegate.h"
#import "Common/Navigation/NavigationManager+Deprecated.h"
#import "Helpers/Resources.h"
#import "JMGallery/JMGallery/JMGallery.h"
#import "JMGallery/JMGallery/JMGalleryItem+MediaFetch.h"
#import "JMOutlineView/JMOutlineViewController+Prerender.h"
#import "RedditApp/Detail/Comments/REDCommentsController+API.h"
#import "RedditApp/Detail/Comments/REDCommentsController+LinkHandling.h"
#import "RedditApp/Detail/Comments/REDCommentsController+NavigationBar.h"
#import "RedditApp/Detail/Comments/REDCommentsController+ReplyInteraction.h"
#import "RedditApp/Detail/Comments/REDCommentsController+State.h"
#import "RedditApp/Detail/REDDetailViewController.h"
#import "Sections/Comments/Comment.h"
#import "Sections/Comments/CommentHeaderBarOverlay.h"
#import "Sections/Comments/CommentNode.h"
#import "Sections/Comments/CommentPostHeaderNode.h"
#import "Sections/Comments/CommentPostHeaderToolbar.h"
#import "Sections/Comments/Comment+Style.h"
#import "Sections/Comments/NCenteredTextCell.h"
#import "Sections/Posts/Post.h"
#import "Sections/Posts/Post+Style.h"
#import "Sections/Reddits/NSectionSpacerCell.h"

#define kTrainingCommentsHeaderBarExistencePrefKey @"kTrainingCommentsHeaderBarExistencePrefKey"
#define kTrainingCommentsHeaderBarExistenceNumberTimes 9

@interface REDCommentsController ()
@property(nonatomic, strong) Post *post;
@property(nonatomic, strong) NSString *contextId;
@property(nonatomic, weak) REDDetailViewController *detailViewController;
- (void)fetchComments;
@property(nonatomic, strong) CommentPostHeaderToolbar *headerToolbar;
@property(nonatomic, strong) NSMutableArray *nodes;
@end

@implementation REDCommentsController

- (id)initWithPost:(Post *)post;
{ return [self initWithPost:post contextId:nil detailViewController:nil]; }

- (id)initWithPost:(Post *)post contextId:(NSString *)contextId;
{ return [self initWithPost:post contextId:contextId detailViewController:nil]; }

- (id)initWithPost:(Post *)post
               contextId:(NSString *)contextId
    detailViewController:(__weak REDDetailViewController *)detailViewController;
{
  self = [super init];
  if (self) {
    self.loadOperation = nil;
    self.post = post;
    self.contextId = contextId;
    self.detailViewController = detailViewController;
    self.sortOrder = [UDefaults stringForKey:kABSettingKeyCommentDefaultSortOrder];
    self.nodes = [NSMutableArray array];
    //    // add placeholder header node while the comments load
    //    CommentPostHeaderNode *headerNode = [CommentPostHeaderNode placeholderNodeForPost:post];
    //    SectionSpacerNode *spacerNode =
    //        [SectionSpacerNode spacerNodeWithCustomHeight:4.
    //        decoration:SectionSpacerDecorationNone];
    //    CenteredTextNode *loadingNode = [CenteredTextNode nodeWithTitle:@"Loading comments ..."];
    //    [self.nodes addObject:headerNode];
    //    [self.nodes addObject:spacerNode];
    //    [self.nodes addObject:loadingNode];
    //    [self setNavbarTitle:@""];
    //    self.title = @"Comments";
    //    self.navigationItem.backBarButtonItem =
    //        [[UIBarButtonItem alloc] initWithTitle:@"Back"
    //                                         style:UIBarButtonItemStyleBordered
    //                                        target:nil
    //                                        action:nil];
  }
  return self;
}

//- (void)respondToStyleChange;
//{
//  [super respondToStyleChange];
//
//  [self.nodes each:^(JMOutlineNode *node) {
//      if ([node isKindOfClass:[CommentNode class]]) {
//        [[(CommentNode *)node comment] flushCachedStyles];
//      } else if ([node isKindOfClass:[CommentPostHeaderNode class]]) {
//        CommentPostHeaderNode *headerNode = (CommentPostHeaderNode *)node;
//        [headerNode.post flushCachedStyles];
//        [headerNode.comment flushCachedStyles];
//      }
//  }];
//  [self reload];
//
//  self.tableView.backgroundColor = [UIColor colorForBackground];
//  self.pullRefreshView.backgroundColor = [UIColor colorForBackground];
//  [self.pullRefreshView setForegroundColor:[UIColor colorForPullToRefreshForeground]];
//
//  [self.headerToolbar setNeedsDisplay];
//}
//
//- (void)loadView;
//{
//  [super loadView];
//
//  if (self.isHeadlessMode) {
//    return;
//  }
//
//  BSELF(REDCommentsController);
//  self.pullRefreshView =
//      [JMRefreshHeaderView hookRefreshHeaderToController:self
//                                               onTrigger:^{ [blockSelf fetchComments]; }];
//
//  if ([[NavigationManager shared] deprecated_isFullscreen]) {
//    UIView *paddingView =
//        [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 32.)];
//    paddingView.backgroundColor = [UIColor clearColor];
//    self.tableView.tableFooterView = paddingView;
//  }
//
//  self.headerToolbar = [CommentPostHeaderToolbar postHeaderToolbar];
//  [self.headerToolbar updateWithPost:self.post];
//  self.tableView.tableHeaderView = self.headerToolbar;
//
//  DONT_DO_WHILE_TRAINING(kTrainingCommentsHeaderBarExistencePrefKey,
//                         kTrainingCommentsHeaderBarExistenceNumberTimes, ^{
//      blockSelf.pullRefreshView.defaultScrollOffset = kCommentPostHeaderToolbarHeight;
//      if (blockSelf.savedScrollPosition.y <= 0) {
//        // hide the sort options out of the way when the user first lands on this screen
//        blockSelf.savedScrollPosition = CGPointMake(0, kCommentPostHeaderToolbarHeight);
//      }
//  });
//
//  self.headerToolbar.onModerationSendMessage = ^(id modCommentResponse) {
//      if (modCommentResponse) {
//        [blockSelf.headerToolbar hideModTools];
//        BOOL isCommentResponse = JMIsClass(modCommentResponse, NSDictionary);
//        if (isCommentResponse) {
//          [blockSelf afterCommentReply:modCommentResponse];
//        }
//      }
//  };
//
//  self.headerToolbar.onCanvasButtonTap = ^{ [blockSelf showAllImagesInCanvas]; };
//
//  [self respondToStyleChange];
//}

NSArray *JMGenerateCommentGalleryItemsFromNode(BaseStyledTextNode *sNode) {
  if (!JMIsClass(sNode, BaseStyledTextNode)) {
    return [NSArray new];
  }

  NSMutableArray *galleryCompatibleItems = [NSMutableArray new];
  [sNode.thumbLinks each:^(CommentLink *cLink) {
      if (cLink.linkType == LinkTypePhoto || cLink.linkType == LinkTypeVideo) {
        JMGalleryItem *galleryItem = [JMGalleryItem new];
        NSString *title = [[(CommentNode *)sNode comment].body jm_truncateToLength:110];
        title = [title jm_stringByReplacingRegExPattern:@"\\[(.*?)\\]" withString:@""];
        title = [title jm_stringByReplacingRegExPattern:@"\\((.*?)\\)" withString:@""];
        title = [title jm_trimmed];
        galleryItem.title = title;
        galleryItem.subtitle = cLink.isDescribed ? cLink.caption : nil;
        if (galleryItem.title.length < 5) {
          galleryItem.title = galleryItem.subtitle;
          galleryItem.subtitle = nil;
        }
        galleryItem.linkedUrl = cLink.url;
        galleryItem.requiresTapToReveal =
            sNode.containsRestrictedContent || [title jm_contains:@"spoiler"];
        [galleryCompatibleItems addObject:galleryItem];
      }
  }];
  return galleryCompatibleItems;
}

static NSArray *JMUniqueGalleryItemsFromAllItems(NSArray *allItems) {
  NSMutableArray *uniqueItems = [NSMutableArray new];
  [allItems each:^(JMGalleryItem *item) {
      BOOL alreadyExists = [uniqueItems match:^BOOL(JMGalleryItem *existingItem) {
          return [item.imageUrl jm_matches:existingItem.imageUrl];
      }];
      if (!alreadyExists) {
        [uniqueItems addObject:item];
      }
  }];
  return uniqueItems;
}

- (BOOL)isImageBasedThread;
{
  return self.nodes.count > 40 &&
         ((CGFloat)self.post.numberOfImagesInCommentThread / (CGFloat)self.nodes.count) > 0.11;
}

- (void)showAllImagesInCanvas;
{
  if (self.post.numberOfImagesInCommentThread == 0) return;

  void (^ShowGalleryItemsAction)(NSArray * commentNodes, CommentPostHeaderNode * postHeaderNode) =
      ^(NSArray *commentNodes, CommentPostHeaderNode *postHeaderNode) {
      [PromptManager hideHud];
      [PromptManager showHudWithMessage:@"Preparing Images"];
      DO_IN_BACKGROUND(^{
          __block NSMutableArray *galleryItems = [NSMutableArray new];
          [galleryItems addObjectsFromArray:JMGenerateCommentGalleryItemsFromNode(postHeaderNode)];
          [commentNodes each:^(CommentNode *cNode) {
              [galleryItems addObjectsFromArray:JMGenerateCommentGalleryItemsFromNode(cNode)];
          }];
          [JMGalleryItem
              updateGalleryItemsWithThumbnailAndMediaUrls:galleryItems
                                           shouldStopWhen:nil
                                               onComplete:^(NSArray *galleryReadyItems) {
                                                   NSArray *uniqueItems =
                                                       JMUniqueGalleryItemsFromAllItems(
                                                           galleryReadyItems);
                                                   DO_IN_MAIN(^{
                                                       [PromptManager hideHud];
                                                       [[NavigationManager shared]
                                                           showFullScreenViewerForGalleryItems:
                                                               uniqueItems startingAtIndex:0];
                                                   });
                                               }
                                  skipThumbnailExtraction:NO];
      });
  };

  if (self.isImageBasedThread && self.post.numComments > 210 && self.nodes.count < 210) {
    [PromptManager showHudWithMessage:@"Loading More Images"];
    REDCommentsController *dummyController = [[REDCommentsController alloc] initWithPost:self.post];
    dummyController.customFetchLimit = 1000;
    dummyController.disallowPrerendingAndAttributedStylePreprocessing = YES;
    [dummyController fetchCommentsOnComplete:ShowGalleryItemsAction];
  } else {
    CommentPostHeaderNode *postHeaderNode = [self.nodes first];
    NSArray *commentNodes = [self.nodes subarrayWithRange:NSMakeRange(1, self.nodes.count - 2)];
    ShowGalleryItemsAction(commentNodes, postHeaderNode);
  }
}

//- (void)viewWillDisappear:(BOOL)animated;
//{
//  [self.loadOperation cancel];
//  self.loadOperation = nil;
//  [super viewWillDisappear:animated];
//}
//
//- (void)viewDidUnload;
//{
//  [self.loadOperation cancel];
//  self.loadOperation = nil;
//  [super viewDidUnload];
//}
//
//- (void)viewDidAppear:(BOOL)animated;
//{
//  [super viewDidAppear:animated];
//  if ([self.nodes count] <= 3) {
//    [self performSelector:@selector(fetchComments) withObject:nil afterDelay:0.5];
//  }
//}

- (void)showAllComments;
{
  self.contextId = nil;
  [self fetchComments];
}

- (void)commentsDidFinishLoading;
{
  self.headerToolbar.shouldHighlightCanvasButton = self.isImageBasedThread;
  [self.headerToolbar updateWithPost:self.post];

  BSELF(REDCommentsController);

  DONT_DO_WHILE_TRAINING(kTrainingCommentsHeaderBarExistencePrefKey,
                         kTrainingCommentsHeaderBarExistenceNumberTimes, ^{
      // This is a hack to stop the tableview from snapping the header bar into view
      // when there isn't enough content in the table to fill the height of the view
      if (blockSelf.detailViewController.tableView.contentOffset.y == 0. &&
          blockSelf.detailViewController.tableView.contentSize.height <
              blockSelf.detailViewController.view.bounds.size.height) {
        [blockSelf.detailViewController.tableView
            setContentOffset:CGPointMake(0., kCommentPostHeaderToolbarHeight)
                    animated:NO];
      }
  });

  DO_WHILE_TRAINING(kTrainingCommentsHeaderBarExistencePrefKey,
                    kTrainingCommentsHeaderBarExistenceNumberTimes, ^{
      if (!blockSelf.contextId && blockSelf.detailViewController.tableView.contentOffset.y == 0.) {
        [blockSelf.detailViewController.tableView
            setContentOffset:CGPointMake(0., kCommentPostHeaderToolbarHeight)
                    animated:YES];
      }
  });

  if ([self isImageBasedThread] &&
      self.detailViewController.tableView.contentOffset.y == kCommentPostHeaderToolbarHeight) {
    [blockSelf.detailViewController.tableView setContentOffset:CGPointMake(0., 0) animated:YES];
  }

  [self.delegate commentsDidFinishLoading:self];
}

- (void)addPreCommentNodes;
{}

- (void)fetchComments;
{
  BSELF(REDCommentsController);
  typedef void (^ProcessCommentsAction)(NSArray * commentNodes, CommentPostHeaderNode * headerNode);

  ProcessCommentsAction processAction =
      ^(NSArray *commentNodes, CommentPostHeaderNode *headerNode) {
      //      [blockSelf deselectNodes];
      //      [blockSelf.pullRefreshView finishedLoading];
      //      [blockSelf removeAllNodes];
      //
      //      // If commentNodes and headerNode are nil due to a 400-level error,
      //      // show an error message
      //      BOOL shouldShowErrorMessage = !commentNodes && !headerNode;
      //      if (shouldShowErrorMessage) {
      //        CenteredTextNode *headerNode =
      //            [CenteredTextNode nodeWithTitle:@"Looks like there's nothing to see here
      //            anymore"];
      //        [blockSelf addNode:headerNode];
      //        [blockSelf reload];
      //        [blockSelf performSelector:@selector(commentsDidFinishLoading)];
      //        return;
      //      }
      //
      //      CommentPostHeaderNode *existingHeaderNode = [blockSelf.nodes
      //          match:^BOOL(JMOutlineNode *node) { return JMIsClass(node, CommentPostHeaderNode);
      //          }];
      //
      //      if (existingHeaderNode) {
      //        headerNode.state = existingHeaderNode.state;
      //      }
      //
      //      [blockSelf addNode:headerNode];
      //      blockSelf.post = headerNode.post;
      //
      //      if (headerNode.post.linkType == LinkTypePhoto &&
      //          ![UDefaults boolForKey:kABSettingKeyAutoLoadInlineImageLink]) {
      //        // give the user to show the image inline
      //        __block __ab_weak CommentPostHeaderNode *weakHeaderNode = headerNode;
      //        CenteredTextNode *showImageNode =
      //            [CenteredTextNode nodeWithTitle:@"Show Image" selectedTitle:@"Loading
      //            Image..."];
      //        __block __ab_weak CenteredTextNode *weakShowImageNode = showImageNode;
      //        showImageNode.onSelect = ^{
      //            weakHeaderNode.forceImageLoad = YES;
      //            [weakHeaderNode refresh];
      //            weakShowImageNode.state = JMOutlineNodeStateHidden;
      //        };
      //        [blockSelf addNode:showImageNode];
      //      }
      //
      //      [blockSelf addPreCommentNodes];

      if (blockSelf.contextId) {
        CenteredTextNode *showAllNode = [CenteredTextNode nodeWithTitle:@"Show rest of the comments"
                                                          selectedTitle:@"Loading..."];
        showAllNode.onSelect = ^{ [blockSelf showAllComments]; };
        [blockSelf.nodes addObject:showAllNode];
      }

      [commentNodes eachWithIndex:^(CommentNode *commentNode, NSUInteger ind) {
          commentNode.isContext = [commentNode.comment.ident equalsString:blockSelf.contextId];
          [blockSelf.nodes addObject:commentNode];
      }];

      //      [blockSelf reload];
      //
      //      if (blockSelf.contextId) {
      //        CommentNode *contextNode =
      //            (CommentNode *)[blockSelf nodeForElementId:blockSelf.contextId];
      //        [blockSelf scrollToNode:contextNode];
      //      } else {
      //        [blockSelf handleRestoringStateAutoscroll];
      //      }
      [blockSelf performSelector:@selector(commentsDidFinishLoading)];
  };

  [self fetchCommentsOnComplete:processAction];
}

//- (void)toggleNode:(JMOutlineNode *)node;
//{
//    [super toggleNode:node];
//
//    CGFloat contentHeightRemaining = self.tableView.contentSize.height -
//    self.tableView.contentOffset.y;
//    if (node.collapsed && contentHeightRemaining > (1.5 * self.tableView.height))
//    {
//        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y +
//        kCommentHeaderBarOverlayHeight) animated:YES];
//    }
//}

#pragma Mark - Sliding Drag Release Protocol

- (BOOL)canDragRelease {
  // if it's a self link, no need to push a browser view
  return ![self.post.url contains:self.post.permalink];
}

- (NSString *)titleForDragReleaseLabel {
  NSString *destinationType =
      [CommentLink friendlyNameFromLinkType:[CommentLink linkTypeFromUrl:self.post.url]];
  if ([destinationType equalsString:@"Self"]) destinationType = @"Reddit Post";

  return destinationType;
}

- (void)didDragRelease {
  [self openLinkUrl:self.post.url];
}

- (NSString *)iconNameForDragReleaseDestination {
  return self.post.linkTypeIconName;
}

@end
