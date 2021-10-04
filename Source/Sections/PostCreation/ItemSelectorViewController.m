#import "ItemSelectorViewController.h"
#import "ItemSelectorNode.h"
#import "ItemSelectorManualEntryNode.h"

@implementation ItemSelectorViewController

@synthesize delegate = delegate_;
@synthesize propertyKey = propertyKey_;

- (void)dealloc;
{
    self.delegate = nil;
}

- (id)initWithDelegate:(id<ItemSelectorDelegate>) delegate;
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
        self.propertyKey = nil;
    }
    return self;
}

- (void)loadView;
{
  [super loadView];
  self.tableView.backgroundColor = [UIColor colorForBackground];
}

- (void)finishWithValue:(NSString *)value;
{
    if (value)
    {
        [self.delegate performSelector:@selector(itemSelectorDidSelectValue:propertyKey:) withObject:value withObject:self.propertyKey];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  ItemSelectorNode *itemSelectorNode = JMCastOrNil([self nodeForRow:indexPath.row], ItemSelectorNode);
  if (itemSelectorNode)
  {
    [self selectorCellSelected:itemSelectorNode];
  }
}

- (void)selectorManualEntryCellSelected:(ItemSelectorManualEntryNode *)node;
{
    NSLog(@"manual entry: %@", node.enteredString);
    [self finishWithValue:node.enteredString];
}

- (void)selectorCellSelected:(ItemSelectorNode *)node;
{
    NSLog(@"selected: %@", node.uniqueId);
    [self finishWithValue:node.uniqueId];
}

@end
