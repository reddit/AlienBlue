//
//  VotableElement.m
//  AlienBlue
//
//  Created by J M on 15/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "VotableElement.h"
#import "Resources.h"
#import "RedditAPI.h"
#import "RedditAPI+Moderation.h"
#import "RedditAPI+ElementInteraction.h"
#import "RedditAPI+Account.h"

#define kJMVotableElementReportCountWhenModerationUnavailable -1

@interface VotableElement()
@property (nonatomic,strong) NSDictionary *rawDictionary;
@property (readonly) NSString *elementCategoryNameForAnalytics;
@end

@implementation VotableElement

- (void)setVotableElementPropertiesFromDictionary:(NSDictionary *)dictionary;
{
    self.rawDictionary = dictionary;
    self.ident = [dictionary objectForKey:@"id"];
    self.name = [dictionary objectForKey:@"name"];
    self.author = [dictionary objectForKey:@"author"];    
    self.subreddit = [dictionary objectForKey:@"subreddit"];
    self.subredditId = [dictionary objectForKey:@"subreddit_id"];
    self.permalink = [dictionary objectForKey:@"permalink"];
    self.distinguishedStr = [dictionary objectForKey:@"distinguished"];

    self.timeAgo = [NSString formattedTimeFromReferenceTime:[[dictionary objectForKey:@"created_utc"] floatValue]];
    self.createdDate = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"created_utc"] floatValue]];
  
    SET_IF_EMPTY(self.author, @"[deleted]");
    SET_BLANK_IF_NIL(self.subreddit);
    SET_BLANK_IF_NIL(self.subredditId);
    SET_BLANK_IF_NIL(self.permalink);
    SET_BLANK_IF_NIL(self.distinguishedStr);
    SET_BLANK_IF_NIL(self.name);
    SET_BLANK_IF_NIL(self.ident);
  
    id likesVal = (![[dictionary objectForKey:@"likes"] isKindOfClass:[NSNull class]]) ? [dictionary objectForKey:@"likes"] : nil;
    if (!likesVal)
        self.voteState = VoteStateUndecided;
    else if ([likesVal boolValue])
        self.voteState = VoteStateUpvoted;
    else
        self.voteState = VoteStateDownvoted;
        
    NSInteger ups = [[dictionary objectForKey:@"ups"] integerValue];
    NSInteger downs = [[dictionary objectForKey:@"downs"] integerValue];
    self.score = ups - downs;
  
    if (!JMIsNull([dictionary objectForKey:@"score_hidden"]))
    {
      self.isScoreHidden = [[dictionary objectForKey:@"score_hidden"] boolValue];
    }

    NSNumber *reportsNum = [dictionary objectForKey:@"num_reports"];
    self.isModdable = !JMIsNull(reportsNum);
//#ifdef DEBUG
//    self.isModdable = YES;
//#endif
    self.numReports = JMIsNull(reportsNum) ? kJMVotableElementReportCountWhenModerationUnavailable : [reportsNum integerValue];
  
    if ([[dictionary objectForKey:@"approved_by"] isKindOfClass:[NSString class]])
      self.approvedBy = [dictionary objectForKey:@"approved_by"];

    if ([[dictionary objectForKey:@"banned_by"] isKindOfClass:[NSString class]])
      self.bannedBy = [dictionary objectForKey:@"banned_by"];
}

