//
//  DiscoverySceneController.m
//  AlienBlue
//
//  Created by J M on 16/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "DiscoverySceneController.h"
#import "DiscoveryCategory.h"
#import "UIViewController+Additions.h"
#import "AFJSONRequestOperation.h"

#import "Subreddit+Discovery.h"
#import "NSectionTitleCell.h"
#import "NBaseOptionCell.h"
#import "NDiscoverySubredditCell.h"
#import "NDiscoveryCategoryCell.h"
#import "Subreddit+Discovery.h"
#import "NavigationManager.h"
#import "DiscoveryAddController.h"
#import "SessionManager.h"
#import "RedditsViewController.h"
#import "SubredditSidebarViewController.h"
#import "NDiscoveryOptionCell.h"
#import "JMTextFieldEntryCell.h"
#import "JMOutlineViewController+Keyboard.h"

typedef enum {
    RecommendationStateNormal = 0,
    RecommendationStateEntry,
    RecommendationStateThankyou
} RecommendationState;

@interface DiscoverySceneController ()
@property (strong) DiscoveryCategory *category;
@property (strong) AFJSONRequestOperation *loadOperation;

@property (strong) NSString *ident;

@property (readonly) BOOL isHomeScene;

@property RecommendationState recommendationState;

- (void)fetchScene;
- (void)generateNodes;
@end

@implementation DiscoverySceneController

- (void)dealloc;
{
    if (self.isHomeScene)
    {
        [[[SessionManager manager] subredditPrefs] recommendSyncToCloud];
    }
    
    [self.loadOperation cancel];
    self.loadOperation = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRedditGroupsDidChangeNotification object:nil];    
}

- (id)initWithTitle:(NSString *)title sceneIdent:(NSString *)ident;
{
    self = [super init];
    if (self)
    {
        [self enableKeyboardReaction];
        self.loadOperation = nil;
        self.category = nil;
        
        self.ident = ident;
        [self setNavbarTitle:title];
        self.title = title;
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[title limitToFirstWord] style: UIBarButtonItemStyleBordered target:nil action:nil];
        
        self.hidesBottomBarWhenPushed = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateFolderChanges) name:kRedditGroupsDidChangeNotification object:nil];
    }
    return self;
}

- (void)loadView;
{
    [super loadView];
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    UIView *activityBarButtonItemView = [[UIView alloc] initWithFrame:self.loadingIndicator.bounds];
    [activityBarButtonItemView addSubview:self.loadingIndicator];
    self.loadingIndicator.left -= 7;

    UIBarButtonItem *loadingActivityItem = [[UIBarButtonItem alloc] initWithCustomView:activityBarButtonItemView];
    self.navigationItem.rightBarButtonItem = loadingActivityItem;
//    [self.view addSubview:self.loadingIndicator];
//    [self.loadingIndicator centerInSuperView];
    [self generateNodes];
}

- (void)respondToStyleChange;
{
    [super respondToStyleChange];
    [self generateNodes];
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    if (!self.category)
    {
        [self fetchScene];
    }
}

- (void)viewDidUnload;
{
    [self.loadOperation cancel];
    self.loadOperation = nil;
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [DiscoveryAddController resetDontAskOption];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)fetchScene;
{
    BSELF(DiscoverySceneController);
    
    NSString *sceneUrl = [NSString stringWithFormat:@"http://alienblue-static.s3.amazonaws.com/discovery/%@.json", self.ident];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:sceneUrl]];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];

    [self.loadingIndicator startAnimating];
    self.loadOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        blockSelf.loadOperation = nil;
        [blockSelf.loadingIndicator stopAnimating];
        NSDictionary *categoryDictionary = (NSDictionary *)JSON;
        DiscoveryCategory *category = [[DiscoveryCategory alloc] initWithDiscoveryDictionary:categoryDictionary];
        blockSelf.category = category;
        [blockSelf animateFolderChanges];
    } failure:nil];
    [self.loadOperation start];
}

- (void)animateFolderChanges;
{
    BSELF(DiscoverySceneController);
    [UIView jm_transition:self.tableView animations:^{
        [blockSelf generateNodes];
    } completion:nil animated:YES];
}

- (BOOL)isHomeScene;
{
    return [self.ident equalsString:@"main"];
}

