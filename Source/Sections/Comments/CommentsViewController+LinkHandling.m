//
//  CommentsViewController+LinkHandling.m
//  AlienBlue
//
//  Created by J M on 26/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "CommentsViewController+LinkHandling.h"
#import "Post.h"
#import "NavigationManager.h"
#import "MarkupEngine.h"
#import "BrowserViewController.h"
#import "Resources.h"
#import "BrowserViewController_iPhone.h"
#import "NSString+ABLegacyLinkTypes.h"
#import "NavigationManager+Deprecated.h"

@implementation CommentsViewController (LinkHandling)

- (void)openLinkUrl:(NSString *)url;
{
  [[NavigationManager shared] handleTapOnUrl:url fromController:self];
}

- (void)coreTextURLPressed:(NSString *)url;
{
  [self openLinkUrl:url];
}

@end
