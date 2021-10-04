#import "ABNotificationManager.h"
#import "RedditAPI.h"
#import "JSONKit.h"
#import "NavigationManager.h"
#import "RedditAPI+Account.h"

#define kABNotificationOpenInboxActionLabel @"Open"
#define kABNotificationHasRequestedPermissionForBackgroundNotifications @"kABNotificationHasRequestedPermissionForBackgroundNotifications"

@interface ABNotificationManager()
@property (readonly) BOOL shouldCheckInbox;
@property (strong) NSDate *lastMessageCheckDate;
@end

@implementation ABNotificationManager

+ (ABNotificationManager *)manager;
{
  JM_SHARED_INSTANCE_USING_BLOCK(^{
    return [[self alloc] init];
  });
}

- (BOOL)userDisallowsSystemNotifications;
{
  if (![[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)])
    return YES;
  
  UIUserNotificationSettings *notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
  return notificationSettings.types == UIUserNotificationTypeNone;
}

- (void)askPermissionForLocalNotificationsIfNecessary;
{
  if (![UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    return;
  
  if (![UDefaults boolForKey:kABSettingKeyAllowBackgroundNotifications])
    return;
  
  if ([UDefaults boolForKey:kABNotificationHasRequestedPermissionForBackgroundNotifications])
    return;
  
  UIUserNotificationType notificationTypes = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
  UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
  [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
  [UDefaults setBool:YES forKey:kABNotificationHasRequestedPermissionForBackgroundNotifications];
}

- (BOOL)shouldCheckInbox;
{
  if (![RedditAPI shared].authenticated)
    return NO;
  
  if (!JMIsIOS7())
    return NO;
  
  if (![UDefaults boolForKey:kABSettingKeyAllowBackgroundNotifications])
    return NO;
  
  if ([self userDisallowsSystemNotifications])
    return NO;
  
  return YES;
}

- (void)checkIfUserHasMailOnComplete:(void(^)(BOOL hasMail, BOOL hasModMail))onComplete;
{
	NSString *userStatsUrl = [NSString stringWithFormat:@"/api/v1/me"];
  NSURLRequest *request = [[RedditAPI shared] requestForUrl:userStatsUrl];
  NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error || !data || JMIsClass(data, NSNull) || data.length < 120)
    {
      DLog(@"bg retrieve error : %@", error);
      onComplete(NO, NO);
    }
    else
    {
      NSDictionary *JSON = [data objectFromJSONData];
      if (JSON && JMIsClass(JSON, NSDictionary) && [JSON objectForKey:@"has_mail"])
      {
        BOOL hasMail = [[JSON valueForKeyPath:@"has_mail"] boolValue];
        BOOL hasModMail = [[JSON valueForKeyPath:@"has_mod_mail"] boolValue];
        onComplete(hasMail, hasModMail);
      }
      else
      {
        onComplete(NO, NO);
      }
    }
  }];
  [task resume];
}

- (void)retrieveUnreadMessagesAtBaseUrl:(NSString *)baseUrl skipWhen:(BOOL)skipWhen onComplete:(void(^)(NSArray *unreadMessages))onComplete;
{
  if (skipWhen)
  {
    onComplete([NSArray new]);
    return;
  }
  
  NSString *apiUrl = [NSString stringWithFormat:@"%@/.json?mark=false&limit=5", baseUrl];
  DLog(@"%@", apiUrl);
  NSURLRequest *request = [[RedditAPI shared] requestForUrl:apiUrl];
  NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (JMIsNull(data) || [data bytes] == NULL)
    {
      onComplete([NSArray new]);
      return;
    }
    
    NSDictionary *JSON = [data mutableObjectFromJSONData];
    if (JSON && JMIsClass(JSON, NSDictionary) && [JSON objectForKey:@"data"] && [JSON valueForKeyPath:@"data.children"])
    {
      NSArray *messageDictionaries = [JSON valueForKeyPath:@"data.children"];
      if (![apiUrl jm_contains:@"moderator"])
      {
        messageDictionaries = [messageDictionaries select:^BOOL(NSDictionary *messageDictionary) {
          return [[messageDictionary valueForKeyPath:@"data.new"] boolValue];
        }];
      }
      [messageDictionaries each:^(NSMutableDictionary *dictionary) {
        [dictionary setValue:baseUrl forKeyPath:@"data.requestUrl"];
      }];
      onComplete(messageDictionaries);
    }
    else
    {
      onComplete([NSArray new]);
    }
  }];
  [task resume];
}

