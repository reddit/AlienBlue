//
//  RedditAPI.m
//  Alien Blue :: http://alienblue.org
//
//  Created by Jason Morrissey on 4/04/10.
//  Copyright 2010 The Design Shed. All rights reserved.
//

#import "RedditAPI.h"
#import "RedditAPI+OAuth.h"
#import "RedditAPI+DeprecationPatches.h"
#import "RedditAPI+HideQueue.h"
#import "RedditAPI+Posts.h"
#import "RedditAPI+Account.h"
#import "RedditAPI+Announcements.h"
#import "AlienBlueAppDelegate.h"
#import "Resources.h"
#import "SFHFKeychainUtils.h"
#import "AFNetworking.h"
#import "NSDictionary+UrlEncoding.h"
#import "Subreddit+API.h"
#import "Subreddit+Moderation.h"
#import "JSONKit.h"
#import "SessionManager+Authentication.h"

@interface RedditAPI()
@property (strong) NSMutableDictionary *connections;
@end

@implementation RedditAPI

- (id)init
{
  JM_SUPER_INIT(init);
  
  self.connections = [[NSMutableDictionary alloc] init];
  [self prepareHideQueue];
  [self prepareDefaultUserState];
  [self prepareAnnouncementChecking];
  
  return self;
}

+ (RedditAPI *)shared
{
  JM_SHARED_INSTANCE_USING_BLOCK(^{
    return [[self alloc] init];
  });
}

#pragma mark - Connection Management

- (void)clearConnectionsWithCategory:(ConnectionCategory)connectionCategory
{
  if (!self.connections)
      return;

  if (![NSDictionary instancesRespondToSelector:@selector(enumerateKeysAndObjectsUsingBlock:)])
      return;
    
  @synchronized(self)
  {
    NSMutableArray *keysToRemove = [NSMutableArray array];
    [self.connections enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      ConnectionCategory cCategory = (ConnectionCategory) [[obj objectForKey:kABDownloadKeyConnectionCategory] intValue];
      if (cCategory == connectionCategory)
      {
        [keysToRemove addObject:key];
      }
    }];
    [self.connections removeObjectsForKeys:keysToRemove];
  }
}

#pragma mark -
#pragma mark - Connection Delegate

static inline NSString * ABAPIGenerateConnectionKey(NSURLConnection *connection)
{
  return [NSString stringWithFormat:@"%ld", ((intptr_t) connection)];
}

