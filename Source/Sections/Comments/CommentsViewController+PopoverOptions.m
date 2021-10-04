//
//  CommentsViewController+PopoverOptions.m
//  AlienBlue
//
//  Created by J M on 25/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "CommentsViewController+PopoverOptions.h"
#import "CommentsViewController+API.h"
#import "CommentsViewController+ReplyInteraction.h"
#import "CommentsViewController+Interaction.h"
#import "CommentsViewController+NavigationBar.h"
#import "Post+Style.h"
#import "SHK.h"
#import "Resources.h"
#import "NavigationManager.h"
#import "Post.h"
#import "CommentNode.h"
#import "NInlineImageCell.h"
#import "InlineImageOverlay.h"
#import "UIActionSheet+BlocksKit.h"
#import "UIAlertView+BlocksKit.h"
#import "RedditAPI+Comments.h"
#import "RedditAPI+Account.h"
#import "MKStoreManager.h"
#import "LinkShareCoordinator.h"

@interface CommentsViewController (PopoverOptions_) <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (strong) UIActionSheet *popupQuery;
@property (strong) UIBarButtonItem *popupOptionsBarItem;
@end

@implementation CommentsViewController (PopoverOptions)

SYNTHESIZE_ASSOCIATED_STRONG(UIActionSheet, popupQuery, PopupQuery);
SYNTHESIZE_ASSOCIATED_STRONG(UIBarButtonItem, popupOptionsBarItem, PopupOptionsBarItem);

- (void)popupCommentOrderSheet:(id)sender
{
	if ([self nodeCount] == 0)
		return;
    
	self.popupQuery = [[UIActionSheet alloc]
                  initWithTitle:@"Order Comments By..."
                  delegate:self
                  cancelButtonTitle:@"Cancel"
                  destructiveButtonTitle:nil
                  otherButtonTitles:
                  @"Top",
                  @"Hot",
                  @"New",
                  @"Controversial",
                  @"Old",
                  @"Best",
                  nil];
    
	if ([Resources isIPAD] && self.popupOptionsBarItem)
  {
    [self.popupQuery jm_showFromBarButtonItem:self.popupOptionsBarItem animated:YES];
  }
	else
  {
    [self.popupQuery setBackgroundColor:[UIColor blackColor]];
    self.popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;        
		[self.popupQuery jm_showInView:self.navigationController.view];
  }
    
	[self.popupQuery setTag:2];
}

- (void)deletePost;
{
  CommentPostHeaderNode *postHeaderNode = [self.nodes match:^BOOL(JMOutlineNode *node) {
    return JMIsClass(node, CommentPostHeaderNode);
  }];
  [self deletePostNode:postHeaderNode];
}

- (void)deletePostNode:(CommentPostHeaderNode *)postHeaderNode;
{
  UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"Are you sure?" message:@"Deleting a post is irreversible."];
  [alert bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
  [alert bk_addButtonWithTitle:@"Delete" handler:^{
    [[RedditAPI shared] deleteCommentWithID:postHeaderNode.post.name];
    [NavigationManager shared].lastVisitedPost.title = @"[Deleted]";
    [NavigationManager shared].lastVisitedPost.deleted = YES;
    [[NavigationManager shared].lastVisitedPost flushCachedStyles];
    [PromptManager addPrompt:@"Post has been deleted."];
    [[NavigationManager shared] goBackToPreviousScreen];
  }];
  [alert show];
}

- (void)loadAllImages;
{
	if (![MKStoreManager isProUpgraded])
	{
		[MKStoreManager needProAlert];
		return;
	}
    
  BSELF(CommentsViewController);
  NSMutableArray *nodes = [self.nodes mutableCopy];
  [nodes eachWithIndex:^(JMOutlineNode *node, NSUInteger ind) {
    if ([node isKindOfClass:[BaseStyledTextNode class]])
    {
      BaseStyledTextNode *commentNode = (BaseStyledTextNode *)node;
      [commentNode.thumbLinks each:^(CommentLink *commentLink) {
        if (commentLink.linkType == LinkTypePhoto)
        {
          InlineImageNode *inlineImageNode = [[InlineImageNode alloc] init];
          inlineImageNode.commentLink = commentLink;
          [blockSelf insertNode:inlineImageNode afterNode:commentNode];
          [InlineImageOverlay precacheImageForNode:inlineImageNode constrainedToWidth:blockSelf.tableView.width];
        }
      }];
    }
  }];
  [self reload];
}

- (void)toggleVoteIcons;
{
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  [prefs setBool:![prefs boolForKey:kABSettingKeyShowVoteArrowsOnComments] forKey:kABSettingKeyShowVoteArrowsOnComments];
  
  [self reload];
}

- (void)scrollToSelectCommentParent;
{
  CommentNode *node = (CommentNode *)[self selectedNode];
  BaseStyledTextNode *parentNode = [self nodeForElementId:node.comment.parentIdent];
  if (parentNode)
  {
    [self scrollToNode:parentNode];
  }
}