- (NSArray *)sortMessagesByOldestFirst:(NSArray *)unsortedMessages;
{
  NSArray *sortedMessages = [unsortedMessages sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
    NSTimeInterval obj1UTC = [[obj1 valueForKeyPath:@"data.created_utc"] floatValue];
    NSTimeInterval obj2UTC = [[obj2 valueForKeyPath:@"data.created_utc"] floatValue];
    if (obj1UTC > obj2UTC)
      return NSOrderedDescending;
    else if (obj1UTC < obj2UTC)
      return NSOrderedAscending;
    else
      return NSOrderedSame;
  }];
  return sortedMessages;
}

- (void)retrieveAllUnreadMessagesOnComplete:(void(^)(NSArray *unreadMessages))onComplete;
{
  [self checkIfUserHasMailOnComplete:^(BOOL hasMail, BOOL hasModMail) {
    BOOL skipModMail = !hasModMail || ![UDefaults boolForKey:kABSettingKeyAlertForModeratorMail];
    BOOL skipInbox = !hasMail || (![UDefaults boolForKey:kABSettingKeyAlertForDirectMessages] && ![UDefaults boolForKey:kABSettingKeyAlertForCommentReplies]);
    [self retrieveUnreadMessagesAtBaseUrl:@"message/unread" skipWhen:skipInbox onComplete:^(NSArray *unreadInboxMessages) {
      [self retrieveUnreadMessagesAtBaseUrl:@"message/moderator" skipWhen:skipModMail onComplete:^(NSArray *unreadModeratorMessages) {
        NSMutableArray *allUnreadItems = [NSMutableArray new];
        [allUnreadItems addObjectsFromArray:unreadInboxMessages];
        [allUnreadItems addObjectsFromArray:unreadModeratorMessages];
        onComplete(allUnreadItems);
      }];
    }];
  }];
}

- (NSArray *)filterMessagesThatRequireNotification:(NSArray *)messageDictionaries;
{
  if (!self.lastMessageCheckDate)
  {
    NSTimeInterval oneDayEarlier = -1 * 60 * 60 * 24;
    self.lastMessageCheckDate = [[NSDate date] dateByAddingTimeInterval:oneDayEarlier];
  }
  
  NSTimeInterval cutOffDate = [self.lastMessageCheckDate timeIntervalSince1970];
  NSArray *messagesRequiringNotification = [messageDictionaries select:^BOOL(NSDictionary *dictionary) {
    NSTimeInterval messageUTC = [[dictionary valueForKeyPath:@"data.created_utc"] floatValue];
    if (messageUTC < cutOffDate)
    {
      DLog(@"filtering out message due to cutoff date requirement (messageUTC : %f vs cutOffUTC : %f)", messageUTC, cutOffDate);
    }
    return messageUTC >= cutOffDate;
  }];
  
  if (![UDefaults boolForKey:kABSettingKeyAlertForDirectMessages])
  {
    messagesRequiringNotification = [messagesRequiringNotification reject:^BOOL(NSDictionary *dictionary) {
      return JMIsEmpty([dictionary valueForKeyPath:@"data.subreddit"]);
    }];
  }
  
  if (![UDefaults boolForKey:kABSettingKeyAlertForCommentReplies])
  {
    messagesRequiringNotification = [messagesRequiringNotification reject:^BOOL(NSDictionary *dictionary) {
      return !JMIsEmpty([dictionary valueForKeyPath:@"data.subreddit"]) && ![[dictionary valueForKeyPath:@"data.requestUrl"] jm_contains:@"moderator"];
    }];
  }
  
  return messagesRequiringNotification;
}

