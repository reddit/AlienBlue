//
//  NSubredditCell.h
//  AlienBlue
//
//  Created by J M on 7/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NBaseOptionCell.h"
#import "Subreddit.h"

@interface SubredditNode : OptionNode
@property (strong) Subreddit *subreddit;
@property BOOL hiddenThumbnail;
- (id)initWithSubreddit:(Subreddit *)subreddit;
+ (SubredditNode *)nodeForSubreddit:(Subreddit *)subreddit;
@end

@interface NSubredditCell : NBaseOptionCell
@property (readonly) Subreddit *subreddit;
@property (strong) JMViewOverlay *thumbOverlay;
@end
