//
//  VoteOverlay.m
//  AlienBlue
//
//  Created by J M on 15/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "VoteOverlay.h"
#import "RedditAPI+Account.h"
#import "Resources.h"

@interface VoteOverlay()
@property (nonatomic,strong) VotableElement *votableElement;
@property BOOL touchUpvoteHighlighted;
@property BOOL touchDownvoteHighlighted;
- (void)upvote;
- (void)downvote;

@end

@implementation VoteOverlay

- (id)init;
{
    self = [super initWithFrame:CGRectMake(0, 0, kVoteOverlaySize.width, kVoteOverlaySize.height)];
    if (self)
    {
        BSELF(VoteOverlay);
        self.onTap = ^(CGPoint touchPoint)
        {
            if (touchPoint.y < (blockSelf.frame.size.height / 2.))
                [blockSelf upvote];
            else
                [blockSelf downvote];
        };
        
        self.onPress = ^(CGPoint touchPoint)
        {
            if (touchPoint.y < (blockSelf.frame.size.height / 2.))
            {
                blockSelf.touchUpvoteHighlighted = YES;
                blockSelf.touchDownvoteHighlighted = NO;
            }
            else
            {
                blockSelf.touchUpvoteHighlighted = NO;
                blockSelf.touchDownvoteHighlighted = YES;
            }
            [blockSelf setNeedsDisplay];
        };
        
        self.allowTouchPassthrough = NO;
    }
    return self;
}

- (void)updateWithVotableElement:(VotableElement *)votableElement;
{
    self.votableElement = votableElement;
    [self setNeedsDisplay];
}

- (void)upvote;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    [self.votableElement upvote];
    [self setNeedsDisplay];
}

- (void)downvote;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    [self.votableElement downvote];
    [self setNeedsDisplay];
}

- (void)drawVotingIcons;
{    
    UIColor *normalColor = [UIColor colorWithWhite:0.80 alpha:1.];
    
    UIImage *upvoteNormal = [UIImage skinImageNamed:@"icons/ipad-navbar/navbar-up" withColor:normalColor];
    UIImage *downvoteNormal = [UIImage skinImageNamed:@"icons/ipad-navbar/navbar-down" withColor:normalColor];
    
    UIImage *upvoteHighlighted = [UIImage skinImageNamed:@"icons/ipad-navbar/navbar-up" withColor:[UIColor colorWithHex:0xff7a31]];
    UIImage *downvoteHighlighted = [UIImage skinImageNamed:@"icons/ipad-navbar/navbar-down" withColor:[UIColor colorWithHex:0x80abfd]];

    CGPoint upvoteOrigin = CGPointMake(6., -5.);
    CGPoint downvoteOrigin = CGPointMake(7., 24.);

    UIImage *upvoteImage = upvoteNormal;
    UIImage *downvoteImage = downvoteNormal;

    if ((self.touchUpvoteHighlighted && self.highlighted) || self.votableElement.voteState == VoteStateUpvoted)
        upvoteImage = upvoteHighlighted;
    
    if ((self.touchDownvoteHighlighted && self.highlighted) || self.votableElement.voteState == VoteStateDownvoted)
        downvoteImage = downvoteHighlighted;

//    [UIView startEtchedInnerShadowDrawWithColor:[UIColor colorWithWhite:0. alpha:0.18]];
//    [upvoteImage drawAtPoint:upvoteOrigin];
//    [downvoteImage drawAtPoint:downvoteOrigin];
//    [UIView endEtchedInnerShadowDraw];
    
    CGFloat opacity = [Resources isNight] ? 0.6 : 1.;
    
    [UIView startEtchedDropShadowDraw];
    [upvoteImage drawAtPoint:upvoteOrigin blendMode:kCGBlendModeNormal alpha:opacity];
    [downvoteImage drawAtPoint:downvoteOrigin blendMode:kCGBlendModeNormal alpha:opacity];
    [UIView endEtchedDropShadowDraw];

}

- (void)drawRect:(CGRect)rect;
{
//    [[UIColor orangeColor] set];
//    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
    
    [UIView startEtchedDropShadowDraw];
    [self drawVotingIcons];
    [UIView endEtchedDropShadowDraw];

//    self.upvoteButton = [[ABButton alloc] initWithImageName:];
//    self.downvoteButton = [[ABButton alloc] initWithImageName:@"galleries/canvas-toolbar/buttons/normal/down.png"];
}

@end
