//  REDInboxViewController.m
//  RedditApp

#import "RedditApp/REDInboxViewController.h"

#import "Helpers/RedditAPI+Account.h"
#import "Sections/Messages/MessagesViewController.h"

@interface REDInboxViewController ()
@property(nonatomic, strong) MessagesViewController *messagesViewController;
@end

@implementation REDInboxViewController

- (instancetype)init {
  if (self = [super init]) {
    NSString *defaultBoxUrl = [RedditAPI shared].hasModMail && ![RedditAPI shared].hasMail
                                  ? @"/message/moderator/"
                                  : @"/message/inbox/";
    self.messagesViewController = [[MessagesViewController alloc] initWithBoxUrl:defaultBoxUrl];
    [self addChildViewController:self.messagesViewController];
  }
  return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationController.navigationBarHidden = YES;
  [self.view addSubview:self.messagesViewController.view];
  [self setTabBarIconWithImageName:@"tab_inbox" selectedImageName:@"tab_inbox_dn"];
}

@end