- (void)showCategory:(DiscoveryCategory *)category;
{
    DiscoverySceneController *controller = [[DiscoverySceneController alloc] initWithTitle:category.title sceneIdent:category.ident];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showSubreddit:(Subreddit *)subreddit;
{
    [[NavigationManager shared] showPostsForSubreddit:subreddit.url title:subreddit.title animated:YES];
}

- (void)showAddSubredditForNode:(DiscoverySubredditNode *)subredditNode;
{
    Subreddit *sr = subredditNode.subreddit;
    
    BSELF(DiscoverySceneController);
    UIViewController *controller = [[DiscoveryAddController alloc] initWithSubreddit:sr onComplete:^{
        [blockSelf animateFolderChanges];
    }];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)attemptToAddAutomatically:(DiscoverySubredditNode *)subredditNode;
{
    BSELF(DiscoverySceneController);
    if ([DiscoveryAddController shouldAddWithoutView])
    {
        [DiscoveryAddController processAutomaticAddingOfSubreddit:subredditNode.subreddit onComplete:^{
            [blockSelf animateFolderChanges];
        }];
    }
    else
    {
        [self showAddSubredditForNode:subredditNode];
    }
}

- (void)showSidebarInfoForSubreddit:(NSString *)subredditTitle;
{
  SubredditSidebarViewController *controller = [[SubredditSidebarViewController alloc] initWithSubredditNamed:subredditTitle];
  [self.navigationController pushViewController:controller animated:YES];
}

- (void)addSubcategoryNodes;
{
    BSELF(DiscoverySceneController);
    if (!self.isHomeScene && self.category.subCategories.count > 0)
    {
        SectionTitleNode *titleNode = [SectionTitleNode nodeForTitle:@"Related"];
        [self addNode:titleNode];
    }
    
    [self.category.subCategories each:^(DiscoveryCategory *category){
        DiscoveryCategoryNode *categoryNode = [DiscoveryCategoryNode categoryNodeForCategory:category];
        [blockSelf addNode:categoryNode];
        categoryNode.onSelect = ^{
            [blockSelf showCategory:category];
        };
    }];    
}

- (void)addSubredditNodeForSubreddit:(Subreddit *)subreddit;
{
    BSELF(DiscoverySceneController);

    UserSubredditPreferences *subredditPrefs = [[SessionManager manager] subredditPrefs];    
    
    DiscoverySubredditNode *node = [[DiscoverySubredditNode alloc] initWithSubreddit:subreddit];
    [blockSelf addNode:node];
    
    node.onThumbnailTap = ^{
        [blockSelf showSidebarInfoForSubreddit:subreddit.title];
    };
    
    BOOL listedInUserFolder = [subredditPrefs folderContainingSubreddit:subreddit] != nil;
    UIImage *secondaryIcon = nil;
    __block __ab_weak DiscoverySubredditNode *weakNode = node;  
    if (!listedInUserFolder)
    {
        secondaryIcon = [UIImage skinImageNamed:@"icons/add-button-rounded" withColor:[UIColor colorWithHex:0x6d9f60]];
        node.secondaryAction = ^{
            [blockSelf attemptToAddAutomatically:weakNode];
        };
    }
    else
    {
        secondaryIcon = [UIImage skinImageNamed:@"icons/indeterminate-small" withColor:[UIColor colorWithHex:0xff8400]];
        node.secondaryAction = ^{
            [blockSelf showAddSubredditForNode:weakNode];
        };
    }
    
    node.secondaryIcon = secondaryIcon;
    
    node.onSelect = ^{
        [blockSelf showSubreddit:subreddit];
    };    
}

- (void)addSubredditNodes;
{
    BSELF(DiscoverySceneController);
    if (self.category.subreddits.count > 0)
    {
        SectionTitleNode *titleNode = [SectionTitleNode nodeForTitle:@"Subreddits"];
        [self addNode:titleNode];
    }
    
    [self.category.subreddits each:^(Subreddit *subreddit){
        [blockSelf addSubredditNodeForSubreddit:subreddit];
    }];
}

- (void)addRecommendationNode;
{
    BSELF(DiscoverySceneController);
    if (self.recommendationState == RecommendationStateNormal)
    {
        DiscoveryOptionNode *recommendNode = [[DiscoveryOptionNode alloc] init];
        recommendNode.title = @"Something missing?";
        recommendNode.titleColor = [UIColor grayColor];
        recommendNode.subtitle = @"Recommend a subreddit for this category";
        recommendNode.onSelect = ^{
            blockSelf.recommendationState = RecommendationStateEntry;
            [blockSelf animateFolderChanges];
        };    
        [self addNode:recommendNode];        
    }
    
    if (self.recommendationState == RecommendationStateEntry)
    {
        JMTextFieldEntryNode *textEntryNode = [JMTextFieldEntryNode textEntryNodeOnComplete:^(NSString *text) {
            [blockSelf.loadingIndicator startAnimating];
            [DiscoveryCategory recommendSubreddit:text forCategory:blockSelf.category onComplete:^{
                blockSelf.recommendationState = RecommendationStateThankyou;
                [blockSelf.loadingIndicator stopAnimating];
                [blockSelf animateFolderChanges];
            }];
        }];
        textEntryNode.placeholder = @"/r/";
        textEntryNode.defaultText = @"/r/";
        textEntryNode.onCancel = ^{
            blockSelf.recommendationState = RecommendationStateNormal;
            [blockSelf animateFolderChanges];
        };
        [self addNode:textEntryNode];
    }
    
    if (self.recommendationState == RecommendationStateThankyou)
    {
        DiscoveryOptionNode *thanksNode = [[DiscoveryOptionNode alloc] init];
        thanksNode.title = @"Thank you.";
        thanksNode.titleColor = [UIColor colorForUpvote];
        thanksNode.subtitle = @"Your recommendation will be added shortly.";
        [self addNode:thanksNode];        

        self.recommendationState = RecommendationStateNormal;
        [blockSelf performSelector:@selector(animateFolderChanges) withObject:nil afterDelay:3.];
    }
}

- (void)addAlienBlueSection;
{
}

- (void)generateNodes;
{
    if (!self.category)
        return;
    
    [self removeAllNodes];
    
    [self addSubcategoryNodes];
    
    [self addSubredditNodes];

    if (self.isHomeScene)
    {
        [self addAlienBlueSection];
    }
    else
    {
        [self addRecommendationNode];
    }
    
    [self reload];
}

@end
