#import "ABOutlineViewController.h"

@class Announcement;
@interface AnnouncementViewController : ABOutlineViewController

- (id)initWithAnnouncement:(Announcement *)announcement;

+ (void)showLatest;

@end
