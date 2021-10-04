#import "PostOptionsDrawerView.h"

#import "ABEventLogger.h"
#import "NPostCell.h"

@implementation PostOptionsDrawerView

- (VotableElement *)modableElement;
{
  Post *post = [(PostNode *)self.node post];
  return post;
}

- (void) addPrimaryButtons;
{
  Post *post = [(PostNode *)self.node post];
  
  UIButton *saveButton = [self createDrawerButtonWithIconName:@"small-save-icon" highlightColor:JMHexColor(ff7bdb) target:self action:@selector(save)];
  UIButton *hideButton = [self createDrawerButtonWithIconName:@"small-hide-icon" highlightColor:JMHexColor(2baaf3) target:self action:@selector(hide)];
  UIButton *reportButton = [self createDrawerButtonWithIconName:@"small-report-icon" highlightColor:JMHexColor(f3cb2b) target:self action:@selector(report)];
  UIButton *downvoteButton = [self createDrawerButtonWithIconName:@"small-downvote-icon" highlightColor:[UIColor colorForDownvote] target:self action:@selector(downvote)];
  UIButton *upvoteButton = [self createDrawerButtonWithIconName:@"small-upvote-icon" highlightColor:[UIColor colorForUpvote] target:self action:@selector(upvote)];
  
//    ABButton * saveButton = [ABButton buttonWithImageName:@"icons/post-drawer/normal/save.png" target:self action:@selector(save)];
//    ABButton * hideButton = [ABButton buttonWithImageName:@"icons/post-drawer/normal/hide.png" target:self action:@selector(hide)];
//    ABButton * reportButton = [ABButton buttonWithImageName:@"icons/post-drawer/normal/report.png" target:self action:@selector(report)];
//    ABButton * downvoteButton = [ABButton buttonWithImageName:@"icons/post-drawer/normal/downvote.png" target:self action:@selector(downvote)];
//    ABButton * upvoteButton = [ABButton buttonWithImageName:@"icons/post-drawer/normal/upvote.png" target:self action:@selector(upvote)];
  
  
  upvoteButton.highlighted = (post.voteState == VoteStateUpvoted);
  downvoteButton.highlighted = (post.voteState == VoteStateDownvoted);
  saveButton.highlighted = post.saved;
  hideButton.highlighted = post.hidden;
  reportButton.highlighted = post.reported;

  [self addButton:saveButton];
  [self addButton:hideButton];
  if (post.isModdable)
  {
    [self addButton:[self generateModButton]];
  }
  else
  {
    [self addButton:reportButton];
  }
  [self addButton:downvoteButton];
  [self addButton:upvoteButton];    
}

- (id)initWithNode:(NSObject *)node;
{
    self = [super initWithNode:node];
    if (self)
    {
      [self addPrimaryButtons];
      if ([self shouldShowModToolsByDefault])
      {
        [self enterModModeAnimated:NO];
      }
    }
    return self;
}

#pragma Mark - 
#pragma Mark - Option Handling

- (void)save;
{
    [self.delegate performSelector:@selector(toggleSavePostNode:) withObject:self.node];
}

- (void)hide;
{
    [self.delegate performSelector:@selector(toggleHidePostNode:) withObject:self.node];
}

- (void)report;
{
    [self.delegate performSelector:@selector(reportPostNode:) withObject:self.node];
}

- (void)downvote;
{
    Post *post = [(PostNode *)self.node post];
    [[ABEventLogger shared] logDownvoteChangeForPost:post
                                           container:@"listing"
                                             gesture:@"button_press"];
    [self.delegate performSelector:@selector(voteDownPostNode:) withObject:self.node];
}

- (void)upvote;
{
    Post *post = [(PostNode *)self.node post];
    [[ABEventLogger shared] logUpvoteChangeForPost:post
                                         container:@"listing"
                                           gesture:@"button_press"];
    [self.delegate performSelector:@selector(voteUpPostNode:) withObject:self.node];
}
                           
@end
