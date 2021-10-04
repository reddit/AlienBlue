#import "CommentOptionsDrawerView.h"
#import "CommentNode.h"
#import "CommentPostHeaderNode.h"
#import "Comment.h"
#import "Post.h"
#import "CommentsViewController+Interaction.h"

@interface CommentOptionsDrawerView()
@property (readonly) BOOL isPostHeader;

// Post Header Options

- (void)savePost;
- (void)hidePost;
- (void)downvotePost;
- (void)upvotePost;
- (void)addCommentToPost;

// Comment Options

- (void)collapseToRoot;
- (void)moreOptionsForComment;
- (void)replyToComment;
- (void)downvoteComment;
- (void)upvoteComment;

@end


@implementation CommentOptionsDrawerView

- (BOOL)isPostHeader;
{
  return [self.node isKindOfClass:[CommentPostHeaderNode class]];
}

- (VotableElement *)modableElement;
{
  Comment *comment = [(CommentNode *)self.node comment];
  return comment;
}

- (void) addPostButtons;
{
  Post *post = [(CommentPostHeaderNode *)self.node post];

  UIButton *saveButton = [self createDrawerButtonWithIconName:@"small-save-icon" highlightColor:JMHexColor(ff7bdb) target:self action:@selector(savePost)];
  UIButton *hideButton = [self createDrawerButtonWithIconName:@"small-hide-icon" highlightColor:JMHexColor(2baaf3) target:self action:@selector(hidePost)];
  UIButton *replyButton;
  if (post.isMine && post.selfPost)
      replyButton = [self createDrawerButtonWithIconName:@"small-edit-icon" highlightColor:JMHexColor(39B54A) target:self action:@selector(addCommentToPost)];
  else
      replyButton = [self createDrawerButtonWithIconName:@"small-add-comment-icon" highlightColor:JMHexColor(39B54A) target:self action:@selector(addCommentToPost)];
  
  UIButton *downvoteButton = [self createDrawerButtonWithIconName:@"small-downvote-icon" highlightColor:[UIColor colorForDownvote] target:self action:@selector(downvotePost)];
  UIButton *upvoteButton = [self createDrawerButtonWithIconName:@"small-upvote-icon" highlightColor:[UIColor colorForUpvote] target:self action:@selector(upvotePost)];
  
  upvoteButton.highlighted = (post.voteState == VoteStateUpvoted);
  downvoteButton.highlighted = (post.voteState == VoteStateDownvoted);
  saveButton.highlighted = post.saved;
  hideButton.highlighted = post.hidden;
  
  [self addButton:saveButton];
  [self addButton:hideButton];
  [self addButton:replyButton];
  [self addButton:downvoteButton];
  [self addButton:upvoteButton];    
}

- (void) addCommentButtons;
{
    Comment *comment = [(CommentNode *)self.node comment];
  
    UIButton *collapseButton = [self createDrawerButtonWithIconName:@"small-collapse-to-root-icon" highlightColor:JMHexColor(ff7bdb) target:self action:@selector(collapseToRoot)];
    UIButton *modButton = [self generateModButton];
    UIButton *moreButton = [self createDrawerButtonWithIconName:@"small-share-icon" highlightColor:JMHexColor(ff7bdb) target:self action:@selector(moreOptionsForComment)];
    UIButton *replyButton;
    if (comment.isMine)
      replyButton = [self createDrawerButtonWithIconName:@"small-edit-icon" highlightColor:JMHexColor(39B54A) target:self action:@selector(replyToComment)];
    else
      replyButton = [self createDrawerButtonWithIconName:@"small-reply-icon" highlightColor:JMHexColor(39B54A) target:self action:@selector(replyToComment)];
    UIButton *downvoteButton = [self createDrawerButtonWithIconName:@"small-downvote-icon" highlightColor:[UIColor colorForDownvote] target:self action:@selector(downvoteComment)];
    UIButton *upvoteButton = [self createDrawerButtonWithIconName:@"small-upvote-icon" highlightColor:[UIColor colorForUpvote] target:self action:@selector(upvoteComment)];
  
//    ABButton *collapseButton = [ABButton buttonWithImageName:@"icons/comment-drawer/normal/collapse.png" target:self action:@selector(collapseToRoot)];
//    ABButton *modButton = [self generateModButton];
//  
//    ABButton *moreButton = [ABButton buttonWithImageName:@"icons/comment-drawer/normal/more.png" target:self action:@selector(moreOptionsForComment)];
//    ABButton *replyButton;
//    if (comment.isMine)
//        replyButton = [ABButton buttonWithImageName:@"icons/comment-drawer/normal/edit.png" target:self action:@selector(replyToComment)];
//    else
//        replyButton = [ABButton buttonWithImageName:@"icons/message-drawer/normal/reply.png" target:self action:@selector(replyToComment)];
//    ABButton * downvoteButton = [ABButton buttonWithImageName:@"icons/comment-drawer/normal/downvote.png" target:self action:@selector(downvoteComment)];
//    ABButton * upvoteButton = [ABButton buttonWithImageName:@"icons/comment-drawer/normal/upvote.png" target:self action:@selector(upvoteComment)];
  
    upvoteButton.highlighted = (comment.voteState == VoteStateUpvoted);
    downvoteButton.highlighted = (comment.voteState == VoteStateDownvoted);
  
    [self addButton:collapseButton];
  
    [self addButton:moreButton];
  
    [self addButton:replyButton];
    if (comment.isModdable)
    {
      [self addButton:modButton];
    }

    [self addButton:downvoteButton];
    [self addButton:upvoteButton];    
}

