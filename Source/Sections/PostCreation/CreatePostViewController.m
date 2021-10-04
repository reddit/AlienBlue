#import "CreatePostViewController.h"
#import "ABNavigationController.h"
#import "ABNavigationBar.h"
#import "UIColor+Hex.h"
#import "PostDetailNode.h"
#import "CreatePostDetailCell.h"
#import "CreatePostMoreOptionsCell.h"
#import "CreatePostSubmitCell.h"
#import "UIImage+Skin.h"
#import "RedditAPI+Posting.h"
#import "AccountSelectorViewController.h"
#import "SubredditSelectorViewController.h"
#import "AlienBlueAppDelegate.h"
#import "ABButton.h"
#import "UIImage+Resize.h"
#import "MBProgressHUD.h"
#import "NSString+ABAdditions.h"
#import "Resources.h"
#import "SessionManager+Authentication.h"
#import "Subreddit+API.h"

#import "MessageBoxSelectionBackgroundLayer.h"
#import "MessageBoxSelectionView.h"
#import "MessageBoxTabItem.h"

#import "GTMNSString+HTML.h"
#import "BrowserViewController.h"
#import "UIImage+JMActionMenuAssets.h"

typedef enum kPostType
{
	PostTypeLink = 0,
	PostTypeText = 1,
	PostTypePhoto = 2
} PostType;

#define kPostDetailKeyPostType @"kPostDetailKeyPostType"
#define kPostDetailKeyTitle @"kPostDetailKeyTitle"
#define kPostDetailKeySubreddit @"kPostDetailKeySubreddit"
#define kPostDetailKeyUrl @"kPostDetailKeyUrl"
#define kPostDetailKeyCaptchaId @"kPostDetailKeyCaptchaId"
#define kPostDetailKeyCaptchaEntered @"kPostDetailKeyCaptchaEntered"
#define kPostDetailKeyFromAccount @"kPostDetailKeyFromAccount"
#define kPostDetailKeyNSFW @"kPostDetailKeyNSFW"
#define kPostDetailKeyLoadFromAutosave @"kPostDetailKeyLoadFromAutosave"
#define kPostDetailKeySelfText @"kPostDetailKeySelfText"
#define kPostDetailKeyPhotoUrl @"kPostDetailKeyPhotoUrl"
#define kPostDetailKeyPhotoPreviewImage @"kPostDetailKeyPhotoPreviewImage"

@interface CreatePostViewController()
@property (nonatomic,strong) NSMutableDictionary *postDetails;
@property (strong) Subreddit *subredditMatchingSelection;
@property (assign) PostType postType;
@property (assign) BOOL showAdvancedOptions;
- (void)prepareNodes;
- (void)sendToReddit;
- (UIImage *)sectionImageWithName:(NSString *)name;
@end

@implementation CreatePostViewController

@synthesize postDetails = postDetails_;
@synthesize postType = postType_;
@synthesize showAdvancedOptions = showAdvancedOptions_;


- (id)init;
{
    self = [super init];
    if (self)
    {
        self.title = @"New Post";
        CGSize cancelButtonOffset = CGSizeZero;
        UIBarButtonItem *cancelButtonItem = [UIBarButtonItem skinBarItemWithTitle:@"Cancel" textColor:nil fillColor:nil positionOffset:cancelButtonOffset target:self action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = cancelButtonItem;
        
        if ([Resources isIPAD])
        {
            CGSize sendItemOffset = JMIsIOS7() ? CGSizeMake(5., 1.) : CGSizeZero;
            UIBarButtonItem *sendItem = [UIBarButtonItem skinBarItemWithTitle:@"Submit Post" textColor:[UIColor skinColorForConstructive] fillColor:nil positionOffset:sendItemOffset target:self action:@selector(sendToReddit)];
            self.navigationItem.rightBarButtonItem = sendItem;
        }
        
        self.postType = PostTypeLink;
        self.postDetails = [NSMutableDictionary dictionary];
        
        NSString * username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        [self.postDetails setObject:username forKey:kPostDetailKeyFromAccount];
        [self.postDetails setObject:[NSNumber numberWithBool:NO] forKey:kPostDetailKeyNSFW];

        NSString *lastVisitedSubreddit = [NavigationManager shared].lastVisitedSubreddit;
        if (lastVisitedSubreddit && [lastVisitedSubreddit length] > 2 && ![lastVisitedSubreddit hasPrefix:@"/user/"])
        {
            NSString *defaultSubreddit = [[lastVisitedSubreddit stringByReplacingOccurrencesOfString:@"/r/" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@""];
            [self.postDetails setObject:defaultSubreddit forKey:kPostDetailKeySubreddit];
        }
      
        [self prepareNodes];
    }
    return self;
}

- (void)cancel;
{
    [[NavigationManager shared] dismissModalView];
}

- (void)loadView;
{
    [super loadView];

    self.tableView.backgroundColor = [UIColor colorForBackground];
  
    [self.tableView setShowsVerticalScrollIndicator:NO];

    // pad the bottom of the table on the iPad (the keyboard may be covering the lower items)
    if ([Resources isIPAD])
    {
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1., 220.)];
    }
  
    UIView *postTypeSelectionView = [self generatePostTypeSelectorHeaderView];
    self.tableView.tableHeaderView = postTypeSelectionView;
}

