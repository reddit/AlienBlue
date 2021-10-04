//
//  SendMessageViewController.m
//  AlienBlue
//
//  Created by J M on 25/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "SendMessageViewController.h"
#import "NSectionTitleCell.h"
#import "NSectionSpacerCell.h"
#import "JMTextFieldEntryCell.h"

#import "NDiscoveryOptionCell.h"
#import "NavigationManager.h"
#import "UIAlertView+BlocksKit.h"
#import "SendMessageViewController+Submit.h"
#import "JMOutlineViewController+Keyboard.h"
#import "Resources.h"

#import "ABCustomOutlineNavigationBar.h"
#import "JMOutlineViewController+CustomNavigationBar.h"

@interface SendMessageViewController()

@property (strong) JMTextView *messageTextView;
@property (strong) NSString *username;
@property (strong) NSString *subject;
@property (readonly) CGFloat textViewHeight;

- (void)generateNodes;
- (void)animateNodeChanges;

@end

@implementation SendMessageViewController

- (id)initWithUsername:(NSString *)username;
{
    self = [super init];
    if (self)
    {
        self.hidesBottomBarWhenPushed = YES;

        if (![Resources isIPAD])
        {
            [self enableKeyboardReaction];
        }
        
        self.username = username;
        self.title = @"Send Private Message";
        [self setNavbarTitle:self.title];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
        
        UIBarButtonItem * sendItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleBordered target:self action:@selector(send)];
        self.navigationItem.rightBarButtonItem = sendItem;
    }
    return self;
}

- (void)dismiss;
{
    if (![self.messageTextView.text isEmpty])
    {
        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"Discard message" message:@"You will lose the contents of your unsent message. Are you sure?"];
        [alert bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
        [alert bk_addButtonWithTitle:@"Discard" handler:^{
            [[NavigationManager shared] dismissModalView];
        }];
        [alert show];
    }
    else 
    {
        [[NavigationManager shared] dismissModalView];
    }
}

- (void)send;
{
    [self.messageTextView resignFirstResponder];
    [self submit];
}

- (void)animateNodeChanges;
{
    BSELF(SendMessageViewController);
    [UIView jm_transition:self.tableView animations:^{
        [blockSelf generateNodes];
    } completion:nil animated:YES];
}

- (CGFloat)textViewHeight;
{
    if ([Resources isIPAD])
        return 290.;
    
    return JMPortrait() ? 150. : 60.;
}

- (void)loadView;
{
    [super loadView];
  
    BSELF(SendMessageViewController);
    ABCustomOutlineNavigationBar *customNavigationBar = (ABCustomOutlineNavigationBar *)self.attachedCustomNavigationBar;
    [customNavigationBar setCustomLeftButtonWithIcon:[ABCustomOutlineNavigationBar cancelIcon] onTapAction:^{
      [blockSelf dismiss];
    }];
    [customNavigationBar setCustomRightButtonWithTitle:@"Send" onTapAction:^{
      [blockSelf send];
    }];
  
    [self generateNodes];
    
    self.messageTextView = [[JMTextView alloc] initWithFrame:CGRectMake(6., 192., self.tableView.width - 12., self.textViewHeight)];
    self.messageTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.messageTextView.delegate = self;
    if ([Resources isNight])
    {
        self.messageTextView.backgroundColor = [UIColor colorForBackgroundAlt];
        self.messageTextView.textColor = [UIColor colorForText];
        self.messageTextView.keyboardAppearance = UIKeyboardAppearanceDark;
    }

    [self.tableView addSubview:self.messageTextView];
}

- (void)stickMessageToTopAnimated:(BOOL)animated;
{
    if (!self.messageTextView.isFirstResponder)
        return;
    
    if (![Resources isIPAD])
    {
        // iphone
        [self.tableView setContentOffset:CGPointMake(0, 150.) animated:animated];
        return;
    }
    
    if ([Resources isIPAD] && JMLandscape())
    {
        [self.tableView setContentOffset:CGPointMake(0, 140.) animated:animated];
        return;
    }
}

- (void)releaseMessageFromTop;
{
    if (self.messageTextView.isFirstResponder)
    {
        if (![Resources isIPAD])
        {
            [self.messageTextView resignFirstResponder];
        }
        else if (JMLandscape())
        {
            [self.messageTextView resignFirstResponder];
        }
    }
    BSELF(SendMessageViewController);
    [UIView animateWithDuration:0.5 delay:0. options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionOverrideInheritedCurve) animations:^{
        blockSelf.tableView.contentOffset = CGPointZero;
    } completion:^(BOOL finished) {
    }];
}

- (void)textViewDidBeginEditing:(UITextView *)textView;
{
    [self stickMessageToTopAnimated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView;
{
    [self releaseMessageFromTop];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    [self stickMessageToTopAnimated:NO];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
{
    self.messageTextView.height = self.textViewHeight;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [super scrollViewWillBeginDragging:scrollView];
    if ([scrollView isKindOfClass:[UITableView class]])
    {
        [self releaseMessageFromTop];
    }
}

- (void)generateNodes;
{
    [self removeAllNodes];

    BSELF(SendMessageViewController);  
    
    SectionTitleNode *toUserTitleNode = [SectionTitleNode nodeForTitle:@"Message for:"];
    [self addNode:toUserTitleNode];
    
    JMTextFieldEntryNode *usernameEntryNode = [JMTextFieldEntryNode textEntryNodeOnComplete:^(NSString *text) {
        blockSelf.username = text;
        [blockSelf animateNodeChanges];
    }];
    usernameEntryNode.onEndEditing = ^(NSString *text) {
        blockSelf.username = text;
        [blockSelf animateNodeChanges];
    };

    if ([Resources isNight])
    {
        usernameEntryNode.backgroundColor = [UIColor colorForBackgroundAlt];
        usernameEntryNode.textColor = [UIColor colorForText];
    }
    
    usernameEntryNode.defaultText = self.username;
    usernameEntryNode.placeholder = @"Enter a username";
    [self addNode:usernameEntryNode];
        
    JMTextFieldEntryNode *subjectEntryNode = [JMTextFieldEntryNode textEntryNodeOnComplete:^(NSString *text) {
        blockSelf.subject = text;
        [blockSelf animateNodeChanges];
    }];
    subjectEntryNode.onEndEditing = ^(NSString *text) {
        blockSelf.subject = text;
        [blockSelf animateNodeChanges];
    };
    subjectEntryNode.defaultText = self.subject;

    if ([Resources isNight])
    {
        subjectEntryNode.backgroundColor = [UIColor colorForBackgroundAlt];
        subjectEntryNode.textColor = [UIColor colorForText];
    }
    
    subjectEntryNode.placeholder = @"Enter a brief subject for your message";
    [self addNode:subjectEntryNode];

    SectionTitleNode *messageTitleNode = [SectionTitleNode nodeForTitle:@"Your Message"];
    messageTitleNode.onSelect = ^{
        [blockSelf.messageTextView resignFirstResponder];
    };

    [self addNode:messageTitleNode];
  
    [self reload];
}

@end
