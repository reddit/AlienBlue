#import "PhoneCommentEntryView.h"
#import "UIView+Additions.h"
#import "UIImage+Skin.h"
#import "BarBackgroundLayer.h"
#import "PhoneCommentEntryDrawer.h"
#import "ABBundleManager.h"
#import "UIApplication+ABAdditions.h"


#import "PhoneCommentEntryDrawerSelectionView.h"

@interface PhoneCommentEntryView()
@property (nonatomic,strong) PhoneCommentEntryDrawer *drawer;
@property (nonatomic,strong) ABButton * sendButton;
@property (nonatomic,strong) ABButton * cancelButton;
@end

@implementation PhoneCommentEntryView

@synthesize drawer = drawer_;
@synthesize sendButton = sendButton_;
@synthesize cancelButton = cancelButton_;

- (void)createSubviewsInFrame:(CGRect)frame;
{
    self.drawer = [[PhoneCommentEntryDrawer alloc] initWithFrame:CGRectMake(0, -10., frame.size.width, 99.)];
    self.drawer.delegate = self;
    [self addSubview:self.drawer];
    
    self.switchTabView = [[JMTabView alloc] initWithFrame:self.drawer.scrollView.bounds];
    [self.switchTabView setDelegate:self];
    [self.switchTabView setBackgroundLayer:nil];
    [self.switchTabView setSelectionView:[PhoneCommentEntryDrawerSelectionView new]];
    [self.switchTabView addTabItemWithTitle:@"in response to" icon:[UIImage skinImageNamed:@"icons/comment-entry/response-to.png"]];
    [self.switchTabView addTabItemWithTitle:@"your reply" icon:[UIImage skinImageNamed:@"icons/comment-entry/my-comment.png"]];
    [self.drawer setCenterView:self.switchTabView];

    self.toolbar = [[JMTabView alloc] initWithFrame:self.drawer.scrollView.bounds];
    [self.toolbar setDelegate:self];
    [self.toolbar setBackgroundLayer:nil];
    [self.toolbar setMomentary:YES];
    [self.toolbar addTabItemWithTitle:@"more" icon:[UIImage skinImageNamed:@"icons/comment-entry/actionsheet.png"]];
    [self.toolbar addTabItemWithTitle:@"image" icon:[UIImage skinImageNamed:@"icons/comment-entry/photo.png"]];
    [self.toolbar addTabItemWithTitle:nil icon:[UIImage skinImageNamed:@"icons/comment-entry/disapproval.png"]];
    [self.drawer setLeftView:self.toolbar];
    
    NSString * assetFolder = [self.delegate assetFolder];
    if (assetFolder)
    {
        self.assetSelectorView = [[CommentAssetSelectorView alloc] initWithFrame:self.drawer.scrollView.bounds assetFolder:assetFolder];
        [self.drawer setRightView:self.assetSelectorView];
    }
    else
    {
        UILabel *noAssetLabel = [[UILabel alloc] init];
        noAssetLabel.font = [[ABBundleManager sharedManager] fontForKey:kBundleFontPostSubtitleBold];
        noAssetLabel.backgroundColor = [UIColor clearColor];
        noAssetLabel.textColor = [UIColor whiteColor];
        noAssetLabel.text = @"No graphic assets are available for this subreddit.";
        noAssetLabel.textAlignment = UITextAlignmentCenter;
        [self.drawer setRightView:noAssetLabel];
        
    }
    
//    UIBarButtonItem * doneButton = [[[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self.coordinator action:@selector(submitCommentToController:)] autorelease];
//    self.navigationItem.rightBarButtonItem = doneButton;
//    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.coordinator action:@selector(cancelComment:)] autorelease]
    
    self.cancelButton = [[ABButton alloc] initWithImageName:@"icons/comment-entry/iphone/cancel-normal.png"];
    [self.cancelButton sizeToFit];
    [self.cancelButton addTarget:[self.delegate commentCoordinator] action:@selector(cancelComment:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.frame = CGRectOffset(self.cancelButton.frame, -3., 5.);
    self.cancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:self.cancelButton];
    
    self.sendButton = [[ABButton alloc] initWithImageName:@"icons/comment-entry/iphone/submit-normal.png"];
    [self.sendButton addTarget:[self.delegate commentCoordinator] action:@selector(submitCommentToController:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton sizeToFit];
    self.sendButton.frame = CGRectOffset(self.sendButton.frame, self.bounds.size.width - self.sendButton.frame.size.width + 9., 5.);
    self.sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

    [self addSubview:self.sendButton];   
    
    self.commentContainer = [[UIScrollView alloc] init];
    self.commentContainer.scrollEnabled = NO;
    self.commentContainer.pagingEnabled = YES;
    self.commentContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:self.commentContainer];
    
    UIFont *commentFont = [[ABBundleManager sharedManager] fontForKey:kBundleFontCommentBodyBold];
    
    self.parentTextView = [[CommentEntryTextView alloc] init];
    self.parentTextView.editable = NO;
    self.parentTextView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.1];
    self.parentTextView.font = commentFont;
    [self.commentContainer addSubview:self.parentTextView];
    
    self.commentTextView = [[CommentEntryTextView alloc] init];
    self.commentTextView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.1];
    self.commentTextView.font = commentFont;
    [self.commentContainer addSubview:self.commentTextView];
    
    [self addSubview:self.commentContainer];
    
    [self.drawer toggleDrawerAnimated:NO];
}

