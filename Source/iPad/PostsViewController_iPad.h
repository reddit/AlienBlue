//
//  PostsViewController_iPad.h
//  AlienBlue
//
//  Created by J M on 15/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "PostsViewController.h"
#import "JMFoldingNavigation.h"

@interface PostsViewController_iPad : PostsViewController <JMFoldingControllerProtocol>
- (BOOL)isContentPaneOpenForPost:(Post *)post;
- (void)scrollToLastTouchedPost;
@end
