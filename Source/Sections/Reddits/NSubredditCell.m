//
//  NSubredditCell.m
//  AlienBlue
//
//  Created by J M on 7/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NSubredditCell.h"
#import "ThumbManager.h"
#import "Resources.h"

@implementation SubredditNode

- (id)initWithSubreddit:(Subreddit *)subreddit;
{
  self = [super init];
  if (self)
  {
      self.subreddit = subreddit;
      self.title = subreddit.title;
      self.stickyHighlight = YES;
  }
  return self;
}

+ (SubredditNode *)nodeForSubreddit:(Subreddit *)subreddit;
{
  return [[[self class] alloc] initWithSubreddit:subreddit];
}

+ (Class)cellClass;
{
  return NSClassFromString(@"NSubredditCell");
}

@end

@interface NSubredditCell()
@end

@implementation NSubredditCell

- (Subreddit *)subreddit;
{
    SubredditNode *subredditNode = (SubredditNode *)self.node;
    return subredditNode.subreddit;
}

- (void)applyGestureRecognizers;
{
}

- (void)createSubviews;
{
  [super createSubviews];
  
  CGRect thumbRect = CGRectMake(10., 4., 36., 36.);
  BSELF(NSubredditCell);
  self.thumbOverlay = [JMViewOverlay overlayWithFrame:thumbRect drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    UIImage *thumb = nil;
    
    if ([UDefaults boolForKey:kABSettingKeyShowLegacySubredditIcons])
    {
        NSString *legacyUrl = [NSString stringWithFormat:@"http://thumbs.reddit.com/%@.png", blockSelf.subreddit.name];
        thumb = [UIImage jm_remoteImageWithURL:[legacyUrl URL] onRetrieveComplete:^(UIImage *image) {
          [blockSelf.containerView setNeedsDisplay];
        }];
    }
    else
    {
      thumb = [[ThumbManager manager] subredditIconForSubreddit:blockSelf.subreddit.iconIdent ident:blockSelf.subreddit.ident onComplete:^(UIImage *image){
          [blockSelf.containerView setNeedsDisplay];
      }];
    }
  
    if (!thumb)
    {
        thumb = [UIImage skinImageNamed:@"section/reddits-list/subreddit-icon-placeholder"];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    [UIView addRoundedRectToPathForContext:context rect:bounds ovalWidth:4. ovalHeight:4.];
    CGContextClip(context);
    
    [thumb drawAtPoint:CGPointMake(-1., 0.)];
    
    if (blockSelf.subreddit.subscribed && blockSelf.isEditing)
    {
      CGRect tickRect = CGRectMake(bounds.size.width - 12., bounds.size.height - 12., 11., 11.);
      [UIView startEtchedDraw];
      [[UIImage skinImageNamed:@"icons/rounded-tick"] drawInRect:tickRect];
      [UIView endEtchedDraw];
    }
  
    UIColor *thumbOutlineColor = JMIsNight() ? JMHexColor(292929) : JMHexColor(BBBBBB);
    [thumbOutlineColor setStroke];
    [[UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:4.] stroke];
  
    CGContextRestoreGState(context);
  }];
  [self.containerView addOverlay:self.thumbOverlay];
  self.thumbOverlay.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  
  [self applyGestureRecognizers];
}

- (void)layoutCellOverlays;
{
  [super layoutCellOverlays];
  
  SubredditNode *subredditNode = (SubredditNode *)self.node;
  self.titleOverlay.left = (subredditNode.hiddenThumbnail) ? 17. : 56.;
}

- (void)updateWithNode:(JMOutlineNode *)node
{
  [super updateWithNode:node];

  SubredditNode *subredditNode = (SubredditNode *)node;
  self.thumbOverlay.hidden = subredditNode.hiddenThumbnail;
}

@end
