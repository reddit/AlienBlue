#import "SessionManager+Authentication.h"

#import "NavigationManager.h"
#import "RedditAPI+Account.h"
#import "RedditAPI+OAuth.h"
#import "SFHFKeychainUtils.h"
#import "ReachabilityCoordinator.h"
#import "AlienBlueAppDelegate.h"

@interface SessionManager(Authentication_)
@property (weak) id<NSObject> switchAccountCallbackTarget;
@property (strong) NSTimer *inboxCheckTimer;
@end

@implementation SessionManager (Authentication)

SYNTHESIZE_ASSOCIATED_WEAK(NSObject, switchAccountCallbackTarget, SwitchAccountCallbackTarget);
SYNTHESIZE_ASSOCIATED_STRONG(NSString, switchBackToAccountUsername, SwitchBackToAccountUsername);
SYNTHESIZE_ASSOCIATED_BOOL(shouldSwitchBackToMainAccountAfterPosting, ShouldSwitchBackToMainAccountAfterPosting);
SYNTHESIZE_ASSOCIATED_STRONG(NSTimer, inboxCheckTimer, InboxCheckTimer)

- (void)switchAccountResponse:(id)sender;
{
}

- (void)resetSwitchAccountCallback;
{
  self.switchAccountCallbackTarget = nil;
}

- (void)handleSwitchBackToMainAccountIfNecessary;
{
  if (!self.switchBackToAccountUsername)
    return;
  
  if ([self.switchBackToAccountUsername jm_matches:[UDefaults stringForKey:@"username"]])
    return;
  
  if (!self.shouldSwitchBackToMainAccountAfterPosting)
    return;
  
  [self switchToRedditAccountUsername:self.switchBackToAccountUsername withCallBackTarget:self];

  self.switchBackToAccountUsername = nil;
  self.shouldSwitchBackToMainAccountAfterPosting = NO;
}

- (void)switchToRedditAccountAtIndex:(NSUInteger)accountIndex withCallBackTarget:(id)target;
{
  NSMutableArray *redditAccountsList = [NSMutableArray arrayWithArray:[UDefaults objectForKey:kABSettingKeyRedditAccountsList]];
    
  if (accountIndex > [redditAccountsList count] - 1)
    return;
  
  NSMutableDictionary *userAccount = (NSMutableDictionary *) [redditAccountsList objectAtIndex:accountIndex];
  NSString *activeUserName = [userAccount valueForKey:@"username"];
  [[RedditAPI shared] setActiveUsername:activeUserName];
  
  self.switchAccountCallbackTarget = target;
  BSELF(SessionManager);
  [[RedditAPI shared] establishAuthenticationForCurrentUserOnComplete:^{
    [blockSelf apiLoginResponse:nil];
  } onFailure:^(NSString *errorMessage, BOOL isSupercededByNewerAttempt) {
      if (!isSupercededByNewerAttempt)
      {
        [UIAlertView bk_showAlertViewWithTitle:@"Login Failed" message:errorMessage cancelButtonTitle:@"OK" otherButtonTitles:nil handler:nil];
      }
  }];
}

- (void)forceReauthenticationForActiveUser;
{
  [self switchToRedditAccountUsername:[UDefaults objectForKey:@"username"] withCallBackTarget:nil];
}

- (void)switchToRedditAccountUsername:(NSString *)username withCallBackTarget:(id)target;
{
  NSMutableArray *redditAccountsList = [NSMutableArray arrayWithArray:[UDefaults objectForKey:kABSettingKeyRedditAccountsList]];
  
  NSDictionary *matchingAccountDictionary = [redditAccountsList match:^BOOL(NSDictionary *account) {
    return [[account objectForKey:@"username"] jm_matches:username];
  }];
  
  if (!matchingAccountDictionary)
    return;

  NSUInteger matchingAccountIndex = [redditAccountsList indexOfObject:matchingAccountDictionary];
  [self switchToRedditAccountAtIndex:matchingAccountIndex withCallBackTarget:target];
}

- (void)apiLoginResponse:(id)sender;
{
  if (![RedditAPI shared].authenticated)
    return;
  
  NSString *authenticatedUsername = [RedditAPI shared].authenticatedUser;

  [[NSNotificationCenter defaultCenter] postNotificationName:kABAuthenticationStatusDidSucceedNotification object:authenticatedUsername];
  
  [self checkForNewMessages];
  [self activateInboxCheckTimerIfNecessary];
  
  if (self.switchAccountCallbackTarget)
  {
    [self.switchAccountCallbackTarget performSelector:@selector(switchAccountResponse:) withObject:nil];
  }
}

- (NSTimeInterval)recommendedTimeIntervalForInboxChecking;
{
  NSUInteger frequencySelection = [UDefaults integerForKey:kABSettingKeyMessageCheckFrequencyIndex];
  NSTimeInterval checkTimeInterval;
  if (frequencySelection == 1)
    checkTimeInterval = 5 * 60;
  else if (frequencySelection == 2)
    checkTimeInterval = 10 * 60;
  else if (frequencySelection == 3)
    checkTimeInterval = 20 * 60;
  else
    checkTimeInterval = -1;
  return checkTimeInterval;
}

