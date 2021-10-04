#import "SubredditSelectorViewController.h"
#import "ItemSelectorNode.h"
#import "ItemSelectorManualEntryNode.h"
#import "RedditAPI.h"
#import "Resources.h"
#import "SessionManager.h"
#import "NSArray+BlocksKit.h"
#import "ThumbManager.h"

#define kSubredditIconThumbBase @"http://alienblue-static.s3.amazonaws.com/subreddit-icons/"

@implementation SubredditSelectorViewController

- (void)prepareOptions;
{
    BSELF(SubredditSelectorViewController);
    
    [self addNode:[ItemSelectorManualEntryNode nodeWithPlaceholder:@"Other Subreddit"]];

    [[SessionManager manager].subredditPrefs.folderForSubscribedReddits.subreddits each:^(Subreddit *sr) {
        NSMutableString *iconUrl = [NSMutableString stringWithString:kSubredditIconThumbBase];
        [iconUrl appendString:[sr.title lowercaseString]];
        if (JMIsRetina())
        {
            [iconUrl appendFormat:@"@%.fx", [UIScreen mainScreen].scale];
        }
        [iconUrl appendString:@".png"];

        ItemSelectorNode *node = [[ItemSelectorNode alloc] init];
        node.title = sr.title;
        node.uniqueId = node.title;
        node.icon = [[ThumbManager manager] subredditIconForSubreddit:sr.title ident:@"" onComplete:^(UIImage *image) {
        }];
        if (!node.icon)
        {
            node.icon = [UIImage skinImageNamed:@"section/reddits-list/subreddit-icon-placeholder"];
        }
//        node.thumbUrl = iconUrl;
//        node.placeholderIcon = [UIImage skinImageNamed:@"section/reddits-list/subreddit-icon-placeholder"];
        [blockSelf addNode:node];
    }];
    
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

#pragma Mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
    return [Resources isIPAD];
}

- (CGSize)contentSizeForViewInPopover;
{
    return CGSizeMake(320., 400.);
}

- (CGSize)preferredContentSize;
{
  return self.contentSizeForViewInPopover;
}

@end