- (NSMutableDictionary *)downloadDictionaryForConnection:(NSURLConnection *)connection;
{
  return [self.connections objectForKey:ABAPIGenerateConnectionKey(connection)];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  NSMutableDictionary *dl = [self downloadDictionaryForConnection:connection];
  if (!dl)
    return;
  
	NSMutableData *data = [[NSMutableData alloc] init];
	[dl setObject:data forKey:kABDownloadKeyData];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  NSMutableDictionary *dl = [self downloadDictionaryForConnection:connection];
  if (!dl)
    return;
	NSMutableData *dataReceivedSoFar = (NSMutableData *)[dl objectForKey:kABDownloadKeyData];
	[dataReceivedSoFar appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  NSMutableDictionary *dl = [self downloadDictionaryForConnection:connection];
  if (!dl)
    return;
  
	// perform necessary callbacks with the data
	if ([dl objectForKey:kABDownloadKeyFailedNotificationAction] && [dl objectForKey:kABDownloadKeyAfterCompleteTarget])
	{
		SEL action = NSSelectorFromString([dl valueForKey:kABDownloadKeyFailedNotificationAction]);
    if ([[dl objectForKey:kABDownloadKeyAfterCompleteTarget] respondsToSelector:action])
    {
      [[dl objectForKey:kABDownloadKeyAfterCompleteTarget] rd_performSelector:action withObject:nil];
    }
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  NSString *connectionKey = ABAPIGenerateConnectionKey(connection);
	NSMutableDictionary * dl = [self.connections objectForKey:connectionKey];
  if (!dl)
      return;
  
	if ([dl objectForKey:kABDownloadKeyAfterCompleteMethod] && [dl objectForKey:kABDownloadKeyAfterCompleteTarget] && [dl objectForKey:kABDownloadKeyData])
	{
		SEL action = NSSelectorFromString([dl valueForKey:kABDownloadKeyAfterCompleteMethod]);
    id target = [dl objectForKey:kABDownloadKeyAfterCompleteTarget];
    if (target && [target respondsToSelector:action])
    {
      [target rd_performSelector:action withObject:[dl objectForKey:kABDownloadKeyData]];
    }
	}
	[self.connections removeObjectForKey:connectionKey];
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  return request;
}

- (void)connectionFailedDialog:(id)sender
{
	self.loadingPosts = NO;
	self.loadingMessages = NO;
	self.currentlyAuthenticating = NO;
	[self.hideQueue removeAllObjects];
	// release connections so that we don't keep bugging the user
  // if there are multiple connections.
	[self.connections removeAllObjects];
}

#pragma mark -
#pragma mark - Connection API

- (NSDictionary *)generateAuthenticationHeadersForRedditRequest;
{
  return [self generateOAuthAuthenticationHeadersForRedditRequest];
}

- (NSMutableURLRequest *)requestForUrl:(NSString *)url;
{
  NSString *redditUrl = [self.server stringByAppendingPathComponent:url];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:redditUrl]];
  [request setTimeoutInterval:400.];
  [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
  [request setAllHTTPHeaderFields:[self generateAuthenticationHeadersForRedditRequest]];
  return request;
}

- (void)doPostToURL:(NSString *)urlString withParams:(NSString *)params connectionCategory:(ConnectionCategory)connectionCategory callBackTarget:(id)target callBackMethod:(SEL)loadSucceededMethod failedMethod:(SEL)loadFailedMethod
{
	NSData *postData = [params dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  [request setTimeoutInterval:300];
	[request setURL:[NSURL URLWithString:urlString]];
  [request setAllHTTPHeaderFields:[self generateAuthenticationHeadersForRedditRequest]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	NSURLConnection * connection = [NSURLConnection connectionWithRequest:request delegate:self];
  NSString *connectionKey = ABAPIGenerateConnectionKey(connection);
	NSMutableDictionary *dl = [[NSMutableDictionary alloc] init];
	[dl setValue:[NSNumber numberWithInt:connectionCategory] forKey:kABDownloadKeyConnectionCategory];
	[dl setValue:connectionKey forKey:kABDownloadKeyConnectionIdentifier];
	[dl setValue:target forKey:kABDownloadKeyAfterCompleteTarget];
	[dl setValue:NSStringFromSelector(loadSucceededMethod) forKey:kABDownloadKeyAfterCompleteMethod];
	[dl setValue:NSStringFromSelector(loadFailedMethod) forKey:kABDownloadKeyFailedNotificationAction];
  
	[self.connections setValue:dl forKey:connectionKey];
}

- (void)doGetURL:(NSString *)urlString withConnectionCategory:(ConnectionCategory)connectionCategory callBackTarget:(id)target callBackMethod:(SEL)loadSucceededMethod failedMethod:(SEL)loadFailedMethod;
{
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlString]];
  [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
  NSDictionary *authenticationHeaders = [self generateAuthenticationHeadersForRedditRequest];
  if (authenticationHeaders)
  {
    [request setAllHTTPHeaderFields:authenticationHeaders];
  }
  NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
	NSString *connectionKey = ABAPIGenerateConnectionKey(connection);

  NSMutableDictionary *dl = [[NSMutableDictionary alloc] init];
	[dl setValue:[NSNumber numberWithInt:connectionCategory] forKey:kABDownloadKeyConnectionCategory];
	[dl setValue:connectionKey forKey:kABDownloadKeyConnectionIdentifier];
	if (target && loadSucceededMethod)
	{
		[dl setValue:target forKey:kABDownloadKeyAfterCompleteTarget];
		[dl setValue:NSStringFromSelector(loadSucceededMethod) forKey:kABDownloadKeyAfterCompleteMethod];
	}
	[dl setValue:NSStringFromSelector(loadFailedMethod) forKey:kABDownloadKeyFailedNotificationAction];
  
	[self.connections setValue:dl forKey:connectionKey];
}

- (void)showAuthorisationRequiredDialog
{
  NSString *title;
  NSString *message;
  
  if (self.currentlyAuthenticating)
  {
    title = @"Still authenticating...";
    message = @"reddit servers are taking time to authenticate.";
  }
  else if ([self hasAuthenticatableUser])
  {
    title = @"Retry Login";
    message = @"We were unable to log you in when you launched the app, but you can attempt a re-authentication now. Optionally, please visit the Settings->Accounts section if you recently changed your password.";
  }
  else
  {
    title = @"Please login.";
    message = @"You need to enter your reddit username and password in the 'Settings' panel.  If you wish to force re-authentication, you can tap the *Alien* next to your username in the Settings.";
  }
  
  UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:title message:message];
  [alert bk_setCancelButtonWithTitle:@"OK" handler:nil];
  if ([self hasAuthenticatableUser])
  {
    [alert bk_addButtonWithTitle:@"Retry Login" handler:^{
      [[SessionManager manager] forceReauthenticationForActiveUser];
    }];
  }
  [alert show];
}

- (NSString *)server
{
  return [self recommendedServerForActiveUser];
}

@end