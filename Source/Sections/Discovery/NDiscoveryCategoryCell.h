//
//  NDiscoveryGategoryCell.h
//  AlienBlue
//
//  Created by J M on 17/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NBaseOptionCell.h"
#import "DiscoveryCategory.h"

@interface DiscoveryCategoryNode : OptionNode
@property (strong) DiscoveryCategory *category;
+ (DiscoveryCategoryNode *)categoryNodeForCategory:(DiscoveryCategory *)category;
@end

@interface NDiscoveryCategoryCell : NBaseOptionCell
@end
