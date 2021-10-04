//
//  PostsViewController+Hiding.h
//  AlienBlue
//
//  Created by J M on 10/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "PostsViewController.h"
#import "NPostCell.h"

@interface PostsViewController (FooterSupport)

- (void)loadMore;
- (void)hideRead;
- (void)hideAll;

@end