- (UIImage *)sectionImageWithName:(NSString *)name;
{
    NSString *imageName = [NSString stringWithFormat:@"section/create-post/%@.png", name];
    return [UIImage skinImageNamed:imageName];
}


- (PostDetailNode *)createNodeForKey:(NSString *)key title:(NSString *)title placeholder:(NSString *)placeholder icon:(UIImage *)icon disclosureIconName:(NSString *)disclosureIconName;
{
    PostDetailNode *node = [[PostDetailNode alloc] init];
    node.title = title;
    node.placeholder = placeholder;
    node.key = key;
    node.value = [self.postDetails objectForKey:key];
    node.icon = icon;
    node.disclosureIcon = [UIImage skinIcon:@"thin-right-arrow" withColor:[UIColor skinColorForDisabledIcon]];
    BSELF(CreatePostViewController);
    __block __weak PostDetailNode *weakNode = node;
    node.onSelect = ^{
      [blockSelf postNodeSelected:weakNode];
    };
    return node;
}

- (void)prepareNodes;
{
    [self removeAllNodes];
    NSString *disclosureStandard = @"icon-disclosure";
    PostDetailNode *titleNode = [self createNodeForKey:kPostDetailKeyTitle title:@"Title" placeholder:@"Enter a descriptive title." icon:[UIImage actionMenuIconWithName:@"am-icon-posts-message-mods" fillColor:nil] disclosureIconName:disclosureStandard];
    PostDetailNode *subredditNode = [self createNodeForKey:kPostDetailKeySubreddit title:@"Subreddit" placeholder:@"Choose where it belongs." icon:[UIImage actionMenuIconWithName:@"am-icon-global-goto-subreddit" fillColor:nil] disclosureIconName:disclosureStandard];
    PostDetailNode *linkNode = [self createNodeForKey:kPostDetailKeyUrl title:@"Link" placeholder:@"Link to website or article." icon:[UIImage actionMenuIconWithName:@"am-icon-global-goto-last-submitted-post" fillColor:nil] disclosureIconName:disclosureStandard];
    PostDetailNode *accountNode = [self createNodeForKey:kPostDetailKeyFromAccount title:@"From Account" placeholder:@"reddit account to post from." icon:[UIImage actionMenuIconWithName:@"am-icon-global-karma" fillColor:nil] disclosureIconName:disclosureStandard];
    PostDetailNode *loadAutosavedNode = [self createNodeForKey:kPostDetailKeyLoadFromAutosave title:@"Load from Autosave" placeholder:@"Retrieve autosaved details." icon:[UIImage skinIcon:@"message-outbox-icon"] disclosureIconName:nil];
//    PostDetailNode *nsfwNode = [self createNodeForKey:kPostDetailKeyNSFW title:@"Not Safe for Work" placeholder:@"Classify the post as adults only." iconName:@"icon-nsfw" disclosureIconName:@"icon-check-empty"];
//    nsfwNode.value = nil;
    
    PostDetailNode *textNode = [self createNodeForKey:kPostDetailKeySelfText title:@"Self Post / Text" placeholder:@"Enter the text for your self post." icon:[UIImage skinIcon:@"article-icon"] disclosureIconName:disclosureStandard];
    PostDetailNode *photoNode = [self createNodeForKey:kPostDetailKeyPhotoUrl title:@"Upload a Photo" placeholder:@"Take or choose a photo." icon:[UIImage actionMenuIconWithName:@"am-icon-browser-save-image" fillColor:nil] disclosureIconName:disclosureStandard];
    if ([self.postDetails objectForKey:kPostDetailKeyPhotoPreviewImage])
    {
        photoNode.disclosureIcon = [self.postDetails objectForKey:kPostDetailKeyPhotoPreviewImage];
    }
  
    BSELF(CreatePostViewController);
    MoreOptionsNode *moreOptionsNode = [[MoreOptionsNode alloc] init];
    __block __weak MoreOptionsNode *weakMoreOptionsNode = moreOptionsNode;
    moreOptionsNode.onSelect = ^{
      [blockSelf moreNodeSelected:weakMoreOptionsNode];
    };

    PostSubmitNode *postSubmitNode = [[PostSubmitNode alloc] init];
    postSubmitNode.shouldShowSubmitRulesButton = self.subredditMatchingSelection != nil && !JMIsEmpty(self.subredditMatchingSelection.submitRulesText);
  
    BOOL wrongPostTypeForSubreddit = self.subredditMatchingSelection != nil &&
                                     ((!self.subredditMatchingSelection.allowsLinkPosts && (self.postType == PostTypeLink || self.postType == PostTypePhoto)) ||
                                     (!self.subredditMatchingSelection.allowsSelfPosts && self.postType == PostTypeText));
    BOOL missingRequiredFields = JMIsEmpty(self.postDetails[kPostDetailKeyTitle]) || JMIsEmpty(self.postDetails[kPostDetailKeySubreddit]);
    postSubmitNode.shouldShowPostWarning = wrongPostTypeForSubreddit || missingRequiredFields;

//    postSubmitNode.shouldShowPostWarning = YES;
  
    [self addNode:titleNode];
    [self addNode:subredditNode];
    
    if (self.postType == PostTypeLink)
        [self addNode:linkNode];
    else if (self.postType == PostTypePhoto)
        [self addNode:photoNode];
    else if (self.postType == PostTypeText)
        [self addNode:textNode];
    
    if (self.showAdvancedOptions)
    {
        [self addNode:accountNode];
        [self addNode:loadAutosavedNode];
    }
    else
    {
        [self addNode:moreOptionsNode];
    }
    
    [self addNode:postSubmitNode];
}

