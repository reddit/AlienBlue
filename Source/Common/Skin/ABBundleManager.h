#import "ABBundleManagerKeys.h"
#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface ABBundleManager : NSObject 
{
  NSBundle *bundle_;
  NSString *resourcePath_;
  NSDictionary *fontDictionary_;

  NSMutableDictionary *fontCache_;
  NSMutableDictionary *fontRefCache_;
  
  CTFontRef bodyFont_;
}

+ (ABBundleManager*) sharedManager;

- (NSString*)pathForResource:(NSString*)name;
- (UIImage*)imageNamed:(NSString*)name;

- (CTFontRef)fontRefForKey:(NSString*)key;
- (UIFont *)fontForKey:(NSString*)key;
- (void) resetFontCaches;

@end
