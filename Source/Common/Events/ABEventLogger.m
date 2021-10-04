//  ABEventLogger.m
//  AlienBlue

#import "ABEventLogger.h"

#import <sys/time.h>

#import <Puree/Puree.h>

#import "ABDataEvent.h"
#import "RedditAPI+Account.h"

@interface ABEventLogger ()
@property (nonatomic, strong) PURLogger *logger;
@end

@implementation ABEventLogger

static ABEventLogger *sharedLogger = nil;
static NSString *kTag = @"reddit";
static NSString *kEventVersion = @"0.0.1";

+ (ABEventLogger *)shared
{
  if (!sharedLogger) {
    sharedLogger = [[ABEventLogger alloc] init];
  }
  return sharedLogger;
}

- (id)init
{
  if (self = [super init]) {
    PURLoggerConfiguration *configuration = [PURLoggerConfiguration defaultConfiguration];
    configuration.outputSettings = @[ [[PUROutputSetting alloc] initWithOutput:[ABDataEvent class]
                                                                    tagPattern:kTag] ];
    self.logger = [[PURLogger alloc] initWithConfiguration:configuration];
  }
  return self;
}

- (void)logTopic:(NSString *)topic type:(NSString *)type payload:(NSDictionary *)payload
{
  [self logTopic:topic type:type payload:payload obfuscatedPayload:nil];
}

- (void)logTopic:(NSString *)topic
    type:(NSString *)type
    payload:(NSDictionary *)payload
    obfuscatedPayload:(NSDictionary *)obfuscatedPayload
{
  if (obfuscatedPayload) {
    payload = [NSMutableDictionary dictionaryWithDictionary:payload];
    [payload setValue:obfuscatedPayload forKey:@"obfuscated_data"];
  }

  struct timeval time;
  gettimeofday(&time, NULL);
  u_int64_t timeInMillis = (time.tv_sec * 1000ULL) + (time.tv_usec / 1000ULL);

  CFUUIDRef uuid = CFUUIDCreate(NULL);
  NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
  CFRelease(uuid);

  NSString *eventTypePrefix = JMIsIpad() ? @"iPadAlienBlue." : @"iPhoneAlienBlue.";
  NSDictionary *event = @{ @"event_topic" : topic,
                           @"event_type" : [eventTypePrefix stringByAppendingString:type],
                           @"event_ts" : [NSNumber numberWithUnsignedLongLong:timeInMillis],
                           @"uuid" : uuidString,
                           @"payload" : payload };
  [self.logger postLog:event tag:kTag];
}

- (void)logUpvoteChangeForPost:(Post *)post
                     container:(NSString *)container
                       gesture:(NSString *)gesture
{
  if (post.voteState == VoteStateUpvoted) {
    [self logVoteChangeForPost:post container:container gesture:gesture voteType:@"un_upvote"];
  } else {
    [self logVoteChangeForPost:post container:container gesture:gesture voteType:@"upvote"];
  }
}

- (void)logDownvoteChangeForPost:(Post *)post
                       container:(NSString *)container
                         gesture:(NSString *)gesture
{
  if (post.voteState == VoteStateDownvoted) {
    [self logVoteChangeForPost:post container:container gesture:gesture voteType:@"un_downvote"];
  } else {
    [self logVoteChangeForPost:post container:container gesture:gesture voteType:@"downvote"];
  }
}

#pragma mark - private

- (NSMutableDictionary *)standardPayload
{
  // Get the GMT timezone offset as "-07:00", "04:30", etc.
  double hoursFromGMT = [[NSTimeZone localTimeZone] secondsFromGMT] / 3600.0;
  int intHoursFromGMT = hoursFromGMT;
  int intMinutesFromGMT = abs((int)((hoursFromGMT - intHoursFromGMT) * 60));
  // Three characters for the hour if it's negative ("-07"), two if it's positive ("07").
  NSString *format = (intHoursFromGMT < 0) ? @"%03d:%02d" : @"%02d:%02d";
  NSString *gmtOffset = [NSString stringWithFormat:format, intHoursFromGMT, intMinutesFromGMT];

  NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:
      @{ @"utc_offset" : gmtOffset,
         @"user_agent" : @"AlienBlue",
         @"app_version" : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
         @"event_version" : kEventVersion }];
  if ([RedditAPI shared].authenticated) {
    [payload setObject:[NSNumber numberWithUnsignedInteger:[RedditAPI shared].base10Id]
                forKey:@"user_id"];
  }

  return payload;
}

- (void)logVoteChangeForPost:(Post *)post
                   container:(NSString *)container
                     gesture:(NSString *)gesture
                    voteType:(NSString *)voteType
{
  NSMutableDictionary *payload = [self standardPayload];
  [payload setObject:container forKey:@"container"];
  [payload setObject:[NSString stringWithFormat:@"t3_%@", post.ident] forKey:@"target_id"];
  [payload setObject:(post.linkType == LinkTypeSelf ? @"self_post" : @"link")
              forKey:@"target_type"];
  if (post.linkType != LinkTypeSelf) {
    [payload setObject:[[CommentLink friendlyNameFromLinkType:post.linkType] lowercaseString]
                forKey:@"link_type"];
  }
  [payload setObject:gesture forKey:@"target_gesture"];
  [self logTopic:@"content_actions" type:voteType payload:payload];
}

@end