- (CGFloat)heightForTextView;
{
  CGFloat height = 0.;
  
  if (JMIsIphone5())
  {
   height += JMLandscape() ? 110. : 290.;
  }
  else if (JMIsIphone6())
  {
   height += JMLandscape() ? 160. : 390.;
  }
  else if (JMIsIphone6Plus())
  {
   height += JMLandscape() ? 185. : 445.;
  }
  else
  {
    // iphone 4
   height += JMLandscape() ? 110. : 210.;
  }
  
  if (JMIsIOS8())
  {
    height -= 40.;
  }

  return height;
}

- (void)layoutCommentComponents;
{
    CGRect frame = [self frame];
    CGFloat heightForTextView = [self heightForTextView];
    CGRect commentContainerRect = CGRectMake(0, 48., frame.size.width, heightForTextView);
    self.commentContainer.frame = commentContainerRect;
    self.commentContainer.contentSize = CGSizeMake(frame.size.width * 2, heightForTextView);
    
    CGRect parentCommentRect = CGRectInset(CGRectMake(0, 0, frame.size.width, heightForTextView), 10., 6.);
    self.parentTextView.frame = parentCommentRect;
    
    CGRect commentRect = CGRectOffset(parentCommentRect, frame.size.width, 0);
    self.commentTextView.frame = commentRect;
  
    if (self.commentContainer.contentOffset.x > 20.)
    {
        [self.commentContainer setContentOffset:CGPointMake(self.commentContainer.frame.size.width, 0) animated:YES];
    }
    else
    {
        [self.commentContainer setContentOffset:CGPointZero animated:YES];
    }
    [UIApplication ab_enableEdgePanning];
}

#pragma Mark - Drawer Delegate

- (void)animateCommentContainerToOffset:(CGFloat)yOffset;
{
    [UIView beginAnimations:@"textContainer" context:(__bridge void *)(self.commentContainer)];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    self.commentContainer.frame = CGRectMake(self.commentContainer.frame.origin.x, yOffset, self.commentContainer.frame.size.width, self.commentContainer.frame.size.height);
    [UIView commitAnimations];
}

- (void)drawerWillExpand:(PhoneCommentEntryDrawer *)drawer;
{
    [self bringSubviewToFront:self.drawer];
    [self animateCommentContainerToOffset:62.];
}

- (void)drawerWillCollapse:(PhoneCommentEntryDrawer *)drawer;
{
    [self sendSubviewToBack:self.drawer];    
    [self animateCommentContainerToOffset:48.];
}

#pragma Mark - Tabview Delegate

- (void)tabView:(JMTabView *)tabView didSelectTabAtIndex:(NSUInteger)index;
{
    if ([tabView isEqual:self.switchTabView])
    {
        if (index == 0)
        {
            self.drawer.scrollView.scrollEnabled = NO;
            [self.drawer fadeGripsOut];
            [self switchToParentComment];
        }
        else
        {
            self.drawer.scrollView.scrollEnabled = YES;
            [self.drawer fadeGripsIn];
            [self switchToMyComment];
        }
    }
    else if ([tabView isEqual:self.toolbar])
    {
        switch (index) {
            case 0:
                [self.delegate performSelector:@selector(showPopup)];
                break;
            case 1:
                [self.delegate performSelector:@selector(showAddImagePopup)];
                break;
            case 2:
                [self didSelectLOD];
                break;
            default:
                break;
        }
    }
}

@end
