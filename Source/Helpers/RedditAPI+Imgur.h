#import "RedditAPI.h"

@interface RedditAPI (Imgur)

- (void)postImageToImgur:(NSData *)photoData callBackTarget:(id)target;
- (void)removeImageFromImgurWithDeleteHash:(NSString *)deleteHash;
- (void)resetConnectionsForImgur;

@end