- (void)refreshCreatePostRows;
{
    [self prepareNodes];
    [self reload];
}

- (void)refreshCreatePostRowsAnimated;
{
  BSELF(CreatePostViewController);
  [UIView jm_transition:blockSelf.tableView animations:^{
    [blockSelf refreshCreatePostRows];
  } completion:nil];
}

#pragma mark -
#pragma mark - Selection Handling

- (JMTextViewController *)textEntryControllerForNode:(PostDetailNode *)node;
{
    JMTextViewController *textEntryController = [[JMTextViewController alloc] initWithDelegate:self propertyKey:node.key];
    textEntryController.title = node.title;
    textEntryController.defaultText = [self.postDetails objectForKey:node.key];
    textEntryController.placeholderText = node.placeholder;
    return textEntryController;
}

- (void)showSubredditsSelector;
{
    SubredditSelectorViewController *selectorViewController = [[SubredditSelectorViewController alloc] initWithDelegate:self];
    selectorViewController.propertyKey = kPostDetailKeySubreddit;
    selectorViewController.title = @"Choose Subreddit";
    [self.navigationController pushViewController:selectorViewController animated:YES];    
}

- (void)showAccountSelector;
{
    AccountSelectorViewController *selectorViewController = [[AccountSelectorViewController alloc] initWithDelegate:self];
    selectorViewController.title = @"Choose Account";
    selectorViewController.propertyKey = kPostDetailKeyFromAccount;
    [self.navigationController pushViewController:selectorViewController animated:YES];    
}

