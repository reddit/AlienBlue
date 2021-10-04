//
//  NSubredditFolderCell.h
//  AlienBlue
//
//  Created by J M on 9/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NBaseOptionCell.h"
#import "SubredditFolder.h"
#import "NSectionTitleCell.h"

@interface SubredditFolderNode : SectionTitleNode
@property (strong) SubredditFolder *subredditFolder;
@property (copy) ABAction onDoubleTap;
+ (SubredditFolderNode *)folderNodeForFolder:(SubredditFolder *)folder;
@end

@interface NSubredditFolderCell : NSectionTitleCell
@end
