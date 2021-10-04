#import "Template.h"

@interface TemplateGroup : NSObject <NSCoding>

@property (strong) NSString *title;
@property (strong) NSString *ident;
@property (strong) NSMutableArray *templates;

+ (TemplateGroup *)groupWithTitle:(NSString *)title;

- (void)i_addTemplate:(Template *)tplate;
- (void)i_removeTemplate:(Template *)tplate;
- (void)i_insertTemplate:(Template *)tplate atIndex:(NSUInteger)nIndex;

@property (readonly) NSArray *userCreatedTemplates;
@property (readonly) NSArray *stockTemplates;

@end
