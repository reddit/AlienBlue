#import "GalleryViewController.h"

#import "ABEventLogger.h"
#import "AFImageRequestOperation.h"
#import "JMSiteMedia.h"
#import "MBProgressHUD.h"
#import "NavigationManager.h"
#import "NavigationManager+Deprecated.h"
#import "Post.h"
#import "RedditAPI+ElementInteraction.h"
#import "SHKActionSheet.h"

@interface SubredditGalleryViewController ()
- (NSString *)generateRelativeRedditUrlForNextPage;
@end

@implementation GalleryViewController

- (id)initWithSubredditUrl:(NSString *)subredditUrl additionalParams:(NSString *)additionalParams title:(NSString *)title;
{
    self = [super initWithSubredditUrl:subredditUrl additionalParams:additionalParams title:title];
    if (self)
    {
        self.title = @"Canvas";
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style: UIBarButtonItemStyleBordered target:nil action:nil];        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated;
{
    [[NavigationManager shared] deprecated_exitFullscreenAnimated:YES];
    [super viewWillAppear:animated];
}

- (void)apiUpvotePost:(NSDictionary *)postDictionary;
{
    Post *p = [Post postFromDictionary:postDictionary];
    [[ABEventLogger shared] logUpvoteChangeForPost:p
                                         container:@"gallery_detail"
                                           gesture:@"button_press"];
    [p upvote];
}

- (void)apiDownvotePost:(NSDictionary *)postDictionary;
{
    Post *p = [Post postFromDictionary:postDictionary];
    [[ABEventLogger shared] logDownvoteChangeForPost:p
                                           container:@"gallery_detail"
                                             gesture:@"button_press"];
    [p downvote];
}

- (void)apiSavePost:(NSDictionary *)postDictionary;
{
    Post *p = [Post postFromDictionary:postDictionary];
    if (p.saved)
    {
        [[RedditAPI shared] unsavePostWithID:p.name];
    }
    else
    {
        [[RedditAPI shared] savePostWithID:p.name];        
    }
}

- (void)apiHidePost:(NSDictionary *)postDictionary;
{
    Post *p = [Post postFromDictionary:postDictionary];
    if (p.hidden)
    {
        [[RedditAPI shared] unhidePostWithID:p.name];
    }
    else
    {
        [[RedditAPI shared] hidePostWithID:p.name];
    }
}

- (void)showCommentsForPost:(NSDictionary *)postDictionary;
{
    [self stopAutoplay];
    Post *post = [Post postFromDictionary:postDictionary];
    [post markVisited];
    [[NavigationManager shared] showCommentsForPost:post contextId:nil fromController:self];
}

- (void)showSharingOptionsForPost:(NSDictionary *)postDictionary;
{
    if (!postDictionary)
      return;
  
    NSString *address = [postDictionary valueForKey:@"url"];
    NSString *title = [postDictionary valueForKey:@"title"];

    NSURL *url = [NSURL URLWithString:address];
    SHKItem *item = [SHKItem URL:url title:title];
    item.shareType = SHKShareTypeImage;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  
    BSELF(GalleryViewController);
  
    NSURL *URL = [address URL];
    void(^linkShareAction)(NSURL *deeplinkURL) = ^(NSURL *deeplinkURL){
      NSURLRequest *request = [NSURLRequest requestWithURL:deeplinkURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:20.];
      AFImageRequestOperation *downloadImageOperation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image) {
        [MBProgressHUD hideHUDForView:blockSelf.view animated:YES];
        item.image = image;
        SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
        [actionSheet jm_showInView:blockSelf.view];
      }];
      [downloadImageOperation start];
    };
    if (JMURLIsDirectLinkToImage(URL))
    {
      linkShareAction(URL);
    }
    else
    {
      [JMSiteMedia deeplinkedImageURLForLinkURL:URL onComplete:^(NSURL *deepURL) {
        linkShareAction(deepURL);
      } onFailure:nil];
    }
}

- (NSURLRequest *)generateRequestForNextPageOfResults;
{
  return [[RedditAPI shared] requestForUrl:[self generateRelativeRedditUrlForNextPage]];
}

- (void)showMomentaryHudMessage:(NSString *)message minDisplayTime:(NSTimeInterval)displayTime;
{
  [PromptManager showMomentaryHudWithMessage:message minShowTime:displayTime];
}

@end
