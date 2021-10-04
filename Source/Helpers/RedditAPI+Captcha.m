#import "RedditAPI+Captcha.h"
#import "RedditAPI+DeprecationPatches.h"

@interface RedditAPI (Captcha_)
@property (ab_weak) id captchaCallBackTarget;
@end

@implementation RedditAPI (Captcha)

SYNTHESIZE_ASSOCIATED_WEAK(NSObject, captchaCallBackTarget, CaptchaCallBackTarget);

- (void)requestCaptchaWithCallBackTarget:(id)target;
{
  NSString * captchaRequestUrl = [[NSString alloc] initWithFormat:@"%@/api/new_captcha", self.server];
  
  // if we call this with api_type=json, reddit doesn't send back the captcha link, so we need
  // to do a standard jquery call instead
  NSString *params = @"";
  self.captchaCallBackTarget = target;
  [self doPostToURL:captchaRequestUrl withParams:params connectionCategory:kConnectionCategoryOther callBackTarget:self callBackMethod:@selector(captchaResponseReceived:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)captchaResponseReceived:(id)sender;
{
  NSData *data = (NSData *)sender;
  NSString *responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  JMJSONParser *parser = [[JMJSONParser alloc] init];
  NSArray *jqueryResponses = [[parser objectWithString:responseString error:nil] objectForKey:@"jquery"];
  NSString *captcha = [self extractCaptchaFromJQueryResponse:jqueryResponses];
  
  if (self.captchaCallBackTarget)
  {
    [self.captchaCallBackTarget rd_performSelector:@selector(captchaResponse:) withObject:captcha];
  }
}

- (NSString *)extractCaptchaFromJQueryResponse:(NSArray *)jqueryResponse;
{
  NSString *captcha;
  if (!jqueryResponse || jqueryResponse.count == 0)
    return nil;
  
  // the captcha section is in the last part of the jquery response
  NSArray *captchaAttribute = [jqueryResponse objectAtIndex:([jqueryResponse count] - 1)];
  if (!captchaAttribute || captchaAttribute.count == 0)
    return nil;
  
  // the captcha itself is then in the last part of the captcha attribute
  NSArray * captcha_section = [captchaAttribute objectAtIndex:([captchaAttribute count] - 1)];
  NSString * captcha_f = [captcha_section objectAtIndex:([captcha_section count] - 1)];
  if (captcha_f && [captcha_f length] > 25 && [captcha_f length] < 40)
  {
    captcha = [captcha_f copy];
  }
  return captcha;
}

@end