- (void)copySelectedCommentToClipboard;
{
  CommentNode *node = (CommentNode *)[self selectedNode];
  [[UIPasteboard generalPasteboard] setString:node.comment.body];
  [PromptManager addPrompt:@"Comment is copied to clipboard."];
}

- (void)copySelectedCommentPermalinkToClipboard;
{
  CommentNode *node = (CommentNode *)[self selectedNode];
  NSMutableString *contextLink = [NSMutableString string];
  [contextLink appendString:@"http://www.reddit.com"];
  [contextLink appendString:self.post.permalink];
  [contextLink appendString:node.comment.ident];
  [[UIPasteboard generalPasteboard] setString:contextLink];
  [PromptManager addPrompt:@"Permalink copied to clipboard."];
}

- (void)viewSelectedCommentAuthorInfo;
{
  CommentNode *node = (CommentNode *)[self selectedNode];
  [[NavigationManager shared] showUserDetails:node.comment.author];
}

- (void)deleteSelectedComment;
{
  BSELF(CommentsViewController);
  UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"Delete Comment" message:@"Are you sure?"];
  [alert bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
  [alert bk_addButtonWithTitle:@"Delete" handler:^{
    CommentNode *node = (CommentNode *)[blockSelf selectedNode];
    [blockSelf deleteCommentNode:node];
  }];
  [alert show];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
  [[NavigationManager shared] dismissModalView];
}

- (void)showEmailModalView:(NSString *) url
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
    
  [picker setSubject:self.post.title];
    	
	[picker setMessageBody:url isHTML:NO];
	
	picker.navigationBar.barStyle = UIBarStyleDefault;
  if (picker)
  {
    [[NavigationManager mainViewController] presentViewController:picker animated:YES completion:nil];
  }
}

- (void)emailSelectedComment;
{
    CommentNode *node = (CommentNode *)[self selectedNode];
	[self showEmailModalView:node.comment.body];		
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([actionSheet tag] == 2)
	{
		switch (buttonIndex) {
			case 0:
				self.sortOrder = @"top";
				[self fetchComments];
				break;
			case 1:
				self.sortOrder = @"hot";
				[self fetchComments];
				break;
			case 2:
				self.sortOrder = @"new";
				[self fetchComments];
				break;
			case 3:
				self.sortOrder = @"controversial";
				[self fetchComments];
				break;
			case 4:
				self.sortOrder = @"old";
				[self fetchComments];
				break;
			case 5:
				self.sortOrder = @"best";
				[self fetchComments];
				break;
			default:
				break;
		}

        // remember the setting for future requests
        [UDefaults setObject:self.sortOrder forKey:kABSettingKeyCommentDefaultSortOrder];
        
	}
	
	// comment options
	if ([actionSheet tag] == 4)
	{
		switch (buttonIndex) {
			case 0:
				[self scrollToSelectCommentParent];
				break;
			case 1:
				[self copySelectedCommentToClipboard];
				break;
			case 2:
				[self copySelectedCommentPermalinkToClipboard];
				break;
			case 3:
				[self emailSelectedComment];
				break;
			case 4:
				[self viewSelectedCommentAuthorInfo];
				break;
			case 5:
				if ([[actionSheet buttonTitleAtIndex:5] isEqualToString:@"Delete Comment"])
				{
					[self deleteSelectedComment];
				}
			default:
				break;
		}
		
	}
	
}

- (void)addNewComment;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    CommentPostHeaderNode *headerNode = (CommentPostHeaderNode *)[self nodeForElementId:self.post.ident];
    [self showLegacyCommentEntryForDictionary:headerNode.comment.legacyDictionary editing:NO];
}

- (void)openThreadInSafari;
{
  CommentPostHeaderNode *headerNode = (CommentPostHeaderNode *)[self nodeForElementId:self.post.ident];
  Post *ps = headerNode.post;
  NSString *url = [NSString stringWithFormat:@"https://www.reddit.com%@",[ps.permalink copy]];
  NSString *escapedUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:escapedUrl]];
}

