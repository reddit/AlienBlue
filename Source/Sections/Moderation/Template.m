#import "Template.h"

@implementation Template

+ (Template *)templateWithTitle:(NSString *)title body:(NSString *)body;
{
  Template *t = [Template new];
  t.body = body;
  t.title = title;
  return t;
}

#pragma mark -
#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder;
{
  NSString *body = [aDecoder decodeObjectForKey:@"body"];
  NSString *title = [aDecoder decodeObjectForKey:@"title"];
  BOOL removed = [aDecoder decodeBoolForKey:@"removed"];
  BOOL stockTemplate = [aDecoder decodeBoolForKey:@"stockTemplate"];
  TemplateSendPreference sendPreference = [aDecoder decodeIntegerForKey:@"sendPreference"];
  Template *t = [Template new];
  t.title = title;
  t.body = body;
  t.sendPreference = sendPreference;
  t.stockTemplate = stockTemplate;
  t.removed = removed;
  return t;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
  [aCoder encodeObject:self.body forKey:@"body"];
  [aCoder encodeObject:self.title forKey:@"title"];
  [aCoder encodeInteger:self.sendPreference forKey:@"sendPreference"];
  [aCoder encodeBool:self.removed forKey:@"removed"];
  [aCoder encodeBool:self.stockTemplate forKey:@"stockTemplate"];
}

@end
