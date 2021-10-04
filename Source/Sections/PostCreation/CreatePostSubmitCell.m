#import "CreatePostSubmitCell.h"
#import "UIImage+Skin.h"
#import "ABButton.h"

@implementation PostSubmitNode

+ (Class)cellClass;
{
    return NSClassFromString(@"CreatePostSubmitCell");
}

//+ (SEL)selectedAction;
//{
//    return nil;
//}

@end

@interface CreatePostSubmitCell()
@property (nonatomic,strong) ABButton * submitButton;
@property (strong) ABButton *viewSubmitRulesButton;
@end

@implementation CreatePostSubmitCell

@synthesize submitButton = submitButton_;

- (void)createSubviews;
{
    [super createSubviews];

    self.submitButton = [[ABButton alloc] initWithIcon:[self submitButtonImageHighlighted:NO]];
    [self.containerView addSubview:self.submitButton];
  
    self.viewSubmitRulesButton = [[ABButton alloc] initWithIcon:[self rulesButtonImageHighlighted:NO]];
    [self.containerView addSubview:self.viewSubmitRulesButton];
}

- (UIImage *)submitButtonImageHighlighted:(BOOL)highlighted;
{
  BSELF(CreatePostSubmitCell);
  UIImage *submitImage = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    CGRect b = CGRectInset(bounds, 3., 3.);
    PostSubmitNode *submitNode = JMCastOrNil(blockSelf.node, PostSubmitNode);
    UIColor *buttonColor = submitNode.shouldShowPostWarning ? [UIColor colorWithWhite:0.5 alpha:0.5] : [UIColor skinColorForConstructive];
    if (highlighted)
    {
      buttonColor = [buttonColor colorWithAlphaComponent:0.5];
    }
    [buttonColor setFill];
    [[UIBezierPath bezierPathWithRoundedRect:b cornerRadius:2.] fill];
    [@"Submit to Reddit" jm_drawVerticallyCenteredInRect:b withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.] color:[UIColor whiteColor] horizontalAlignment:NSTextAlignmentCenter];
  } opaque:NO withSize:CGSizeMake(200., 40.) cacheKey:nil];
  return submitImage;
}

- (UIImage *)rulesButtonImageHighlighted:(BOOL)highlighted;
{
  BSELF(CreatePostSubmitCell);
  UIImage *viewRulesImage = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    PostSubmitNode *submitNode = JMCastOrNil(blockSelf.node, PostSubmitNode);
    UIColor *textColor = submitNode.shouldShowPostWarning ? [UIColor skinColorForDestructive] : [UIColor skinColorForConstructive];
    UIFont *font = submitNode.shouldShowPostWarning ? [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.] : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.];

    if (highlighted)
    {
      textColor = [textColor colorWithAlphaComponent:0.5];
    }

    NSString *prefix = submitNode.shouldShowPostWarning ? @"⚠︎" : @"ⓘ";
    NSString *title = [NSString stringWithFormat:@"%@  View Subreddit Rules", prefix];
    
    [title jm_drawVerticallyCenteredInRect:bounds withFont:font color:textColor horizontalAlignment:NSTextAlignmentCenter];
  } withSize:CGSizeMake(200., 40.)];
  return viewRulesImage;
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    [self.submitButton centerInSuperView];
  
    PostSubmitNode *submitNode = JMCastOrNil(self.node, PostSubmitNode);
    if (submitNode.shouldShowSubmitRulesButton)
    {
      self.submitButton.top -= 17.;
      [self.viewSubmitRulesButton centerHorizontallyInSuperView];
      self.viewSubmitRulesButton.top = self.submitButton.bottom;
    }
}

- (void)updateSubviews;
{
    [super updateSubviews];
    [self.submitButton addTarget:self.node.delegate action:@selector(submitNodeSelected:) forControlEvents:UIControlEventTouchUpInside];
    self.submitButton.imageNormal = [self submitButtonImageHighlighted:NO];
    self.submitButton.imageHighlighted = [self submitButtonImageHighlighted:YES];

    PostSubmitNode *submitNode = JMCastOrNil(self.node, PostSubmitNode);
    self.viewSubmitRulesButton.hidden = !submitNode.shouldShowSubmitRulesButton;
    [self.viewSubmitRulesButton addTarget:self.node.delegate action:@selector(viewSubmitRulesButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.viewSubmitRulesButton.imageNormal = [self rulesButtonImageHighlighted:NO];
    self.viewSubmitRulesButton.imageHighlighted = [self rulesButtonImageHighlighted:YES];
  
}

- (void)decorateCellBackground;
{
  [super decorateCellBackground];
  [[UIColor colorForBackground] setFill];
  [[UIBezierPath bezierPathWithRect:self.containerView.bounds] fill];
  [UIView jm_drawHorizontalDottedLineInRect:CGRectCropToTop(self.bounds, 1.) lineWidth:1. lineColor:[UIColor colorForDottedDivider]];
}

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
  return 110.;
}

@end
