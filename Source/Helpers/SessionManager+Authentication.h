#import "SessionManager.h"

@interface SessionManager(Authentication)
- (void)didManuallyUpdateUserInformation;

// app delegate hooks
- (void)handleAuthenticationForApplicationLaunching;
- (void)handleAuthenticationForApplicationDidBecomeActive;
- (void)handleAuthenticationForApplicationDidEnterBackground;

// account switching
@property BOOL shouldSwitchBackToMainAccountAfterPosting;
@property (strong) NSString *switchBackToAccountUsername;
- (void)handleSwitchBackToMainAccountIfNecessary;
- (void)switchToRedditAccountUsername:(NSString *)username withCallBackTarget:(id)target;
- (void)switchToRedditAccountAtIndex:(NSUInteger)accountIndex withCallBackTarget:(id)target;
- (void)resetSwitchAccountCallback;
- (void)doAfterAuthenticationProcessIsComplete:(JMAction)afterAuthenticationAction;
- (void)userDidDeleteAccountWithUsername:(NSString *)username;
- (void)forceReauthenticationForActiveUser;

@end