- (void)showPhotoUpload;
{
    PhotoUploadViewController *photoViewController = [[PhotoUploadViewController alloc] initWithDelegate:self propertyKey:kPostDetailKeyPhotoUrl];
    [self.navigationController pushViewController:photoViewController animated:YES];
}

- (void)showTextEntryForNode:(PostDetailNode *)node;
{
    JMTextViewController *textEntryController = [self textEntryControllerForNode:node];
  
    if([node.key isEqual:kPostDetailKeyTitle])
    {
      textEntryController.singleLine = YES;
      textEntryController.keyboardType = UIKeyboardTypeDefault;
      textEntryController.autoCorrectionType = UITextAutocorrectionTypeDefault;
      textEntryController.returnKeyType = UIReturnKeyDone;
    }
  
    if ([node.key isEqual:kPostDetailKeyUrl])
    {
        textEntryController.singleLine = YES;
        textEntryController.keyboardType = UIKeyboardTypeURL;
        textEntryController.autoCorrectionType = UITextAutocorrectionTypeNo;
        textEntryController.returnKeyType = UIReturnKeyDone;
        if (![self.postDetails objectForKey:kPostDetailKeyUrl])
        {
            textEntryController.placeholderText = @"http://";
        }
    }
    
    [self.navigationController pushViewController:textEntryController animated:YES];
}

- (void)showCaptchaEntry;
{
    CaptchaEntryViewController *captchaViewController = [[CaptchaEntryViewController alloc] initWithDelegate:self propertyKey:kPostDetailKeyCaptchaEntered];
    [self.navigationController pushViewController:captchaViewController animated:YES];
}


- (void)retrieveKeyFromAutosave:(NSString *)key;
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *retrievedVal = [prefs objectForKey:key];
    if (retrievedVal)
    {
        [self.postDetails setObject:retrievedVal forKey:key];
    }
}

- (void)loadFromAutosave;
{
    [self retrieveKeyFromAutosave:kPostDetailKeyTitle];
    [self retrieveKeyFromAutosave:kPostDetailKeySubreddit];
    [self retrieveKeyFromAutosave:kPostDetailKeyUrl];
    [self retrieveKeyFromAutosave:kPostDetailKeySelfText];
    [self retrieveKeyFromAutosave:kPostDetailKeyPhotoUrl];
    [self refreshCreatePostRows];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 1)
    {
        [self loadFromAutosave];
    }
}

- (void)showLoadFromAutosaveConfirmation;
{
    NSString *message = @"Are you sure you want to replace the current fields with the autosaved post?";
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Load Autosaved Post" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Replace", nil];
    [alert show];
}

- (void)postNodeSelected:(PostDetailNode *)node;
{
    if ([node.key isEqual: kPostDetailKeySubreddit])
    {
        [self showSubredditsSelector];
    }
    else if ([node.key isEqual: kPostDetailKeyPhotoUrl])
    {
        [self showPhotoUpload];
    }
    else if ([node.key isEqual: kPostDetailKeyFromAccount])
    {
        [self showAccountSelector];
    }
    else if ([node.key isEqual: kPostDetailKeyNSFW])
    {
        NSNumber *nsfw = [NSNumber numberWithBool:![[self.postDetails objectForKey:kPostDetailKeyNSFW] boolValue]];
        [self.postDetails setObject:nsfw forKey:kPostDetailKeyNSFW];
        [self refreshCreatePostRows];
    }
    else if ([node.key isEqual: kPostDetailKeyLoadFromAutosave])
    {
        [self showLoadFromAutosaveConfirmation];
    }
    else
    {
        [self showTextEntryForNode:node];
    }
    
//    NSLog(@"selected node: %@", node.title);
    
//    [self pushSubredditsSelector];
}

- (void)moreNodeSelected:(MoreOptionsNode *)node;
{
    self.showAdvancedOptions = YES;
    [self refreshCreatePostRows];
}

- (void)submitNodeSelected:(PostSubmitNode *)node;
{
  if (JMIsEmpty(self.postDetails[kPostDetailKeySubreddit]) || JMIsEmpty(self.postDetails[kPostDetailKeyTitle]))
    return;
  
  [self sendToReddit];
}