-(void) popupExtraOptionsActionSheet:(id) sender {
	if (self.nodeCount == 0)
		return;
	
	if ([Resources isIPAD] && self.popupQuery && self.popupQuery.visible)
    {
        [self.popupQuery dismissWithClickedButtonIndex:0 animated:YES];        
        return;
    }
	
//	self.popupQuery = [[UIActionSheet alloc]
//                  initWithTitle:nil
//                  delegate:self
//                  cancelButtonTitle:nil
//                  destructiveButtonTitle:nil
//                  otherButtonTitles:
//                  @"Show All Images",
//                  nil];
    
    self.popupQuery =[UIActionSheet bk_actionSheetWithTitle:@""];
    
    CommentPostHeaderNode *headerNode = (CommentPostHeaderNode *)[self nodeForElementId:self.post.ident];
    Post *ps = headerNode.post;
    BSELF(CommentsViewController);

	if ([ps isMine])
  {
    [self.popupQuery bk_setDestructiveButtonWithTitle:@"Delete Post" handler:^{
        [blockSelf deletePostNode:headerNode];
    }];
  }

  [self.popupQuery bk_addButtonWithTitle:@"Open in Safari" handler:^{
    NSString *url = [NSString stringWithFormat:@"http://www.reddit.com%@",[ps.permalink copy]];
    NSString *excapedUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:excapedUrl]];
  }];
  
  [self.popupQuery bk_addButtonWithTitle:@"Send reddit link to..." handler:^{
    [blockSelf showShareOptions];
  }];
  
  [self.popupQuery bk_addButtonWithTitle:@"Show All Images" handler:^{
    [blockSelf loadAllImages];
  }];
    
  NSString *savedTitle = ps.saved ? @"Un-Save from Reddit" : @"Save to Reddit";
  [self.popupQuery bk_addButtonWithTitle:savedTitle handler:^{
    [blockSelf toggleSavePostNode:headerNode];
  }];
  
  NSString *hiddenTitle = ps.hidden ? @"Un-Hide Post" : @"Hide Post";
  [self.popupQuery bk_addButtonWithTitle:hiddenTitle handler:^{
    [blockSelf toggleHidePostNode:headerNode];
  }];
        
	[self.popupQuery bk_addButtonWithTitle:@"Add a Comment" handler:^{
    [blockSelf addNewComment];
  }];
  
	[self.popupQuery bk_addButtonWithTitle:@"Sort Comments" handler:^{
    [blockSelf popupCommentOrderSheet:nil];
  }];
    
  NSString *voteIconTitle = [Resources showCommentVotingIcons] ? @"Hide Voting Icons" : @"Show Voting Icons";
  [self.popupQuery bk_addButtonWithTitle:voteIconTitle handler:^{
    [blockSelf toggleVoteIcons];
  }];
          
  [self.popupQuery bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    
	[self.popupQuery setTag:1];
  
	if ([Resources isIPAD])
  {
    self.popupOptionsBarItem = sender;
    [self.popupQuery jm_showFromBarButtonItem:self.popupOptionsBarItem animated:YES];
  }
	else
  {
    self.popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
		[self.popupQuery jm_showInView:self.navigationController.view];
  }
}

- (void)showCommentSortOptions;
{
  [self popupCommentOrderSheet:nil];
}

- (void)showShareOptions;
{
  CommentPostHeaderNode *headerNode = (CommentPostHeaderNode *)[self nodeForElementId:self.post.ident];
  Post *ps = headerNode.post;
  [LinkShareCoordinator presentLinkShareSheetFromViewController:self barButtonItemOrNil:self.popupOptionsBarItem withAddress:[NSString stringWithFormat:@"https://www.reddit.com%@", ps.permalink] title:ps.title];
}

- (void)showOptionsForComment:(Comment *)comment;
{	
	if ([Resources isIPAD] && self.popupQuery && self.popupQuery.visible)
    {
        [self.popupQuery dismissWithClickedButtonIndex:0 animated:YES];        
        return;
    }
    
	self.popupQuery = [[UIActionSheet alloc]
				  initWithTitle:nil
				  delegate:self
				  cancelButtonTitle:nil
				  destructiveButtonTitle:nil
				  otherButtonTitles:
				  @"Scroll to Parent",
				  @"Copy Text to Clipboard",
				  @"Copy Permalink to Clipboard",
				  @"Email Comment",
				  [NSString stringWithFormat:@"View %@'s History", [comment valueForKey:@"author"]],
				  nil];
	
	if ([comment isMine])
	{
		[self.popupQuery addButtonWithTitle:@"Delete Comment"];
    [self.popupQuery setDestructiveButtonIndex:5];
	}
	
	[self.popupQuery addButtonWithTitle:@"Cancel"];
	[self.popupQuery setCancelButtonIndex:[self.popupQuery numberOfButtons] - 1];
	[self.popupQuery setTag:4];
	
	if ([Resources isIPAD])
    {
        CommentNode *commentNode = (CommentNode *)[self nodeForElementId:comment.ident];
        NSUInteger row = [self rowForNode:(JMOutlineNode *)commentNode];
		NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:0];        
		CGRect r1 = [[self tableView] rectForRowAtIndexPath:ip];
		CGRect r = CGRectMake(self.tableView.bounds.size.width / 4. + 4., r1.origin.y + r1.size.height - self.tableView.contentOffset.y, 20, 48);
		[self.popupQuery showFromRect:r inView:self.view animated:YES];
    }
	else
    {
        self.popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;        
		[self.popupQuery jm_showInView:self.navigationController.view];
    }
}

@end
