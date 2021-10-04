#import "ItemSelectorManualEntryCell.h"
#import "ItemSelectorNode.h"
#import "ItemSelectorManualEntryNode.h"
#import "UIImage+Skin.h"
#import "UIColor+Hex.h"
#import "ABButton.h"

@interface ItemSelectorManualEntryCell()
@property (nonatomic,strong) JMTextFieldEntry *textFieldEntry;
@end

@implementation ItemSelectorManualEntryCell
@synthesize textFieldEntry = textFieldEntry_;


- (void)updateSubviews;
{
    [super updateSubviews];
    ItemSelectorManualEntryNode * node = (ItemSelectorManualEntryNode *)self.node;
    [self.textFieldEntry setTextFieldPlaceholder:node.placeholder];
}

- (void)createSubviews;
{
    [super createSubviews];
    self.textFieldEntry = [[JMTextFieldEntry alloc] init];
    self.textFieldEntry.frame = self.containerView.bounds;
    self.textFieldEntry.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textFieldEntry.delegate = self;
    [self.containerView addSubview:self.textFieldEntry];
}

- (void)decorateCellBackground;
{
  [[UIColor colorForBackground] setFill];
  [[UIBezierPath bezierPathWithRect:self.containerView.bounds] fill];
}


+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
    return 50.;
}

- (void)textFieldEntry:(JMTextFieldEntry *)textFieldEntry finishedWithString:(NSString *)string;
{
    ItemSelectorManualEntryNode * node = (ItemSelectorManualEntryNode *)self.node;
    node.enteredString = string;
    [node.delegate performSelector:@selector(selectorManualEntryCellSelected:) withObject:node afterDelay:0];
}

@end
