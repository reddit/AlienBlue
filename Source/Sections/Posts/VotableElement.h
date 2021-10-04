//
//  VotableElement.h
//  AlienBlue
//
//  Created by J M on 15/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  ModerationStateUnmoddable = 0,
  ModerationStatePending,
  ModerationStateReported,
  ModerationStateRemoved,
  ModerationStateApproved
} ModerationState;

typedef enum {
    VoteStateDownvoted = -1,
    VoteStateUndecided = 0,
    VoteStateUpvoted = 1
} VoteState;

typedef enum {
    OwnershipNormal = 0,
    OwnershipMine,
    OwnershipOperator,
} OwnershipType;

@interface VotableElement : NSObject
@property VoteState voteState;

@property (readonly) BOOL isMine;
@property (readonly) BOOL isFromModerator;
@property (readonly) BOOL isFromAdmin;

@property (readonly) NSString *tinyTimeAgo;
@property (readonly) NSString *formattedScore;
@property (readonly) NSString *formattedScoreWithText;
@property (readonly) NSString *formattedScoreTinyWithPlus;
@property (readonly) NSString *formattedScoreTiny;

@property BOOL deleted;
@property BOOL isScoreHidden;

@property (nonatomic,strong) NSString *ident;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *author;
@property (nonatomic,strong) NSString *timeAgo;
@property (nonatomic,strong) NSString *subreddit;
@property (nonatomic,strong) NSString *subredditId;
@property (nonatomic,strong) NSString *permalink;
@property (nonatomic,strong) NSString *distinguishedStr;
@property (strong) NSDate *createdDate;

@property (nonatomic) NSInteger score;

// mod info

@property (nonatomic,strong) NSString *approvedBy;
@property (nonatomic,strong) NSString *bannedBy;
@property (nonatomic) NSInteger numReports;
@property (nonatomic) BOOL isModdable;
@property (nonatomic) BOOL isSpam;
@property (readonly) ModerationState moderationState;


- (void)setVotableElementPropertiesFromDictionary:(NSDictionary *)dictionary;

- (NSString *)formattedScore;
- (NSString *)formattedScoreWithText;

- (OwnershipType)ownershipToUser:(NSString *)user;
- (void)upvote;
- (void)downvote;

- (void)modApprove;
- (void)modRemove;
- (void)modMarkAsSpam;

- (NSMutableDictionary *)legacyDictionary;
- (void)reportAnalyticEventWithAction:(NSString *)action;

@end
