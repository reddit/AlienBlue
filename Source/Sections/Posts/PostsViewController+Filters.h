//
//  PostsViewController+Filters.h
//  AlienBlue
//
//  Created by J M on 12/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "PostsViewController.h"
#import "Post.h"

@interface PostsViewController (Filters)

- (BOOL)shouldFilterPost:(Post *)post removeExisting:(BOOL)removeExisting;

@end