- (id)initWithNode:(NSObject *)node;
{
    self = [super initWithNode:node];
    if (self)
    {
        if (self.isPostHeader)
            [self addPostButtons];
        else
            [self addCommentButtons];
      
        if ([self shouldShowModToolsByDefault])
        {
          [self enterModModeAnimated:NO];
        }
    }
    return self;
}

#pragma Mark - 
#pragma Mark - Option Handling


// Post Header Options

- (void)savePost;
{
    [self.delegate performSelector:@selector(toggleSavePostNode:) withObject:self.node];
}

- (void)hidePost;
{
    [self.delegate performSelector:@selector(toggleHidePostNode:) withObject:self.node];
}

- (void)addCommentToPost;
{
    [self.delegate performSelector:@selector(addCommentToPostNode:) withObject:self.node];    
}

- (void)downvotePost;
{
    [self.delegate performSelector:@selector(voteDownPostNode:) withObject:self.node];
}

- (void)upvotePost;
{
    [self.delegate performSelector:@selector(voteUpPostNode:) withObject:self.node];    
}

// Comment Options


- (void)collapseToRoot;
{
    [self.delegate performSelector:@selector(collapseToRootCommentNode:) withObject:self.node];        
}

- (void)moreOptionsForComment;
{
    [self.delegate performSelector:@selector(showMoreOptionsForCommentNode:) withObject:self.node];        
}

- (void)replyToComment;
{
    [self.delegate performSelector:@selector(addCommentToCommentNode:) withObject:self.node];            
}

- (void)downvoteComment;
{
    [self.delegate performSelector:@selector(voteDownCommentNode:) withObject:self.node];            
}

- (void)upvoteComment;
{
    [self.delegate performSelector:@selector(voteUpCommentNode:) withObject:self.node];            
}

//- (void)more;
//{
//    [self.delegate performSelector:@selector(showOptionsForComment:) withObject:self.node];
//}
//
//- (void)collapse;
//{
//    [self.delegate performSelector:@selector(collapseToRootForComment:) withObject:self.node];
//}
//
//- (void)reply;
//{
//    NSMutableDictionary * comment = (NSMutableDictionary *)self.node;
//    if ([[comment valueForKey:@"comment_type"] isEqualToString:@"me"])
//        [self.delegate performSelector:@selector(editModeForComment:) withObject:self.node];
//    else
//        [self.delegate performSelector:@selector(showReplyAreaForComment:) withObject:self.node];
//}
//
//- (void)save;
//{
//    [self.delegate performSelector:@selector(toggleSavePost:) withObject:self.node];
//}
//
//- (void)hide;
//{
//    [self.delegate performSelector:@selector(toggleHidePost:) withObject:self.node];
//}
//
//- (void)report;
//{
//    [self.delegate performSelector:@selector(reportPostConfirmation)];
//}
//
//- (void)downvote;
//{
//    [self.delegate performSelector:@selector(voteDownComment:) withObject:self.node];
//}
//
//- (void)upvote;
//{
//    [self.delegate performSelector:@selector(voteUpComment:) withObject:self.node];    
//}
@end
