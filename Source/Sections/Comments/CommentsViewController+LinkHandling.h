//
//  CommentsViewController+LinkHandling.h
//  AlienBlue
//
//  Created by J M on 26/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "CommentsViewController.h"

@interface CommentsViewController (LinkHandling)

- (void)coreTextURLPressed:(NSString *)url;
- (void)openLinkUrl:(NSString *)url;

@end
