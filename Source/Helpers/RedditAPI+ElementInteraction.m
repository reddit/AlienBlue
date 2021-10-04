#import "RedditAPI+ElementInteraction.h"
#import "RedditAPI+DeprecationPatches.h"

@interface RedditAPI (ElementInteraction_)

@end

@implementation RedditAPI (ElementInteraction)

- (void)reportPostWithID:(NSString *)postID;
{
  NSString *url = [[NSString alloc] initWithFormat:@"%@/api/report",self.server];
  NSString *params = [[NSString alloc] initWithFormat:@"api_type=json&executed=reported&id=%@",postID];
  [self doPostToURL:url withParams:params connectionCategory:kConnectionCategoryOther callBackTarget:self callBackMethod:@selector(saveResponseReceived:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)unsavePostWithID:(NSString *)postID
{
  NSString *url = [[NSString alloc] initWithFormat:@"%@/api/unsave",self.server];
  NSString *params = [[NSString alloc] initWithFormat:@"api_type=json&executed=unsaved&id=%@",postID];
  [self doPostToURL:url withParams:params connectionCategory:kConnectionCategoryOther callBackTarget:self callBackMethod:@selector(unsaveResponseReceived:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)savePostWithID:(NSString *)postID
{
  NSString *url = [[NSString alloc] initWithFormat:@"%@/api/save", self.server];
  NSString *params = [[NSString alloc] initWithFormat:@"api_type=json&executed=saved&id=%@",postID];
  [self doPostToURL:url withParams:params connectionCategory:kConnectionCategoryOther callBackTarget:self callBackMethod:@selector(saveResponseReceived:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)unhidePostWithID:(NSString *)postID
{
  NSString * url = [[NSString alloc] initWithFormat:@"%@/api/unhide", self.server];
  NSString * params = [[NSString alloc] initWithFormat:@"api_type=json&executed=unhidden&id=%@",postID];
  [self doPostToURL:url withParams:params connectionCategory:kConnectionCategoryOther callBackTarget:self callBackMethod:@selector(unhideResponseReceived:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)hidePostWithID:(NSString *)postID
{
  NSString *url = [[NSString alloc] initWithFormat:@"%@/api/hide", self.server];
  NSString *params = [[NSString alloc] initWithFormat:@"api_type=json&executed=hidden&id=%@",postID];
  [self doPostToURL:url withParams:params connectionCategory:kConnectionCategoryOther callBackTarget:self callBackMethod:@selector(hideResponseReceived:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)submitVote:(NSMutableDictionary *)item;
{
  NSString *itemID = [item valueForKey:@"name"];
  int voteDirection = [[item valueForKey:@"voteDirection"] intValue];
  NSString *url = [[NSString alloc] initWithFormat:@"%@/api/vote", self.server];
  NSString *params = [[NSString alloc] initWithFormat:@"api_type=json&dir=%d&id=%@",voteDirection,itemID];
  [self doPostToURL:url withParams:params connectionCategory:kConnectionCategoryOther callBackTarget:self callBackMethod:@selector(voteResponseReceived:) failedMethod:@selector(connectionFailedDialog:)];
}

@end