- (void)scheduleNotificationsFromMessages:(NSArray *)messageDictionaries;
{
  if (![UDefaults boolForKey:kABSettingKeyShowAlertPreviewsOnLockScreen] && messageDictionaries.count > 0)
  {
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = [NSString stringWithFormat:@"You have %d unread message(s) since last check", messageDictionaries.count];
    localNotification.alertAction = kABNotificationOpenInboxActionLabel;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    return;
  }
  
  NSArray *sortedMessages = [self sortMessagesByOldestFirst:messageDictionaries];
  
  __block NSUInteger badgeNumberCounter = 0;
  NSArray *notifications = [sortedMessages map:^id(NSDictionary *d) {
    badgeNumberCounter++;
    UILocalNotification *localNotification = [UILocalNotification new];
    NSString *body = [[d valueForKeyPath:@"data.body"] jm_truncateToLength:300];
    body = [body jm_replace:@"&gt;" withString:@">"];
    body = [body jm_replace:@"&lt;" withString:@"<"];
    body = [body jm_replace:@"&amp;" withString:@"&"];
    
    NSString *author = [d valueForKeyPath:@"data.author"];
    NSString *prefix = [[d valueForKeyPath:@"data.requestUrl"] jm_contains:@"moderator"] ? @"[Mod] " : @"";
    if (JMIsEmpty(author))
    {
      author = @"reddit";
    }
    NSString *message = [NSString stringWithFormat:@"%@%@ : %@", prefix, author, body];
  
//    NSTimeInterval timeSince1970 = [[d valueForKeyPath:@"data.created_utc"] floatValue];
//    NSDate *notificationTimestamp = [[NSDate alloc] initWithTimeIntervalSince1970:timeSince1970];
//    localNotification.fireDate = notificationTimestamp;
    localNotification.alertBody = message;
    localNotification.alertAction = kABNotificationOpenInboxActionLabel;
    localNotification.applicationIconBadgeNumber = badgeNumberCounter;
		localNotification.soundName = UILocalNotificationDefaultSoundName;
    return localNotification;
  }];
  
  [notifications each:^(UILocalNotification *item) {
    [[UIApplication sharedApplication] presentLocalNotificationNow:item];
  }];
}

- (void)handleRedditNotificationsOnComplete:(void(^)(BOOL hasNewData))onComplete;
{
  DLog(@"handleRedditNotificationsOnComplete in()");
  if (!self.shouldCheckInbox)
  {
    if (onComplete) onComplete(NO);
    return;
  }

  [self retrieveAllUnreadMessagesOnComplete:^(NSArray *unreadMessages) {
    DLog(@"retrieved unread messages : %d", unreadMessages.count);
    NSArray *notificationMessages = [self filterMessagesThatRequireNotification:unreadMessages];
    DLog(@"scheduled number of messages : %d", notificationMessages.count);
    [self scheduleNotificationsFromMessages:notificationMessages];
    BOOL didReceiveNewData = notificationMessages.count > 0;
    if (didReceiveNewData)
    {
      self.lastMessageCheckDate = [NSDate date];
    }
    DO_IN_MAIN(^{
      onComplete(didReceiveNewData);
    });
  }];
}

- (void)applicationDidBecomeActive;
{
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidEnterBackground;
{
  self.lastMessageCheckDate = [NSDate date];
}

- (void)applicationWillResignActive;
{
  [self applicationDidEnterBackground];
}

- (BOOL)handleLocalNotification:(UILocalNotification *)localNotification;
{
  BOOL canHandleNotification = [localNotification.alertAction jm_matches:kABNotificationOpenInboxActionLabel];
  if (!canHandleNotification)
    return NO;
 
  DO_AFTER_WAITING(2, ^{
    [[NavigationManager shared] showMessagesScreen];
  });
  
  return YES;
}

@end
