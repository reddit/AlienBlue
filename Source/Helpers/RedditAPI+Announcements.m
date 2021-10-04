#import "RedditAPI+Announcements.h"
#import "NavigationManager.h"
#import "MBProgressHUD.h"
#import "Resources.h"
#import "RedditAPI+DeprecationPatches.h"
#import "RedditsViewController+Announcement.h"

@interface RedditAPI(Announcements_)
@property (strong) NSObject *announcementCheckCallBackTarget;
@property (strong) NSTimer *announcementCheckTimer;
@property BOOL canCheckAnnouncement;
@end

@implementation RedditAPI (Announcements)

SYNTHESIZE_ASSOCIATED_STRONG(NSObject, announcementCheckCallBackTarget, AnnouncementCheckCallBackTarget);
SYNTHESIZE_ASSOCIATED_BOOL(canCheckAnnouncement, CanCheckAnnouncement);
SYNTHESIZE_ASSOCIATED_STRONG(NSTimer, announcementCheckTimer, AnnouncementCheckTimer);

- (void)prepareAnnouncementChecking;
{
  self.canCheckAnnouncement = YES;
  self.announcementCheckTimer = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(allowAnnouncementCheck:) userInfo:nil repeats:YES];
}

- (void)allowAnnouncementCheck:(NSTimer *)theTimer
{
  self.canCheckAnnouncement = YES;
}

- (void)checkLatestAnnouncementsIfAllowedWithCallBackTarget:(id)target;
{
  if (!self.canCheckAnnouncement)
  {
    return;
  }
  
  // we set this flag, so that we can obey a timer that prohibits checking
  // the /r/AlienBlue subreddit everytime the subreddit picker appears
  self.canCheckAnnouncement = NO;
  
  self.announcementCheckCallBackTarget = target;
  NSUInteger fetchCount = 2;
  NSString *params = [NSString stringWithFormat:@"?sort=new&limit=%d", fetchCount];
  NSString *url;
  
  if ([Resources isIPAD])
    url = [[NSString alloc] initWithFormat:@"%@%@.json%@", self.server, @"/user/alien-blue-hd/submitted/", params];
  else
    url = [[NSString alloc] initWithFormat:@"%@%@.json%@", self.server, @"/user/alien-blue/submitted/", params];
  
  [self doGetURL:url withConnectionCategory:kConnectionCategorySubreddit callBackTarget:self callBackMethod:@selector(latestAnnouncementResponse:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)latestAnnouncementResponse:(id)sender
{
  NSData *data = (NSData *) sender;
  JMJSONParser *parser = [[JMJSONParser alloc] init];
  NSString *responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  
  if (![responseString jm_contains:@"alien-blue"])
    return;
  
  NSMutableDictionary *response = [parser objectWithString:responseString error:nil];
  if (!response)
    return;
  
  if (![response isKindOfClass:[NSDictionary class]])
    return;
  
  if ([response objectForKey:@"data"] &&
      [[response objectForKey:@"data"] objectForKey:@"children"] &&
      [[[response objectForKey:@"data"] objectForKey:@"children"] count] > 0)
  {
    NSDictionary * post_data = [[[response objectForKey:@"data"] objectForKey:@"children"] objectAtIndex:0];
    
    RedditsViewController *controller = JMCastOrNil(self.announcementCheckCallBackTarget, RedditsViewController);
    [controller apiAnnouncementCheckResponse:[post_data objectForKey:@"data"]];
    self.announcementCheckCallBackTarget = nil;
  }
}

- (void)clearAnnouncementCheckCallbacks;
{
  self.announcementCheckCallBackTarget = nil;
}

@end
