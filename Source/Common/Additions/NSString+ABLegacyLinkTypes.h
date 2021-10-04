#import <Foundation/Foundation.h>

// todo: these methods are really old and coded poorly and will need
// to be re-written or discarded. They're included here for the time
// being as some parts of the app still rely on them, until I get a chance
// to refactor
@interface NSString (ABLegacyLinkTypes)
+ (NSString *)ab_useTinyResImgurVersion:(NSString *)link;
+ (NSString *)ab_useMediumThumbnailImgurVersion:(NSString *)link;
+ (NSString *)ab_useLowResImgurVersion:(NSString *)link;
+ (NSString *)ab_fixImgurLink:(NSString *)url;
+ (NSString *)ab_fixImgurLinkForCanvas:(NSString *)url;
+ (NSString *)ab_getLinkType:(NSString *)url;
+ (BOOL)ab_isSelfLink:(NSString *)link;
@end
