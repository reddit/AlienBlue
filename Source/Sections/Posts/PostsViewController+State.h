//
//  PostsViewController+State.h
//  AlienBlue
//
//  Created by J M on 7/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "PostsViewController.h"

@interface PostsViewController (State) <StatefulControllerProtocol>
- (void)handleRestoringStateAutoscroll;
@end
