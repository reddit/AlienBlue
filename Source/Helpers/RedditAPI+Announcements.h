#import "RedditAPI.h"

@interface RedditAPI (Announcements)
- (void)prepareAnnouncementChecking;
//- (void)checkRedditStatus;
- (void)checkLatestAnnouncementsIfAllowedWithCallBackTarget:(id)target;
- (void)clearAnnouncementCheckCallbacks;
@end
