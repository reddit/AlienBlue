#import <Foundation/Foundation.h>

// bookmarklet:
// javascript:window.location='alienblue://post?url='+escape(window.location)+'&title='+escape(document.title)
// Supported schemes:
// alienblue://post?url=http://www.google.com.au
// alienblue://subreddit?sr=iphone
// alienblue://inbox

@interface AppSchemeCoordinator : NSObject
+ (BOOL)handleSchemeWithURL:(NSURL *)openURL;
+ (void)handleApplicationDidBecomeActive;
@end
