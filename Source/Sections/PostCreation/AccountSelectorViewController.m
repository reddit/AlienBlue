#import "AccountSelectorViewController.h"
#import "ItemSelectorNode.h"
#import "ItemSelectorManualEntryNode.h"
#import "RedditAPI.h"
#import "Resources.h"
#import "UIImage+Skin.h"

@implementation AccountSelectorViewController

- (void)prepareOptions;
{
    NSArray *accounts = [[NSUserDefaults standardUserDefaults] objectForKey:kABSettingKeyRedditAccountsList];
    for (NSDictionary *account in accounts)
    {
        ItemSelectorNode *node = [[ItemSelectorNode alloc] init];
        node.title = [account objectForKey:@"username"];
        node.uniqueId = node.title;
        node.icon = [UIImage skinIcon:@"self-icon" withColor:[UIColor colorForHighlightedOptions]];
        [self addNode:node];
    }
    [self reload];
}

- (id)initWithDelegate:(id<ItemSelectorDelegate>) delegate;
{
    self = [super initWithDelegate:delegate];
    if (self)
    {
        [self prepareOptions];
    }
    return self;
}

- (void)loadView;
{
    [super loadView];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
}

#pragma Mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
    return [Resources isIPAD];
}


@end
