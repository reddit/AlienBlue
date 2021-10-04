#import "ABBundleManager.h"
#import "RedditAPI+DeprecationPatches.h"

#define SKIN_BUNDLE_PATH "ABSkin.bundle"

@implementation ABBundleManager

+ (id)sharedManager
{
  JM_SHARED_INSTANCE_USING_BLOCK(^{
      return [[self alloc] init];
  });
}

- (id)init;
{
  if ((self = [super init]))
  {
    fontCache_ = nil;
    fontRefCache_ = nil;
    bundle_ = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@SKIN_BUNDLE_PATH ofType:@""]];
  }
  return self;
}

- (void) dealloc;
{
  resourcePath_ = nil;
  fontDictionary_ = nil;
  fontCache_ = nil;
  fontRefCache_ = nil;
}

- (NSMutableDictionary *) fontCache;
{
  if (!fontCache_)
  {
    fontCache_ = [[NSMutableDictionary alloc] init];
  }
  return fontCache_;
}

- (NSMutableDictionary *) fontRefCache;
{
  if (!fontRefCache_)
  {
    fontRefCache_ = [[NSMutableDictionary alloc] init];
  }
  return fontRefCache_;
}

- (NSString*)pathForResource:(NSString*)name
{
  if (!resourcePath_)
  {
    resourcePath_ = [[[bundle_ resourcePath] lastPathComponent] stringByAppendingPathComponent:@"en.lproj"];
  }
  return [resourcePath_ stringByAppendingPathComponent:name];
}

- (UIImage*)imageNamed:(NSString*)name;
{
  NSString *imageLocation = [self pathForResource:[@"images" stringByAppendingPathComponent:name]];
  UIImage *image = [UIImage imageNamed:imageLocation];
  return image;
}

- (NSDictionary*)fontDictionary;
{
  if (!fontDictionary_)
  {
    JMJSONParser *parser = [[JMJSONParser alloc] init];
    NSString *path = [bundle_ pathForResource:@"fonts" ofType:@"json" inDirectory:@"fonts"];
    NSString *jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *jsonDict = [parser objectWithString:jsonString];
    fontDictionary_ = [jsonDict valueForKey:@"fonts"];
  }
  return fontDictionary_;
}

- (CGFloat) useFontSizeForFontDictionary:(NSArray *)nameAndSizes
{
  NSUInteger sizeIndex = [UDefaults integerForKey:kABSettingKeyTextSizeIndex];
  CGFloat fontSize;
  if ([nameAndSizes count] > sizeIndex + 1)
  {
      fontSize = [[nameAndSizes objectAtIndex:sizeIndex + 1] floatValue];
  }
  else
  {
      fontSize = [[nameAndSizes objectAtIndex:[nameAndSizes count] - 1] floatValue];
  }
  return fontSize;
}

- (CTFontRef)createFontRefForKey:(NSString*)key;
{
  NSArray *nameAndSizes = [[self fontDictionary] objectForKey:key];
  CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)[nameAndSizes objectAtIndex:0], [self useFontSizeForFontDictionary:nameAndSizes], NULL);
  return font;
}

- (UIFont *)createFontForKey:(NSString*)key;
{
  NSArray *nameAndSizes = [[self fontDictionary] objectForKey:key];
  return [UIFont fontWithName:[nameAndSizes objectAtIndex:0] size:[self useFontSizeForFontDictionary:nameAndSizes]];
}

- (UIFont *)fontForKey:(NSString *) key;
{
  if ([[self fontCache] objectForKey:key])
  {
    return [[self fontCache] objectForKey:key];
  }
  else
  {
    UIFont * font = [self createFontForKey:key];
    [[self fontCache] setObject:font forKey:key];
    return font;
  }
}

- (CTFontRef) fontRefForKey:(NSString *) key;
{
  if ([[self fontRefCache] objectForKey:key])
  {
    return (__bridge CTFontRef) [[self fontRefCache] objectForKey:key];
  }
  else
  {
    CTFontRef font = [self createFontRefForKey:key];
    [[self fontRefCache] setObject:(__bridge_transfer id)font forKey:key];
    return font;
  }
}

- (void)resetFontCaches
{
  [[self fontCache] removeAllObjects];
  [[self fontRefCache] removeAllObjects];
}

- (CTFontRef)bodyFont;
{
  if (!bodyFont_)
  {
    bodyFont_ = [self fontRefForKey:kBundleFontRegular];
  }
  return bodyFont_;
}

@end
