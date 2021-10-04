#import "RedditAPI+Posting.h"
#import "RedditAPI+DeprecationPatches.h"

@interface RedditAPI (Posting_)
@property (ab_weak) id submitPostCallBackTarget;
@end

@implementation RedditAPI (Posting)

SYNTHESIZE_ASSOCIATED_WEAK(NSObject, submitPostCallBackTarget, SubmitPostCallBackTarget);

- (void)submitPost:(NSMutableDictionary *)newPostToSubmit withCallBackTarget:(id)target useJSON:(BOOL)useJSON
{
  if (!newPostToSubmit)
    return;
  
  // using the api_type=json only gives us a small fraction of error messages.  For example, if a link is already submitted
  // the json api directs us to a "Page Not Found" where as the jquery request will tell us that the link is already submitted.
  // and warnings about submission frequency.  In some cases, we actually need to submit the link twice, once with .json to
  // get the first batch of errors, and then with a standard request to get the rest.
  
  NSString *submitUrl = [[NSString alloc] initWithFormat:@"%@/api/submit", self.server];
  NSMutableString *p = [NSMutableString new];
  [p appendFormat:@"id=#newlink&sr=%@&title=%@&iden=%@&captcha=%@&kind=%@&",
   [newPostToSubmit valueForKey:@"subreddit"],
   [[newPostToSubmit valueForKey:@"title"] jm_escaped],
   [newPostToSubmit valueForKey:@"captchaID"],
   [newPostToSubmit valueForKey:@"captchaEntered"],
   [newPostToSubmit valueForKey:@"kind"]
   ];
  
  if ([[newPostToSubmit valueForKey:@"kind"] isEqualToString:@"link"])
  {
    [p appendFormat:@"url=%@", [[newPostToSubmit valueForKey:@"content"] jm_escaped]];
  }
  else
  {
    [p appendFormat:@"text=%@", [[newPostToSubmit valueForKey:@"content"] jm_escaped]];
  }
  
  self.submitPostCallBackTarget = target;
  [self doPostToURL:submitUrl withParams:p connectionCategory:kConnectionCategoryOther callBackTarget:self callBackMethod:@selector(submitPostResponseReceived:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)submitPostResponseReceived:(id)sender;
{
  NSData * data = (NSData *) sender;
  NSString * responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  NSMutableArray * errors = [self getErrorsInPostSubmission:responseString];
  
  if (self.submitPostCallBackTarget)
  {
    [self.submitPostCallBackTarget rd_performSelector:@selector(submitResponse:) withObject:errors];
  }
}

- (NSMutableArray *)getErrorsInPostSubmission:(NSString*)response;
{
  NSMutableArray * errors = [[NSMutableArray alloc] init];
  if([response rangeOfString:@"USER_REQUIRED" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"Please login to submit a post."];
  
  if([response rangeOfString:@"NO_URL" options:NSCaseInsensitiveSearch].location != NSNotFound
     || [response rangeOfString:@"BAD_URL" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"Invalid URL"];
  
  if([response rangeOfString:@"NO_TITLE" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"Title Required"];

  if([response rangeOfString:@"NO_LINKS" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"This subreddit only allows text posts"];
  
  if([response rangeOfString:@"TITLE_TOO_LONG" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"Title is too long"];
  
  if([response rangeOfString:@"BAD_CAPTCHA" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"Incorrect Captcha"];
  
  if([response rangeOfString:@"ALREADY_SUB" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"This link has already been submitted."];
  
  if([response rangeOfString:@"SUBREDDIT_NOEXIST" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"That reddit does not exist."];
  
  if([response rangeOfString:@"NO_TEXT" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"Compulsary field is empty."];
  
  if([response rangeOfString:@"verify your email address" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"reddit wants you to verify your email address (at Reddit.com) or wait one hour."];
  
  if([response rangeOfString:@"wait a while" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"reddit wants you to wait a while before submitting more posts."];
  
  if([response rangeOfString:@"too fast" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"You're submitting posts too fast."];
  
  if([response rangeOfString:@"SUBREDDIT_REQUIRED" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"A subreddit is required."];
  
  if([response rangeOfString:@"RATELIMIT" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"You're trying to submit too fast."];
  
  if([response rangeOfString:@"NO_USER" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"Please enter a username."];
  
  if([response rangeOfString:@"NO_SUBJECT" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"Please enter a subject."];
  
  if([response rangeOfString:@"USER_BLOCKED" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"You can't send to a user that you have blocked."];
  
  if([response rangeOfString:@"DELETED_LINK" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"The link you are commenting on has been deleted."];
  
  if([response rangeOfString:@"DELETED_COMMENT" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"That comment has been deleted."];
  
  if([response rangeOfString:@"DELETED_THING" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"That element has been deleted."];
  
  if([response rangeOfString:@"BAD_STRING" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"You used a character that we can't handle."];
  
  if([response rangeOfString:@"SUBREDDIT_RATELIMIT" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"You're submitting too fast. Please try again later."];
  
  if([response rangeOfString:@"TOO_OLD" options:NSCaseInsensitiveSearch].location != NSNotFound)
    [errors addObject:@"That's a piece of history now; it's too late to reply to it"];
  
  return errors;
}

@end
