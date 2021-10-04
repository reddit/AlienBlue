#import "LinkShareActivityImageItemProvider.h"
#import "JMSiteMedia.h"

@interface LinkShareActivityImageItemProvider()
@property (strong) NSURL *URL;
@end

@implementation LinkShareActivityImageItemProvider

- (instancetype)initWithURL:(NSURL *)URL;
{
  BOOL shouldShowImageItemProvider = JMURLIsDirectLinkToImage(URL) && ![URL.absoluteString jm_contains:@".gif"];
  UIImage *placeholderItem = shouldShowImageItemProvider ? [UIImage new] : nil;
  JM_SUPER_INIT(initWithPlaceholderItem:placeholderItem);
  self.URL = URL;
  return self;
}

- (id)item;
{
  // Assuming users will want only a URL when copying to clipboard
  // and not the image itself
  if (self.activityType == UIActivityTypeCopyToPasteboard)
    return nil;

  NSData *imageData = [NSData dataWithContentsOfURL:self.URL];
  UIImage *image = [UIImage imageWithData:imageData];
  return image;
}

@end