- (void)viewSubmitRulesButtonPressed;
{
  NSString *html = [NSString stringWithFormat:@"html://%@", [self.subredditMatchingSelection.submitRulesHtml gtm_stringByUnescapingFromHTML]];
  BrowserViewController *controller = [[UNIVERSAL(BrowserViewController) alloc] initWithUrl:html];
  controller.title = @"Submission Rules";
  [self.navigationController pushViewController:controller animated:html];
}

#pragma mark -
#pragma mark - JMTableViewContoller customisation

- (UIView *)generatePostTypeSelectorHeaderView;
{
    JMTabView *postTypeSelect = [[JMTabView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 48.)];
    [postTypeSelect setBackgroundLayer:[MessageBoxSelectionBackgroundLayer new]];
    [postTypeSelect setSelectionView:[MessageBoxSelectionView new]];
  
    JMTabItem *linkItem = [[MessageBoxTabItem alloc] initWithTitle:@"Link" skinIconName:@"browser-icon"];
    JMTabItem *textItem = [[MessageBoxTabItem alloc] initWithTitle:@"Text" skinIconName:@"article-icon"];
    JMTabItem *photoItem = [[MessageBoxTabItem alloc] initWithTitle:@"Photo" skinIconName:@"photo-icon"];

    [postTypeSelect addTabItem:linkItem];
    [postTypeSelect addTabItem:textItem];
    [postTypeSelect addTabItem:photoItem];
    
    [postTypeSelect setSelectedIndex:0];
    [postTypeSelect setDelegate:self];
    return postTypeSelect;
}

- (UIView *)staticFooterView;
{
    return nil;
}

+ (ABNavigationController *) viewControllerWithNavigation;
{
    CreatePostViewController *viewController = [[CreatePostViewController alloc] init];
    ABNavigationController *navController = [[ABNavigationController alloc] initWithRootViewController:viewController];
    navController.toolbarHidden = YES;
    navController.modalPresentationStyle = UIModalPresentationPageSheet;
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    return navController;
}

- (void)fetchMatchingSubredditDetails;
{
  self.subredditMatchingSelection = nil;
  BSELF(CreatePostViewController);
  NSString *subredditName = [self.postDetails objectForKey:kPostDetailKeySubreddit];
  [Subreddit fetchSubredditInformationForSubredditName:subredditName onComplete:^(Subreddit *subredditOrNil) {
    blockSelf.subredditMatchingSelection = subredditOrNil;
    if (subredditOrNil == nil)
    {
      [blockSelf.postDetails removeObjectForKey:kPostDetailKeySubreddit];
      [PromptManager showMomentaryHudWithMessage:@"This subreddit is not available for posting." minShowTime:2];
      [blockSelf showSubredditsSelector];
    }
    [blockSelf refreshCreatePostRowsAnimated];
  }];
}

#pragma mark -
#pragma mark - JMTabView Delegate

-(void)tabView:(JMTabView *)tabView didSelectTabAtIndex:(NSUInteger)itemIndex;
{
    self.postType = itemIndex;
    [self refreshCreatePostRows];
}

#pragma mark -
#pragma mark - ItemSelector Delegate

- (void)itemSelectorDidSelectValue:(NSString *)value propertyKey:(NSString *)propertyKey;
{
    [self.postDetails setObject:value forKey:propertyKey];
    if ([propertyKey jm_matches:kPostDetailKeySubreddit])
    {
      [self fetchMatchingSubredditDetails];
    }
  
    [self refreshCreatePostRows];
    
    if ([propertyKey isEqual: kPostDetailKeyFromAccount])
    {
      [[SessionManager manager] switchToRedditAccountUsername:[self.postDetails objectForKey:kPostDetailKeyFromAccount] withCallBackTarget:nil];
    }
}

- (void)viewDidLoad;
{
  [super viewDidLoad];
  if (!JMIsEmpty(self.postDetails[kPostDetailKeySubreddit]))
  {
    [self fetchMatchingSubredditDetails];
  }
}

#pragma mark -
#pragma mark - TextEntry View Delegate

