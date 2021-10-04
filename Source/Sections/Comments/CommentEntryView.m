#import "CommentEntryView.h"
#import "UIView+Additions.h"
#import "UIImage+Skin.h"
#import "CommentEntryTextView.h"
#import "UIViewController+Additions.h"
#import "Resources.h"
#import "UIApplication+ABAdditions.h"

#import "PhoneCommentEntryDrawerSelectionView.h"
#import "MessageBoxSelectionBackgroundLayer.h"
#import "MessageBoxTabItem.h"
#import "MessageBoxSelectionView.h"


#define kCommentParentSwitchAnimation @"kCommentParentSwitchAnimation"

@interface CommentEntryView()
@property CGFloat keyboardHeight;
@property BOOL keyboardShowing;

- (void)switchToMyComment;
- (void)switchToParentComment;
- (CGFloat)heightForTextView;
-(void)didSelectLOD;
- (void)layoutCommentComponents;
@end

@implementation CommentEntryView

@synthesize delegate = delegate_;
@synthesize switchTabView = commentSwitchTabView_;
@synthesize toolbar = toolbar_;
@synthesize commentTextView = commentTextView_;
@synthesize parentTextView = parentTextView_;
@synthesize commentContainer = commentContainer_;
@synthesize forceReposition = forceReposition_;
@synthesize assetSelectorView = assetSelectorView_;

- (void)dealloc;
{
    self.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void) createSwitchTabItems;
{
    [self.switchTabView addTabItemWithTitle:@"in response to" icon:[UIImage skinImageNamed:@"icons/comment-entry/response-to.png"]];
    [self.switchTabView addTabItemWithTitle:@"your reply" icon:[UIImage skinImageNamed:@"icons/comment-entry/my-comment.png"]];
}

- (void) createToolbarItems;
{
    [self.toolbar addTabItemWithTitle:@"more options" icon:[UIImage skinImageNamed:@"icons/comment-entry/actionsheet.png"]];
    [self.toolbar addTabItemWithTitle:@"add image" icon:[UIImage skinImageNamed:@"icons/comment-entry/photo.png"]];
   
    if ([self.delegate isSmallWindow])
    {
        [self.toolbar addTabItem:[JMTabItem tabItemWithFixedWidth:180.]];
    }
    else
    {
        [self.toolbar addTabItem:[JMTabItem tabItemWithFixedWidth:400.]];
    }
    
    [self.toolbar addTabItemWithTitle:@"" icon:[UIImage skinImageNamed:@"icons/comment-entry/disapproval.png"]];
}

- (void)createSubviewsInFrame:(CGRect)frame;
{
    self.switchTabView = [[JMTabView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, [Resources isIPAD] ? 60. : 48.)];
    self.switchTabView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.switchTabView setDelegate:self];
    [self.switchTabView setSelectionView:[PhoneCommentEntryDrawerSelectionView new]];
    [self.switchTabView setBackgroundLayer:nil];
    self.switchTabView.backgroundColor = JMHexColor(353535);
    [self createSwitchTabItems];
    [self addSubview:self.switchTabView];
    
    self.commentContainer = [[UIScrollView alloc] init];
    self.commentContainer.scrollEnabled = NO;
    self.commentContainer.pagingEnabled = YES;
    self.commentContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:self.commentContainer];
    
    self.parentTextView = [[CommentEntryTextView alloc] init];
    self.parentTextView.editable = NO;
    [self.commentContainer addSubview:self.parentTextView];
    
    self.commentTextView = [[CommentEntryTextView alloc] init];
    [self.commentContainer addSubview:self.commentTextView];
    
    self.toolbar = [[JMTabView alloc] initWithFrame:CGRectMake(0, frame.size.height - 60., frame.size.width, [Resources isIPAD] ? 60. : 48.)];
    [self.toolbar setMomentary:YES];
    [self.toolbar setDelegate:self];
    [self.toolbar setSelectionView:[PhoneCommentEntryDrawerSelectionView new]];
    [self.toolbar setBackgroundLayer:nil];
    self.toolbar.backgroundColor = JMHexColor(353535);
    [self.toolbar setAlpha:0.];
    [self createToolbarItems];
    
    [self addSubview:self.toolbar];
    
    if (![self.delegate isSmallWindow] && [self.delegate assetFolder])
    {
        self.assetSelectorView = [[CommentAssetSelectorView alloc] initWithFrame:CGRectZero assetFolder:[self.delegate assetFolder]]; 
        [self.toolbar addSubview:self.assetSelectorView];
    }
}

