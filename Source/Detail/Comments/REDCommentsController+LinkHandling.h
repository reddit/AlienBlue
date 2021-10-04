//  REDCommentsController+LinkHandling.h
//  RedditApp

#import "RedditApp/Detail/Comments/REDCommentsController.h"

@interface REDCommentsController (LinkHandling)

- (void)coreTextURLPressed:(NSString *)url;
- (void)openLinkUrl:(NSString *)url;

@end
