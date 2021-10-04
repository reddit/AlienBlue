//
//  NDiscoveryOptionCell.h
//  AlienBlue
//
//  Created by J M on 17/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NBaseOptionCell.h"

typedef void(^OptionSwitchChange)(BOOL switchValue);

@interface DiscoveryOptionNode : OptionNode
@property (strong) NSString *subtitle;
@property BOOL switchSetting;
@property (copy) OptionSwitchChange onSwitchChange;
@end

@interface NDiscoveryOptionCell : NBaseOptionCell
@end
