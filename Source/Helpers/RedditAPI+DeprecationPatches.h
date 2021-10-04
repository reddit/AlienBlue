#import "RedditAPI.h"

@interface RedditAPI (DeprecationPatches)
@end

@interface JMJSONParser : NSObject
@property NSUInteger maxDepth;
- (id)objectWithString:(NSString*)repr;
- (id)objectWithString:(NSString*)repr error:(NSError**)error;
@end

@interface NSObject (RedditAPI_DeprecationPatches)
- (void)rd_performSelector:(SEL)aSelector withObject:(id)object;
@end

