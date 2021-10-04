#import "RedditAPI.h"

@interface RedditAPI (OAuth)

- (void)setActiveUsername:(NSString *)username;

- (void)authenticateAndPersistTokensWithUsername:(NSString *)username password:(NSString *)password onComplete:(JMAction)onComplete onFailure:(JMOnErrorAction)onError;
- (void)establishAuthenticationForCurrentUserOnComplete:(JMAction)onComplete onFailure:(void(^)(NSString *errorMessage, BOOL isSupercededByNewerAttempt))onFailure;

- (void)deauthenticateUsername:(NSString *)username;
- (void)cancelTokenRefreshTimers;

- (BOOL)hasAuthenticatableUser;

- (NSString *)recommendedServerForActiveUser;
- (NSDictionary *)generateOAuthAuthenticationHeadersForRedditRequest;

- (void)deleteLegacyKeychainItemForUsername:(NSString *)username;

@end