- (NSString *)tinyTimeAgo;
{
    SET_IF_EMPTY(self.timeAgo, @"");
    return [self.timeAgo stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (NSMutableDictionary *)legacyDictionary;
{
    NSMutableDictionary *legacyDictionary = [NSMutableDictionary dictionaryWithDictionary:self.rawDictionary];
    if (self.voteState == VoteStateUpvoted)
        [legacyDictionary setObject:[NSNumber numberWithInt:1] forKey:@"voteDirection"];
    else if (self.voteState == VoteStateDownvoted)
        [legacyDictionary setObject:[NSNumber numberWithInt:-1] forKey:@"voteDirection"];
    else
        [legacyDictionary setObject:[NSNumber numberWithInt:0] forKey:@"voteDirection"];
    return legacyDictionary;
}

- (OwnershipType)ownershipToUser:(NSString *)user;
{
    if ([self.author equalsString:[[RedditAPI shared] authenticatedUser]])
        return OwnershipMine;
    else if ([self.author equalsString:user])
        return OwnershipOperator;
    else
        return OwnershipNormal;
}

- (BOOL)isMine;
{
    return [self ownershipToUser:nil];
}

- (BOOL)isFromModerator;
{
  return [self.distinguishedStr jm_contains:@"moderator"];
}

- (BOOL)isFromAdmin;
{
  return [self.distinguishedStr jm_contains:@"admin"];
}

- (NSMutableDictionary *)legacyVoteDictionary;
{
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    [d setValue:self.name forKey:@"name"];
    
    NSInteger voteDirection;
    if (self.voteState == VoteStateUpvoted)
        voteDirection = 1;
    else if (self.voteState == VoteStateDownvoted)
        voteDirection = -1;
    else
        voteDirection = 0;
    
    [d setValue:[NSNumber numberWithInt:voteDirection] forKey:@"voteDirection"];
    return d;
}

- (NSString *)formattedScoreTiny;
{
    NSString *prefix = (self.score >= 0) ? @"" : @"-";
    return [NSString stringWithFormat:@"%@%d", prefix, labs(self.score)];
}


- (NSString *)formattedScore;
{
    NSString *prefix = (self.score >= 0) ? @"+" : @"-";
    return [NSString stringWithFormat:@"%@ %d", prefix, labs(self.score)];
}

- (NSString *)formattedScoreTinyWithPlus;
{
    NSString *prefix = (self.score >= 0) ? @"+" : @"-";
    return [NSString stringWithFormat:@"%@%d", prefix, labs(self.score)];
}

- (NSString *)formattedScoreWithText;
{
  NSMutableString *scoreStr = [NSMutableString string];
  [scoreStr appendFormat:@"%d pt", self.score];
  if (self.score != 1)
  {
    [scoreStr appendString:@"s"];
  }
  return scoreStr;
}

- (void)upvote;
{	
  VoteState previousState = self.voteState;
    
	if (previousState == VoteStateUpvoted)
	{
        self.voteState = VoteStateUndecided;
        self.score--;
        [self reportAnalyticEventWithAction:@"Unupvote"];
	}
	else if (previousState == VoteStateUndecided)
	{
        self.voteState = VoteStateUpvoted;
        self.score++;
        [self reportAnalyticEventWithAction:@"Upvote"];
	}
	else if (previousState == VoteStateDownvoted)
	{
        self.voteState = VoteStateUpvoted;
        self.score++;
        self.score++;
        [self reportAnalyticEventWithAction:@"Undownvote-to-Upvote"];
	}
    
	[[RedditAPI shared] submitVote:[self legacyVoteDictionary]];
}

- (void)downvote;
{	
    VoteState previousState = self.voteState;
    
	if (previousState == VoteStateUpvoted)
	{
        self.voteState = VoteStateDownvoted;
        self.score--;
        self.score--;
        [self reportAnalyticEventWithAction:@"Unupvote-to-Downvote"];
	}
	else if (previousState == VoteStateUndecided)
	{
        self.voteState = VoteStateDownvoted;
        self.score--;
        [self reportAnalyticEventWithAction:@"Downvote"];
	}
	else if (previousState == VoteStateDownvoted)
	{
        self.voteState = VoteStateUndecided;
        self.score++;
        [self reportAnalyticEventWithAction:@"Undownvote"];
	}
	[[RedditAPI shared] submitVote:[self legacyVoteDictionary]];
}

#pragma mark - Moderation

- (ModerationState)moderationState;
{
  if (!self.isModdable)
    return ModerationStateUnmoddable;
  
  if (self.approvedBy && ![self.approvedBy isEmpty])
    return ModerationStateApproved;
  
  if (self.bannedBy && ![self.bannedBy isEmpty])
    return ModerationStateRemoved;
  
  if (self.numReports > 0)
    return ModerationStateReported;
  
  return ModerationStatePending;
}

- (void)replaceRawDictionaryKey:(NSString *)key withObjectOrNil:(id)obj;
{
  NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:self.rawDictionary];
  if (!obj)
  {
    [d removeObjectForKey:key];
  }
  else
  {
    [d setObject:obj forKey:key];
  }
  self.rawDictionary = d;
}

- (void)i_modUpdateRawDictionaryWithIVars;
{
  [self replaceRawDictionaryKey:@"approved_by" withObjectOrNil:self.approvedBy];
  [self replaceRawDictionaryKey:@"banned_by" withObjectOrNil:self.bannedBy]; 
}

- (void)modApprove;
{
  self.isSpam = NO;
  self.approvedBy = [RedditAPI shared].authenticatedUser;
  self.bannedBy = nil;

  [self i_modUpdateRawDictionaryWithIVars];
  [self reportAnalyticEventWithAction:@"Mod Approve"];
  [[RedditAPI shared] modApproveItemWithName:self.name];
}

- (void)modRemove;
{
  self.isSpam = NO;
  self.bannedBy = [RedditAPI shared].authenticatedUser;
  self.approvedBy = nil;
  
  [self i_modUpdateRawDictionaryWithIVars];
  [self reportAnalyticEventWithAction:@"Mod Remove"];
  [[RedditAPI shared] modRemoveItemWithName:self.name];
}

- (void)modMarkAsSpam;
{
  self.isSpam = YES;
  self.bannedBy = [RedditAPI shared].authenticatedUser;
  self.approvedBy = nil;
  
  [self i_modUpdateRawDictionaryWithIVars];
  
  [self reportAnalyticEventWithAction:@"Mod Marked Spam"];
  [[RedditAPI shared] modMarkAsSpamItemWithName:self.name];
}

- (void)reportAnalyticEventWithAction:(NSString *)action;
{
  BSELF(VotableElement);

  NSString *descriptiveCategoryName = [@[@"Post", @"Comment", @"Message"] match:^BOOL(NSString *classType) {
    return JMIsClass(blockSelf, NSClassFromString(classType));
  }];
  
  SET_IF_EMPTY(descriptiveCategoryName, @"Unknown");
  
  [ABAnalyticsManager trackEventWithCategory:descriptiveCategoryName action:action];
}

@end
