//
//  PostsViewController+PostInteraction.h
//  AlienBlue
//
//  Created by J M on 10/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "PostsViewController.h"
#import "NPostCell.h"

@interface PostsViewController (PostInteraction)
- (void)toggleSavePostNode:(PostNode *)postNode;
- (void)toggleHidePostNode:(PostNode *)postNode;
- (void)voteUpPostNode:(PostNode *)postNode;
- (void)voteDownPostNode:(PostNode *)postNode;
- (void)reportPostNode:(PostNode *)postNode;
@end
