//
//  Category.m
//  AlienBlue
//
//  Created by J M on 16/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "DiscoveryCategory.h"
#import "Subreddit+Discovery.h"
#import "NSArray+BlocksKit.h"
#import "NSData+md5.h"
#import "AFNetworking.h"
#import "Resources.h"

@implementation DiscoveryCategory

- (id)initWithDiscoveryDictionary:(NSDictionary *)d;
{
    self = [super init];
    if (self)
    {
        self.title = [d objectForKey:@"title"];
        self.ident = [d objectForKey:@"ident"];
        self.iconIdent = [d objectForKey:@"iconIdent"];
        
        self.subCategories = [[d objectForKey:@"categories"] map:^id<NSObject>(NSDictionary *categoryDictionary) {
            return [[DiscoveryCategory alloc] initWithDiscoveryDictionary:categoryDictionary];
        }];

        self.subreddits = [[d objectForKey:@"subreddits"] map:^id<NSObject>(NSDictionary *subredditDictionary) {
            return [[Subreddit alloc] initWithDiscoveryDictionary:subredditDictionary];
        }];
    }
    return self;
}


+ (void)recommendSubreddit:(NSString *)subreddit forCategory:(DiscoveryCategory *)category onComplete:(ABAction)onComplete;
{
	NSMutableString * str = [NSMutableString stringWithString:subreddit];
	[str replaceOccurrencesOfString:@"/r/" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
	[str replaceOccurrencesOfString:@"/" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
    
    NSString *k = [NSString stringWithFormat:@"ab_%@%@", category.ident, str];
    NSString *vToken = [[k dataUsingEncoding:NSUTF8StringEncoding] md5];
    
    NSString *url = [NSString stringWithFormat:@"http://abdiscovery.heroku.com/recommend/%@/%@/%@",
                     [category.ident jm_escaped],
                     [str jm_escaped],
                     [vToken jm_escaped]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (onComplete)
        {
            onComplete();
        }
    } failure:nil];
    
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        if (onComplete)
//        {
//            onComplete();
//        }        
//    } failure:nil];
    [operation start];
}


@end
