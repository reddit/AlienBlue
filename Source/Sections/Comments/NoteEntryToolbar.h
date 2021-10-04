//
//  NoteEntryToolbar.h
//  AlienBlue
//
//  Created by JM on 29/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABToolbar.h"

@interface NoteEntryToolbar : ABToolbar 
{
	id controlDelegate_;
}

@property (nonatomic,strong) id controlDelegate;

- (void)addPhotoOptions;
- (void)addTextMessage:(NSString *)text;

@end
