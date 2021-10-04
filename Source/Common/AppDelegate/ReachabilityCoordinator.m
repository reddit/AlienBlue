#import "ReachabilityCoordinator.h"
#import "SHKReachability.h"
#import "RedditAPI.h"
#import "NavigationManager.h"

#define Reachability SHKReachability

@interface ReachabilityCoordinator()
@property (strong) Reachability* hostReach;
@property (strong) Reachability* internetReach;
@property (strong) Reachability* wifiReach;
@property BOOL previouslyWasReachable;
@property BOOL didReceiveReachabilityResponse;
@property (copy) JMAction onReachableAction;
@end

@implementation ReachabilityCoordinator

+ (ReachabilityCoordinator *)shared;
{
  JM_SHARED_INSTANCE_USING_BLOCK(^{
    return [[self alloc] init];
  });
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)clearExistingReachabilityMonitors;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];

  [self.hostReach stopNotifier];
  [self.internetReach stopNotifier];
  [self.wifiReach stopNotifier];

  self.hostReach = nil;
  self.internetReach = nil;
  self.wifiReach = nil;
  
  self.previouslyWasReachable = NO;
  self.didReceiveReachabilityResponse = NO;
}

- (void)startMonitoringReachability;
{
  [self clearExistingReachabilityMonitors];
  
  [[NSNotificationCenter defaultCenter] addObserver: self
                                           selector: @selector(reachabilityChanged:)
                                               name: kReachabilityChangedNotification object: nil];
  
  self.hostReach = [Reachability reachabilityWithHostName:@"reddit.com"];
  [self.hostReach connectionRequired];
  [self.hostReach startNotifier];
  
  self.internetReach = [Reachability reachabilityForInternetConnection];
  [self.internetReach startNotifier];
  
  self.wifiReach = [Reachability reachabilityForLocalWiFi];
  [self.wifiReach startNotifier];
}

- (void)reachabilityChanged:(NSNotification* )note
{
  Reachability* curReach = [note object];
  NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
  DLog(@"%@", curReach);
  self.didReceiveReachabilityResponse = YES;
  [self updateInterfaceWithReachability:curReach];
}

- (BOOL)isReachable;
{
  if (!self.didReceiveReachabilityResponse)
  {
    DLog(@"[--] haven't received reachability response yet... assume unreachable");
    return NO;
  }
  
  BOOL hostReachable = [self.hostReach currentReachabilityStatus] != NotReachable;
  BOOL internetReachable = [self.internetReach currentReachabilityStatus] != NotReachable;
//  BOOL wifiReachable = [self.wifiReach currentReachabilityStatus] != NotReachable;
  
  BOOL reachable = internetReachable && hostReachable;
//  DLog(@"host reachable :: %d", hostReachable);
//  DLog(@"net  reachable :: %d", internetReachable);
//  DLog(@"wifi reachable :: %d", wifiReachable);
//  DLog(@"-----------------------------------");
  return reachable;
}

- (void)updateInterfaceWithReachability:(Reachability *)curReach;
{
  if (curReach == self.hostReach)
  {
    DLog(@"[+] HOST REACH RESPONSE :: %d", [self.hostReach currentReachabilityStatus] != NotReachable);
    if ([self.hostReach currentReachabilityStatus] == NotReachable)
    {
      DLog(@"break");
    }
  }
  
  if (curReach == self.internetReach)
  {
    DLog(@"[+] NET REACH RESPONSE  :: %d", [self.internetReach currentReachabilityStatus] != NotReachable);
  }
  
  if (curReach == self.wifiReach)
  {
    DLog(@"[+] WIFI REACH RESPONSE :: %d", [self.wifiReach currentReachabilityStatus] != NotReachable);
  }

  
  BOOL reachable = [self isReachable];
  if (!reachable && [UDefaults boolForKey:kABSettingKeyShowConnectionErrors])
  {
    [self showConnectionErrorImage];
  }
  else
  {
    [self hideConnectionErrorImage];
  }
  
  [self checkAndExecuteOnReachableActionsIfNecessary];
}

- (void)checkAndExecuteOnReachableActionsIfNecessary;
{
  if (!self.previouslyWasReachable && [self isReachable])
  {
    DLog(@"[*] did become reachable");
    if (self.onReachableAction)
    {
      self.onReachableAction();
    }
  }
  self.previouslyWasReachable = [self isReachable];
}

- (void)showConnectionErrorImage
{
  if (!self.didReceiveReachabilityResponse)
    return;
  
  [PromptManager showConnectionErrorHud];
}

- (void)hideConnectionErrorImage
{
  [PromptManager hideHud];
}

- (void)updateNetworkConnectionStatus;
{
  [self updateInterfaceWithReachability:nil];
}

- (void)handleApplicationBecomingInactive;
{
  DLog(@"becoming inactive");
  [self clearExistingReachabilityMonitors];
}

- (void)handleApplicationBecomingActiveDoWhenReachable:(JMAction)onReachableAction;
{
  DLog(@"did become active");
  self.onReachableAction = onReachableAction;
  [self startMonitoringReachability];
  
  [self checkAndExecuteOnReachableActionsIfNecessary];
  [self hideConnectionErrorImage];
  BSELF(ReachabilityCoordinator);
  DO_AFTER_WAITING(3.5, ^{
    [blockSelf updateNetworkConnectionStatus];
  });
}

- (NSString *)statusSummary
{
  BOOL hostReachable = [self.hostReach currentReachabilityStatus] != NotReachable;
  BOOL internetReachable = [self.internetReach currentReachabilityStatus] != NotReachable;
  BOOL wifiReachable = [self.wifiReach currentReachabilityStatus] != NotReachable;

  return [NSString stringWithFormat:@"H : %d, I : %d, W : %d, R : %d", hostReachable, internetReachable, wifiReachable, [self isReachable]];
}

@end
