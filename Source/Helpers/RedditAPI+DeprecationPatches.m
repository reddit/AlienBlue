#import "RedditAPI+DeprecationPatches.h"
#import "JSONKit.h"

@implementation RedditAPI (DeprecationPatches)
@end

@implementation JMJSONParser

- (id)objectWithString:(NSString*)repr;
{
  return [repr mutableObjectFromJSONString];
}

- (id)objectWithString:(NSString*)repr error:(NSError**)error;
{
  return [repr mutableObjectFromJSONString];
}

@end

@implementation NSObject (RedditAPI_DeprecationPatches)

- (void)rd_performSelector:(SEL)aSelector withObject:(id)object;
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
  if ([self respondsToSelector:aSelector])
  {
    [self performSelector:aSelector withObject:object];
  }
#pragma clang diagnostic pop
}

@end