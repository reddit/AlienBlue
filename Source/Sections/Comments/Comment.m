//
//  Comment.m
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (id)initWithDictionary:(NSDictionary *)dictionary;
{
  JM_SUPER_INIT(init);

  self.cachedStyledBody = nil;
  [self setVotableElementPropertiesFromDictionary:dictionary];
  
  self.body = [dictionary objectForKey:@"body"];
  self.bodyHTML = [dictionary objectForKey:@"body_html"];
  self.parentName = [dictionary objectForKey:@"parent_id"];
  self.parentIdent = [self.parentName convertRedditNameToIdent];
  self.linkIdent = [dictionary objectForKey:@"link_id"];
  self.flairText = [dictionary objectForKey:@"author_flair_text"];
  SET_IF_EMPTY(self.flairText, @"");
  self.flairText = [self.flairText stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
  
  SET_BLANK_IF_NIL(self.body);
  SET_BLANK_IF_NIL(self.bodyHTML);
  return self;
}

+ (Comment *)commentFromDictionary:(NSDictionary *)dictionary;
{
  Comment *comment = [[Comment alloc] initWithDictionary:dictionary];
  return comment;
}

@end
