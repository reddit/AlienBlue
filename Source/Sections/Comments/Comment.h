//
//  Comment.h
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "VotableElement.h"

@interface Comment : VotableElement

@property (nonatomic,strong) NSString *body;
@property (nonatomic,strong) NSString *bodyHTML;
@property (nonatomic,strong) NSMutableArray *links;
@property NSUInteger numberOfReplies;
@property NSUInteger commentIndex;
@property (nonatomic,strong) NSString *parentName;
@property (nonatomic,strong) NSString *parentIdent;
@property (nonatomic,strong) NSString *linkIdent;
@property (nonatomic,strong) NSString *flairText;

@property (nonatomic,strong) NSAttributedString *cachedStyledBody;

- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (Comment *)commentFromDictionary:(NSDictionary *)dictionary;

@end
