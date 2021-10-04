#import "RedditAPI.h"

@interface RedditAPI (Posting)

- (void)submitPost:(NSMutableDictionary *)newPostToSubmit withCallBackTarget:(id)target useJSON:(BOOL)useJSON;
- (NSMutableArray *)getErrorsInPostSubmission:(NSString*)response;

@end
