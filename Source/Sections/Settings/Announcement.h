
#define kAnnouncementReceivedNotification @"kAnnouncementReceivedNotification"
#define kAnnouncementMarkedReadNotification @"kAnnouncementMarkedReadNotification"

@interface Announcement : NSObject

@property NSInteger ident;
@property BOOL showsOnPhones;
@property BOOL showsOnPads;
@property CGFloat minVersion;
@property CGFloat maxVersion;
@property BOOL showsImmediately;
@property BOOL showsBanner;

@property (strong) NSString *title;
@property (strong) NSString *content;

@property (strong) NSString *link1Url;
@property (strong) NSString *link1Title;
@property BOOL link1OpensInSafari;

@property (strong) NSString *link2Url;
@property (strong) NSString *link2Title;
@property BOOL link2OpensInSafari;

@property (strong) NSString *link3Url;
@property (strong) NSString *link3Title;
@property BOOL link3OpensInSafari;

@property (strong) NSString *commentFeedUrl;
@property BOOL commentFeedOpensInSafari;

@property (readonly) BOOL hasLink1;
@property (readonly) BOOL hasLink2;
@property (readonly) BOOL hasLink3;
@property (readonly) BOOL hasCommentFeed;

@property (readonly) BOOL shouldShow;

+ (void)checkAnnouncements;

+ (void)markLatestAnnouncementAsRead;
+ (Announcement *)latestAnnouncement;

@end
