#import "AppSchemeCoordinator.h"
#import "PocketAPI.h"
#import "SHKFacebook.h"
#import "SHKConfiguration.h"
#import "NavigationManager.h"
#import "Post.h"

@implementation AppSchemeCoordinator

+ (void)autoCreatePost;
{
  DO_AFTER_WAITING(0.7, ^{
    [[NavigationManager shared] showCreatePostScreen];
  });
}

+ (void)autoLoadInbox;
{
  DO_AFTER_WAITING(0.7, ^{
    [[NavigationManager shared] showMessagesScreen];
  });
}

+ (void)autoLoadSubreddit:(NSString *)subreddit;
{
  NSString *subredditWithSlashR = [NSString stringWithFormat:@"/r/%@", subreddit];
  DO_AFTER_WAITING(0.7, ^{
    [[NavigationManager shared] handleTapOnUrl:subredditWithSlashR fromController:nil];
  });
}

+ (void)autoLoadThreadWithEncodedUrl:(NSString *)encodedThreadUrl;
{
  NSString *threadUrl = [encodedThreadUrl jm_unescaped];
  if (![threadUrl contains:@"reddit.com/"] && ![threadUrl contains:@"http://redd.it/"])
  {
    return;
  }
  DO_AFTER_WAITING(0.7, ^{
    [self openRedditThreadUrl:threadUrl];
  });
}

+ (BOOL)handleSchemeWithURL:(NSURL *)openURL;
{
  if (!openURL)
    return NO;
  
  NSString* scheme = [openURL scheme];
  
  if ([scheme hasPrefix:[NSString stringWithFormat:@"fb%@", SHKCONFIG(facebookAppId)]])
  {
    return [SHKFacebook handleOpenURL:openURL];
  }
  
  if([[PocketAPI sharedAPI] handleOpenURL:openURL])
  {
    return YES;
  }
  
  NSString *URLString = [openURL absoluteString];
  if (!URLString || [URLString length] == 0)
  {
    return NO;
  }
  
  if ([URLString rangeOfString:@"//post?url="].location != NSNotFound)
  {
    NSScanner *urlScanner = [NSScanner scannerWithString:URLString];
    NSString *postURL = nil;
    NSString *postTitle = nil;
    [urlScanner scanString:@"alienblue://post?url=" intoString:nil];
    [urlScanner scanUpToString:@"&title=" intoString:&postURL];
    [urlScanner scanString:@"&title=" intoString:nil];
    postURL = [postURL jm_unescaped];
    postTitle = [[URLString substringFromIndex:[urlScanner scanLocation]] jm_unescaped];
    
    [UDefaults setBool:NO forKey:@"autosave_newpost_istext"];
    [UDefaults setValue:postTitle forKey:@"autosave_newpost_title"];
    [UDefaults setValue:postURL forKey:@"autosave_newpost_url"];
    [UDefaults setBool:YES forKey:@"autosave_newpost_forcepreload"];
    [self autoCreatePost];
  }
  else if ([URLString rangeOfString:@"//inbox"].location != NSNotFound)
  {
    [self autoLoadInbox];
  }
  else if ([URLString jm_contains:@"alienblue://r/"])
  {
    NSString *subreddit = [[URLString jm_removeOccurrencesOfString:@"alienblue://r/"] jm_trimmed];
    [self autoLoadSubreddit:subreddit];
  }
  else if ([URLString jm_contains:@"alienblue://thread/"])
  {
    NSString *encodedThreadUrl = [[URLString jm_removeOccurrencesOfString:@"alienblue://thread/"] jm_trimmed];
    [self autoLoadThreadWithEncodedUrl:encodedThreadUrl];
  }
  [UDefaults synchronize];
  
  return YES;
}

+ (void)handleApplicationDidBecomeActive;
{
  [self performSelector:@selector(checkClipboardForRedditLink) withObject:nil afterDelay:1.];
}

+ (void)checkClipboardForRedditLink;
{
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  if (pasteboard && pasteboard.string)
  {
    if ([pasteboard.string contains:@"reddit.com/"] || [pasteboard.string contains:@"http://redd.it/"])
    {
      [self openRedditThreadUrl:pasteboard.string];
    }
  }
}

+ (void)openRedditThreadUrl:(NSString *)url;
{
  NSString *threadUrl = url;
  if ([url contains:@"http://redd.it/"])
  {
    // tiny hack to allow the reddit postID parser to work without modification
    threadUrl = [url stringByReplacingOccurrencesOfString:@"http://redd.it/" withString:@"http://redd.it/comments/"];
    threadUrl = [threadUrl stringByAppendingString:@"/"];
  }
  
  Post *p = [Post postSkeletonFromRedditUrl:threadUrl];
  if (!p)
    return;
  
  if (p.isInVisitedList)
  {
    // already visited this link, so ignore the clipboard
    return;
  }
  
  // as the visited list gets rotated, we should also maintain a separate list
  // of handled clipboard post idents - this handles the case when the user leaves
  // reddit link in their clipboard for a very long time (enough for the visited list
  // to get rotated).
  
  NSMutableArray *previouslyDetectedClipboardPostIdents = [NSMutableArray array];
  NSArray *clipboardIdentsInPrefs = [UDefaults objectForKey:@"clipboard_posts"];
  if (clipboardIdentsInPrefs && [clipboardIdentsInPrefs isKindOfClass:[NSArray class]])
  {
    [previouslyDetectedClipboardPostIdents addObjectsFromArray:clipboardIdentsInPrefs];
  }
  
  BOOL alreadyProcessed = [previouslyDetectedClipboardPostIdents match:^BOOL(NSString *prevPostIdent) {
    return [prevPostIdent equalsString:p.ident];
  }] != nil;
  
  if (alreadyProcessed)
  {
    return;
  }
  
  [previouslyDetectedClipboardPostIdents addObject:p.ident];
  [UDefaults setObject:previouslyDetectedClipboardPostIdents forKey:@"clipboard_posts"];
  
  [p markVisited];
  
  [[NavigationManager shared] showCommentsForPost:p contextId:p.contextCommentIdent fromController:nil];
}

@end
