#import "JMOutlineCell.h"

typedef enum SectionSpacerDecoration {
  SectionSpacerDecorationNone,
  SectionSpacerDecorationDot,
  SectionSpacerDecorationLine,
} SectionSpacerDecoration;

@interface SectionSpacerNode : JMOutlineNode
+ (SectionSpacerNode *)spacerNode;
+ (SectionSpacerNode *)spacerNodeWithCustomHeight:(CGFloat)height decoration:(SectionSpacerDecoration)decoration;
@property (strong) UIColor *backgroundColor;
@property SectionSpacerDecoration spacerDecoration;
@end

@interface NSectionSpacerCell : JMOutlineCell
@end
