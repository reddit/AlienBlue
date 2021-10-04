//  REDTabbedViewController.m
//  RedditApp

#import "REDTabbedViewController.h"

static int const kImageOffset = 5;

@implementation REDTabbedViewController

- (instancetype)init {
  return [super initWithNibName:nil bundle:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  NSAssert(NO, @"Invalid initializer.");
  self = [self init];
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  NSAssert(NO, @"Invalid initializer.");
  self = [self init];
  return self;
}

- (void)setTabBarIconWithImageName:(NSString *)imageName
                 selectedImageName:(NSString *)selectedImageName {
  self.tabBarItem = [[UITabBarItem alloc]
      initWithTitle:nil
              image:[[UIImage imageNamed:imageName]
                        imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
      selectedImage:[[UIImage imageNamed:selectedImageName]
                        imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
  self.tabBarItem.imageInsets = UIEdgeInsetsMake(kImageOffset, 0, -kImageOffset, 0);
}

@end
