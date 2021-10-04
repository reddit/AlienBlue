#import "AlienBlueAppDelegate+UAT.h"
#import "Resources.h"

#if TARGET_IPHONE_SIMULATOR
#if DEBUG
  #import "DCIntrospect.h"
#endif
#endif

#ifdef ENABLE_HOCKEY
    #import <HockeySDK/HockeySDK.h>
#endif

@implementation AlienBlueAppDelegate(UAT)

- (void)enableAcceptanceTestingIfNecessary;
{
  #if TARGET_IPHONE_SIMULATOR
  #if DEBUG
  [[DCIntrospect sharedIntrospector] start];
  #endif
  #endif
    
  #ifdef ENABLE_HOCKEY
    NSString *hockeyIdent = JMIsIpad() ? @"" : @"";
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:hockeyIdent];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    DLog(@"enabled hockey : %@", hockeyIdent);
  #endif
}

@end
