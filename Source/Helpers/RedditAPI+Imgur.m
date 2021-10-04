#import "RedditAPI+Imgur.h"
#import "RedditAPI+DeprecationPatches.h"

@interface RedditAPI (Imgur_)
@property (ab_weak) id imgurCallBackTarget;
@end

@implementation RedditAPI (Imgur)

SYNTHESIZE_ASSOCIATED_WEAK(NSObject, imgurCallBackTarget, ImgurCallBackTarget);

- (void)removeImageFromImgurWithDeleteHash:(NSString *)deleteHash
{
  NSString *fetchUrl = [[NSString alloc] initWithFormat:@"http://imgur.com/delete/?a=%@",deleteHash];
  [self doGetURL:fetchUrl withConnectionCategory:kConnectionCategoryOther callBackTarget:self callBackMethod:@selector(imgurDeleteResponse:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)postImageToImgur:(NSData *)photoData callBackTarget:(id)target
{
  self.imgurCallBackTarget = target;
  
  NSURL *url = [NSURL URLWithString:@"http://imgur.com/api/upload.json"];
  NSString *boundary = @"----1010101010";
  NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"POST"];
  [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
  
  NSMutableData *body = [NSMutableData data];
  [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[@"Content-Disposition: form-data; name=\"key\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@\"\r\n", @"photo.jpg"] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:photoData];
  [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  [request setHTTPBody:body];
  [request addValue:[NSString stringWithFormat:@"%d", body.length] forHTTPHeaderField: @"Content-Length"];
  
  NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
  NSString *connectionKey = [NSString stringWithFormat: @"%ld", ((intptr_t) connection)];
  NSMutableDictionary *dl = [[NSMutableDictionary alloc] init];
  [dl setValue:connectionKey forKey:kABDownloadKeyConnectionIdentifier];
  [dl setValue:self forKey:kABDownloadKeyAfterCompleteTarget];
  [dl setValue:@"imgurPostResponse:" forKey:kABDownloadKeyAfterCompleteMethod];
  [dl setValue:@"connectionFailedDialog:" forKey:kABDownloadKeyFailedNotificationAction];
  [self.connections setValue:dl forKey:connectionKey];
}

- (void)imgurPostResponse:(id)sender
{
  JMJSONParser *parser = [[JMJSONParser alloc] init];
  NSData *data = (NSData *) sender;
  
  NSString *responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  if (JMIsEmpty(responseString))
    return;
  
  NSDictionary *response = [[[parser objectWithString:responseString error:nil] objectForKey:@"rsp"] objectForKey:@"image"];
  if (!response)
  {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image Upload Failed" message:@"Your photo could not be uploaded to Imgur at this time." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    return;
  }
  
  if (self.imgurCallBackTarget)
  {
    [self.imgurCallBackTarget rd_performSelector:@selector(imageUploadResponse:) withObject:response];
  }
}

- (void)resetConnectionsForImgur;
{
  self.imgurCallBackTarget = nil;
}

@end
