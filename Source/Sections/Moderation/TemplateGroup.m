#import "TemplateGroup.h"

@interface TemplateGroup()
@end

@implementation TemplateGroup

+ (TemplateGroup *)groupWithTitle:(NSString *)title;
{
  TemplateGroup *group = [TemplateGroup new];
  group.title = title;
  group.ident = title;
  group.templates = [NSMutableArray array];
  return group;
}

#pragma mark -
#pragma mark Managing Templates

- (Template *)itemMatchingTemplate:(Template *)template;
{
  Template *match = [self.templates match:^BOOL(Template *existingTemplate) {
    return [existingTemplate.title equalsString:template.title];
  }];
  return match;
}

- (BOOL)containsTemplate:(Template *)template;
{
  return [self itemMatchingTemplate:template] != nil;
}

- (void)i_insertTemplate:(Template *)template atIndex:(NSUInteger)nIndex;
{
  if (![self containsTemplate:template])
  {
    [self.templates insertObject:template atIndex:nIndex];
  }
}

- (void)i_addTemplate:(Template *)template;
{
  [self i_insertTemplate:template atIndex:[self.templates count]];
}

- (void)i_removeTemplate:(Template *)template;
{
  [self.templates removeObject:[self itemMatchingTemplate:template]];
}

#pragma mark -
#pragma mark Querying

- (NSArray *)userCreatedTemplates;
{
  return [self.templates select:^BOOL(Template *tPlate) {
    return !tPlate.stockTemplate;
  }];
}

- (NSArray *)stockTemplates;
{
  return [self.templates select:^BOOL(Template *tPlate) {
    return tPlate.stockTemplate;
  }];  
}

#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
  [aCoder encodeObject:self.title forKey:@"title"];
  [aCoder encodeObject:self.templates forKey:@"templates"];
  [aCoder encodeObject:self.ident forKey:@"ident"];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
  TemplateGroup *tGroup = nil;
  NSString *title = [aDecoder decodeObjectForKey:@"title"];
  NSString *ident = [aDecoder decodeObjectForKey:@"ident"];
  NSArray *templates = [aDecoder decodeObjectForKey:@"templates"];
  if (title && templates && ident)
  {
    tGroup = [TemplateGroup new];
    tGroup.title = title;
    tGroup.ident = ident;
    tGroup.templates = [NSMutableArray arrayWithArray:templates];
  }
  return tGroup;
}

@end
