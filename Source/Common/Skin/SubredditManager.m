//
//  SubredditManager.m
//  AlienBlue
//
//  Created by JM on 14/11/10.
//  Copyright (c) 2010 The Design Shed. All rights reserved.
//

#import "SubredditManager.h"
#import "RedditAPI+DeprecationPatches.h"

#define SUBREDDIT_BUNDLE_PATH "Subreddits.bundle"

@implementation SubredditManager

//static SubredditManager *manager_ = nil;

@synthesize subreddit = subreddit_;

//+ (SubredditManager*) sharedSubredditManager
//{
//    if (manager_ == nil) 
//    {
//        manager_ =  [[super allocWithZone:NULL] init];
//        [manager_ setSubreddit:@"fffffffuuuuuuuuuuuu"];
//    }
//    return manager_;
//}

+ (SubredditManager *)sharedSubredditManager
{
    JM_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}


- (id)init;
{
    if ((self = [super init]))
    {
        bundle_ = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@SUBREDDIT_BUNDLE_PATH ofType:@""]];
    }
    return self;
}

- (void) changeSubredditBundleTo:(NSString *) subreddit
{
	[self setSubreddit:subreddit];
	tagDictionary_ = nil;
}

- (void) dealloc;
{
    tagDictionary_ = nil;
}

- (NSString*)pathForResource:(NSString*)name
{
    NSString * resourcePath = [[[bundle_ resourcePath] lastPathComponent] stringByAppendingPathComponent:[self subreddit]];
    return [resourcePath stringByAppendingPathComponent:name];
}

- (UIImage*)imageNamed:(NSString*)name;
{
    UIImage *image = [UIImage imageNamed:[self pathForResource:name]];
    NSLog(@"loading image: %@ (%@)", name, image);
    return image;
}

- (NSDictionary*)tagDictionary;
{
    if (!tagDictionary_)
    {
        JMJSONParser *parser = [[JMJSONParser alloc] init];
        NSString *path = [bundle_ pathForResource:@"tags" ofType:@"json" inDirectory:[self subreddit]];		
        NSString *jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSDictionary *jsonDict = [parser objectWithString:jsonString];
        tagDictionary_ = [jsonDict valueForKey:@"tags"];
    }
    return tagDictionary_;
}

- (UIImage *)imageForTag:(NSString *)tag
{
//	NSLog(@"tag count: %d", [[self tagDictionary] count]);
//	NSLog(@"Finding image for tag: %@", tag);
	NSDictionary * tagDetails = [[self tagDictionary] objectForKey:tag];
	if (tagDetails)
	{
		UIImage * glyphs = [self imageNamed:@"glyphs.png"];
		
		CGRect cropRect = CGRectMake(
									 [[tagDetails objectForKey:@"offset-x"] intValue] * -1, 
									 [[tagDetails objectForKey:@"offset-y"] intValue] * -1, 
									 [[tagDetails objectForKey:@"width"] intValue], 
									 [[tagDetails objectForKey:@"height"] intValue]
									 );
		CGImageRef imageRef = CGImageCreateWithImageInRect([glyphs CGImage], cropRect);
        UIImage *image =  [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
		return image;
	}
	return nil;
}

- (UIImage*)imageForTag:(NSString*)tag inSubreddit:(NSString *)subreddit;
{
    NSString * subredditPath = [[[[bundle_ resourcePath] lastPathComponent] stringByAppendingPathComponent:subreddit] stringByAppendingPathComponent:@"tags"];
    NSString * imageName = [NSString stringWithFormat:@"%@.png", tag];
    NSString * imageLocation = [subredditPath stringByAppendingPathComponent:imageName];
    UIImage *image = [UIImage imageNamed:imageLocation];
    return image;
}

- (NSArray *)imageTagsAvailableForSubreddit:(NSString *)subreddit;
{
    NSString * path = [[[bundle_ resourcePath] stringByAppendingPathComponent:subreddit] stringByAppendingPathComponent:@"tags"];
    NSArray * tags = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    tags = [tags filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(self contains %@)", @".png"]];
    
    NSMutableArray * filteredArray = [NSMutableArray array];
    for (NSString * tag in tags)
    {
        [filteredArray addObject:[tag stringByReplacingOccurrencesOfString:@".png" withString:@""]];
    }
    return filteredArray;
}

- (BOOL)doesSubredditHaveAssets:(NSString *)subreddit;
{
    return [[self imageTagsAvailableForSubreddit:subreddit] count] > 0;
}

- (NSString *)randomSubreddit;
{
    NSString *listPath = [[bundle_ resourcePath] stringByAppendingPathComponent:@"sfw-random-reddits.txt"];
    NSString *fileContents = [NSString stringWithContentsOfFile:listPath encoding:NSUTF8StringEncoding error:nil];
    NSArray *allReddits = [fileContents componentsSeparatedByString:@"\n"];
    NSUInteger randomIndex = arc4random() % (allReddits.count - 1);
    return [allReddits objectAtIndex:randomIndex];
}

- (NSArray *)defaultSubreddits;
{
  NSString *listPath = [[bundle_ resourcePath] stringByAppendingPathComponent:@"default-subreddits.txt"];
  NSString *fileContents = [NSString stringWithContentsOfFile:listPath encoding:NSUTF8StringEncoding error:nil];
  NSArray *defaultSubreddits = [fileContents componentsSeparatedByString:@"\n"];
  return defaultSubreddits;
}

@end