#import "Announcement.h"
#import "AnnouncementViewController.h"
#import "NavigationManager.h"

#define USE_LOCAL_TESTING_ANNOUNCEMENT 0

#define kJMPrefKeyLastViewedAnnouncementIdent @"kJMPrefKeyLastViewedAnnouncementIdent"

// NOTE: Pre-transfer news feed is here http://alienblue.s3.amazonaws.com/reddit/alienblue-news.json
#define kJMAnnouncementFeedUrl @"http://alienblue-static.s3.amazonaws.com/announcement/alienblue-news.json"

#define kJMAnnouncementFeedLocalTestingUrl @"http://192.168.1.22:8000/alienblue-news.json"

static Announcement *i_latestAnnouncement = nil;

@implementation Announcement

- (id)initWithDictionary:(NSDictionary *)d;
{
  self = [super init];
  if (self)
  {
    self.ident = [[d valueForKey:@"ident"] integerValue];
    
    self.showsOnPhones = [[d valueForKey:@"show-on-iphone"] boolValue];
    self.showsOnPads = [[d valueForKey:@"show-on-ipad"] boolValue];
    self.showsImmediately = [[d valueForKey:@"shows-immediately"] boolValue];
    self.showsBanner = [[d valueForKey:@"shows-banner"] boolValue];
    
    self.minVersion = [[d valueForKey:@"min-version"] floatValue];
    self.maxVersion = [[d valueForKey:@"max-version"] floatValue];
    
    self.title = [d valueForKey:@"title"];
    self.content = [d valueForKey:@"content"];
    
    self.link1Title = [d valueForKey:@"link1-title"];
    self.link1Url = [d valueForKey:@"link1-url"];
    self.link1OpensInSafari = [[d valueForKey:@"link1-open-in-safari"] boolValue];
    
    self.link2Title = [d valueForKey:@"link2-title"];
    self.link2Url = [d valueForKey:@"link2-url"];
    self.link2OpensInSafari = [[d valueForKey:@"link2-open-in-safari"] boolValue];
    
    self.link3Title = [d valueForKey:@"link3-title"];
    self.link3Url = [d valueForKey:@"link3-url"];
    self.link3OpensInSafari = [[d valueForKey:@"link3-open-in-safari"] boolValue];
    
    self.commentFeedUrl = [d valueForKey:@"comment-feed-url"];
    self.commentFeedOpensInSafari = [[d valueForKey:@"comment-feed-open-in-safari"] boolValue];
  }
  return self;
}

- (BOOL)hasLink1;
{
  return (!JMIsEmpty(self.link1Url) && !JMIsEmpty(self.link1Title));
}

- (BOOL)hasLink2;
{
  return (!JMIsEmpty(self.link2Url) && !JMIsEmpty(self.link2Title));
}

- (BOOL)hasLink3;
{
  return (!JMIsEmpty(self.link3Url) && !JMIsEmpty(self.link3Title));
}

- (BOOL)hasCommentFeed;
{
  return !JMIsEmpty(self.commentFeedUrl);
}

- (BOOL)shouldShow;
{
  if ([Announcement lastViewedAnnouncementIdent] >= self.ident)
    return NO;
  
  if (JMIsIpad() && !self.showsOnPads)
    return NO;
  
  if (JMIsIphone() && !self.showsOnPhones)
    return NO;
  
  NSString *versionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
  CGFloat version = [versionStr floatValue];
  if (version < 0.1 || version == HUGE_VAL)
  {
    DLog(@"App version couldn't be converted to comparable float. Bailing on announcement test.");
    return NO;
  }
  
  if (version < self.minVersion || version > self.maxVersion)
  {
    return NO;
  }
  
  return YES;
}

+ (void)fetchAnnouncementOnComplete:(void(^)(Announcement *announcement))onComplete;
{
  NSURL *url = [kJMAnnouncementFeedUrl URL];
  
#ifdef DEBUG
  #if USE_LOCAL_TESTING_ANNOUNCEMENT
    url = [kJMAnnouncementFeedLocalTestingUrl URL];
//    NSString *testJSONPath = [[NSBundle mainBundle] pathForResource:@"alienblue-news" ofType:@"json"];
//    url = [NSURL fileURLWithPath:testJSONPath];
  #endif
#endif
  
  NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.];
  AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    if (JSON && [JSON isKindOfClass:[NSDictionary class]]);
    {
      Announcement *announcement = [[Announcement alloc] initWithDictionary:JSON];
      DLog(@"received new announcement with version: %d", announcement.ident);
      onComplete(announcement);
    }
  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//    DLog(@"unable to retrieve announcement: %@", error);
  }];
  [op start];
}

+ (Announcement *)latestAnnouncement;
{
  return i_latestAnnouncement;
}

+ (void)checkAnnouncements;
{
  [Announcement fetchAnnouncementOnComplete:^(Announcement *announcement) {
    i_latestAnnouncement = announcement;
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnnouncementReceivedNotification object:i_latestAnnouncement];
    if (announcement.shouldShow && announcement.showsImmediately)
    {
      BOOL showingAnnouncementAlready = JMIsClass([(UINavigationController *)[NavigationManager mainViewController] visibleViewController], AnnouncementViewController);
      if (!showingAnnouncementAlready)
      {
        // give the app/UI a chance to load
        double delayInSeconds = 1.;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
          [AnnouncementViewController showLatest];
        });
      }
    }
  }];
}

+ (NSInteger)lastViewedAnnouncementIdent;
{
  return [UDefaults integerForKey:kJMPrefKeyLastViewedAnnouncementIdent];
}

+ (void)markLatestAnnouncementAsRead;
{
  if (!i_latestAnnouncement)
    return;
  
  [UDefaults setInteger:i_latestAnnouncement.ident forKey:kJMPrefKeyLastViewedAnnouncementIdent];
  [UDefaults synchronize];
  [[NSNotificationCenter defaultCenter] postNotificationName:kAnnouncementMarkedReadNotification object:i_latestAnnouncement];
}

@end
