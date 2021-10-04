//
//  DiscoverySceneController.h
//  AlienBlue
//
//  Created by J M on 16/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "ABOutlineViewController.h"

@interface DiscoverySceneController : ABOutlineViewController
@property (strong) UIActivityIndicatorView *loadingIndicator;
- (id)initWithTitle:(NSString *)title sceneIdent:(NSString *)ident;
- (void)animateFolderChanges;
@end
