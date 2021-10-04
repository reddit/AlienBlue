#import "ViewContainerCell.h"

@implementation ViewContainerNode

- (id)initWithView:(UIView *)view;
{
  self = [super init];
  if (self)
  {
    self.view = view;
    self.heightForViewLandscape = view.height;
    self.heightForViewPortrait = view.height;
  }
  return self;
}

+ (Class)cellClass;
{
  return [ViewContainerCell class];
}

@end

@implementation ViewContainerCell

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
  ViewContainerNode *viewNode = (ViewContainerNode *)node;
  CGFloat height = JMPortrait() ? viewNode.heightForViewPortrait : viewNode.heightForViewLandscape;
  height += viewNode.padding.height * 2.;
  return height;
}

- (void)updateSubviews;
{
  [super updateSubviews];
  self.backgroundColor = [UIColor colorForBackground];
  self.containerView.backgroundColor = self.backgroundColor;
  ViewContainerNode *viewNode = (ViewContainerNode *)self.node;
  UIView *view = viewNode.view;
  if (view.superview != self.containerView)
  {
    [self.containerView addSubview:view];
    
    if (viewNode.resizesToFitCell)
    {
      view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      view.frame = CGRectInset(self.containerView.bounds, viewNode.padding.width, viewNode.padding.height);
    }
    else
    {
      view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
      [view centerInSuperView];
    }
  }
  
  if ([view respondsToSelector:@selector(applyDefaultThemeSettings)])
  {
    [view performSelector:@selector(applyDefaultThemeSettings)];
  }
}

@end
