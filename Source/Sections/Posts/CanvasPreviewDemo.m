//
//  CanvasPreviewDemo.m
//  AlienBlue
//
//  Created by JM on 30/01/11.
//  Copyright 2011 The Design Shed. All rights reserved.
//

#import "CanvasPreviewDemo.h"
#import "ABBundleManager.h"
#import "AlienBlueAppDelegate.h"
#import "Resources.h"

@implementation CanvasPreviewDemo

@synthesize imageView;
@synthesize upgradeButton;
@synthesize iOS4RecommendedLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
  JM_SUPER_INIT(initWithNibName:nibNameOrNil bundle:nibBundleOrNil);
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(closePanel:)];
  self.navigationController.toolbarHidden = YES;
  self.hidesBottomBarWhenPushed = YES;

  return self;
}

- (void)closePanel:(id)sender;
{
	[[NavigationManager shared] dismissModalView];
}

- (void)upgradePressed:(id)sender;
{
	[[NavigationManager shared] showProUpgradeScreen];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
  [super viewDidLoad];
 
	imageView.image = [[ABBundleManager sharedManager] imageNamed:@"other/canvas-splash-iphone.png"];
	[upgradeButton setImage:[[ABBundleManager sharedManager] imageNamed:@"other/canvas-upgrade-button.png"] forState:UIControlStateNormal];
  
  if (!JMIsIOS7())
  {
    imageView.top -= 55.;
    upgradeButton.top -= 20.;
  }
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload 
{
	self.imageView = nil;
	self.upgradeButton = nil;
	self.iOS4RecommendedLabel = nil;
    [super viewDidUnload];
}




@end
