//
//  SubredditManager.h
//  AlienBlue
//
//  Created by JM on 14/11/10.
//  Copyright (c) 2010 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubredditManager : NSObject {
    NSBundle *bundle_;
    NSString *subreddit_;
    NSDictionary *tagDictionary_;
}

@property (nonatomic, strong) NSString * subreddit;

+ (SubredditManager*) sharedSubredditManager;
- (UIImage*)imageNamed:(NSString*)name;
- (UIImage *)imageForTag:(NSString *)tag;


- (UIImage*)imageForTag:(NSString*)tag inSubreddit:(NSString *)subreddit;
- (NSArray *)imageTagsAvailableForSubreddit:(NSString *)subreddit;

- (BOOL)doesSubredditHaveAssets:(NSString *)subreddit;
- (NSString *)randomSubreddit;
- (NSArray *)defaultSubreddits;
@end
