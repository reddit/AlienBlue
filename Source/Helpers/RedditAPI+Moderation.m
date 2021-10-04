#import "RedditAPI+Moderation.h"
#import "RedditAPI+DeprecationPatches.h"

@interface RedditAPI (Moderation_)
@end

@implementation RedditAPI (Moderation)

- (void)modRemoveItemWithName:(NSString *)name spam:(BOOL)spam;
{
  NSString *executedStr = spam ? @"spammed" : @"removed";
  NSString *spamStr = spam ? @"True" : @"False";
  NSString *url = [[NSString alloc] initWithFormat:@"%@/api/remove", self.server];
  NSString *params = [[NSString alloc] initWithFormat:@"api_type=json&spam=%@&executed=%@&id=%@", spamStr, executedStr, name];
  [self doPostToURL:url withParams:params connectionCategory:kConnectionCategoryOther callBackTarget:self callBackMethod:@selector(modRemoveResponseReceived:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)modMarkAsSpamItemWithName:(NSString *)name;
{
  [self modRemoveItemWithName:name spam:YES];
}

- (void)modRemoveItemWithName:(NSString *)name;
{
  [self modRemoveItemWithName:name spam:NO];
}

- (void)modDistinguishItemWithName:(NSString *)name distinguish:(BOOL)distinguish;
{
  NSString *howStr = distinguish ? @"yes" : @"no";
  NSString *url = [[NSString alloc] initWithFormat:@"%@/api/distinguish", self.server];
  NSString *params = [[NSString alloc] initWithFormat:@"api_type=json&executed=distinguishing&id=%@&how=%@", name, howStr];
  [self doPostToURL:url withParams:params connectionCategory:kConnectionCategoryOther callBackTarget:self callBackMethod:@selector(modDistinguishResponseReceived:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)modApproveItemWithName:(NSString *)name;
{
  NSString *url = [[NSString alloc] initWithFormat:@"%@/api/approve",self.server];
  NSString *params = [[NSString alloc] initWithFormat:@"api_type=json&executed=approved&id=%@", name];
  [self doPostToURL:url withParams:params connectionCategory:kConnectionCategoryOther callBackTarget:self callBackMethod:@selector(modApproveResponseReceived:) failedMethod:@selector(connectionFailedDialog:)];
}

@end
