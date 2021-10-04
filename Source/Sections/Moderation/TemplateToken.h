#import <Foundation/Foundation.h>

typedef NSString*(^TokenReplacerBlock)();

@interface TemplateToken : NSObject

@property (readonly) NSString *title;
@property (readonly) NSString *tokenIdent;
@property (readonly) NSString *escapedToken;
@property (readonly) NSString *replacerString;

- (id)initWithTokenIdent:(NSString *)tokenIdent title:(NSString *)title tokenReplacer:(TokenReplacerBlock)tokenReplacer;
- (void)applyTokenToMutableString:(NSMutableString *)mString;
@end
