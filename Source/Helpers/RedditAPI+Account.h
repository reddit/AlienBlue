#import "RedditAPI.h"

@interface RedditAPI (Account)

@property (readonly, strong) NSString *authenticatedUser;
@property (readonly) BOOL authenticated;
@property NSUInteger base10Id;
@property BOOL isMod;
@property BOOL hasMail;
@property BOOL hasModMail;
@property BOOL isOver18;
@property BOOL isGold;
@property NSInteger karmaLink;
@property NSInteger karmaComment;

@property BOOL currentlyAuthenticating;

- (void)prepareDefaultUserState;
- (void)fetchUserInfo:(NSString *)username withCallback:(id)target;
- (void)updateUserStateWithDictionary:(NSDictionary *)responseDictionary;
- (void)resetConnectionsForUserDetails;

@end
