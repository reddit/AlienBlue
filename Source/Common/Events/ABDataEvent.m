//  ABDataEvent.m
//  AlienBlue

#import "ABDataEvent.h"

#import <CommonCrypto/CommonHMAC.h>
#import <JSONKit/JSONKit.h>

@implementation ABDataEvent

#ifdef DEBUG
static NSString *kBaseUri = @"https://events-test.redditmedia.com/v1";
static NSString *kAppKey = @"Test1";
#else
static NSString *kBaseUri = @"https://events.redditmedia.com/v1";
static NSString *kAppKey = @"AlienBlue1";
#endif

static inline char itoh(int i)
{
  if (i > 9) return 'A' + (i - 10);
  return '0' + i;
}

+ (NSString *)NSDataToHex:(NSData *)data
{
  NSUInteger i, len;
  unsigned char *buf, *bytes;

  len = data.length;
  bytes = (unsigned char *)data.bytes;
  buf = (unsigned char *)malloc(len * 2);

  for (i = 0; i < len; i++) {
    buf[i * 2] = itoh((bytes[i] >> 4) & 0xF);
    buf[i * 2 + 1] = itoh(bytes[i] & 0xF);
  }

  return [[NSString alloc] initWithBytesNoCopy:buf
                                        length:len * 2
                                      encoding:NSASCIIStringEncoding
                                  freeWhenDone:YES];
}

- (NSString *)hmacDigestWithMessage:(NSData *)message
                          keyString:(NSString *)keyString {
  // Neat trick for base64 decoding found here:
  // http://stackoverflow.com/questions/19088231/base64-decoding-in-ios-7
  NSURL *URL = [NSURL URLWithString:
                [NSString stringWithFormat:@"data:application/octet-stream;base64,%@", keyString]];
  NSData *cKey = [NSData dataWithContentsOfURL:URL];
  const char *cData = (const char *)[message bytes];
  unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
  CCHmac(kCCHmacAlgSHA256, cKey.bytes, cKey.length, cData, message.length, cHMAC);
  NSData *hmacData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
  return [ABDataEvent NSDataToHex:hmacData];
}

- (NSString *)buildSignature:(NSString *)computedMac {
  return [NSString stringWithFormat:@"key=%@, mac=%@", kAppKey, [computedMac lowercaseString]];
}

#pragma mark - PURBufferedOutput

- (void)writeChunk:(PURBufferedOutputChunk *)chunk completion:(void (^)(BOOL success))completion
{
  NSMutableArray *logs = [NSMutableArray new];
  for (PURLog *log in chunk.logs) {
    NSMutableDictionary *logDict = [log.userInfo mutableCopy];
    [logs addObject:logDict];
  }
  NSData *logData = [NSJSONSerialization dataWithJSONObject:logs options:0 error:NULL];

  NSString *computedMac = [self hmacDigestWithMessage:logData keyString:@""];

  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.dateFormat = @"EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz";
  dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
  NSString *date = [dateFormatter stringFromDate:[NSDate date]];

  NSMutableURLRequest *request =
      [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kBaseUri]];
  request.HTTPMethod = @"POST";
  request.allHTTPHeaderFields = @{ @"Content-Type" : @"application/json",
                                   @"X-Signature" : [self buildSignature:computedMac],
                                   @"Date" : date };

  NSURLSessionUploadTask *task =
      [[NSURLSession sharedSession] uploadTaskWithRequest:request
          fromData:logData
          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
              if (error || httpResponse.statusCode / 100 != 2) {
#ifdef DEBUG
                NSLog(@"[DATA] ERROR sending event:\n%@",
                      [[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding]);
                NSLog(@"[DATA] Errors: %d %@", httpResponse.statusCode, error);
#endif
                // Treat a "Forbidden" response as a success so it doesn't retry.
                completion(httpResponse.statusCode == 403);
                return;
              }
#ifdef DEBUG
            NSLog(@"[DATA] SUCCESS sending event:\n%@",
                  [[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding]);
#endif
              completion(YES);
          }];
  [task resume];
}

@end
