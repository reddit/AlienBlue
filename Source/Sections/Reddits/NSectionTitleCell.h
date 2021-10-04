//
//  NRedditTitleCell.h
//  AlienBlue
//
//  Created by J M on 7/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "JMOutlineCell.h"
#import "NBaseOptionCell.h"

@interface SectionTitleNode : OptionNode
+ (SectionTitleNode *)nodeForTitle:(NSString *)title;
@property BOOL collapsable;
@end

@interface NSectionTitleCell : NBaseOptionCell
@end