- (void)textViewDidEnterValue:(NSString *)value propertyKey:(NSString *)propertyKey;
{
    [self.postDetails setObject:value forKey:propertyKey];
    [self refreshCreatePostRows];
}

#pragma mark -
#pragma mark - Upload View Delegate

- (void)didUploadToImgurImage:(UIImage *)image withUrl:(NSString *)url;
{
    [self.postDetails setObject:url forKey:kPostDetailKeyPhotoUrl];
    
    UIImage *thumbnail = [image thumbnailImage:36. transparentBorder:2. cornerRadius:3. interpolationQuality:kCGInterpolationLow];
    
    [self.postDetails setObject:thumbnail forKey:kPostDetailKeyPhotoPreviewImage];
    [self refreshCreatePostRows];
}

#pragma mark -
#pragma mark - Captcha Delegate

- (void)didEnterCaptcha:(NSString *)captchaEntered forCaptchaId:(NSString *)captchaId;
{
    [self.postDetails setObject:captchaEntered forKey:kPostDetailKeyCaptchaEntered];
    [self.postDetails setObject:captchaId forKey:kPostDetailKeyCaptchaId];
    [self performSelector:@selector(sendToReddit) withObject:nil afterDelay:1.];
}

#pragma mark -
#pragma mark - Post to Reddit

- (void)sendToReddit;
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Posting to Reddit"];
    
    NSLog(@"sending to reddit");
	NSString * kind;
	NSString * content;
    
	if (self.postType == PostTypeText)
	{
		kind = @"self";
		if (![self.postDetails objectForKey:kPostDetailKeySelfText])
			content = @"";
		else
			content = [[self.postDetails objectForKey:kPostDetailKeySelfText] copy];
	}
	else
	{
		kind = @"link";
        if (self.postType == PostTypePhoto)
        {
            content = [[self.postDetails objectForKey:kPostDetailKeyPhotoUrl] copy];
        }
        else
        {
            content = [[self.postDetails objectForKey:kPostDetailKeyUrl] copy];            
        }
	}
    
    NSString * title = ([self.postDetails objectForKey:kPostDetailKeyTitle] != nil) ? [[self.postDetails objectForKey:kPostDetailKeyTitle] copy] : @"";
    
	NSMutableDictionary * newPost = [[NSMutableDictionary alloc] init];	
	[newPost setValue:[kind copy] forKey:@"kind"];
	[newPost setValue:content forKey:@"content"];
	[newPost setValue:title forKey:@"title"];
	[newPost setValue:[[self.postDetails objectForKey:kPostDetailKeyCaptchaId] copy] forKey:@"captchaID"];
	[newPost setValue:[[self.postDetails objectForKey:kPostDetailKeyCaptchaEntered] copy] forKey:@"captchaEntered"];
	[newPost setValue:[[self.postDetails objectForKey:kPostDetailKeySubreddit] copy] forKey:@"subreddit"];
	
	[[RedditAPI shared] submitPost:newPost withCallBackTarget:self useJSON:YES];
}

- (void) submitResponse: (id)sender
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
	NSMutableArray * errors = (NSMutableArray *) sender;
	
	if (errors && [errors count] == 0)
	{
        [[SessionManager manager] handleSwitchBackToMainAccountIfNecessary];
        [[NavigationManager shared] dismissModalView];
        [PromptManager showMomentaryHudWithMessage:@"Post has been submitted" minShowTime:2.];
	}
    else if (errors && [errors count] > 0)
	{
        BOOL captchaError = NO;
        
		NSMutableString * errorMessage = [NSMutableString stringWithString:@"reddit has reported the following information:\n\n"];
		// this is how Reddit returns error responses:
		// {"errors": [["SUBREDDIT_NOEXIST", "that reddit doesn't exist"], ["BAD_CAPTCHA", "care to try these again?"]]}
		for (NSString * error in errors)
		{
            if ([error contains:@"captcha"])
            {
                captchaError = YES;
            }
			[errorMessage appendFormat:@"* %@\n", error];
		}

        if ([errors count] == 1 && captchaError)
        {
            [self showCaptchaEntry];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Submission Failed" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
    return [Resources isIPAD];
}

@end