- (void)activateInboxCheckTimerIfNecessary;
{
  NSTimeInterval inboxCheckTimeInterval = [self recommendedTimeIntervalForInboxChecking];

  if (inboxCheckTimeInterval <= 0)
    return;
  
  if (self.inboxCheckTimer && self.inboxCheckTimer.timeInterval == inboxCheckTimeInterval)
    return;
  
  self.inboxCheckTimer = [NSTimer scheduledTimerWithTimeInterval:inboxCheckTimeInterval target:self selector:@selector(checkForNewMessages) userInfo:nil repeats:YES];
}

- (void)checkForNewMessages;
{
  if (![RedditAPI shared].authenticated)
    return;
  
  [[RedditAPI shared] fetchUserInfo:[[RedditAPI shared] authenticatedUser] withCallback:self];
}

- (void)userInfoResponse:(id)response
{
  [[RedditAPI shared] updateUserStateWithDictionary:response];
  [self postUpdatedUserInformationNotification];
}

- (void)authenticationResponseReceived:(id)sender
{
  if ([RedditAPI shared].authenticated)
  {
//    [[NavigationManager shared] refreshUserSubreddits];
    [self activateInboxCheckTimerIfNecessary];
    [self postUpdatedUserInformationNotification];
  }
  [RedditAPI shared].currentlyAuthenticating = NO;
}

- (void)postUpdatedUserInformationNotification;
{
  [[NSNotificationCenter defaultCenter] postNotificationName:kABAuthenticationStatusDidReceiveUpdatedUserInformation object:nil];
}

- (void)didManuallyUpdateUserInformation;
{
  [self postUpdatedUserInformationNotification];
}

- (void)establishAuthenticationForCurrentUserWithAttemptedCount:(NSUInteger)attemptCount
{
  if ([RedditAPI shared].currentlyAuthenticating)
    return;
  
  [RedditAPI shared].currentlyAuthenticating = YES;
  [[RedditAPI shared] establishAuthenticationForCurrentUserOnComplete:^{
    [self authenticationResponseReceived:nil];
  } onFailure:^(NSString *errorMessage, BOOL isSupercededByNewerAttempt) {
    [RedditAPI shared].currentlyAuthenticating = NO;
    BOOL isInForeground = [(AlienBlueAppDelegate *) [[UIApplication sharedApplication] delegate] isActiveInForeground];
    BOOL isNetworkReachable = [[ReachabilityCoordinator shared] isReachable];
    BOOL isAuthenticatedFromAnotherRequest = [RedditAPI shared].authenticated;
    BOOL errorRequiresHandling = isInForeground && isNetworkReachable && !isSupercededByNewerAttempt && !isAuthenticatedFromAnotherRequest;
    
    // todo: need to find out why timeouts are sometimes/but rarely occurring when returning to foreground
    // notes: we are occassionally seeing timeout errors occur when device returns to foreground
    // these are typically false alarms, and authentication is established regardless in subsequent
    // requests - will hacky patch for now to avoid further delaying release... but will need to work
    // out why these "timed out" messages are activating
    BOOL isTimeOutError = [errorMessage jm_contains:@"[0]"];
    BOOL isUnauthorizedError = [errorMessage jm_contains:@"[403]"];
    
    BOOL shouldAutomaticallyReattempt = errorRequiresHandling && (isTimeOutError || isUnauthorizedError) && attemptCount < 3;
    if (shouldAutomaticallyReattempt)
    {
      DO_AFTER_WAITING(1, ^{
        [self establishAuthenticationForCurrentUserWithAttemptedCount:(attemptCount + 1)];
      });
    }
    
    BOOL needToDisplayErrorDialog = errorRequiresHandling && !shouldAutomaticallyReattempt && !isTimeOutError;
    if (needToDisplayErrorDialog)
    {
      NSDateFormatter *dateFormatter = [NSDateFormatter new];
      [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
      [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
      NSString *formattedDateString = [dateFormatter stringFromDate:[NSDate date]];
      NSString *message = [NSString stringWithFormat:@"%@\n\n%@", formattedDateString, errorMessage];
      
      UIAlertView *errorDialog = [UIAlertView bk_alertViewWithTitle:@"Login Failed" message:message];
      [errorDialog bk_addButtonWithTitle:@"Try Again" handler:^{
        [self establishAuthenticationForCurrentUser];
      }];
      [errorDialog bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
      [errorDialog show];
    }
  }];
}

- (void)establishAuthenticationForCurrentUser;
{
  [self establishAuthenticationForCurrentUserWithAttemptedCount:0];
}

- (void)handleAuthenticationForApplicationLaunching;
{
  [self establishAuthenticationForCurrentUser];
}

- (void)handleAuthenticationForApplicationDidBecomeActive;
{
  [self establishAuthenticationForCurrentUser];
}

- (void)handleAuthenticationForApplicationDidEnterBackground;
{
  [RedditAPI shared].currentlyAuthenticating = NO;
  [[RedditAPI shared] cancelTokenRefreshTimers];
}

- (void)doAfterAuthenticationProcessIsComplete:(JMAction)afterAuthenticationAction;
{
  if (![RedditAPI shared].currentlyAuthenticating)
  {
    afterAuthenticationAction();
    return;
  }
  
  [self performSelector:@selector(doAfterAuthenticationProcessIsComplete:) withObject:afterAuthenticationAction afterDelay:0.1];
}

- (void)userDidDeleteAccountWithUsername:(NSString *)username;
{
  [[RedditAPI shared] deauthenticateUsername:username];
}

@end
