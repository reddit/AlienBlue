#import "TemplateToken.h"

@interface TemplateToken()
@property (strong) NSString *title;
@property (strong) NSString *tokenIdent;
@property (copy) TokenReplacerBlock tokenReplacer;
@end

@implementation TemplateToken

- (id)initWithTokenIdent:(NSString *)tokenIdent title:(NSString *)title tokenReplacer:(TokenReplacerBlock)tokenReplacer;
{
  self = [super init];
  if (self)
  {
    self.title = title;
    self.tokenIdent = tokenIdent;
    self.tokenReplacer = tokenReplacer;
  }
  return self;
}

- (NSString *)escapedToken
{
  return [NSString stringWithFormat:@"<%@>", self.tokenIdent];
}

- (void)applyTokenToMutableString:(NSMutableString *)mString;
{
  [mString replaceString:self.escapedToken withString:self.tokenReplacer()];
}

- (NSString *)replacerString;
{
  if (!self.tokenReplacer || !self.tokenReplacer())
    return self.escapedToken;

  return self.tokenReplacer();
}

@end
