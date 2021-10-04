//
//  RedditAPI.h
//  Alien Blue :: http://alienblue.org
//
//  Created by Jason Morrissey on 4/04/10.
//  Copyright 2010 The Design Shed. All rights reserved.
//

// todo: Retire the rest of the methods here in favor of Post+API style
// structure. The performSelector/target way of accessing (esp here) is now
// outdated, loose and messy. Newer API calls will be replaced with
// blocks, and oAuth support shortly following.

#define kABDownloadKeyFailedNotificationAction @"kABDownloadKeyFailedNotificationAction"
#define kABDownloadKeyData @"kABDownloadKeyData"
#define kABDownloadKeyConnectionCategory @"kABDownloadKeyConnectionCategory"
#define kABDownloadKeyAfterCompleteTarget @"kABDownloadKeyAfterCompleteTarget"
#define kABDownloadKeyAfterCompleteMethod @"kABDownloadKeyAfterCompleteMethod"
#define kABDownloadKeyConnectionIdentifier @"kABDownloadKeyConnectionIdentifier"

typedef enum {
  kConnectionCategoryAuth,
  kConnectionCategoryUser,
  kConnectionCategoryPosts,
  kConnectionCategoryComments,
  kConnectionCategorySubreddit,
  kConnectionCategoryMessages,
  kConnectionCategoryOther
} ConnectionCategory;

typedef void(^APIAction)(id response);

@interface RedditAPI : NSObject

@property (strong, readonly) NSMutableDictionary *connections;

@property (readonly) NSString *server;

@property BOOL loadingMessages;

+ (RedditAPI *)shared;

- (void)showAuthorisationRequiredDialog;

- (NSMutableURLRequest *)requestForUrl:(NSString *)url;
- (void)doPostToURL:(NSString *)urlString withParams:(NSString *)params connectionCategory:(ConnectionCategory)connectionCategory callBackTarget:(id)target callBackMethod:(SEL)loadSucceededMethod failedMethod:(SEL)loadFailedMethod;
- (void)doGetURL:(NSString *)urlString withConnectionCategory:(ConnectionCategory)connectionCategory callBackTarget:(id)target callBackMethod:(SEL)loadSucceededMethod failedMethod:(SEL)loadFailedMethod;
- (void)clearConnectionsWithCategory:(ConnectionCategory)connectionCategory;

@end
