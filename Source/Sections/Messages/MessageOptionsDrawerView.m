#import "MessageOptionsDrawerView.h"
#import "Message.h"
#import "NMessageCell.h"
#import "MessagesViewController+Interaction.h"

@interface MessageOptionsDrawerView()
@property (readonly) Message *message;
@property (readonly) MessagesViewController *messagesViewController;
@end

@implementation MessageOptionsDrawerView

- (Message *)message;
{
  return [(MessageNode *)self.node message];
}

- (MessagesViewController *)messagesViewController;
{
  MessageNode *messageNode = (MessageNode *)self.node;
  return (MessagesViewController *)messageNode.delegate;
}

- (void)addMessageButtons;
{
  UIButton *contextButton = [self createDrawerButtonWithIconName:@"small-context-icon" highlightColor:JMHexColor(ff7bdb) target:self action:@selector(context)];
  UIButton *replyButton = [self createDrawerButtonWithIconName:@"small-reply-icon" highlightColor:JMHexColor(39B54A) target:self action:@selector(reply)];
  UIButton *downvoteButton = [self createDrawerButtonWithIconName:@"small-downvote-icon" highlightColor:[UIColor colorForDownvote] target:self action:@selector(downvote)];
  UIButton *upvoteButton = [self createDrawerButtonWithIconName:@"small-upvote-icon" highlightColor:[UIColor colorForUpvote] target:self action:@selector(upvote)];

  [self addButton:contextButton];
  
  BOOL isVotableElement = JMIsEmpty(self.message.subject) || self.message.wasComment;

  contextButton.hidden = !isVotableElement;

  [self addButton:replyButton];
  
  if (isVotableElement)
  {
    upvoteButton.highlighted = self.message.voteState == VoteStateUpvoted;
    downvoteButton.highlighted = self.message.voteState == VoteStateDownvoted;

    [self addButton:downvoteButton];
    [self addButton:upvoteButton];
  }
}

- (id)initWithNode:(NSObject *)node;
{
  self = [super initWithNode:node];
  if (self)
  {
    [self addMessageButtons];
  }
  return self;
}

#pragma Mark - 
#pragma Mark - Option Handling

- (void)context;
{
  [self.messagesViewController showContextForMessageNode:(MessageNode *)self.node];
}

- (void)reply;
{
  [self.messagesViewController showReplyScreenForMessageNode:(MessageNode *)self.node];
}

- (void)downvote;
{
  [self.messagesViewController voteDownMessageNode:(MessageNode *)self.node];
}

- (void)upvote;
{
  [self.messagesViewController voteUpMessageNode:(MessageNode *)self.node];
}

@end
