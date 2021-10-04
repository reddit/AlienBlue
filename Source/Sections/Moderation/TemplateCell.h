#import "NBaseOptionCell.h"
#import "Template.h"

@interface TemplateNode : OptionNode
- (id)initWithTemplate:(Template *)tPlate;
@property (strong, readonly) Template *tPlate;
@end

@interface TemplateCell : NBaseOptionCell

@end