- (id)initWithFrame:(CGRect)frame delegate:(id<CommentEntryViewDelegate>)delegate;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.delegate = delegate;
        self.backgroundColor = [UIColor colorForBackground];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        self.forceReposition = YES;
        [self createSubviewsInFrame:frame];
        [self.switchTabView setSelectedIndex:1.];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
        
        [self performSelector:@selector(switchToMyComment) withObject:nil afterDelay:0.75];
    }
    return self;
}

- (CGFloat)heightForTextView;
{
    CGFloat height = 0.;
    UIInterfaceOrientation o = [[UIApplication sharedApplication] statusBarOrientation];
    if (o == UIDeviceOrientationLandscapeLeft || o == UIDeviceOrientationLandscapeRight)
    {
        height += 234.;
    }
    else
    {
        height += [self.delegate isSmallWindow] ? 386. : 576.;
    }
    
    if (!self.keyboardShowing)
    {
        height -= self.keyboardHeight;
    }

    if (JMIsIOS7())
    {
      height += 4.;
    }
  
    if (JMIsIOS8())
    {
      height -= 48.;
    }
  
    return height;
}

- (void)keyboardDidChange:(NSNotification *)notification;
{
}

- (void)layoutCommentComponents;
{
    CGRect frame = [self frame];
    CGFloat heightForTextView = [self heightForTextView];
    CGRect commentContainerRect = CGRectMake(0, 60., frame.size.width, heightForTextView);
    self.commentContainer.frame = commentContainerRect;
    self.commentContainer.contentSize = CGSizeMake(frame.size.width * 2, heightForTextView);
    
    CGRect parentCommentRect = CGRectInset(CGRectMake(0, 0, frame.size.width, heightForTextView), 20., 10.);
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
    
    self.toolbar.frame = CGRectMake(0, CGRectGetMaxY(self.commentContainer.frame), self.bounds.size.width, 60.);
    
    self.assetSelectorView.frame = CGRectMake(290., 5., 400., 50.);
}

- (void)layoutSubviews;
{
    [self layoutCommentComponents];
}

- (void)drawRect:(CGRect)rect;
{
}

- (void)switchToParentComment;
{
    [UIView beginAnimations:kCommentParentSwitchAnimation context:(__bridge void *)(self)];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [self.commentContainer setContentOffset:CGPointMake(0, 0)];
    [self.commentTextView resignFirstResponder];
    [self.toolbar setAlpha:0.];
    [UIView commitAnimations];
}

- (void)switchToMyComment;
{
    [UIView beginAnimations:kCommentParentSwitchAnimation context:(__bridge void *)(self)];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [self.commentContainer setContentOffset:CGPointMake(self.bounds.size.width, 0)];    
    [self.commentTextView becomeFirstResponder];
    [self.toolbar setAlpha:1.];
    [UIView commitAnimations];
}

- (void)externalSwitchToMyComment;
{
    [self.switchTabView setSelectedIndex:1.];
    [self performSelector:@selector(switchToMyComment) withObject:nil afterDelay:0.5];
}

- (void)tabView:(JMTabView *)tabView didSelectTabAtIndex:(NSUInteger)index;
{
    if ([tabView isEqual:self.switchTabView])
    {
        if (index == 0)
        {
            [self switchToParentComment];
        }
        else
        {
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
            case 3:
                [self didSelectLOD];
                break;
            default:
                break;
        }
    }
}

#pragma Mark - 
#pragma Mark - Asset Selector

-(void)didSelectTagFromCarousel:(NSString *)tagName;
{
    [self.commentTextView insertTag:tagName];
}

-(void)didSelectLOD;
{
    [self.commentTextView insertLOD];
}

@end
