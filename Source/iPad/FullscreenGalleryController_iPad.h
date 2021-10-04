#import <UIKit/UIKit.h>
#import "JMGalleryViewController.h"

extern NSString *JMFullscreenGalleryDeeplinkFromURL(NSURL *linkURL);
extern NSString *JMFullscreenGalleryThumbnailFromURL(NSURL *linkURL);

@interface FullscreenGalleryController_iPad : JMGalleryViewController

- (id)initWithImageUrls:(NSArray *)imageUrls startingAtIndex:(NSUInteger)startingIndex;
- (id)initWithGalleryItems:(NSArray *)galleryItems startingAtIndex:(NSUInteger)startingIndex;

@end
