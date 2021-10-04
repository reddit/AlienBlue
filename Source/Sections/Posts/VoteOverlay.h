//
//  VoteOverlay.h
//  AlienBlue
//
//  Created by J M on 15/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "JMViewOverlay.h"
#import "VotableElement.h"

#define kVoteOverlaySize CGSizeMake(46., 70.)

@interface VoteOverlay : JMViewOverlay
- (void)updateWithVotableElement:(VotableElement *)votableElement;
@end
